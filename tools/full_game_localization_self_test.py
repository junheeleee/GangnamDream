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

    def test_final_year_chapter_receipt_and_honorific_contexts(self):
        for source, target in (
            ('1장의 마지막 상환확인일', '第一章最後的還款確認日期'),
            ('1장의 마지막 상환확인서 사본', '第1章最後的還款確認書影本'),
            ('두 분은 내가 대답하기도 전에', '兩位在我回答以前'),
            ('내 이름만으로 227번을 접수한다', '只用我的名字送件，收件編號為227號'),
            ('접수본에 227번과 날짜를 찍었다.', '在收件文件上蓋了227號和日期。'),
            ('자기 명의 227번을 차례로 펼쳤다.', '依序展開自己名義的227號。'),
            ('못 한 사람이나.', '或沒能做到的人。'),
            ('그 말을 한 사람이 제안자이기도 하다.', '說這話的人也是提案者。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_final_year_chapter_receipt_and_honorific_mutations(self):
        for source, good in (
            ('1장의 마지막 상환확인일', '第一章'),
            ('내 이름만으로 227번을 접수한다', '227號'),
            ('두 분은 내가 대답하기도 전에', '兩位'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            for bad in (good.replace('一', '二').replace('227', '228').replace('兩', '三'), '負'+good, '十 '+good):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))
        for source, bad in (
            ('1장의 마지막 상환확인일', '一張還款確認書'),
            ('종이 한 장을 폈다.', '第一章'),
            ('내 이름만으로 227번을 접수한다', '227次'),
            ('접수본에 227번과 날짜를 찍었다.', '227分鐘'),
            ('227번을 반복했다.', '227號'),
            ('두 분은 내가 대답하기도 전에', '兩分鐘'),
            ('두 분이 지났다.', '兩位'),
            ('한 사람이 앉았다.', '人坐下了。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_final_year_mixed_won_amounts(self):
        for locale, pairs in (
            ('ja', (('2억 5천8백만원', '2億5,800万ウォン'), ('1천8백만원', '1,800万ウォン'),
                    ('1천2백만원', '1,200万ウォン'), ('-1천2백만원', '-1,200万ウォン'),
                    ('+1천2백만원', '+1,200万ウォン'))),
            ('zh-CN', (('2억 5천8백만원', '2亿5800万韩元'), ('1천8백만원', '1800万韩元'),
                       ('1천2백만원', '1200万韩元'), ('-1천2백만원', '-1200万韩元'))),
            ('zh-TW', (('2억 5천8백만원', '2億5800萬韓元'), ('1천8백만원', '1800萬韓元'),
                       ('1천2백만원', '1200萬韓元'), ('-1천2백만원', '-1200萬韓元'))),
        ):
            for source, target in pairs:
                leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
                self.assertEqual(tool.translation_errors(leaf, locale, target), [], (source, target))

    def test_final_year_mixed_won_mutations(self):
        for locale, good, bad_currency in (
            ('ja', '2億5,800万ウォン', '2億5,800万円'),
            ('zh-CN', '2亿5800万韩元', '2亿5800万元'),
            ('zh-TW', '2億5800萬韓元', '2億5800萬元'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '2억 5천8백만원', 'event_standard')
            for bad in (good.replace('800','900'), good.replace('2','3'), '負'+good, '十 '+good, good+'、'+good, bad_currency):
                self.assertTrue(tool.translation_errors(leaf, locale, bad), (locale, bad))
        for source, target in (('-1천2백만원','1,200万ウォン'),('+1천2백만원','1,200万ウォン'),('1천2백만원','+1,200万ウォン')):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'ja', target), (source, target))

    def test_final_year_ordinal_version_and_source_document(self):
        for source, target in (('열한 번째 장에', '第十一頁'), ('여섯 번째 장면', '第六個場景'), ('첫 번째 장면', '第一個場景'), ('두 버전의 모서리', '兩個版本的邊角'), ('R3 원문이 있었다.', '有R3原文。')):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))
        for source, bad in (('열한 번째 장에', '第十二頁'), ('열한 번째 장에', '十一分鐘'), ('두 버전의 모서리', '三個版本的邊角'), ('두 버전의 모서리', '兩個人'), ('R3 원문이 있었다.', '有3韓元。'), ('3원이었다.', '有原文。')):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_final_year_mixed_money_owner_order(self):
        for source, good, bad in (
            ('A는 1천8백만원, B는 1천2백만원이었다.', 'Aは1,800万ウォン、Bは1,200万ウォンだった。', 'Aは1,200万ウォン、Bは1,800万ウォンだった。'),
            ('1천8백만원. 7일. 1천2백만원.', '1,800万ウォン。7日。1,200万ウォン。', '1,800万ウォン。1,200万ウォン。7日。'),
            ('1천8백만원. 7만원.', '1,800万ウォン。7万ウォン。', '7万ウォン。1,800万ウォン。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], (source, good))
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))

    def test_final_year_typed_name_columns_chairs_and_covers(self):
        for source, good, bad in (
            ('두 이름 칸의 차이.', '兩個姓名欄的差異。', '兩個名字的差異。'),
            ('두 이름 칸의 차이.', '两个名字栏的差异。', '三個姓名欄的差異。'),
            ('두 이름을 보았다.', '看見兩個名字。', '看見兩個人。'),
            ('두 의자의 등받이.', '兩張椅子的椅背。', '三張椅子的椅背。'),
            ('두 의자의 등받이.', '两把椅子的椅背。', '兩個小時。'),
            ('두 표지에는 같은 시각.', '兩份封面上有相同的時間。', '三份封面上有相同的時間。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            locale = 'zh-CN' if '两个' in good or '两把' in good else 'zh-TW'
            self.assertEqual(tool.translation_errors(leaf, locale, good), [], (source, good))
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))
        for locale, classifier in (('zh-CN', '个'), ('zh-TW', '個')):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '셋을 모두 캐물으면 대답은 흐려졌다.', 'event_standard')
            good = '三' + classifier + ('都追问的话，回答就含糊了。' if locale == 'zh-CN' else '都追問的話，回答就含糊了。')
            self.assertEqual(tool.translation_errors(leaf, locale, good), [])
            for suffix in ('月', '年', '日', '週', '秒', '人', '小時', '韓元', '公里'):
                bad = good.replace('三' + classifier, '三' + classifier + suffix)
                self.assertTrue(tool.translation_errors(leaf, locale, bad), (locale, bad))
            for suffix in ('股份', '股', '椅子'):
                self.assertTrue(tool.translation_errors(leaf, locale, '三' + classifier + suffix + '。'))
        leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '고맙다. 그리고 미안했다. 둘 다.', 'event_standard')
        for suffix in ('人', '小时', '月', '公里', '股份'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-CN', '两样' + suffix + '。'), suffix)

    def test_final_year_monthly_sunday_and_paper_signs(self):
        for locale, source, good, bads in (
            ('zh-CN', '한 달에 일요일 하나를 남긴다.', '每月留下一个星期天。', ('每月留下零个星期天。', '每月留下负一个星期天。', '每月留下十 一个星期天。', '每月留下一个人。')),
            ('zh-TW', '한 달에 일요일 하나를 남긴다.', '每月留下一個星期天。', ('每月留下零個星期天。', '每月留下負一個星期天。')),
            ('zh-CN', '두 종이가 남았다.', '两张纸留下了。', ('负两张纸留下了。', '十 两张纸留下了。')),
            ('zh-TW', '두 종이만 남았다. 두 종이는 접혀 있었다.', '只留下兩張紙。兩張紙是折好的。', ('只留下負兩張紙。兩張紙是折好的。', '只留下兩張紙。負兩張紙是折好的。')),
            ('zh-CN', '네 주를 한 번도 비켜 가지 않았다.', '四周里一次也没有漏过。', ('四周里两次也没有漏过。',)),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, locale, good), [], (source, good))
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, locale, bad), (source, bad))

    def test_final_year_money_suffix_and_megabyte_prefix(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '1천8백만원', 'event_standard')
        for bad in ('1,800万ウォン円', '1,800万ウォン韓元', '1,800万ウォンウォン'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        for locale, good in (('zh-CN', '6.4 MB文件。'), ('zh-TW', '6.4 MB檔案。'), ('zh-TW', '6.4兆位元組檔案。')):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '6.4메가바이트 파일.', 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, locale, good), [], good)
            for bad in ('负' + good, '負' + good, '十 ' + good, good.replace('6.4', '7.4'), good.replace('MB', 'GB') if 'MB' in good else good.replace('兆', '千')):
                self.assertTrue(tool.translation_errors(leaf, locale, bad), bad)

    def test_relationship_approximate_repetitions_and_ages(self):
        for source, goods, bads in (
            ('소주잔이 두어 번 오갔다.', ('酒杯來回了兩三次。', '酒杯來回了兩次左右。'),
             ('酒杯來回了二十次。', '酒杯來回了一次。', '酒杯來回了兩次。', '酒杯來回了負兩三次。', '酒杯來回了十 兩三次。', '酒杯來回了兩三分鐘。', '酒杯來回了兩三次元。', '酒杯來回了。')),
            ('서른 몇의 연애는 단단했다.', ('三十幾歲的戀愛很堅定。', '30多歲的戀愛很堅定。'),
             ('四十幾歲的戀愛很堅定。', '十三歲的戀愛很堅定。', '三十三歲的戀愛很堅定。', '三十幾年的戀愛很堅定。', '負三十幾歲的戀愛很堅定。', '十 三十幾歲的戀愛很堅定。')),
            ('서른을 넘긴 두 사람 사이에 거리가 있었다.', ('年過三十的兩個人之間有距離。', '三十歲出頭的兩個人之間有距離。'),
             ('年過四十的兩個人之間有距離。', '三十歲的兩個人之間有距離。', '三十天出頭的兩個人之間有距離。', '負三十歲出頭的兩個人之間有距離。', '年過三十天的兩個人之間有距離。', '年過三十的三個人之間有距離。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), source, 'event_standard')
            for good in goods:
                self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_relationship_temperature_and_honorific_people(self):
        for source, goods, bads in (
            ('그 목소리의 온도가 반 도쯤 내려간 걸 느꼈다.', ('感覺那聲音的溫度降了半度左右。', '感覺那聲音的溫度降了0.5度左右。'),
             ('感覺那聲音的溫度降了一度左右。', '感覺那聲音的溫度降了半分鐘左右。', '感覺那聲音的溫度降了負半度左右。', '感覺那聲音的溫度降了十 半度左右。', '感覺那聲音的溫度降了負0.5度左右。')),
            ('두 분 모두의 자리가 있는 집으로 하자.', ('就找兩位都有位置的家吧。',),
             ('就找兩分鐘都有位置的家吧。', '就找三位都有位置的家吧。', '就找負兩位都有位置的家吧。', '就找十 兩位都有位置的家吧。')),
            ('다은에게 두 분 뒤 같은 파일을 보냈다.', ('兩分鐘後把同一份檔案傳給Daeun。',),
             ('兩位後把同一份檔案傳給Daeun。',)),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_married.json', ('description',), source, 'event_standard')
            for good in goods:
                self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_relationship_span_unit_and_prefix(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), '그 거리가 한 뼘씩 줄었다.', 'event_standard')
        for good in ('那距離一拃一拃地縮短了。', '那距離每次縮短一個手掌寬。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], good)
        for bad in ('那距離兩拃地縮短了。', '那距離一厘米地縮短了。', '那距離負一拃地縮短了。', '那距離+一拃地縮短了。', '那距離十 一拃地縮短了。', '那距離一個人地縮短了。', '那距離縮短了。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)

    def test_relationship_dial_ring_answer_context(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '아버지 번호를 눌렀다. 신호가 두 번 울리고 아버지가 받았다.', 'event_standard')
        good = '撥了父親的號碼。回鈴音響了兩聲，父親接了。'
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], good)
        for bad in (good.replace('兩聲','三聲'), good.replace('兩聲','兩分鐘')):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
        for source in ('서류 번호를 눌렀다. 신호가 두 번 울리고 아버지가 받았다.', '아버지 번호를 눌렀다. 신호가 두 번 울리고 서류를 받았다.'):
            other = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(other, 'zh-TW', good), source)

    def test_relationship_natural_quantity_order_and_no_toss(self):
        for source, good, bads in (
            ('서른을 넘긴 두 사람 사이에 거리가 있었다.', '兩個過了三十的人之間有距離。',
             ('三個過了三十的人之間有距離。', '兩個過了四十的人之間有距離。', '兩個過了三十天的人之間有距離。')),
            ('카페의 소음이 두 사람에게서 한 걸음씩 멀어졌다.', '咖啡館的嘈雜聲，一步步離兩人遠去。',
             ('咖啡館的嘈雜聲，兩步步離兩人遠去。', '咖啡館的嘈雜聲，一步步離三人遠去。', '咖啡館的嘈雜聲，負一步步離兩人遠去。')),
            ('밤새 한 번도 뒤척이지 않은 얼굴이었다.', '那張臉，像是一整夜都沒有翻過身。',
             ('那張臉，像是一整夜都翻過身。', '那張臉，像是負一整夜都沒有翻過身。', '那張臉，像是十 一整夜都沒有翻過身。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)

    def test_relationship_one_plus_one_offer(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_extension.json', ('description',), '삼각김밥 1+1이었다.', 'event_standard')
        for good in ('三角飯捲1+1。', '三角飯捲買一送一。', '三角飯捲買1送1。', '三角飯捲1+1活動，買一送一喔。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], good)
        for bad in ('三角飯捲1-1。', '三角飯捲1×1。', '三角飯捲1/1。', '三角飯捲1+2。', '三角飯捲買一送二。', '三角飯捲負1+1。', '三角飯捲負買一送一。', '三角飯捲十 買一送一。', '三角飯捲買1送10。', '三角飯捲。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
        self.assertTrue(tool.translation_errors(leaf, 'zh-TW', '三角飯捲買一送一買一送一。'))

    def test_relationship_separable_toss_turn_verb(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), '밤새 한 번도 뒤척이지 않은 얼굴이었다.', 'event_standard')
        for good in ('那張臉，像是整夜都沒翻過一次身。', '那張臉，像是一整夜都沒翻身。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], good)
        for bad in ('那張臉，像是整夜都沒翻過兩次身。', '那張臉，像是整夜都翻過一次身。', '那張臉，像是整夜都沒翻過負一次身。', '那張臉，像是負整夜都沒翻過一次身。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)

    def test_relationship_review_numeric_range_and_offer_suffix(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), '소주잔이 두어 번 오갔다.', 'event_standard')
        for good in ('酒杯來回了兩三次。', '酒杯來回了2、3次。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], good)
        for bad in ('酒杯來回了23次。', '酒杯來回了23回。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
        leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_extension.json', ('description',), '삼각김밥 1+1이었다.', 'event_standard')
        for bad in ('三角飯捲買一送一百。', '三角飯捲買一送一千。', '三角飯捲1+1活動，買一送一百。', '三角飯捲1+1活動，買一送二。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)

    def test_relationship_review_unit_extensions_and_ring_sign(self):
        for source, bads in (
            ('아버지 번호를 눌렀다. 신호가 두 번 울리고 아버지가 받았다.',
             ('撥了父親的號碼。回鈴音響了-2聲，父親接了。', '撥了父親的號碼。回鈴音響了負兩聲，父親接了。', '撥了父親的號碼。回鈴音響了十 兩聲，父親接了。')),
            ('서른 몇의 연애는 단단했다.', ('30幾歲元的戀愛很堅定。',)),
            ('서른을 넘긴 두 사람 사이에 거리가 있었다.',
             ('兩個年過30公里的人之間有距離。', '兩個年過30米的人之間有距離。', '兩個年過30度的人之間有距離。')),
            ('그 목소리의 온도가 반 도쯤 내려간 걸 느꼈다.',
             ('感覺那聲音的溫度降了0.5度角。', '感覺那聲音的溫度降了0.5度分鐘左右。')),
            ('삼각김밥 1+1이었다.',
             ('三角飯捲買一送一元。', '三角飯捲1+1活動，買一送一元。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), source, 'event_standard')
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_relationship_no_toss_requires_whole_night_source(self):
        for source in ('지난달 한 번도 뒤척이지 않은 얼굴이었다.', '한 번도 뒤척이지 않은 얼굴이었다.'):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_romance.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', '那張臉，像是一整夜都沒有翻過身。'), source)
    def test_finale_original_file_and_relative_clause_contexts(self):
        for source, good in (
            ('00:31 원본을 지웠다.', '刪掉00:31的原檔。'),
            ('이 원본을 남겼다.', '留下這個原檔。'),
            ('이 원문을 남겼다.', '留下這份原文。'),
            ('만나기로 한 시각도 생기지 않았다.', '也沒有約好見面的時間。'),
            ('휴대폰은 화면을 아래로 한 채 손 닿는 곳에 있었다.', '手機螢幕朝下，放在伸手可及之處。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
        for source, bad in (
            ('00:31 원본을 지웠다.', '刪掉00:32的原檔。'),
            ('00:31 원본을 지웠다.', '刪掉00:31韓元的原檔。'),
            ('이 원본을 남겼다.', '留下2韓元。'),
            ('31원을 남겼다.', '留下31原檔。'),
            ('이 원을 남겼다.', '留下這個原檔。'),
            ('집 한 채를 샀다.', '買了兩棟房子。'),
            ('집 한 채를 샀다.', '手機螢幕朝下。'),
            ('한 시각을 남겼다.', '留下兩個時間。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_finale_records_and_signature_alternatives(self):
        for source, good in (
            ('세 물건의 순서가 바뀌었다.', '三件物品的順序變了。'),
            ('두 결과를 남긴다.', '留下兩個結果。'),
            ('마지막까지 두 장부는 맞지 않았다.', '直到最後，兩本帳仍對不上。'),
            ('남겨 둘 현금 칸이 비어 있었다.', '要留下的現金欄還是空的。'),
            ('세 뜻을 읽었다. 하나를 쓰는 순간 다른 둘은 빈 줄에서 밀려났다. 셋을 모두 고른 척하면.', '讀出三種意思。寫下一種的瞬間，另外兩種就被擠出了空行。假裝三種全選的話。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
            if '兩' in good or '三' in good:
                for bad in (good.replace('兩','四').replace('三','四'), good.replace('兩','負兩').replace('三','負三'), good.replace('兩','十 兩').replace('三','十 三')):
                    self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))
        for source, bad in (
            ('두 결과를 남긴다.', '留下兩個人。'), ('세 물건의 순서가 바뀌었다.', '三個小時。'),
            ('마지막까지 두 장부는 맞지 않았다.', '直到最後，兩個人仍對不上。'),
            ('하나를 쓰는 순간 다른 둘은 빈 줄에서 밀려났다. 셋을 모두 고른 척하면.', '寫下一種的瞬間，另外兩種人就被擠出了空行。假裝三種全選的話。'),
            ('하나를 쓰는 순간 다른 둘은 빈 줄에서 밀려났다. 셋을 모두 고른 척하면.', '寫下一種的瞬間，另外兩種就被擠出了空行。假裝三種人全選的話。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_finale_strike_storage_and_food_contexts(self):
        for locale, source, good in (
            ('zh-TW', '다시 비교하던 세 문만 닫혔다.', '只有那三扇一再比較的門關上了。'),
            ('zh-CN', '다시 비교하던 세 문만 닫혔다.', '只是那三扇重新比较着的门关闭了。'),
            ('zh-TW', '수첩 첫 장의 목표를 두 줄로 지우고.', '用兩條線劃掉筆記本第一頁的目標。'),
            ('zh-CN', '수첩 첫 장의 목표를 두 줄로 지우고.', '用两道线划掉笔记本第一页的目标。'),
            ('zh-TW', '검은 줄을 두 번 그었다.', '畫了兩道黑線。'),
            ('zh-CN', '검은 줄을 두 번 그었다.', '画了两次黑线。'),
            ('zh-TW', '둘 다 남겨 둔 채 이름만 쓰는 선택은 없었다.', '沒有把兩邊都留下、只簽名字的選項。'),
            ('zh-CN', '둘 다 남겨 둔 채 이름만 쓰는 선택은 없었다.', '没有把两者都留着、只签名字的选项。'),
            ('zh-TW', '두 결과를 자기 원장에만 둘 수 있었다.', '可以只把兩個結果留在自己的帳冊。'),
            ('zh-TW', '하루를 통째로 비웠었다. 그 하루가 체력이 됐다.', '曾把一整天完全空下來。那一天，成了體力。'),
            ('zh-CN', '밥 한 끼를 함께할 수 있는지 물었다. 한 끼는 확정되지 않았다.', '问能否一起吃顿饭。那顿饭还没有确定。'),
            ('zh-TW', '세 물건 사이에 종이를 끼웠다.', '在三樣東西之間夾紙。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, locale, good), [], (source, good))
        for source, bad in (
            ('다시 비교하던 세 문만 닫혔다.', '只有那四扇一再比較的門關上了。'),
            ('다시 비교하던 세 문만 닫혔다.', '只有那負三扇一再比較的門關上了。'),
            ('다시 비교하던 세 문만 닫혔다.', '三個小時。'),
            ('수첩 첫 장의 목표를 두 줄로 지우고.', '用三條線劃掉筆記本第一頁的目標。'),
            ('수첩 첫 장의 목표를 두 줄로 지우고.', '用負兩條線劃掉筆記本第一頁的目標。'),
            ('수첩 첫 장의 목표를 두 줄로 지우고.', '用兩條線劃掉筆記本第二頁的目標。'),
            ('수첩 첫 장의 목표를 두 줄로 지우고. 두 줄로 지우고.', '用兩條線劃掉筆記本第一頁的目標。'),
            ('검은 줄을 두 번 그었다.', '畫了三道黑線。'),
            ('검은 줄을 두 번 그었다.', '畫了負兩道黑線。'),
            ('둘 다 남겨 둔 채 이름만 쓰는 선택은 없었다.', '沒有把三邊都留下、只簽名字的選項。'),
            ('둘 다 남겨 둔 채 이름만 쓰는 선택은 없었다.', '沒有把兩個人留下、只簽名字的選項。'),
            ('두 결과를 자기 원장에만 둘 수 있었다.', '可以只把三個結果留在自己的帳冊。'),
            ('하루를 통째로 비웠었다. 그 하루가 체력이 됐다.', '曾把兩整天完全空下來。那一天，成了體力。'),
            ('밥 한 끼를 함께할 수 있는지 물었다. 한 끼는 확정되지 않았다.', '問能否一起吃兩頓飯。那頓飯還沒有確定。'),
            ('밥 한 끼를 함께할 수 있는지 물었다. 한 끼는 확정되지 않았다.', '問能否一起吃頓飯。還沒有確定。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_finale_postposition_and_appliance_cycle(self):
        for source, good, bad in (
            ('세 주소를 지웠다. 세 주소에 붙은 알림도 지웠다. 세 문만 닫혔다.', '刪掉三個地址。三個地址的通知也刪了。三扇門關上了。', '刪掉三個地址。兩個地址的通知也刪了。三扇門關上了。'),
            ('두 결과를 남겼다.', '留下兩項結果。', '留下三項結果。'),
            ('세 물건 사이에 종이를 끼웠다.', '在三樣物件之間夾紙。', '在負三樣物件之間夾紙。'),
            ('냉장고가 한 번 돌아가는 동안.', '冰箱運轉了一輪的工夫。', '冰箱運轉了兩輪的工夫。'),
            ('냉장고가 한 번 돌아가는 동안.', '冰箱運轉了一次的工夫。', '冰箱運轉了負一輪的工夫。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_finale_review_timecode_day_and_signature_mutations(self):
        for source, bads in (
            ('00:31 원본을 지웠다.', ('刪掉−00:31的原檔。', '刪掉十 00:31的原檔。', '刪掉+00:31的原檔。')),
            ('하루를 통째로 비웠었다.', ('曾把負一整天完全空下來。', '曾把十 一整天完全空下來。')),
            ('세 뜻을 읽었다. 하나를 쓰는 순간 다른 둘은 빈 줄에서 밀려났다. 셋을 모두 고른 척하면.', ('讀出三種意思。寫下一種的人的瞬間，另外兩種的人就被擠出空行。假裝三種的人全選。',)),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_pre_ending.json', ('description',), source, 'event_standard')
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_finale_agreement_parties_before_same_screen(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_year3_drama.json', ('description',), '둘이 합의한 날짜에 맞춰 한 화면에 띄웠다.', 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-CN', '按双方商定的日期，放到同一个屏幕上。'), [])
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', '按兩人商定的日期，放到同一個螢幕上。'), [])
        for bad in ('按三人商定的日期，放到同一個螢幕上。', '按負雙方商定的日期，放到同一個螢幕上。', '按十 雙方商定的日期，放到同一個螢幕上。', '按雙方商定的日期，放到同兩個螢幕上。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
        leaf = tool.Leaf('events', 'example', 'content/events/arc_year3_drama.json', ('description',), '둘이 합의한 날짜에 맞춰 한 화면에 띄웠다. 서로 다른 두 도시의 시각으로 남았다.', 'event_standard')
        good = '按双方商定的日期，放到同一个屏幕上。留作两个不同城市的时间。'
        self.assertEqual(tool.translation_errors(leaf, 'zh-CN', good), [])
        for bad in (good.replace('双方','三人'), good.replace('一个屏幕','两个屏幕'), good.replace('两个不同城市','三个不同城市'), good.replace('两个不同城市','两个人'), good.replace('两个不同城市','负两个不同城市')):
            self.assertTrue(tool.translation_errors(leaf, 'zh-CN', bad), bad)

    def test_final_year_observed_surface_quantities(self):
        for source, target in (
            ('한 달에 일요일 하나를 남긴다.', '每月留下一個星期天。'),
            ('비워 둘 시간을 말해요.', '說說一開始就空下來的時間。'),
            ('두 화면에는 같은 날짜만 떠 있었다.', '兩個螢幕只顯示相同日期。'),
            ('세 화면을 모두 닫지 않았다.', '三個畫面，一個也沒關。'),
            ('두 말풍선 아래.', '兩個訊息泡泡下。'),
            ('두 첨부파일의 쪽수를 첫 장부터 대조했다.', '從第一頁開始，核對兩個附件的頁數。'),
            ('두 전송 버튼만 남았다.', '只留下兩個傳送按鈕。'),
            ('두 파일의 마지막 장.', '兩個檔案的最後一頁。'),
            ('세 주소를 저장했다.', '儲存三個地址。'),
            ('25억원대 매물 셋 가운데 골랐다.', '從三套25億韓元價位的房源中選。'),
            ('매수인은 한 분으로 보세요?', '買方按一位來看嗎？'),
            ('식은 커피를 한 번도 마시지 않았다.', '一口冷咖啡也沒喝。'),
            ('두 숫자 사이.', '兩個數字之間。'),
            ('두 출처를 구분했다.', '區分兩個來源。'),
            ('영상 세 개를 재생했다.', '播放三段影片。'),
            ('관찰할 시각 세 개가 적혔다.', '寫下三個需要觀察的時間。'),
            ('셋을 모두 캐물으면.', '三個問題都追問的話。'),
            ('비어 있는 두 칸부터.', '從兩個空欄開始。'),
            ('소유자 한 칸으로.', '縮成所有權人一個欄位。'),
            ('두 날짜를 적었다.', '寫下兩個日期。'),
            ('칼이 도마에 닿았다. 하나, 둘.', '刀落在砧板上。一，二。'),
            ('세 글자였다.', '是三個韓文字。'),
            ('둘 중 하나였다.', '只有這兩種。'),
            ('파일은 6.4메가바이트.', '檔案是6.4 MB。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_final_year_surface_quantity_mutations(self):
        for source, good in (
            ('두 화면에는 날짜만 있었다.', '兩個螢幕'), ('세 화면을 모두 열었다.', '三個畫面'),
            ('두 말풍선 아래.', '兩個訊息泡泡'), ('두 첨부파일을 열었다.', '兩個附件'),
            ('두 전송 버튼만 남았다.', '兩個傳送按鈕'), ('세 주소를 저장했다.', '三個地址'),
            ('두 숫자 사이.', '兩個數字'), ('두 출처를 구분했다.', '兩個來源'),
            ('영상 세 개를 재생했다.', '三段影片'), ('관찰할 시각 세 개가 적혔다.', '三個需要觀察的時間'),
            ('셋을 모두 캐물으면.', '三個問題'), ('두 날짜를 적었다.', '兩個日期'),
            ('비어 있는 두 칸부터.', '兩個空欄'), ('세 글자였다.', '三個韓文字'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            for bad in (good.replace('兩','四').replace('三','四'), '負'+good, '十 '+good, '兩分鐘'):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))
        for source, bad in (
            ('한 달에 일요일 하나를 남긴다.', '每週留下一個星期天。'),
            ('두 시간이 지났다.', '時間過去了。'),
            ('칼이 도마에 닿았다. 하나, 둘.', '刀落在砧板上。一，三。'),
            ('칼이 도마에 닿았다. 하나, 둘.', '刀落在砧板上。三，二。'),
            ('식은 커피를 한 번도 마시지 않았다.', '喝了一口冷咖啡。'),
            ('식은 커피를 한 번도 마시지 않았다.', '兩口冷咖啡也沒喝。'),
            ('25억원대 매물 셋 가운데 골랐다.', '從四套25億韓元價位的房源中選。'),
            ('25억원대 매물 셋 가운데 골랐다.', '從三套26億韓元價位的房源中選。'),
            ('6.4메가바이트.', '6.4 GB。'), ('원문 파일.', 'MB。'),
            ('두 첨부파일의 쪽수를 첫 장부터 대조했다.', '從第二頁開始，核對兩個附件的頁數。'),
            ('두 첨부파일의 쪽수를 첫 장부터 대조했다.', '從第一頁開始，核對三個附件的頁數。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_final_year_receipt_negation_and_labels(self):
        for source, target in (
            ('보증 범위를 다시 한 번 위에서 아래로 읽고.', '再次由上往下讀過保證範圍。'),
            ('네 주를 한 번도 비켜 가지 않았다.', '四週裡沒有漏過任何一週。'),
            ('세 개의 현재 동작이 열렸다.', '三種此刻可以做的操作。'),
            ('셋을 모두 캐물으면.', '三件事都追問的話。'),
            ('고맙다. 그리고 미안했다. 둘 다.', '謝謝你。也對不起你。兩樣都是。'),
            ('두 종이만 남았다. 두 종이는 접혀 있었다.', '只留下兩張紙。兩張紙是折好的。'),
            ('두 표지에는 시각이 보였다.', '兩個封面上看得見時間。'),
            ('컵라면 두 개를 먹었다.', '吃了兩碗杯麵。'),
            ('대답해야 할 사람은 셋이었다.', '得向三個人回答。'),
            ('평생 한 번도 안 했던 말을 했다.', '說了一輩子從沒說過的話。'),
            ('김다은이라는 이름이 입력돼 있었다.', 'R3 最後一頁填著「Kim Daeun」。'),
            ("등기부의 '김다은' 세 글자를 짚는다.", '點著登記簿上「Kim Daeun」的三個字。'),
            ("등기부의 '김다은' 세 글자를 짚는다.", '點著登記簿上「Kim Daeun」的三個韓文字。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            # The display-label fixture must preserve the source document ID.
            if target.startswith('R3 '):
                leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), 'R3 마지막 장에는 김다은이라는 이름이 입력돼 있었다.', 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (leaf.source, target))
        leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), '평생 한 번도 안 했던 말을 했다.', 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-CN', '说了这辈子一次也没说过的话。'), [])

    def test_final_year_receipt_negation_and_label_mutations(self):
        for source, bad in (
            ('보증 범위를 다시 한 번 위에서 아래로 읽고.', '兩次由上往下讀過保證範圍。'),
            ('네 주를 한 번도 비켜 가지 않았다.', '四週裡漏過一週。'),
            ('세 개의 현재 동작이 열렸다.', '兩種此刻可以做的操作。'),
            ('셋을 모두 캐물으면.', '三個小時。'),
            ('고맙다. 그리고 미안했다. 둘 다.', '謝謝你。也對不起你。三樣都是。'),
            ('두 종이만 남았다. 두 종이는 접혀 있었다.', '只留下兩張紙。三張紙是折好的。'),
            ('두 표지에는 시각이 보였다.', '三個封面上看得見時間。'),
            ('컵라면 두 개를 먹었다.', '吃了三碗杯麵。'),
            ('대답해야 할 사람은 셋이었다.', '得向四個人回答。'),
            ('평생 한 번도 안 했던 말을 했다.', '說了這輩子說過一次的話。'),
            ('R3 마지막 장에는 김다은이라는 이름이 입력돼 있었다.', 'R3 最後一頁填著「Kim Daeun」金多恩。'),
            ("등기부의 '김다은' 세 글자를 짚는다.", '點著登記簿上金多恩「Kim Daeun」的三個字。'),
            ("등기부의 '김다은' 세 글자를 짚는다.", '點著登記簿上「Kim Daeun」金多恩的三個字。'),
            ("등기부의 '김다은' 세 글자를 짚는다.", '點著登記簿上「Kim Daeun」金多恩的三個韓文字。'),
            ("등기부의 '김다은' 세 글자를 짚는다.", '點著登記簿上金多恩「Kim Daeun」的三個韓文字。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_year_four_observed_noun_counts(self):
        for source, target in (
            ('세 약속을 넣으면 셋을 망칠 수 있었다.', '放進三個約定，可能會把三個都搞砸。'),
            ('세 기록을 놓았다.', '放好三份紀錄。'),
            ('두 약속도 남았다.', '兩個約定也留下了。'),
            ('두 빈칸을 보았다.', '看了兩個空格。'),
            ('세 알림을 두었다. 나머지 둘에는 시각이 붙었다.', '放好三則通知。另外兩個標上時間。'),
            ('세 창구였다.', '是三個窗口。'),
            ('놓친 두 시각이 남았다.', '錯過的兩個時間留了下來。'),
            ('약속 한 곳. 두 곳에는 날짜가 있었다.', '約定的一處。兩處有日期。'),
            ('가족 쪽 두 자리는 지켰지만.', '家人那邊的兩處守住了。'),
            ('한 줄씩 맞췄다.', '逐行對齊。'),
            ('착한 한 달로 만들지 않았다.', '沒有拼成一個做了好事的月份。'),
            ('둘 다 사실의 절반이었다.', '兩邊都只是事實的一半。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_year_four_noun_count_mutations(self):
        for source, good in (
            ('세 약속을 넣었다.', '三個約定'), ('세 기록을 놓았다.', '三份紀錄'),
            ('두 빈칸을 보았다.', '兩個空格'), ('세 알림을 두었다.', '三則通知'),
            ('세 창구였다.', '三個窗口'), ('놓친 두 시각이 남았다.', '兩個時間'),
            ('두 곳에는 날짜가 있었다.', '兩處'), ('가족 쪽 두 자리는 지켰지만.', '兩處'),
            ('착한 한 달로 만들지 않았다.', '一個做了好事的月份'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            for target in (good.replace('三','四').replace('兩','四').replace('一','四'), '負'+good, '十 '+good):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))
        for source, targets in (
            ('세 약속을 넣었다.', ('三個人', '三個小時')),
            ('두 시각이 남았다.', ('兩點', '兩個小時')),
            ('한 줄씩 맞췄다.', ('逐字對齊', '兩行對齊', '負逐行對齊')),
            ('둘 다 사실의 절반이었다.', ('三邊都是', '負兩邊都是')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            for target in targets:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))

    def test_year_four_observed_counter_contexts(self):
        for source, target in (
            ('통화 한 번으로 의료 경과가 바뀌지 않았다.', '一次通話沒有改變醫療狀況。'),
            ('두 시각과 기록을 놓았다.', '放好兩個時間與紀錄。'),
            ('두 기록을 놓았다.', '放好兩份獨自一人的紀錄。'),
            ('두 연락창에는 시각이 남았다.', '兩個聯絡視窗留下時間。'),
            ('놓친 두 대상 중 골랐다.', '從錯過的兩個對象中選。'),
            ('이 밤의 세 마감 중 골랐다.', '從今晚三個期限中選。'),
            ('세 발행처와 시각을 적었다.', '記下三個發出通知的單位與時間。'),
            ('확인받을 한 자리만 다시 열린다.', '得到確認的一處重新開放。'),
            ('놓친 두 자리의 비용', '錯過兩處的代價'),
            ('두 줄을 긋고 이름을 남겼다.', '畫了兩道線，留下名字。'),
            ('한 줄씩 확인했다.', '逐行確認。'),
            ('두 분이 만난 것으로 만들지 않겠다.', '不會說成兩位已經見過面。'),
            ('전송되지 않은 한 글자만 기다렸다.', '只等著一個還沒傳出的字。'),
            ('빈 의자를 한 번 본 뒤.', '看了一眼空椅子。'),
            ('{name}을 한 번 본 뒤.', '看了{name}一眼。'),
            ('약속 한 곳에는 완료 시각이 있었고 두 곳에는 날짜가 있었다.', '一個約定有完成時間，另外兩個有日期。'),
            ('두 곳을 다시 열 수 있다고 쓰지 않았다.', '沒有寫兩邊都能重新打開。'),
            ('병동 통화. 다른 두 곳을 취소했다는 것.', '病房通話。取消另外兩邊的事。'),
            ('세 알림을 두었다. 나머지 둘에는 시각이 붙었다.', '放好三則通知。另外兩項有時間。'),
            ('둘 다 할 수는 없었다.', '兩件事無法都做。'),
            ('둘 다 하지 못하면 그 연락을 미룬다.', '若兩者都做不到，就延後聯絡。'),
            ('병동이 남긴 세 갈래', '病房留下的三個方向'),
            ('셋 다 통화를 끊지 않고 할 수 있었다.', '三樣都能在不掛電話的情況下做。'),
            ('손가락을 접었다. 하나, 둘, 셋.', '屈起手指。一、二、三。'),
            ('예약은 여섯 시였고.', '預約是六點。'),
            ('번호를 눌렀다. 신호가 두 번 갔다.', '按下號碼。回鈴音響了兩聲。'),
            ('침대 난간이 한 번 울렸다.', '床邊護欄響了一聲。'),
            ('구원자는 아니었다.', '並不是救世主。'),
            ('만나기로 한 약속이었다.', '是約好要見面的約定。'),
            ('누구에게도 한 약속이 아니었다.', '還不是向任何人許下的約定。'),
            ('사람에게 한 약속은 지키지 못했다.', '向人許下的承諾，沒能實現。'),
            ('연락하기로 한 시각 하나였다.', '是說好要聯絡的時間。'),
            ('감춰 둘 수 있었던 체면이 사라졌다.', '本可以藏著的面子消失了。'),
            ('만나겠다고 한 사람의 날짜였다.', '是答應見面之人的日期。'),
            ('한 줄씩 적었다.', '逐行寫下。'),
            ('보호자 1순위 연락처였다.', '是第一順位照護者聯絡欄。'),
            ('결과 없는 두 시각만 남았다.', '只留下兩個沒有結果的時間。'),
            ('둘 다 지울 수 없는 사실로 남았다.', '兩者都留下無法抹去的事實。'),
            ('안도와 아쉬움. 둘 중 하나를 지우지 않은 채 저장했다.', '安心與遺憾。沒有抹掉任何一邊，就儲存了。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_year_four_counter_context_mutations(self):
        for source, good in (
            ('통화 한 번으로 의료 경과가 바뀌지 않았다.', '一通電話'),
            ('두 연락창에는 시각이 남았다.', '兩個聯絡視窗'),
            ('놓친 두 대상 중 골랐다.', '兩個對象'),
            ('이 밤의 세 마감 중 골랐다.', '三個期限'),
            ('세 발행처와 시각을 적었다.', '三個發出通知的單位'),
            ('확인받을 한 자리만 다시 열린다.', '一處'),
            ('놓친 두 자리의 비용', '兩處'),
            ('두 줄을 긋고 이름을 남겼다.', '兩道線'),
            ('두 분이 만난 것으로 만들지 않겠다.', '兩位'),
            ('전송되지 않은 한 글자만 기다렸다.', '一個還沒傳出的字'),
            ('둘 다 할 수는 없었다.', '兩件事'),
            ('병동이 남긴 세 갈래', '三個方向'),
            ('셋 다 통화를 끊지 않고 할 수 있었다.', '三樣'),
            ('침대 난간이 한 번 울렸다.', '一聲'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            for bad in (good.replace('一','四').replace('兩','四').replace('三','四'), '負'+good, '十 '+good):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))
        for source, bad in (
            ('두 분이 만난 것으로 만들지 않겠다.', '兩分鐘'),
            ('두 분이 지났다.', '兩位'),
            ('두 연락창을 열었다.', '兩個人'),
            ('세 발행처를 적었다.', '三個小時'),
            ('전송되지 않은 한 글자만 기다렸다.', '一個字'),
            ('한 글자만 보냈다.', '一個還沒傳出的字'),
            ('{name}을 한 번 본 뒤.', '{name}有一眼'),
            ('번호를 눌렀다. 신호가 두 번 갔다.', '按下號碼。響了三聲。'),
            ('한 번 걸었다.', '響了一聲。'),
            ('손가락을 접었다. 하나, 둘, 셋.', '屈起手指。一、四、三。'),
            ('손가락을 접었다. 하나, 둘, 셋.', '屈起手指。一、二、四。'),
            ('예약은 여섯 시였고.', '預約是六個小時。'),
            ('예약은 여섯 시였고.', '預約是七點。'),
            ('구원자는 아니었다.', '不是9韓元。'),
            ('9원이었다.', '是救世主。'),
            ('구 원이었다.', '是救世主。'),
            ('한 줄씩 적었다.', '逐字寫下。'),
            ('보호자 1순위 연락처였다.', '是第二順位照護者聯絡欄。'),
            ('보호자 1순위 연락처였다.', '是負第一順位照護者聯絡欄。'),
            ('보호자 1순위 연락처였다.', '是第一個小時。'),
            ('결과 없는 두 시각만 남았다.', '只留下三個沒有結果的時間。'),
            ('둘 다 지울 수 없는 사실로 남았다.', '三者都留下無法抹去的事實。'),
            ('안도와 아쉬움. 둘 중 하나를 지우지 않은 채 저장했다.', '安心與遺憾。三邊都沒有抹掉，就儲存了。'),
            ('둘이 있었다.', '沒有抹掉任何一邊。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_midgame.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_year_four_mixed_hundred_man_won_and_prepared_lender(self):
        for locale, money, lender in (('ja','500万ウォン',None),('zh-CN','500万韩元','汉江第一金融'),('zh-TW','500萬韓元','漢江第一金融')):
            leaf = tool.Leaf('events','example','content/events/arc_drama.json',('title',),'5백만원','event_standard')
            self.assertEqual(tool.translation_errors(leaf,locale,money), [])
            for bad in (money.replace('500','5'),money.replace('500','600'),'-'+money,'1500'+money[3:],money.replace('ウォン','ドル').replace('韩元','日元').replace('韓元','日圓')):
                self.assertTrue(tool.translation_errors(leaf,locale,bad),(locale,bad))
            if lender:
                leaf = tool.Leaf('events','example','content/events/arc_chapter_themes.json',('title',),'한강제일금융','event_standard')
                self.assertEqual(tool.translation_errors(leaf,locale,lender), [])
                for bad in (lender.replace('第一','第二'),lender.replace('金融','銀行'),lender+' '+ 'Bank'):
                    self.assertTrue(tool.translation_errors(leaf,locale,bad),(locale,bad))

    def test_year_four_independent_review_unit_substitution_mutations(self):
        for source, good, reference in (
            ('세 알림이 울렸다. 나머지 둘에는 답하지 않았다.', '三則通知響起，另外兩個沒有回覆。', '兩個'),
            ('가족 쪽 두 자리는 지켰지만 거래를 놓쳤다.', '保住了家人這邊的兩個，卻錯過交易。', '兩個'),
            ('둘 다 할 수는 없었다.', '兩個都做不到。', '兩個'),
            ('셋 다 통화를 끊지 않고 할 수 있었다.', '三個都能在不掛電話時做。', '三個'),
        ):
            leaf = tool.Leaf('events','example','content/events/arc_chapter_themes.json',('description',),source,'event_standard')
            self.assertEqual(tool.translation_errors(leaf,'zh-TW',good), [])
            for unit in ('人','小時',' 小時','月','韓元','公里'):
                bad = good.replace(reference,reference+unit)
                self.assertTrue(tool.translation_errors(leaf,'zh-TW',bad),(source,bad))

    def test_year_four_money_prefix_and_sentence_boundary(self):
        for locale, sentence, amount in (
            ('ja','分かっていた。\n\n500万ウォンを稼いだ。','500万ウォン'),
            ('zh-CN','知道。\n\n赚下500万韩元。','500万韩元'),
            ('zh-TW','知道。\n\n賺下500萬韓元。','500萬韓元'),
        ):
            leaf = tool.Leaf('events','example','content/events/arc_drama.json',('description',),'알고 있었다.\n\n5백만원을 벌었다.','event_standard')
            self.assertEqual(tool.translation_errors(leaf,locale,sentence), [])
            for prefix in ('負','負 ','− ','千 ','十 ','10. '):
                bad = sentence.replace(amount,prefix+amount)
                self.assertTrue(tool.translation_errors(leaf,locale,bad),(locale,bad))

    def test_year_four_negative_money_and_ordering_verb(self):
        for source, good, bad in (
            ('마이너스 1억 아래였다.', '低於負1億韓元。', '低於1億韓元。'),
            ('마이너스 2억 아래였다.', '低於負 2億韓元。', '低於2億韓元。'),
            ('1억 아래였다.', '低於1億韓元。', '低於負1億韓元。'),
            ('-5백만원이었다.', '是−500萬韓元。', '是500萬韓元。'),
            ('그녀는 6,500원짜리 라떼를.', '她點6,500韓元的拿鐵。', '她點65,000韓元的拿鐵。'),
            ('그녀는 6,500원짜리 라떼를.', '她點6,500韓元的拿鐵。', '她十點6,500韓元的拿鐵。'),
            ('6,500원을 썼다.', '用了6,500韓元。', '十點6,500韓元。'),
        ):
            leaf = tool.Leaf('events','example','content/events/arc_drama.json',('description',),source,'event_standard')
            self.assertEqual(tool.translation_errors(leaf,'zh-TW',good), [],(source,good))
            self.assertTrue(tool.translation_errors(leaf,'zh-TW',bad),(source,bad))

    def test_year_four_source_bound_minseo_name_and_facts(self):
        for source, target in (
            ('이민서가 웃었다.', 'Lee Minseo 笑了。'),
            ('민서가 말했다.', 'Minseo 說了。'),
            ('이민서', 'Lee Minseo'),
            ('민서', 'Minseo'),
            ('이민서입니다.', '我是 Lee Minseo。'),
            ('두 사실을 같은 줄에 놓았다.', '把兩個事實放在同一行。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_new_characters.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_year_four_name_and_fact_mutations(self):
        for source, targets in (
            ('이민서가 웃었다.', ('Minseo 笑了。', 'Lee Minseox 笑了。', 'XLee Minseo 笑了。', 'Lee MinseoETF 笑了。', 'Lee Minseo（李敏書）笑了。', '李敏書笑了。')),
            ('민서가 말했다.', ('Lee Minseo 說了。', 'Minseox 說了。')),
            ('이민서류를 봤다.', ('看了 Lee Minseo。',)),
            ('민서류를 봤다.', ('看了 Minseo。',)),
            ('그가 웃었다.', ('Lee Minseo 笑了。', 'Minseo 笑了。')),
            ('두 사실을 같은 줄에 놓았다.', ('三個事實。', '負兩個事實。', '十 兩個事實。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_new_characters.json', ('description',), source, 'event_standard')
            for target in targets:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))

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
