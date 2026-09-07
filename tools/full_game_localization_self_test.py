#!/usr/bin/env python3
"""Fail-closed, file-isolated tests for bounded full-game translation exchange."""
from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import full_game_localization as tool


class ExchangeTests(unittest.TestCase):
    def setUp(self):
        self.leaf = tool.Leaf("endings", "example", "content/endings.json", ("title",),
                              "다음 주", "ending")
        self.inventory = {"leaves": [self.leaf], "source_manifest_sha256": "a" * 64,
                          "endings": {"example": {"id": "example", "title": "다음 주"}},
                          "events": {}, "catalog": {}}
        self.batch = tool.make_batch(self.inventory, "ja", [self.leaf], "b" * 40, {}, {})
        self.response = [copy.deepcopy(self.batch[0]), {
            "id": self.leaf.id, "locale": "ja", "source_sha256": self.leaf.source_sha256,
            "prompt_version": tool.PROMPT_VERSION, "text": "次の週"}]

    def reject(self, batch=None, response=None, inventory=None):
        with self.assertRaises(tool.ContractError):
            tool.check_batch(inventory or self.inventory, batch or self.batch,
                             response or self.response)

    def test_valid_exact_exchange(self):
        self.assertEqual(tool.check_batch(self.inventory, self.batch, self.response), {self.leaf.id: "次の週"})

    def test_catalog_japanese_numeric_contexts(self):
        for source, target in (
            ("2030 직장인", "20・30代の会社員"),
            ("2차전지주", "二次電池株"),
            ("1인 가구", "一人暮らし世帯"),
            ("2차 창업자 네트워크", "二度目の起業をした人たちのネットワーク"),
        ):
            leaf = tool.Leaf("catalog", "news:example", "content/news_templates.json", ("topics", 0), source, "catalog")
            self.assertEqual(tool.translation_errors(leaf, "ja", target), [])

    def test_catalog_japanese_numeric_context_mutations(self):
        for source, target in (
            ("2030 직장인", "20・40代の会社員"),
            ("2030 직장인", "20・30年の会社員"),
            ("2030 직장인", "120・30代の会社員"),
            ("2030 직장인", "20・30代と四十代の会社員"),
            ("2030 직장인", "20・30代と四十 代の会社員"),
            ("2030 직장인", "20・30代と四十年の会社員"),
            ("2차전지주", "三次電池株"),
            ("2차전지주", "十二次電池株"),
            ("2차전지주", "二十二次電池株"),
            ("2차전지주", "十 二次電池株"),
            ("2차전지주", "二次電池株と四次電池株"),
            ("1인 가구", "二人暮らし世帯"),
            ("1인 가구", "十一人暮らし世帯"),
            ("1인 가구", "二十一人暮らし世帯"),
            ("1인 가구", "十 一人暮らし世帯"),
            ("2차 창업자 네트워크", "三度目の起業をした人たちのネットワーク"),
            ("2차 창업자 네트워크", "十二度目の起業家ネットワーク"),
            ("2차 창업자 네트워크", "二度目と三度目の起業家ネットワーク"),
            ("2030명 직장인", "20・30代の会社員"),
        ):
            leaf = tool.Leaf("catalog", "news:example", "content/news_templates.json", ("topics", 0), source, "catalog")
            self.assertTrue(tool.translation_errors(leaf, "ja", target), (source, target))

    def test_catalog_japanese_names_are_exact_and_not_event_exemptions(self):
        for source, target in (("클로드 4", "Claude 4"), ("코스닥", "KOSDAQ"), ("하이퍼클로바X2", "HyperCLOVA X2")):
            leaf = tool.Leaf("catalog", "news:example", "content/news_templates.json", ("topics", 0), source, "catalog")
            self.assertEqual(tool.translation_errors(leaf, "ja", target), [])
            self.assertTrue(tool.translation_errors(leaf, "ja", target + "x"))
            event = tool.Leaf("events", "example", "content/events/example.json", ("title",), source, "event_standard")
            self.assertTrue(tool.translation_errors(event, "ja", target))
        leaf = tool.Leaf("catalog", "news:example", "content/news_templates.json", ("topics", 0), "깃허브 이력서", "catalog")
        self.assertTrue(tool.translation_errors(leaf, "ja", "GitHub"))

    def test_catalog_chinese_name_does_not_whitelist_unrelated_event(self):
        for locale in ("zh-CN", "zh-TW"):
            leaf = tool.Leaf("catalog", "news:example", "content/news_templates.json", ("topics", 0), "대시", "catalog")
            self.assertEqual(tool.translation_errors(leaf, locale, "Dash"), [])
            event = tool.Leaf("events", "example", "content/events/example.json", ("title",), "대시", "event_standard")
            self.assertTrue(tool.translation_errors(event, locale, "Dash"))

    def test_raw_duplicate_keys(self):
        with self.assertRaises(tool.ContractError):
            tool.loads('{"text":"a","text":"b"}')

    def test_raw_nested_duplicate_keys(self):
        with self.assertRaises(tool.ContractError):
            tool.loads('{"nested":{"id":"a","id":"b"}}')

    def test_duplicate_row_ids(self):
        with self.assertRaises(tool.ContractError):
            tool.row_index([{"id": "a"}, {"id": "a"}], "fixture")

    def test_nonfinite_json(self):
        with self.assertRaises(tool.ContractError):
            tool.loads('{"bad":NaN}')

    def test_missing_id(self):
        self.reject(response=[self.response[0]])

    def test_extra_id(self):
        response = copy.deepcopy(self.response)
        response.append({**response[1], "id": "unknown"})
        self.reject(response=response)

    def test_duplicate_response(self):
        self.reject(response=self.response + [self.response[1]])

    def test_blank(self):
        response = copy.deepcopy(self.response)
        response[1]["text"] = "  "
        self.reject(response=response)

    def test_gameplay_in_response(self):
        response = copy.deepcopy(self.response)
        response[1]["effects"] = {"money": 30}
        self.reject(response=response)

    def test_locale_mixing(self):
        response = copy.deepcopy(self.response)
        response[1]["locale"] = "zh-TW"
        self.reject(response=response)

    def test_stale_leaf(self):
        response = copy.deepcopy(self.response)
        response[1]["source_sha256"] = "0" * 64
        self.reject(response=response)

    def test_stale_manifest(self):
        inventory = {**self.inventory, "source_manifest_sha256": "0" * 64}
        self.reject(inventory=inventory)

    def test_changed_ko_same_revision(self):
        inventory = copy.deepcopy(self.inventory)
        inventory["leaves"] = [tool.Leaf("endings", "example", "content/endings.json", ("title",),
                                         "다음 달", "ending")]
        self.reject(inventory=inventory)

    def test_prompt_mixing(self):
        response = copy.deepcopy(self.response)
        response[1]["prompt_version"] = "old"
        self.reject(response=response)

    def test_selection_corruption(self):
        batch = copy.deepcopy(self.batch)
        batch[1]["source"] = "다음 달"
        self.reject(batch=batch)

    def test_rehashed_extra_source_gameplay(self):
        batch = copy.deepcopy(self.batch)
        batch[1]["effects"] = {}
        batch[0]["selection_sha256"] = tool.digest(batch[1:])
        batch[0]["batch_id"] = tool.digest({k: v for k, v in batch[0].items() if k != "batch_id"})
        response = [batch[0], self.response[1]]
        self.reject(batch=batch, response=response)

    def test_merge_selected_preserves_neighbors(self):
        documents = {"content/endings_ja.json": [{"id": "neighbor", "title": "隣"}]}
        inventory = copy.deepcopy(self.inventory)
        inventory["endings"]["neighbor"] = {"id": "neighbor", "title": "이웃"}
        inventory["leaves"].append(tool.Leaf("endings", "neighbor", "content/endings.json", ("title",), "이웃", "ending"))
        merged = tool.merge_selected(inventory, self.batch, {self.leaf.id: "次の週"}, documents, {})
        self.assertEqual(merged["content/endings_ja.json"][0], documents["content/endings_ja.json"][0])
        self.assertEqual(len(documents["content/endings_ja.json"]), 1)

    def test_existing_translation_not_overwritten(self):
        documents = {"content/endings_ja.json": [{"id": "example", "title": "来週"}]}
        batch = tool.make_batch(self.inventory, "ja", [self.leaf], "b" * 40, documents, {})
        with self.assertRaises(tool.ContractError):
            tool.merge_selected(self.inventory, batch, {self.leaf.id: "次の週"}, documents, {})

    def test_public_demo_cannot_be_replaced(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "protected": True})
        inventory = {**self.inventory, "leaves": [leaf]}
        documents = {"content/endings_ja.json": [{"id": "example", "title": "来週"}]}
        batch = tool.make_batch(inventory, "ja", [leaf], "b" * 40, documents, {})
        with self.assertRaises(tool.ContractError):
            tool.merge_selected(inventory, batch, {leaf.id: "次の週"}, documents, {}, True)

    def test_target_changed_since_export(self):
        documents = {"content/endings_ja.json": [{"id": "example", "title": "来週"}]}
        with self.assertRaises(tool.ContractError):
            tool.merge_selected(self.inventory, self.batch, {self.leaf.id: "次の週"}, documents, {}, True)

    def test_unverified_dynamic_consumer(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "runtime_support": "unverified_consumer"})
        inventory = {**self.inventory, "leaves": [leaf]}
        batch = tool.make_batch(inventory, "ja", [leaf], "b" * 40, {}, {})
        with self.assertRaises(tool.ContractError):
            tool.merge_selected(inventory, batch, {leaf.id: "次の週"}, {}, {})

    def test_foreshadow_validator_contract_classification(self):
        self.assertEqual(tool.event_overlay_support(("choices", 0, "foreshadow")),
                         "validator_contract_missing")
        self.assertEqual(tool.event_overlay_support(("choices", 0, "result_text")),
                         "builtin_overlay_static_only")

    def test_reader_validator_contract_classification(self):
        for field in ("chapter5_causal_reads", "chapter5_finale_reads"):
            self.assertEqual(tool.event_overlay_support((field, "texts", 0, 0)),
                             "builtin_overlay_static_only")
        self.assertEqual(tool.event_overlay_support(("chapter5_future_reads", "texts", 0, 0)),
                         "validator_contract_missing")

    def test_relationship_display_names_are_unsupported_occurrences(self):
        row = {"choices": [
            {"relationship_effects": [{"name": "친한 친구", "trust": 1}]},
            {"relationship_effects": [{"name": "친한 친구"}, {"name": "가족"}],
             "grant_job_display": {"ko": "직업", "en": "Job"}}]}
        unsupported = tool.unsupported_relationship_display_names("example", row, "source.json")
        self.assertEqual(len(unsupported), 3)
        self.assertEqual(len({u["ko"] for u in unsupported}), 2)
        self.assertEqual(len({u["source_id"] for u in unsupported}), 3)
        self.assertTrue(all(u["kind"] == "unsupported_relationship_display_name" for u in unsupported))
        self.assertEqual(tool.event_overlay_support(("choices", 0, "relationship_effects", 0, "name")),
                         "validator_contract_missing")

    def internal_note_fixture(self, root):
        inventory = copy.deepcopy(self.inventory)
        inventory["endings"]["example"]["condition"] = "age >= 38"
        note = tool.Leaf("endings", "example", "content/endings.json", ("condition",),
                         "age >= 38", "internal_metadata")
        records = {locale: {} for locale in tool.LOCALES}
        records["ja"][note.id] = {"source_sha256": note.source_sha256,
                                    "target_sha256": tool.digest("38歳以上")}
        ledger = self.ledger()
        ledger["retained_internal_metadata"] = records
        ledger["retained_internal_metadata_sha256"] = tool.digest(records)
        fingerprint_patch = patch.object(tool, "RETAINED_ENDING_NOTES_SHA256", tool.digest(records))
        fingerprint_patch.start()
        self.addCleanup(fingerprint_patch.stop)
        tool.atomic_json(root / "content/meta/full_game_localization.json", ledger)
        tool.atomic_json(root / "content/endings_ja.json",
                         [{"id": "example", "title": "次の週", "condition": "38歳以上"}])
        return inventory, ledger, note

    def test_retained_note_is_preserved_not_counted_as_translation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, _, _ = self.internal_note_fixture(root)
            documents, _ = tool.targets(root, "ja", inventory)
            self.assertEqual(documents["content/endings_ja.json"][0]["condition"], "38歳以上")
            with patch.object(tool, "private_dir", return_value=root / "private"):
                result = tool.status(root, inventory, "ja")
            self.assertEqual(result["groups"]["ending"]["source"], 1)
            self.assertEqual(result["groups"]["ending"]["receipted_current_source"], 1)

    def test_retained_note_checksum_drift_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, ledger, note = self.internal_note_fixture(root)
            ledger["retained_internal_metadata"]["ja"][note.id]["target_sha256"] = "0" * 64
            tool.atomic_json(root / "content/meta/full_game_localization.json", ledger)
            with self.assertRaisesRegex(tool.ContractError, "checksum"):
                tool.targets(root, "ja", inventory)

    def test_retained_note_wrong_locale_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, ledger, _ = self.internal_note_fixture(root)
            records = ledger["retained_internal_metadata"]
            records["zh"] = records.pop("zh-TW")
            ledger["retained_internal_metadata_sha256"] = tool.digest(records)
            tool.atomic_json(root / "content/meta/full_game_localization.json", ledger)
            with self.assertRaises(tool.ContractError):
                tool.targets(root, "ja", inventory)

    def test_retained_note_source_drift_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, _, _ = self.internal_note_fixture(root)
            inventory["endings"]["example"]["condition"] = "age >= 39"
            with self.assertRaisesRegex(tool.ContractError, "source changed"):
                tool.targets(root, "ja", inventory)

    def test_retained_note_target_drift_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, _, _ = self.internal_note_fixture(root)
            tool.atomic_json(root / "content/endings_ja.json",
                             [{"id": "example", "title": "次の週", "condition": "39歳以上"}])
            with self.assertRaisesRegex(tool.ContractError, "changed internal"):
                tool.targets(root, "ja", inventory)

    def test_retained_note_disappearance_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, _, _ = self.internal_note_fixture(root)
            tool.atomic_json(root / "content/endings_ja.json", [{"id": "example", "title": "次の週"}])
            with self.assertRaisesRegex(tool.ContractError, "disappeared"):
                tool.targets(root, "ja", inventory)

    def test_new_internal_note_not_accepted_as_translation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, _, _ = self.internal_note_fixture(root)
            tool.atomic_json(root / "content/meta/full_game_localization.json", self.ledger())
            with self.assertRaisesRegex(tool.ContractError, "metadata is missing"):
                tool.targets(root, "ja", inventory)

    def test_retained_note_and_receipt_co_deletion_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, ledger, note = self.internal_note_fixture(root)
            del ledger["retained_internal_metadata"]["ja"][note.id]
            ledger["retained_internal_metadata_sha256"] = tool.digest(ledger["retained_internal_metadata"])
            tool.atomic_json(root / "content/meta/full_game_localization.json", ledger)
            tool.atomic_json(root / "content/endings_ja.json", [{"id": "example", "title": "次の週"}])
            with self.assertRaisesRegex(tool.ContractError, "historical fingerprint"):
                tool.targets(root, "ja", inventory)

    def test_retained_note_and_receipt_co_rewrite_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, ledger, note = self.internal_note_fixture(root)
            ledger["retained_internal_metadata"]["ja"][note.id]["target_sha256"] = tool.digest("39歳以上")
            ledger["retained_internal_metadata_sha256"] = tool.digest(ledger["retained_internal_metadata"])
            tool.atomic_json(root / "content/meta/full_game_localization.json", ledger)
            tool.atomic_json(root / "content/endings_ja.json",
                             [{"id": "example", "title": "次の週", "condition": "39歳以上"}])
            with self.assertRaisesRegex(tool.ContractError, "historical fingerprint"):
                tool.targets(root, "ja", inventory)

    def test_extra_self_receipted_internal_note_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, ledger, _ = self.internal_note_fixture(root)
            inventory["endings"]["added"] = {"id": "added", "title": "제목", "condition": "health <= 0"}
            note = tool.Leaf("endings", "added", "content/endings.json", ("condition",), "health <= 0", "internal_metadata")
            ledger["retained_internal_metadata"]["ja"][note.id] = {
                "source_sha256": note.source_sha256, "target_sha256": tool.digest("健康 <= 0")}
            ledger["retained_internal_metadata_sha256"] = tool.digest(ledger["retained_internal_metadata"])
            tool.atomic_json(root / "content/meta/full_game_localization.json", ledger)
            with self.assertRaisesRegex(tool.ContractError, "historical fingerprint"):
                tool.targets(root, "ja", inventory)

    def test_production_retained_ledger_cannot_disappear(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with patch.object(tool, "ROOT", root), patch.object(Path, "exists", return_value=False), \
                    self.assertRaisesRegex(tool.ContractError, "ledger disappeared"):
                tool.retained_ending_notes(root, "ja", self.inventory)

    def test_forged_internal_note_exchange_rejected(self):
        note = tool.Leaf("endings", "example", "content/endings.json", ("condition",),
                         "age >= 38", "ending")
        inventory = {**self.inventory, "leaves": [note]}
        batch = tool.make_batch(inventory, "ja", [note], "b" * 40, {}, {})
        response = [batch[0], {"id": note.id, "locale": "ja", "source_sha256": note.source_sha256,
                               "prompt_version": tool.PROMPT_VERSION, "text": "38歳以上"}]
        self.reject(batch=batch, response=response, inventory=inventory)
        with self.assertRaisesRegex(tool.ContractError, "cannot be imported"):
            tool.merge_selected(inventory, batch, {note.id: "38歳以上"}, {}, {})

    def test_internal_note_does_not_override_text_requirements(self):
        import i18n_coverage_check as coverage
        base = {"example": {"id": "example", "title": "제목", "description": "본문",
                             "condition": "route_orthodox >= 12", "description_if_known": {"x": "기억"}}}
        good = {"example": {"id": "example", "title": "題", "description": "本文",
                             "description_if_known": {"x": "記憶"}}}
        with patch.object(coverage, "load_event_directory", return_value={}), \
                patch.object(coverage, "load_endings", side_effect=[base, good]):
            self.assertEqual(coverage.check_language("ja", True)[0], [])
        for field in ("title", "description", "description_if_known"):
            bad = copy.deepcopy(good)
            del bad["example"][field]
            with self.subTest(field=field), \
                    patch.object(coverage, "load_event_directory", return_value={}), \
                    patch.object(coverage, "load_endings", side_effect=[base, bad]):
                self.assertTrue(coverage.check_language("ja", True)[0])

    def test_merge_new_title_preserves_retained_neighbor_note(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory, _, _ = self.internal_note_fixture(root)
            documents, files = tool.targets(root, "ja", inventory)
            batch = tool.make_batch(inventory, "ja", [self.leaf], "b" * 40, documents, files)
            merged = tool.merge_selected(inventory, batch, {self.leaf.id: "来週"}, documents, files, True)
            self.assertEqual(merged["content/endings_ja.json"][0]["condition"], "38歳以上")

    def test_validator_contract_missing_cannot_be_imported(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "runtime_support": "validator_contract_missing"})
        inventory = {**self.inventory, "leaves": [leaf]}
        batch = tool.make_batch(inventory, "ja", [leaf], "b" * 40, {}, {})
        with self.assertRaisesRegex(tool.ContractError, "validator_contract_missing"):
            tool.merge_selected(inventory, batch, {leaf.id: "次の週"}, {}, {})

    def test_unknown_runtime_support_cannot_be_imported(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "runtime_support": "future_unproven_support"})
        inventory = {**self.inventory, "leaves": [leaf]}
        batch = tool.make_batch(inventory, "ja", [leaf], "b" * 40, {}, {})
        with self.assertRaises(tool.ContractError):
            tool.merge_selected(inventory, batch, {leaf.id: "次の週"}, {}, {})

    def ledger(self):
        accepted = {locale: {} for locale in tool.LOCALES}
        accepted["ja"][self.leaf.id] = {"source_sha256": self.leaf.source_sha256,
                                        "target_sha256": tool.digest("次の週")}
        return {"schema_version": 1, "prompt_version": tool.PROMPT_VERSION,
                "native_review": "OPEN", "accepted": accepted,
                "accepted_sha256": tool.digest(accepted)}

    def read_ledger(self, ledger, inventory=None, locale="ja"):
        with patch.object(Path, "exists", return_value=True), \
                patch.object(tool, "read_json", return_value=ledger):
            return tool.committed_receipts(Path("/unused"), inventory or self.inventory, locale)

    def test_committed_receipt_portable_and_locale_isolated(self):
        ledger = self.ledger()
        self.assertEqual(self.read_ledger(ledger)[self.leaf.id],
                         [ledger["accepted"]["ja"][self.leaf.id]])
        self.assertEqual(self.read_ledger(ledger, locale="zh-TW"), {})

    def test_committed_receipt_absent_is_optional(self):
        with patch.object(Path, "exists", return_value=False):
            self.assertEqual(tool.committed_receipts(Path("/unused"), self.inventory, "ja"), {})

    def test_committed_receipt_checksum(self):
        ledger = self.ledger()
        ledger["accepted"]["ja"][self.leaf.id]["target_sha256"] = "0" * 64
        with self.assertRaises(tool.ContractError):
            self.read_ledger(ledger)

    def test_committed_receipt_locale(self):
        ledger = self.ledger()
        ledger["accepted"]["zh"] = ledger["accepted"].pop("zh-TW")
        ledger["accepted_sha256"] = tool.digest(ledger["accepted"])
        with self.assertRaises(tool.ContractError):
            self.read_ledger(ledger)

    def test_committed_receipt_unknown_leaf(self):
        ledger = self.ledger()
        ledger["accepted"]["ja"]["unknown"] = ledger["accepted"]["ja"].pop(self.leaf.id)
        ledger["accepted_sha256"] = tool.digest(ledger["accepted"])
        with self.assertRaises(tool.ContractError):
            self.read_ledger(ledger)

    def test_committed_receipt_hash_shape(self):
        ledger = self.ledger()
        ledger["accepted"]["ja"][self.leaf.id]["target_sha256"] = "bad"
        ledger["accepted_sha256"] = tool.digest(ledger["accepted"])
        with self.assertRaises(tool.ContractError):
            self.read_ledger(ledger)

    def test_committed_receipt_cannot_claim_native_go(self):
        ledger = self.ledger()
        ledger["native_review"] = "GO"
        with self.assertRaises(tool.ContractError):
            self.read_ledger(ledger)

    def test_committed_receipt_unsupported_leaf(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "runtime_support": "validator_contract_missing"})
        with self.assertRaises(tool.ContractError):
            self.read_ledger(self.ledger(), {**self.inventory, "leaves": [leaf]})

    def test_committed_receipt_stale_source_not_current(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "다음 달"})
        inventory = {**self.inventory, "leaves": [leaf]}
        ledger = self.ledger()
        documents = {"content/endings_ja.json": [{"id": "example", "title": "次の週"}]}
        with tempfile.TemporaryDirectory() as temporary, \
                patch.object(tool, "targets", return_value=(documents, {})), \
                patch.object(tool, "private_dir", return_value=Path(temporary)), \
                patch.object(tool, "committed_receipts", return_value=self.read_ledger(ledger, inventory)):
            result = tool.status(Path(temporary), inventory, "ja")
        counts = result["groups"]["ending"]
        self.assertEqual(counts.get("stale_receipt"), 1)
        self.assertEqual(counts.get("receipted_current_source", 0), 0)
        self.assertEqual(result["status"], "INCOMPLETE")

    def test_committed_receipt_stale_target_not_current(self):
        ledger = self.ledger()
        documents = {"content/endings_ja.json": [{"id": "example", "title": "来週"}]}
        with tempfile.TemporaryDirectory() as temporary, \
                patch.object(tool, "targets", return_value=(documents, {})), \
                patch.object(tool, "private_dir", return_value=Path(temporary)), \
                patch.object(tool, "committed_receipts", return_value=self.read_ledger(ledger)):
            result = tool.status(Path(temporary), self.inventory, "ja")
        self.assertEqual(result["groups"]["ending"].get("stale_receipt"), 1)
        self.assertEqual(result["groups"]["ending"].get("receipted_current_source", 0), 0)

    def test_committed_receipt_schema_and_prompt(self):
        for key, value in (("schema_version", 2), ("prompt_version", "other-prompt")):
            ledger = self.ledger()
            ledger[key] = value
            with self.subTest(key=key), self.assertRaises(tool.ContractError):
                self.read_ledger(ledger)

    def test_overlay_gameplay_field(self):
        with self.assertRaises(tool.ContractError):
            tool.validate_overlay({"id": "x", "effects": {"money": 1}}, {("title",)}, {"title": "제목"})

    def test_short_choice_array(self):
        source = {"choices": [{"text": "가"}, {"text": "나"}]}
        with self.assertRaises(tool.ContractError):
            tool.validate_overlay({"id": "x", "choices": [{"text": "一"}]},
                                  {("choices", 0, "text"), ("choices", 1, "text")}, source)

    def test_partial_reader_array(self):
        source = {"reader": {"texts": ["가", "나"]}}
        with self.assertRaises(tool.ContractError):
            tool.validate_overlay({"reader": {"texts": ["一"]}},
                                  {("reader", "texts", 0), ("reader", "texts", 1)}, source)

    def test_reader_gameplay_object(self):
        with self.assertRaises(tool.ContractError):
            list(tool.reader_strings({"effects": 10}, ("texts",)))

    def test_complete_reader_array(self):
        source = {"reader": {"texts": ["가", ["나", "다"]]}}
        tool.validate_overlay({"reader": {"texts": ["一", ["二", "三"]]}},
                              {("reader", "texts", 0), ("reader", "texts", 1, 0),
                               ("reader", "texts", 1, 1)}, source)

    def test_chapter5_duplicate_reader_alternatives_rejected(self):
        for field in ("chapter5_causal_reads", "chapter5_finale_reads"):
            source = {field: {"texts": [["가", "나"]]}}
            allowed = {(field, "texts", 0, 0), (field, "texts", 0, 1)}
            with self.subTest(field=field), self.assertRaisesRegex(tool.ContractError, "distinct"):
                tool.validate_overlay({field: {"texts": [["同じ", "同じ"]]}}, allowed, source)

    def test_chapter5_distinctness_is_per_row_not_global(self):
        field = "chapter5_finale_reads"
        source = {field: {"texts": [["가", "나"], ["가", "다"]]}}
        allowed = {(field, "texts", i, j) for i in range(2) for j in range(2)}
        tool.validate_overlay({field: {"texts": [["共通", "別"], ["共通", "違う"]]}}, allowed, source)

    def test_chapter5_finale_reader_inline_slot_rejected(self):
        field = "chapter5_finale_reads"
        source = {field: {"texts": [["가"]]}}
        with self.assertRaisesRegex(tool.ContractError, "inline slot"):
            tool.validate_overlay({field: {"texts": [["行 [[c5read:0]]"]]}},
                                  {(field, "texts", 0, 0)}, source)

    def test_chapter5_description_inline_slots_exactly_preserved(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "기록 [[c5read:0]] 결심 [[c5read:1]]"})
        for locale, target in (("ja", "記録 [[c5read:0]] 決断 [[c5read:1]]"),
                               ("zh-CN", "记录 [[c5read:0]] 决心 [[c5read:1]]"),
                               ("zh-TW", "記錄 [[c5read:0]] 決心 [[c5read:1]]")):
            with self.subTest(locale=locale):
                self.assertFalse(any("inline slot" in e for e in tool.translation_errors(leaf, locale, target)))

    def test_chapter5_description_inline_slot_mutations_rejected(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "기록 [[c5read:0]] 결심 [[c5read:1]]"})
        for target in ("記録 0 決断 1",  # Arabic digits survive, slots do not.
                       "記録 [[c5read:1]] 決断 [[c5read:0]]",
                       "記録 [[c5read:0]] 決断 [[c5read:1]] [[c5read:1]]",
                       "記録 [[c5read:0]] 決断 [[c5read:1]",
                       "記録 [[c5read:0]] 決断 [[c5read:1]] [[c5read:extra]]"):
            for locale in tool.LOCALES:
                with self.subTest(locale=locale, target=target):
                    self.assertTrue(any("inline slot" in e for e in tool.translation_errors(leaf, locale, target)))

    def test_native_go_cannot_be_invented(self):
        batch = copy.deepcopy(self.batch)
        batch[0]["native_review"] = "GO"
        batch[0]["batch_id"] = tool.digest({k: v for k, v in batch[0].items() if k != "batch_id"})
        self.reject(batch=batch, response=[batch[0], self.response[1]])

    def test_placeholder(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "{name} 다음 주"})
        self.assertTrue(tool.translation_errors(leaf, "ja", "次の週"))

    def test_printf_order(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "%s 남은 날 %d"})
        self.assertTrue(tool.translation_errors(leaf, "ja", "%d 残りの日数 %s"))

    def test_newlines(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "다음\n주"})
        self.assertTrue(tool.translation_errors(leaf, "ja", "次の週"))

    def test_hangul(self):
        self.assertTrue(tool.translation_errors(self.leaf, "ja", "다음 주"))

    def test_wrong_chinese_script(self):
        self.assertTrue(tool.translation_errors(self.leaf, "zh-CN", "這個週末"))
        self.assertTrue(tool.translation_errors(self.leaf, "zh-TW", "这个周末"))

    def test_currency(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "30억원"})
        self.assertTrue(tool.translation_errors(leaf, "ja", "30億円"))
        self.assertTrue(tool.translation_errors(leaf, "zh-CN", "30亿元"))

    def test_numeric_mutation(self):
        leaf = tool.Leaf(**{**tool.asdict(self.leaf), "source": "자산 30억"})
        self.assertFalse(tool.translation_errors(leaf, "ja", "資産30億ウォン"))
        self.assertTrue(tool.translation_errors(leaf, "ja", "資産3億ウォン"))

    def test_private_cache_locales_separate(self):
        with tempfile.TemporaryDirectory() as folder:
            with patch.object(tool.subprocess, "run") as run:
                run.return_value.stdout = folder + "\n"
                paths = {tool.private_dir(Path(folder), locale) for locale in tool.LOCALES}
                self.assertEqual(len(paths), 3)
                self.assertTrue(all(tool.PROMPT_VERSION in path.parts for path in paths))

    def test_path_escape(self):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(tool.ContractError):
                tool._safe_path(Path(folder), "../outside.json")

    def test_jsonl_duplicate(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "bad.jsonl"
            path.write_text('{"id":"a","id":"b"}\n')
            with self.assertRaises(tool.ContractError):
                tool.read_jsonl(path)


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ExchangeTests)
    result = unittest.TextTestRunner(verbosity=1).run(suite)
    if result.wasSuccessful():
        print(f"FULL_GAME_LOCALIZATION_SELF_TEST_OK cases={result.testsRun}")
    raise SystemExit(0 if result.wasSuccessful() else 1)
