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

    def test_story_half_durations_keep_the_fraction_and_unit(self):
        for locale, pairs in (
            ("zh-CN", (("1年半", "一年半", "1.5年"), ("两个半月", "两个月半", "2.5个月"))),
            ("zh-TW", (("1年半", "一年半", "1.5年", "一 年 半"), ("兩個半月", "兩個月半", "2.5個月"))),
        ):
            for source, targets in zip(("1년 반", "두 달 반"), pairs):
                leaf = tool.Leaf("events", "example", "content/events/arc_midgame.json", ("title",), source, "event_standard")
                for target in targets:
                    self.assertEqual(tool.translation_errors(leaf, locale, target), [], (source, target))

    def test_year_three_source_bound_quantities_and_name_beats(self):
        for source, target in (
            ('“여덟 시”라고 말했다.', '說了「八點」。'),
            ('‘일요일 8시’가 남았다.', '留下了「星期日八點」。'),
            ('숨을 한 번 고른 뒤.', '緩了一口氣之後。'),
            ('숨을 한 번 삼키고.', '吞了一口氣。'),
            ('숨이 한 번 길게 이어졌다.', '一口氣拉得很長。'),
            ('두 개의 도착 기록. 서류 첫 장. 둘 다 열지 않고', '兩筆送達紀錄。文件第一頁。兩個都不打開'),
            ('둘 다 열지 않고', '兩樣都不打開'),
            ('봉투 첫 장만 확인했다.', '只看了信封裡文件的首頁。'),
            ('사흘째 밤', '第三天夜裡'),
            ('사흘째 밤', '第三個晚上'),
            ('그 한 장을 보았다.', '看了那張。'),
            ('둘이서 찍은 것이었다.', '是兩人合拍的。'),
            ('아버지를 망하게 한 사람.', '讓父親一敗塗地的人。'),
            ('미뤘던 전화 한 통을 걸었다.', '撥了那通拖著沒打的電話。'),
            ('반 년 만에 러닝화를 꺼냈다. 첫날 3킬로 뛰다 죽는 줄 알았다.', '隔了半年，拿出跑鞋。第一天跑三公里，就覺得要死了。'),
            ('임씨라고 했다. 임. 상. 철.', '說是姓 Im。Im。Sang。Chul。'),
            ('임가라고 했다.', '說是姓 Im。'),
            ('임 모 씨라고 했다.', '說是 Im 某。'),
            ('창원 김씨요.', '昌原那位姓 Kim 的。'),
            ('등록 이력 한 줄.', '一筆登記紀錄。'),
            ('여섯 자리와 연도, 지방법원 코드.', '六位數與年份、地方法院代碼。'),
            ('한 번 걸린 의심.', '一旦起了疑心。'),
            ('한 번 겹쳐 보였다.', '重疊了一下。'),
            ('한 번 겹쳐 보였다.', '重疊了一瞬。'),
            ('사다리는 한 칸씩 밟아야 한다.', '梯子要一階一階地爬。'),
            ('두 창을 닫지 못한 이유.', '關不掉兩個視窗的理由。'),
            ('두 가지가 동시에 사실이다.', '兩件事同時都是事實。'),
            ('두 파일을 열었다.', '打開兩個檔案。'),
            ('따로 알고 있던 두 세계가 겹쳤다.', '原本分開認識的兩個世界重疊了。'),
            ('총자산 화면과 대화 목록. 둘 다 올해의 기록. 이 둘을 따로 관리했다.', '總資產畫面與對話列表。兩邊都是今年的紀錄。這兩樣分開管理。'),
            ('두 컵이 있었다.', '有兩只杯子。'),
            ('술을 한 잔 더 주문한다', '再點一杯酒'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_drama.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_year_three_quantity_and_name_mutations(self):
        for source, targets in (
            ('“여덟 시”라고 말했다.', ('說了「九點」。', '說了「八個小時」。')),
            ('‘일요일 8시’가 남았다.', ('留下了「星期六八點」。', '留下了「星期日九點」。')),
            ('숨을 한 번 고른 뒤.', ('緩了兩口氣之後。', '緩了十一口氣之後。', '緩了負一口氣之後。')),
            ('손을 한 번 움직였다.', ('一口氣。',)),
            ('두 개의 도착 기록.', ('三筆送達紀錄。', '十二筆送達紀錄。', '負兩筆送達紀錄。')),
            ('두 사람이 왔다.', ('兩筆。',)),
            ('둘 다 열지 않고', ('三樣都不打開', '十二樣都不打開', '負兩樣都不打開')),
            ('봉투 첫 장만 확인했다.', ('只看了第二頁。', '只看了負首頁。')),
            ('사흘째 밤', ('第二天夜裡', '第三天白天', '第十三天夜裡', '負第三天夜裡')),
            ('그 한 장을 보았다.', ('看了兩張。', '看了十一張。', '看了負那張。')),
            ('둘이서 찍은 것이었다.', ('是三人合拍的。', '是十二人合拍的。')),
            ('미뤘던 전화 한 통을 걸었다.', ('撥了兩通電話。', '撥了十一通電話。', '撥了負那通電話。')),
            ('반 년 만에 러닝화를 꺼냈다. 첫날 3킬로 뛰다 죽는 줄 알았다.', (
                '隔了一年，拿出跑鞋。第一天跑三公里，就覺得要死了。',
                '隔了半年，拿出跑鞋。第一天跑四公里，就覺得要死了。',
                '隔了半年，拿出跑鞋。第一天三公斤。',
                '隔了負半年，拿出跑鞋。第一天跑三公里。')),
            ('임씨라고 했다. 임. 상. 철.', ('姓 Im。Im。Chul。Sang。', '姓 Im。Im。Sang。Chulx。')),
            ('임가공업이라고 했다.', ('Im。',)),
            ('임씨라고 했다.', ('姓 Imx。', 'Im。Sang。Chul。')),
            ('임 모 씨라고 했다.', ('Imx。',)),
            ('창원 김씨요.', ('Kimx。', 'Sang。')),
            ('등록 이력 한 줄.', ('兩筆登記紀錄。', '負一筆登記紀錄。', '十一筆登記紀錄。')),
            ('여섯 자리와 연도, 지방법원 코드.', ('七位數。', '負六位數。', '十 六位數。')),
            ('한 번 걸린 의심.', ('兩次起疑。', '負一旦起疑。')),
            ('한 번 움직였다.', ('一旦。',)),
            ('한 번 겹쳐 보였다.', ('重疊了兩下。', '重疊了負一下。', '重疊了十 一瞬。')),
            ('사다리는 한 칸씩 밟아야 한다.', ('梯子要兩階。', '梯子要負一階。', '梯子要十 一階。')),
            ('두 창을 닫지 못한 이유.', ('三個視窗。', '十二個視窗。', '負兩個視窗。')),
            ('두 가지가 동시에 사실이다.', ('三件事。', '負兩件事。', '十 兩件事。')),
            ('두 파일을 열었다.', ('三個檔案。', '負兩個檔案。', '十 兩個檔案。')),
            ('따로 알고 있던 두 세계가 겹쳤다.', ('三個世界。', '負兩個世界。', '十 兩個世界。')),
            ('총자산 화면과 대화 목록. 둘 다 올해의 기록.', ('三樣。', '負兩樣。', '十 兩邊。')),
            ('총자산 화면과 대화 목록. 둘 다 올해의 기록. 이 둘을 따로 관리했다.', (
                '總資產畫面與對話列表。三邊都是今年的紀錄。這兩樣分開管理。',
                '總資產畫面與對話列表。兩邊都是今年的紀錄。這三樣分開管理。',
                '總資產畫面與對話列表。負兩邊都是今年的紀錄。這兩樣分開管理。',
                '總資產畫面與對話列表。兩邊都是今年的紀錄。十 兩樣分開管理。')),
            ('두 컵이 있었다.', ('三只杯子。', '負兩個杯子。', '十 兩個杯子。', '十點兩個杯子。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_drama.json', ('description',), source, 'event_standard')
            for target in targets:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))

    def test_story_half_duration_mutations(self):
        for source, targets in (
            ("1년 반", ("一年", "兩年半", "一個半月", "十一年半", "-一年半", "負 一年半")),
            ("두 달 반", ("兩個月", "三個半月", "兩年半", "十二個半月", "-兩個半月", "負 兩個半月")),
            ("1년", ("一年半", "1.5年")),
            ("두 달", ("兩個半月", "2.5個月")),
        ):
            leaf = tool.Leaf("events", "example", "content/events/arc_midgame.json", ("title",), source, "event_standard")
            for target in targets:
                self.assertTrue(tool.translation_errors(leaf, "zh-TW", target), (source, target))

    def test_story_source_bound_counter_grammar(self):
        for source, target in (
            ("한 칸", "一个格子"),
            ("한 칸", "一个灰色格子"),
            ("한 칸", "一个留给人和身体的格子"),
            ("열차 한 대를 보냈다.", "放过了一班列车。"),
            ("다음 한 달", "下个月"),
            ("다음 한 달", "接下来的一个月"),
            ("다음 한 달 반", "接下来的一个半月"),
            ("현수의 하루를 정하던 시간표", "规定 Hyunsu 每天生活的时间表"),
            ("밥 한 번 먹어요", "一起吃个饭吧"),
            ("밥 한 번 먹어요", "一起吃顿饭吧"),
            ("1년치", "一整年"),
            ("기소된 사례가 6건 나왔다.", "找到六起被起诉的案例。"),
            ("토요일 두 시", "周六两点"),
            ("토요일 두 시", "星期六两点"),
            ("커피 한 잔", "喝杯咖啡"),
            ("커피 한 잔", "这杯咖啡"),
            ("한번 만나보실래요?", "要不要见一面？"),
            ("한번 만나보실래요?", "要不要见见看？"),
            ("한번 만나보실래요?", "要不要见个面？"),
            ("말을 한 번 더 붙이지 않았다", "没有再添一句"),
            ("열 장 넘게 찍었어요", "拍了不止十张"),
            ("주소 두 곳", "两个地址"),
            ("두 종이를", "两张纸"),
            ("한 글자씩 읽었다", "逐字读出"),
            ("작은 날짜 한 줄", "一小行日期"),
            ("말을 한 번 더 붙이지 않았다", "没再补上一句"),
            ("사원증", "工牌"),
            ("사 원", "4韩元"),
            ("둘 다 챙기겠다는 말은 선택이 아니었다", "说两边都顾上，不是选择"),
        ):
            leaf = tool.Leaf("events", "example", "content/events/arc_midgame.json", ("title",), source, "event_standard")
            self.assertEqual(tool.translation_errors(leaf, "zh-CN", target), [], (source, target))

    def test_story_counter_grammar_mutations(self):
        for source, target in (
            ("한 칸", "两个格子"),
            ("한 칸", "一个人"),
            ("열차 한 대를 보냈다.", "放过了两班列车。"),
            ("열차 한 대를 보냈다.", "放过了一班飞机。"),
            ("차량 한 대", "一班列车"),
            ("다음 한 달", "这个月"),
            ("다음 한 달", "下两个月"),
            ("다음 한 달", "下周"),
            ("다음 한 달 반", "下个月"),
            ("다음 한 달", "十下个月"),
            ("다음 한 달", "负下个月"),
            ("밥 한 번 먹어요", "负吃个饭吧"),
            ("한 달", "下个月"),
            ("현수의 하루를 정하던 시간표", "规定 Hyunsu 每周生活的时间表"),
            ("밥 한 번 먹어요", "一起吃两顿饭吧"),
            ("두 번 먹어요", "一起吃个饭吧"),
            ("1년치", "两整年"),
            ("기소된 사례가 6건 나왔다.", "找到七起被起诉的案例。"),
            ("기소된 사례가 6건 나왔다.", "找到六年被起诉的案例。"),
            ("토요일 두 시", "周五两点"),
            ("토요일 두 시", "周六三点"),
            ("토요일 두 시", "周六六十二点"),
            ("커피 한 잔", "两杯咖啡"),
            ("한번 만나보실래요?", "要不要见两面？"),
            ("두 번 만나보실래요?", "要不要见见看？"),
            ("말을 한 번 더 붙이지 않았다", "没有再添两句"),
            ("열 장 넘게 찍었어요", "拍了十张"),
            ("열 장 넘게 찍었어요", "拍了不止九张"),
            ("주소 두 곳", "三个地址"),
            ("두 종이를", "三张纸"),
            ("한 글자씩 읽었다", "每两个字读出"),
            ("작은 날짜 한 줄", "两小行日期"),
            ("사원증", "4韩元的工牌"),
            ("사 원", "工牌"),
            ("둘 다 챙기겠다는 말은 선택이 아니었다", "说三边都顾上，不是选择"),
            ("둘 다 챙기겠다는 말은 선택이 아니었다", "负两边都顾上，不是选择"),
            ("둘이 웃었다", "两边笑了"),
            ("한 칸", "十 一个格子"),
            ("한 칸", "负 一个格子"),
            ("열차 한 대를 보냈다.", "放过了十 一班列车。"),
            ("주소 두 곳", "十 两个地址"),
        ):
            leaf = tool.Leaf("events", "example", "content/events/arc_midgame.json", ("title",), source, "event_standard")
            self.assertTrue(tool.translation_errors(leaf, "zh-CN", target), (source, target))

    def test_goshiwon_and_separate_accounting_course(self):
        source = "저 고시원 나가요. 낮에는 회계 취업반에 다니고"
        leaf = tool.Leaf("events", "arc_hyunsu_new_path", "content/events/arc_midgame.json", ("description",), source, "event_standard")
        self.assertEqual(tool.translation_errors(leaf, "zh-CN", "我要搬出考试院了。白天上会计就业培训班。"), [])
        for target in ("我要搬出考试院培训班了。白天上会计就业培训班。", "我要搬出培训班了。白天上会计就业培训班。",
                       "我搬出白天上会计就业培训班的考试院。", "我搬出考试院了。白天上会计就业培训班的考试院很小。"):
            self.assertTrue(tool.translation_errors(leaf, "zh-CN", target))
        other = tool.Leaf("events", "example", "content/events/arc_midgame.json", ("description",), "저 고시원 나가요", "event_standard")
        self.assertTrue(tool.translation_errors(other, "zh-CN", "我要搬出考试院了。白天上会计就业培训班。"))

    def test_hospital_transliteration_is_not_an_english_exemption(self):
        leaf = tool.Leaf("events", "example", "content/events/arc_events.json", ("title",), "창원 성심병원", "event_standard")
        self.assertEqual(tool.translation_errors(leaf, "zh-CN", "昌原 Seongsim 医院"), [])
        self.assertTrue(tool.translation_errors(leaf, "zh-CN", "Changwon Seongsim Hospital"))
        other = tool.Leaf("events", "example", "content/events/arc_events.json", ("title",), "창원 병원", "event_standard")
        self.assertTrue(tool.translation_errors(other, "zh-CN", "昌原 Seongsim 医院"))

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
                         "builtin_overlay_static_only")
        self.assertEqual(tool.event_overlay_support(("choices", 0, "result_text")),
                         "builtin_overlay_static_only")

    def foreshadow_fixture(self):
        source = {"id": "example", "title": "암시", "description": "다음 선택.",
                  "choices": [{"text": "기다린다", "result_text": "남았다."},
                              {"text": "돌아간다", "result_text": "나왔다.",
                               "foreshadow": "{name}의 다음 선택."}]}
        target = {"id": "example", "title": "予兆", "description": "次の選択。",
                  "choices": [{"text": "待つ", "result_text": "残った。"},
                              {"text": "帰る", "result_text": "外に出た。",
                               "foreshadow": "{name}の次の選択。"}]}
        leaves = [tool.Leaf("events", "example", "content/events/example.json", path,
                            text, "choice_foreshadow" if path[-1] == "foreshadow"
                            else "event_standard", runtime_support=tool.event_overlay_support(path))
                  for path, text in tool.strings(source) if path != ("id",)]
        inventory = {"leaves": leaves, "source_manifest_sha256": "a" * 64,
                     "events": {"example": source}, "endings": {}, "catalog": {}}
        leaf = next(l for l in leaves if l.path[-1] == "foreshadow")
        return source, target, inventory, leaf

    def foreshadow_coverage_errors(self, source, target, locale="ja"):
        import i18n_coverage_check as coverage
        errors = []
        coverage.validate_event(locale, "example", source, target, errors)
        return errors

    def test_foreshadow_present_text_requires_same_source_choice(self):
        source, target, _, _ = self.foreshadow_fixture()
        self.assertEqual(self.foreshadow_coverage_errors(source, target), [])
        for absent in (True, False):
            bad = copy.deepcopy(source)
            if absent:
                del bad["choices"][1]["foreshadow"]
            else:
                bad["choices"][0]["foreshadow"] = bad["choices"][1].pop("foreshadow")
            self.assertTrue(self.foreshadow_coverage_errors(bad, target))

    def test_foreshadow_present_invalid_types_or_blanks_reject(self):
        source, target, _, _ = self.foreshadow_fixture()
        for value in (None, False, 7, [], {}, ["予兆"], {"text": "予兆"}, "", " \n\t"):
            for side in ("source", "target"):
                before, after = copy.deepcopy(source), copy.deepcopy(target)
                (before if side == "source" else after)["choices"][1]["foreshadow"] = value
                with self.subTest(side=side, value=value):
                    self.assertTrue(self.foreshadow_coverage_errors(before, after))

    def test_foreshadow_missing_is_measured_not_forced_into_old_rows(self):
        source, target, inventory, leaf = self.foreshadow_fixture()
        del target["choices"][1]["foreshadow"]
        for locale in ("en", "ja", "zh-CN", "zh-TW"):
            self.assertEqual(self.foreshadow_coverage_errors(source, target, locale), [])
        documents = {"content/events_ja/example.json": [target]}
        self.assertIsNone(tool.target_value(leaf, documents, "ja",
                                           {"example": "content/events_ja/example.json"}))
        self.assertEqual(sum(l.category == "choice_foreshadow" for l in inventory["leaves"]), 1)

    def test_foreshadow_choice_append_truncate_and_gameplay_reject(self):
        source, target, _, _ = self.foreshadow_fixture()
        cases = []
        for extra in ({"foreshadow": "予兆"}, {"money": 7}, {}):
            bad = copy.deepcopy(target); bad["choices"].append(extra); cases.append(bad)
        bad = copy.deepcopy(target); bad["choices"].pop(); cases.append(bad)
        bad = copy.deepcopy(target); bad["choices"][1]["money"] = 7; cases.append(bad)
        for bad in cases:
            self.assertTrue(self.foreshadow_coverage_errors(source, bad), bad)

    def test_foreshadow_bounded_import_preserves_other_text(self):
        _, target, inventory, leaf = self.foreshadow_fixture()
        text = target["choices"][1].pop("foreshadow")
        documents = {"content/events_ja/example.json": [target]}
        files = {"example": "content/events_ja/example.json"}
        batch = tool.make_batch(inventory, "ja", [leaf], "b" * 40, documents, files)
        response = [batch[0], {"id": leaf.id, "locale": "ja", "source_sha256": leaf.source_sha256,
                               "prompt_version": tool.PROMPT_VERSION, "text": text}]
        accepted = tool.check_batch(inventory, batch, response)
        merged = tool.merge_selected(inventory, batch, accepted, documents, files)
        expected = copy.deepcopy(documents)
        expected[files["example"]][0]["choices"][1]["foreshadow"] = text
        self.assertEqual(merged, expected)
        self.assertNotIn("foreshadow", target["choices"][1])

    def test_foreshadow_response_mutations_reject(self):
        _, target, inventory, leaf = self.foreshadow_fixture()
        text = target["choices"][1].pop("foreshadow")
        documents = {"content/events_ja/example.json": [target]}
        files = {"example": "content/events_ja/example.json"}
        batch = tool.make_batch(inventory, "ja", [leaf], "b" * 40, documents, files)
        good = [batch[0], {"id": leaf.id, "locale": "ja", "source_sha256": leaf.source_sha256,
                           "prompt_version": tool.PROMPT_VERSION, "text": text}]
        for key, value in (("locale", "zh-TW"), ("source_sha256", "0" * 64),
                           ("id", leaf.id.replace("/1/", "/0/")), ("text", "次の選択。"),
                           ("text", ""), ("text", [text]), ("money", 7)):
            bad = copy.deepcopy(good); bad[1][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(tool.ContractError):
                tool.check_batch(inventory, batch, bad)
        for bad in ([good[0]], good + [good[1]]):
            with self.assertRaises(tool.ContractError):
                tool.check_batch(inventory, batch, bad)
        changed = copy.deepcopy(documents)
        changed[files["example"]][0]["choices"][1]["foreshadow"] = "次の週。"
        with self.assertRaisesRegex(tool.ContractError, "target changed"):
            tool.merge_selected(inventory, batch, {leaf.id: text}, changed, files)

    def test_foreshadow_extra_source_path_and_raw_duplicate_reject(self):
        source, target, inventory, _ = self.foreshadow_fixture()
        allowed = {l.path for l in inventory["leaves"]}
        for path in (("choices", 0, "foreshadow"), ("choices", 1, "money")):
            bad = copy.deepcopy(target); tool.set_at(bad, path, "予兆")
            with self.assertRaises(tool.ContractError):
                tool.validate_overlay(bad, allowed, source)
        with self.assertRaises(tool.ContractError):
            tool.loads('{"foreshadow":"予兆","foreshadow":"別の予兆"}')

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
