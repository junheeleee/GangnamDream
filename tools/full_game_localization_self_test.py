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

    def test_social_japanese_native_fee_night_week_contexts(self):
        for source, good, replacements in (
            ('1인 128,000원.', '一人128,000ウォン。',
             [('一人', '二人'), ('一人', '十一人'), ('一人', '-一人'),
              ('128,000', '128,001'), ('ウォン', '円'), ('ウォン', 'ウォン円'),
              ('一人', '一泊'), ('一人', '')]),
            ('1박 35만원.', '一泊35万ウォン。',
             [('一泊', '二泊'), ('一泊', '十一泊'), ('一泊', '-一泊'),
              ('35万', '35'), ('ウォン', '円'), ('ウォン', 'ウォン円'),
              ('一泊', '一時間'), ('一泊', '')]),
            ('10월 첫째 주.', '10月の第1週。',
             [('第1', '第2'), ('第1', '第11'), ('第1', '第-1'),
              ('10月', '11月'), ('第1週', '1日'), ('第1週', '第1年'),
              ('10月', '-10月'), ('第1週', '')]),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/social_independence.json',
                             ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
            for before, after in replacements:
                wrong = good.replace(before, after)
                self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)
            self.assertEqual(tool.translation_errors(leaf, 'ja', good.replace('一', '1')), [])
            moved = tool.Leaf('events', 'example', 'content/events/social_independence.json',
                             ('description',), source + '\n다음 문장.', 'event_standard')
            self.assertTrue(tool.translation_errors(moved, 'ja', '次の文。\n' + good))
            self.assertTrue(tool.translation_errors(leaf, 'ja', good + good))

    def test_social_japanese_native_contexts_reject_observed_qualifiers(self):
        for source, good, suffixes in (
            ('1인 128,000원.', '一人128,000ウォン', ('ではない', '未満')),
            ('1박 35만원.', '一泊35万ウォン', ('（人民元）', 'ではない', '以上')),
            ('10월 첫째 주.', '10月の第1週', ('ではない', 'より後')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/social_independence.json',
                             ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good + '。'), [])
            for suffix in suffixes:
                self.assertTrue(tool.translation_errors(leaf, 'ja', good + suffix + '。'))
                self.assertTrue(tool.translation_errors(leaf, 'ja', good + suffix + '。' + good + '。'))

    def test_social_japanese_compound_man_thousand_won_amounts(self):
        for source, good, wrong_number in (
            ('정중히 거절했다. 조용민 대리가 "다음 기회에요" 했다. 12만 8천원이 그냥 밥값이 됐다. 투자 대비 수익률을 따지면 씁쓸하다.', '丁重に断った。チョ・ヨンミン代理が「また次の機会に」と言った。12万8千ウォンは、ただの食事代になった。投資に対するリターンを考えると、ほろ苦い。', '12万9千'),
            ('선별했다. 진짜 친한 한 명에겐 직접 갔다. 나머지 두 명엔 카카오뱅크로 각 2만 5천원. 어딘가 찜찜하지만 통장도 어딘가 덜 찜찜하다.', '選んだ。本当に親しい一人の式には直接行った。残りの二人には、カカオバンクでそれぞれ2万5千ウォン。どこか後ろめたいけれど、口座のほうはそのぶん少し気が楽だ。', '2万6千'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/social_independence.json',
                             ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
            amount = '12万8千' if '12万8千' in good else '2万5千'
            for wrong in (good.replace(amount, wrong_number), good.replace(amount, '-' + amount),
                          good.replace('ウォン', '円'), good.replace('ウォン', 'ウォン円'),
                          good.replace('千ウォン', '百ウォン'), good + good):
                self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)
            changed = tool.Leaf('events', 'example', 'content/events/social_independence.json',
                                ('description',), source.replace('8천', '9천').replace('5천', '6천'),
                                'event_standard')
            self.assertTrue(tool.translation_errors(changed, 'ja', good))

    def test_callback_japanese_implicit_equity_value_keeps_won_and_context(self):
        for source, good in (('합류한 지 1년이 됐다.\n몸은 많이 소모됐다. 근데 서비스는 커졌다.\n공동창업자가 불렀다. "민준아, 우리 A라운드 들어왔어. 네 지분 가치 지금 1억 2천이야."', '加わってから1年が経った。\n体はずいぶんすり減った。それでもサービスは成長した。\n共同創業者に呼ばれた。「ミンジュン、シリーズAの資金が入った。今、お前の持分価値は1億2000万ウォンだ」'), ('"더 키우자. 엑싯은 아직 이르다."\n월급을 올렸다. 지분도 지켰다.\n1억 2천이 이제 시작이다.', '「もっと大きくしよう。エグジットにはまだ早い」\n給料を上げた。持分も守った。\n1億2000万ウォンは、まだ始まりだ。')):
            leaf = tool.Leaf('events', 'callback_startup_grind_result',
                             'content/events/callback_events_2.json',
                             ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
            for wrong in (good.replace('1億2000万', '1億3000万'),
                          good.replace('1億2000万', '1億2000'),
                          good.replace('1億2000万', '-1億2000万'),
                          good.replace('ウォン', '円'),
                          good.replace('ウォン', 'ウォン円'),
                          good + good):
                self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)
            for suffix in ('/月', '/週', '/分', '程度', '（年）', '以上', '未満', 'ではない'):
                self.assertTrue(tool.translation_errors(
                    leaf, 'ja', good.replace('ウォン', 'ウォン' + suffix)), suffix)
            changed = tool.Leaf('events', 'callback_startup_grind_result',
                                'content/events/callback_events_2.json',
                                ('description',), source.replace('1억 2천', '1억 3천'),
                                'event_standard')
            self.assertTrue(tool.translation_errors(changed, 'ja', good))
            lines = good.split('\n')
            lines[0], lines[-1] = lines[-1], lines[0]
            self.assertTrue(tool.translation_errors(leaf, 'ja', '\n'.join(lines)))
        unrelated = tool.Leaf('events', 'example', 'content/events/callback_events_2.json',
                              ('description',), '1억 2천 걸음이다.', 'event_standard')
        self.assertTrue(tool.translation_errors(unrelated, 'ja', '1億2000万歩だ。'))

    def test_callback_japanese_remaining_year_is_less_than_one_before_38(self):
        source = "38세까지 1년이 채 남지 않았다. 공격적으로 가기로 했다.\n오늘 정보가 하나 들어왔다. 안면 있는 브로커.\n\"지금이 마지막 창이야. 잡으면 두 배. 아니면 끝.\"\n강남이 이 결정 하나에 걸려 있다."
        good = "38歳まで、もう一年もない。攻めていくと決めた。\n今日、情報が一つ入った。顔見知りのブローカーからだ。\n「今が最後のチャンスだ。つかめば二倍。逃せば終わりだ」\nカンナムに届くかどうかが、この決断一つにかかっている。"
        leaf = tool.Leaf('events', 'callback_final_sprint_aggressive_all_in',
                         'content/events/callback_events_4.json', ('description',),
                         source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        self.assertEqual(tool.translation_errors(leaf, 'ja', good.replace('一年', '1年')), [])
        for before, after in (('一年', '二年'), ('一年', '十一年'),
                              ('一年', '-一年'), ('一年', '+一年'),
                              ('一年', '一日'), ('一年', '一か月'),
                              ('38歳', '39歳'), ('38歳', '-38歳'),
                              ('年もない', '年以上ある'), ('年もない', '年ある'),
                              ('38歳', '138歳'), ('38歳', '38年')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', good.replace(before, after)), after)
        for extra in ('一年後。', '二歳。', '一時間。', '一ヶ月後。', '一週間後。', '一秒後。'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', good + extra), extra)
        lines = good.split('\n')
        lines[0], lines[1] = lines[1], lines[0]
        self.assertTrue(tool.translation_errors(leaf, 'ja', '\n'.join(lines)))
        for changed_source in (source.replace('1년', '2년'), source.replace('38세', '39세'),
                               source.replace('1년', '1개월'),
                               source.replace('채 남지 않았다', '넘게 남았다')):
            changed = tool.Leaf('events', leaf.owner, leaf.source_path, leaf.path,
                                changed_source, 'event_standard')
            self.assertTrue(tool.translation_errors(changed, 'ja', good), changed_source)

    def test_callback_japanese_third_generation_is_not_age(self):
        leaf = tool.Leaf('events', 'callback_chaebol_elevator_response',
                         'content/events/callback_events_5.json', ('title',),
                         '재벌 3세의 연락', 'event_standard')
        good = '財閥三世からの連絡'
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        self.assertEqual(tool.translation_errors(leaf, 'ja', good.replace('三世', '3世')), [])
        for wrong in ('財閥二世からの連絡', '財閥十三世からの連絡', '財閥-三世からの連絡',
                      '財閥+三世からの連絡', '財閥三歳からの連絡', '財閥3歳からの連絡',
                      '財閥三世からの連絡。四世も', '財閥三世からの連絡\n',
                      '財閥3世ではない人からの連絡', '財閥からの連絡'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)
        for changed_source in ('재벌 4세의 연락', '3세 아이의 연락'):
            changed = tool.Leaf('events', leaf.owner, leaf.source_path, leaf.path,
                                changed_source, 'event_standard')
            self.assertTrue(tool.translation_errors(changed, 'ja', good), changed_source)

    def test_creator_japanese_news_age_group_is_not_calendar_year(self):
        source = '포털 뉴스에 링크가 올라왔다.\n"2030 공감 유발 콘텐츠로 화제"'
        good = 'ポータルサイトのニュースにリンクが載った。\n「20・30代の共感を呼ぶコンテンツとして話題」'
        leaf = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        for wrong in (good.replace('30', '40'), good.replace('20・30代', '2030年'),
                      good.replace('20・30代', '-20・30代'), good.replace('30代', '30年'),
                      good.replace('20・30代の共感', '共感') + '20・30代の共感。',
                      good + '四十代も。', good.replace('20・30代', '120・30代'),
                      good.replace('「20・30代の共感を呼ぶコンテンツとして話題」', '「共感を呼ぶコンテンツとして話題」「20・30代の共感」')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)
        year = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('description',), source.replace('2030 ', '2030년 '), 'event_standard')
        self.assertTrue(tool.translation_errors(year, 'ja', good))

    def test_drama_japanese_implicit_apartment_price_keeps_full_won_value(self):
        source = '분양가 6억 8천. 대출 없이는 불가능한 금액이다.'
        good = '分譲価格は6億8000万ウォン。ローンなしでは手の届かない金額だ。'
        leaf = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        for wrong in (good.replace('8000', '800'), good.replace('8000万', '8000'),
                      good.replace('ウォン', '円'), good.replace('ウォン', 'ドル'),
                      good.replace('6億', '-6億'), good.replace('6億', '16億'),
                      good.replace('ウォン', 'ウォン円'), good.replace('ウォン', 'ウォン（月）'),
                      good.replace('6億8000万ウォン', '月額六億八千万ウォン。分譲価格は6億8000万ウォン')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)

    def test_creator_japanese_lost_subscribers_keep_unit_sign_and_owner(self):
        source = '구독자 5천 명이 빠졌지만 악플러들이 다른 타깃으로 갔다.'
        good = '登録者は5000人減ったが、中傷する人たちは別の標的へ移った。'
        leaf = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('description',), source, 'event_standard')
        for target in (good, good.replace('5000', '5,000')):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [])
        for wrong in (good.replace('5000', '500'), good.replace('5000', '-5000'),
                      good.replace('5000', '15000'), good.replace('5000人', '5000ウォン'),
                      good.replace('減ったが', '増えたが'), good.replace('登録者は', '視聴者は'),
                      good.replace('5000人', '') + '5000人。', good + '登録者は5000人減ったが。',
                      good.replace('登録者は5000人減ったが', '登録者は五千人増えた。登録者は5000人減ったが'),
                      good.replace('登録者は5000人減ったが', '視聴者は五千人減った。登録者は5000人減ったが')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)

    def test_drama_japanese_young_adult_groups_cannot_borrow_other_paragraphs(self):
        source = "'2030 청년 자산 형성 특집' 기사를 준비 중인 기자가 연락했다.\n\n'서울에서 혼자 자립한 2030 청년 이야기를 담고 싶어요.'\n\n노출이 되면 평판이 올라가지만, 사생활이 공개된다.\n거절하면 조용하게 살 수 있다."
        good = '「20・30代の若者の資産形成特集」の記事を準備している記者から、連絡が来た。\n\n「ソウルで一人で自立した、20・30代の若者の話を取り上げたいんです」\n\n人の目に触れれば評判は上がるが、私生活が公になる。\n断れば、静かに暮らせる。'
        leaf = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        removed = good.replace('20・30代の若者', '若者', 1)
        for wrong in (removed + '20・30代の若者。',
                      removed.replace('若者の話', '若者の話と20・30代の若者の話'),
                      good.replace('20・30代の若者の話', '若者の話') + '20・30代の若者。'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)

    def test_drama_japanese_second_generation_is_not_age(self):
        leaf = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('title',), '재벌 2세와의 접촉', 'event_standard')
        for target in ('財閥二世との接触', '財閥2世との接触'):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [])
        for wrong in ('財閥三世との接触', '財閥十二世との接触', '財閥十 二世との接触',
                      '財閥二歳との接触', '財閥2歳との接触', '財閥-2世との接触',
                      '財閥二世との接触、さらに三世との接触'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)

    def test_drama_japanese_young_adult_groups_keep_both_mentions(self):
        source = '2030 청년들의 삶. "2030 청년의 현실을 조명하려고요."'
        good = '20・30代の若者たちの暮らし。「20・30代の若者の現実を照らしたくて」'
        leaf = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                         ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        for wrong in (good.replace('30', '40', 1), good.replace('30代', '30年', 1),
                      good.replace('20・30代', '2030年', 1), good.replace('20・30代', '若者', 1),
                      good.replace('20・30代', '120・30代', 1), good.replace('20・30代', '-20・30代', 1),
                      good.replace('20・30代', '十 20・30代', 1), good + '四十代の若者も。',
                      good + '20・30代の若者も。'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', wrong), wrong)
        other = tool.Leaf('events', 'example', 'content/events/drama_events.json',
                          ('description',), '2030년 청년의 삶.', 'event_standard')
        self.assertTrue(tool.translation_errors(other, 'ja', '20・30代の若者の暮らし。'))

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

    def test_life_japanese_thousand_won_fee_preserves_value_and_owner(self):
        source = '치킨 2만 원에 배달비 4천 원 — 컵라면은 1,200원.'
        good = 'チキン2万ウォンに配達料4千ウォン――カップ麺は1,200ウォン。'
        leaf = tool.Leaf('events', 'example', 'content/events/life_events2.json', ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        for bad in (
            good.replace('4千', '4百'), good.replace('4千', '4万'),
            good.replace('4千ウォン', '4千円'), good.replace('4千ウォン', '4千ウォン円'),
            good.replace('4千', '-4千'), good.replace('4千', '+4千'),
            good.replace('4千', '−4千'), good.replace('4千', '負4千'),
            good.replace('4千', '十 4千'), good + '4千ウォン。',
            good.replace('2万ウォンに配達料4千', '4千ウォンに配達料2万'),
            good.replace('1,200', '1,300'),
        ):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        for source, good, bad in (
            ('-4천 원', '-4千ウォン', '4千ウォン'),
            ('+4천 원', '+4千ウォン', '4千ウォン'),
            ('4천 원과 3천 원', '4千ウォンと3千ウォン', '3千ウォンと4千ウォン'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events2.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], source)
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)

    def test_life_japanese_source_bound_calendar_and_person_fee(self):
        source = '다음 달 셋째 주 토요일. 1인 5만 원'
        leaf = tool.Leaf('events', 'example', 'content/events/life_events2.json', ('description',), source, 'event_standard')
        good = '来月の第3週の土曜日。一人5万ウォン'
        for target in (good, good.replace('第3', '第三'), good.replace('一人', '1人'),
                       good.replace('一人', '一人当たり'), good.replace('の', '')):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], target)
        for bad in (
            good.replace('第3週の土曜日', '第3土曜日'), good.replace('第3', '第4'),
            good.replace('第3', '第十三'), good.replace('第3', '第−3'),
            good.replace('土曜日', '日曜日'), good.replace('来月', '今月'),
            good.replace('来月', '再来月'), good.replace('来月', '再 来月'),
            good.replace('来月の第3', '再来月の第三'),
            good.replace('週', '日'), good + '。来月の第3週の土曜日',
            good.replace('一人', '二人'), good.replace('一人', '十一人'),
            good.replace('一人', '十 一人'), good.replace('一人', '負一人'),
            good.replace('一人', '+一人'), good.replace('一人', '−一人'),
            good.replace('一人', ''), good.replace('一人', '一日'),
            good.replace('5万', '6万'), good.replace('5万', '+5万'),
            good.replace('ウォン', '円'), good.replace('ウォン', 'ウォン円'),
            good + '、一人5万ウォン',
        ):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        for absent_source in ('다음 달 토요일. 1인 5만 원', '다음 달 셋째 주 토요일. 5만 원',
                              '다음 달 셋째 주 토요일. 11인 5만 원', '다음 달 셋째 주 토요일. -1인 5만 원'):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events2.json', ('description',), absent_source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'ja', good), absent_source)

    def test_life_japanese_grouped_and_native_won(self):
        for source, good in (
            ('8천 원', '8,000ウォン'), ('오천 원짜리라도', '5,000ウォンでも'),
            ('8천 원', '8,000ウォン（税込）'),
            ('12,000원', '1万2,000ウォン'), ('18,000원', '1万8,000ウォン'),
            ('-12,000원', '-1万2,000ウォン'), ('+12,000원', '+1万2,000ウォン'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], (source, good))
            for bad in (good.replace('ウォン', '円'), good.replace('ウォン', 'ウォン円'),
                        good.replace('000', '001'), good + '、' + good,
                        '負' + good, '十 ' + good):
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))
        for source, bad in (
            ('오천 원', '5,000ドル'), ('오천 원', '+5,000ウォン'),
            ('오천 원', '−5,000ウォン'), ('오천 원', '5,000万ウォン'),
            ('오천 원', '5,000ウォン%'), ('오천 원', '5,000ウォン ％'),
            ('오천 원', '5,000ウォン万'), ('오천 원', '5,000ウォン 倍'),
            ('8천 원', '8,000ウォン（円）'), ('8천 원', '8,000ウォン ( 円 )'),
            ('오천 원', '5,000ウォン（ドル）'), ('12,000원', '1万2,000ウォン(元)'),
            ('12,000원', '1万3,000ウォン'), ('12,000원', '2万1,000ウォン'),
            ('-12,000원', '1万2,000ウォン'), ('+12,000원', '1万2,000ウォン'),
            ('12,000원. 8천 원.', '8,000ウォン。1万2,000ウォン。'),
            ('18,000원. 7일.', '7日。1万8,000ウォン。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))

    def test_life_japanese_native_clock_and_elapsed_time(self):
        for source, good, number, native, bads in (
            ('새벽 두 시. 집에서 두 블록. 30분 남았다.',
             '午前2時。家から二ブロック。あと30分。', '2', '二',
             ('午後2時。家から二ブロック。あと30分。', '午前3時。家から二ブロック。あと30分。',
              '午前2時間。家から二ブロック。あと30分。', '午前二十時。家から二ブロック。あと30分。')),
            ('밤 열 시에 폰을 끄고 책을 읽었다. 10분. 30분.',
             '夜10時にスマホを切り、本を読んだ。10分。30分。', '10', '十',
             ('午前10時にスマホを切り、本を読んだ。10分。30分。',
              '夜11時にスマホを切り、本を読んだ。10分。30分。',
              '夜10時間にスマホを切り、本を読んだ。10分。30分。')),
            ('버텼다. 두 시간 후에 더 심해졌다.',
             '耐えた。2時間後には、もっとひどくなった。', '2', '二',
             ('耐えた。2時には、もっとひどくなった。', '耐えた。2日後には、もっとひどくなった。',
              '耐えた。2時間前には、もっとひどくなった。')),
            ('비는 한 시간 만에 그쳤다.',
             '雨は1時間でやんだ。', '1', '一',
             ('雨は1日でやんだ。', '雨は2時間でやんだ。', '雨は11時間でやんだ。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
            for target in (good, good.replace(number, native, 1)):
                self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], (source, target))
            for bad in bads + (good.replace(number, '-' + number, 1),
                               good.replace(number, '十 ' + number, 1), good + good):
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))

    def test_jeongseon_japanese_intended_month_break(self):
        source = '좀 거리를 두자. 한 달은 안 가기로.'
        good = '少し距離を置こう。1か月は行かないことにする。'
        leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
        for target in (good, good.replace('1', '一')):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], target)
        for bad in (
            good.replace('1か月', '2か月'), good.replace('1か月', '11か月'),
            good.replace('1か月', '1日'), good.replace('1か月', '1年'),
            good.replace('1か月', '-1か月'), good.replace('1か月', '+1か月'),
            good.replace('1か月', '十 一か月'),
            good.replace('行かないことにする', '行かずに過ごした'),
            good.replace('行かないことにする', '行くことにする'),
            good + '1か月。',
        ):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        unrelated = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), '좀 거리를 두자.', 'event_standard')
        self.assertTrue(tool.translation_errors(unrelated, 'ja', good))

    def test_jeongseon_japanese_repeated_month_expectation(self):
        source = '결심했다.\n\n거창한 게 아니었다. 그냥 한 달.\n\n한 달이면 충분히 멀어질 수 있었다.\n그게 얼마나 어려운 일인지는, 아직 몰랐다.'
        good = '決心した。\n\n大げさなことではなかった。ただ、1か月。\n\n1か月あれば、十分に距離を置けるはずだった。\nそれがどれほど難しいことかは、まだ知らなかった。'
        leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
        for target in (good, good.replace('1', '一')):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], target)
        for bad in (
            good.replace('1か月', '2か月', 1), good.replace('1か月', '1日', 1),
            good.replace('1か月あれば', '2か月あれば'),
            good.replace('1か月あれば', '1年あれば'),
            good.replace('1か月あれば', '-1か月あれば'),
            good.replace('1か月あれば', '十 一か月あれば'),
            good.replace('距離を置けるはずだった', '距離を置けた'),
            good.replace('1か月。', '1か月。1か月。', 1),
        ):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)

    def test_work_japanese_exam_countdown(self):
        leaf = tool.Leaf('events', 'selfdev_certification', 'content/events/life_events.json', ('title',), '자격증 시험 D-14', 'event_standard')
        for good in ('資格試験まであと14日', '資格試験まであと十四日', '資格試験 D-14'):
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], good)
        for bad in (
            '資格試験まであと13日', '資格試験まであと15日',
            '資格試験まであと14時間', '資格試験まであと十四分',
            '資格試験から14日', '資格試験は14日前', '資格試験まであと-14日',
            '資格試験まであと+14日', '資格試験まであと十四日以上',
            '資格試験 D-14時間', '資格試験 D-15。14日',
            '資格試験まであと14日。あと14日', '試験なし。14日',
        ):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)

    def test_callback_japanese_native_elapsed_months(self):
        cases = (
            ('카페에서의 일로 생긴 죄책감을 해소했던 게 두 달 전이다.\n오늘 그 사람을 다시 만났다.',
             'カフェでの出来事から生まれた罪悪感を解消したのは2か月前のことだ。\n今日、あの人とまた会った。', '2'),
            ('모든 것을 다 털어놓았던 게 한 달 전이다.\n그 이후의 시간이 — 달랐다.',
             '何もかも打ち明けたのは1か月前のことだ。\nそのあとの時間は――違っていた。', '1'),
            ('부모님과의 관계가 깊어졌던 게 석 달 전이다.\n오늘 어머니께서 전화를 하셨다.\n오래 이야기하셨다.',
             '両親との関係が深まったのは3か月前のことだ。\n今日、母から電話があった。\n長く話してくれた。', '3'),
            ('다은이 응원해준 지 두 달이 지났다.\n그 지지가 오래 남았다.\n오늘 다은에게서 연락이 왔다.',
             'ダウンが応援してくれてから2か月が過ぎた。\nその支えは長く心に残った。\n今日、ダウンから連絡が来た。', '2'),
            ('다은이 거리를 둔 지 두 달.\n그사이 어쩌다 한 번씩은 마주쳤다.\n오늘은 그녀가 먼저 말을 걸었다.',
             'ダウンが距離を置くようになって2か月。\nその間も、たまに顔を合わせることはあった。\n今日は彼女のほうから話しかけてきた。', '2'),
            ('지갑을 돌려줘서 생긴 인연으로 일을 시작한 지 두 달.\n낯선 출발이었다.\n오늘—익숙해졌다는 걸 느꼈다.',
             '財布を返した縁で仕事を始めて2か月。\n慣れない出発だった。\n今日――なじんだと感じた。', '2'),
            ('사회적으로 한 단계 올라선 지 세 달.\n그 자리가 익숙해지기 시작했다.\n오늘—전에는 닿지 않았을 사람이 먼저 연락해왔다.',
             '社会的に一段上がってから3か月。\nその立場になじみ始めていた。\n今日――以前なら手の届かなかった人のほうから連絡が来た。', '3'),
        )
        for source, good, number in cases:
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_16.json',
                             ('description',), source, 'event_standard')
            native = {'1': '一', '2': '二', '3': '三'}[number]
            for unit in ('か月', 'ヶ月', 'カ月'):
                for digit in (number, native):
                    target = good.replace(number + 'か月', digit + unit)
                    self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], (source, target))
            for replacement in ('4か月', '四か月', '12か月', '十二か月', '-'+number+'か月',
                                '+'+number+'か月', '−'+number+'か月', '十 '+native+'か月',
                                number+'日', native+'年', number+'時間', number+'か月以上',
                                number+'か月未満', number+'か月ではない', ''):
                bad = good.replace(number+'か月', replacement)
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))
            for extra in ('一か月。', '二時間。', '三年。', '1か月。'):
                self.assertTrue(tool.translation_errors(leaf, 'ja', good+extra), (source, extra))
            first, rest = good.split('\n', 1)
            self.assertTrue(tool.translation_errors(leaf, 'ja', rest+'\n'+first))
            for bad in (good.replace('前のことだ', '後の予定だ'),
                        good.replace('が過ぎた', '後に会う予定だ'),
                        good.replace('2か月。', '2か月後に会う。')):
                if bad != good:
                    self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
            unrelated = tool.Leaf('events', 'example', 'content/events/callback_events_16.json',
                                  ('description',), source.replace(' 달', ' 년'), 'event_standard')
            self.assertTrue(tool.translation_errors(unrelated, 'ja', good))
            changed = tool.Leaf('events', 'example', 'content/events/callback_events_16.json',
                                ('description',), source.replace(' 달', ' 주'), 'event_standard')
            self.assertTrue(tool.translation_errors(changed, 'ja', good))

    def test_callback_japanese_actual_actions_are_not_past_plans(self):
        cases = (
            ('카페에서의 일로 생긴 죄책감을 해소했던 게 두 달 전이다.\n오늘 그 사람을 다시 만났다.',
             'カフェでの出来事から生まれた罪悪感を解消したのは2か月前のことだ。\n今日、あの人とまた会った。',
             '解消したのは', ('解消する予定を立てたのは', '解消する計画を立てたのは',
                              '解消するつもりになったのは', '解消しなかったのは',
                              '解消できなかったのは', '解消すると決めたのは')),
            ('다은이 거리를 둔 지 두 달.\n그사이 어쩌다 한 번씩은 마주쳤다.\n오늘은 그녀가 먼저 말을 걸었다.',
             'ダウンが距離を置くようになって2か月。\nその間も、たまに顔を合わせることはあった。\n今日は彼女のほうから話しかけてきた。',
             '距離を置くようになって', ('距離を置く予定になって', '距離を置く計画を立ててから',
                                      '距離を置くつもりになって', '距離を置かないようになって',
                                      '距離を置けないようになって', '距離を置くと決めてから')),
        )
        for source, good, action, alternatives in cases:
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_16.json',
                             ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
            for replacement in alternatives:
                bad = good.replace(action, replacement)
                self.assertIn('source-bound callback accomplished-action mismatch',
                              tool.translation_errors(leaf, 'ja', bad), bad)

    def test_callback_japanese_earlier_punctuation_and_past_forms(self):
        source = '지연에게 직접 따졌던 게 한 달 전이다.\n그 이후 지연의 태도가 조금 달라졌다.\n오늘 지연이 먼저 진지한 이야기를 꺼냈다.'
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_10.json',
                         ('description',), source, 'event_standard')
        good = 'ジヨンに直接問いただしたのは、一か月前だった。\nそれ以来、ジヨンの態度が少し変わった。\n今日、ジヨンのほうから真剣な話を切り出した。'
        for punctuation in ('、', ''):
            for ending in ('前だった', '前だ', '前のことだ'):
                target = good.replace('、一', punctuation+'一').replace('前だった', ending)
                self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], target)
                self.assertTrue(tool.translation_errors(leaf, 'ja', target.replace('一か月', '二か月')))
        source2 = '카페에서 훔친 정보로 판에 들어간 지 두 달.\n승패는 이미 계좌에 찍혔다.'
        leaf2 = tool.Leaf('events', 'example', 'content/events/callback_events_2.json',
                          ('description',), source2, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf2, 'ja',
            'カフェで盗んだ情報を使って勝負に出てから、二か月。\n勝ち負けは、すでに口座に刻まれていた。'), [])


    def test_callback_japanese_actual_setback_and_wins_elapsed_months(self):
        for source, good, action in (
            ('그림자 투자에 데이고 두 달이 지났다.\n그때를 떠올리면 아직도 쓸렸다.\n오늘 비슷한 제안이 또 들어왔다.',
             '影の投資で痛手を負ってから2か月が過ぎた。\nあの時を思い出すと、まだひりついた。\n今日、また似たような話が持ち込まれた。', '痛手を負ってから'),
            ('홀덤에서 크게 따고 두 달이 지났다.\n그 감각이 아직 남아 있었다.\n오늘 또 자리가 생겼다는 연락이 왔다.',
             'ホールデムで大勝ちしてから2か月が過ぎた。\nあの感覚が、まだ残っていた。\n今日、また席が空いたと連絡が来た。', '大勝ちしてから'),
            ('경마에서 크게 따고 두 달이 지났다.\n그 돈을 어떻게 했는지가 중요했다.\n오늘 그 돈을 돌아봤다.',
             '競馬で大勝ちしてから2か月が過ぎた。\nあの金をどうしたかが重要だった。\n今日、その金を振り返った。', '大勝ちしてから'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_21.json',
                             ('description',), source, 'event_standard')
            for unit in ('か月', 'ヶ月', 'カ月'):
                for number in ('2', '二'):
                    self.assertEqual(tool.translation_errors(leaf, 'ja',
                        good.replace('2か月', number + unit)), [])
            for bad in (good.replace('2か月', '3か月'), good.replace('2か月', '十二か月'),
                        good.replace('2か月', '-2か月'), good.replace('2か月', '二年'),
                        good.replace('が過ぎた', '後の予定だ'),
                        good.replace(action, '計画を立ててから'),
                        good.replace(action, '実行しなかったのは、'),
                        good + '一か月。'):
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)

    def test_callback_japanese_repeated_app_history_months_keep_both_lines(self):
        source = '도박 앱을 전부 지운 지 두 달.\n처음엔 손이 갔다.\n오늘 두 달을 돌아봤다.'
        good = '賭博アプリをすべて消してから2か月。\n最初は手が伸びた。\n今日、この2か月を振り返った。'
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_20.json',
                         ('description',), source, 'event_standard')
        for target in (good, good.replace('2か月', '二ヶ月')):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [])
        for before, after in (('この2か月', 'この3か月'), ('この2か月', 'この十二か月'),
                              ('この2か月', 'この-2か月'), ('この2か月', 'この二週間'),
                              ('この2か月', 'この'), ('を振り返った', '後を想像した'),
                              ('を振り返った', 'を振り返る予定だ'),
                              ('を振り返った', 'を振り返らなかった')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', good.replace(before, after)))
        first, second, third = good.split('\n')
        for bad in (third+'\n'+second+'\n'+first, good+'一か月。',
                    good.replace('この2か月', 'この期間')+'2か月。'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)

    def test_callback_japanese_observed_duration_comparison_and_title(self):
        cases = (
            ('두 달 동안 손대지 않았다.\n지운 것이 장벽이 됐다.',
             '2か月間、手を出さなかった。\n消したことが壁になった。', '2'),
            ('아직 멀었다.\n하지만 방향이 생긴 것만으로—세 달 전과 달랐다.',
             'まだ遠かった。\nそれでも方向が定まっただけで――3か月前とは違った。', '3'),
            ('창업한 지 두 달', '起業して2か月', '2'),
        )
        for source, good, number in cases:
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_20.json',
                             ('title',) if '\n' not in source else ('choices', 0, 'result_text'),
                             source, 'event_standard')
            for unit in ('か月', 'ヶ月', 'カ月'):
                for digit in (number, {'2': '二', '3': '三'}[number]):
                    self.assertEqual(tool.translation_errors(leaf, 'ja',
                        good.replace(number+'か月', digit+unit)), [])
            for replacement in ('4か月', '四か月', '12か月', '-'+number+'か月',
                                '+'+number+'か月', number+'日', number+'か月以上', ''):
                self.assertTrue(tool.translation_errors(leaf, 'ja',
                    good.replace(number+'か月', replacement)), (source, replacement))
            for extra in ('一か月。', '三時間。', '2か月。'):
                self.assertTrue(tool.translation_errors(leaf, 'ja', good+extra), extra)
            for changed in (source.replace('두 달', '세 달').replace('세 달 전', '두 달 전'),
                            source.replace(' 달', ' 년')):
                changed_leaf = tool.Leaf('events', leaf.owner, leaf.source_path, leaf.path,
                                         changed, 'event_standard')
                self.assertTrue(tool.translation_errors(changed_leaf, 'ja', good), changed)

    def test_callback_japanese_duration_is_not_intent_and_comparison_is_past(self):
        for source, good, before, alternatives in (
            ('두 달 동안 손대지 않았다.\n지운 것이 장벽이 됐다.',
             '2か月間、手を出さなかった。\n消したことが壁になった。',
             '手を出さなかった', ('手を出した', '手を出さない予定だった', '手を出さないつもりだ')),
            ('아직 멀었다.\n하지만 방향이 생긴 것만으로—세 달 전과 달랐다.',
             'まだ遠かった。\nそれでも方向が定まっただけで――3か月前とは違った。',
             '前とは違った', ('後とは違った', '前とは同じだった', '前と違う予定だ')),
            ('창업한 지 두 달', '起業して2か月', '起業して',
             ('起業するまであと', '起業を考えて', '起業の予定から')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_20.json',
                             ('title',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
            for after in alternatives:
                self.assertTrue(tool.translation_errors(leaf, 'ja', good.replace(before, after)), after)


    def test_callback_japanese_observed_past_actions_keep_actor_and_completion(self):
        for source, good in (
            ('그림자 투자에 데이고 두 달이 지났다.', '影の投資で痛手を負ってから2か月が過ぎた。'),
            ('홀덤에서 크게 따고 두 달이 지났다.', 'テキサスホールデムで大勝ちしてから2か月が過ぎた。'),
            ('경마에서 크게 따고 두 달이 지났다.', '競馬で大勝ちしてから2か月が過ぎた。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_21.json',
                             ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
            for bad in ('友人が'+good, '父が'+good, '友人の'+good,
                        good.replace('影の投資', '競馬').replace('ホールデム', 'カジノ').replace('競馬で大勝ち', '株で大勝ち')):
                self.assertIn('source-bound callback actual setback/win mismatch',
                              tool.translation_errors(leaf, 'ja', bad), bad)
        source = '도박 앱을 전부 지운 지 두 달.\n처음엔 손이 갔다.\n오늘 두 달을 돌아봤다.'
        good = '賭博アプリをすべて消してから2か月。\n最初は手が伸びた。\n今日、この2か月を振り返った。'
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_20.json',
                         ('description',), source, 'event_standard')
        for bad in ('友人が'+good, good.replace('すべて', '一部だけ'),
                    good.replace('消してから', '消す計画を立ててから'),
                    good.replace('消してから', '消さずに使い始めてから')):
            self.assertIn('source-bound callback actual app deletion mismatch',
                          tool.translation_errors(leaf, 'ja', bad), bad)

    def test_callback_japanese_witnessed_bare_te_openings_keep_action_and_time(self):
        cases = (
            ("카페에서 공개적으로 망신을 당한 지 두 달.", "カフェで人前で恥をかいて2か月。"),
            ("카페 일을 일찍 그만둔 지 두 달.", "カフェの仕事を早々に辞めて2か月。"),
            ("카페에서 훔친 돈을 도박에 쓴 지 두 달.", "カフェで盗んだ金を賭け事に使って2か月。"),
            ("카페에서 훔친 돈으로 투자한 지 두 달.", "カフェで盗んだ金を投資して2か月。"),
            ("카페 상황을 발판으로 새로운 기회를 연 지 두 달.", "カフェでの状況を足がかりに、新たな機会を切り開いて2か月。"),
            ("카페에서 실수하고 만회하려 한 지 두 달.", "カフェで過ちを犯し、埋め合わせようとして2か月。"),
            ("콘텐츠 하나가 크게 퍼진 지 두 달.", "ひとつのコンテンツが大きく広まって2か月。"),
            ("신용이 손상된 지 세 달.", "信用が傷ついて3か月。"),
            ("신용 문제에서 더 이상 참지 않겠다고 선을 그은 지 두 달.", "信用の問題で、もう我慢しないと一線を引いて2か月。"),
            ("무언가를 포기하고 다은을 선택한 지 두 달.", "何かを諦めて、ダウンを選んで2か月。"),
            ("다은과 곁을 지켜주기로 한 지 두 달.", "ダウンと互いのそばにいると約束して2か月。"),
            ("다은과 끝난 지 두 달.", "ダウンとの関係が終わって2か月。"),
            ("다은을 보내준 지 두 달.", "ダウンを送り出して2か月。"),
            ("다은과 함께하기로 한 지 두 달.", "ダウンと一緒に歩むと決めて2か月。"),
            ("명확하지 않은 경계를 넘어선 지 두 달.", "曖昧な境界を越えて2か月。"),
            ("다들 한다는 분위기에 휩쓸려 투자한 지 두 달.", "みんながやっているという空気に流されて投資して2か月。"),
            ("프리랜서로 독립한 지 두 달.", "フリーランスとして独立して2か月。"),
            ("실력과 성과로 승진한 지 두 달.", "実力と成果で昇進して2か月。"),
            ("자격증을 취득한 지 세 달.", "資格を取得して3か月。"),
            ("재혁에게 이용당했다는 걸 알게 된 지 두 달.", "ジェヒョクに利用されたと知って2か月。"),
            ("재혁과 파트너십을 맺은 지 두 달.", "ジェヒョクとパートナーシップを結んで2か月。"),
            ("재혁의 제안을 거절한 지 두 달.", "ジェヒョクの提案を断って2か月。"),
            ("재혁에게 사기당했다는 게 확정된 지 두 달.", "ジェヒョクにだまされたことが確定して2か月。"),
            ("재혁에게 직접 맞선 지 두 달.", "ジェヒョクに直接立ち向かって2か月。"),
            ("재혁을 완전히 믿고 모든 것을 공유한 지 두 달.", "ジェヒョクを完全に信じ、すべてを共有して2か月。"),
            ("지연이 강남에서 먼저 연락해온 지 두 달.", "ジヨンがカンナムから先に連絡してきて2か月。"),
            ("지연과 함께하기로 한 지 두 달.", "ジヨンと一緒に歩むと決めて2か月。"),
            ("돈을 주고 내부 정보를 산 지 두 달.", "お金を払って内部情報を買って2か月。"),
            ("의심스러운 내부 정보를 신고한 지 두 달.", "不審な内部情報を通報して2か月。"),
            ("정체불명의 USB를 열어본 지 두 달.", "正体不明のUSBの中身を開いて2か月。"),
            ("엘리트 트랙을 선택한 지 세 달.", "エリートのトラックを選んで3か月。"),
            ("퀀트 투자 전문화 트랙을 선택한 지 세 달.", "クオンツ投資の専門化トラックを選んで3か月。"),
            ("인맥 상승 트랙을 선택한 지 세 달.", "人脈で上を目指すトラックを選んで3か月。"),
            ("사회적 기업가 트랙을 선택한 지 세 달.", "社会起業家のトラックを選んで3か月。"),
            ("투기 트랙을 선택한 지 세 달.", "投機のトラックを選んで3か月。"),
            ("테크 창업 트랙을 선택한 지 세 달.", "テック起業のトラックを選んで3か月。"),
            ("아무 연관 없는 낯선 사람을 도운 지 두 달.", "何のつながりもない、見知らぬ人を助けて2か月。"),
            ("반찬가게 알바에서 얻은 정보로 취업 기회를 잡은 지 두 달.", "おかず屋のアルバイトで得た情報から、就職の機会をつかんで2か月。"),
            ("인테리어 현장 관리를 맡은 지 두 달.", "内装工事の現場管理を任されて2か月。"),
            ("고시원 이웃과 가까워진 지 두 달.", "コシウォンの隣人と親しくなって2か月。"),
            ("마지막 단계에서 공격적인 전략을 선택한 지 두 달.", "最後の段階で攻める戦略を選んで2か月。"),
            ("마지막 단계에서 지키는 전략을 선택한 지 두 달.", "最後の段階で守る戦略を選んで2か月。"),
            ("마지막 단계에서 지나온 길을 돌아보기로 한 지 두 달.", "最後の段階で歩んできた道を振り返ろうと決めて2か月。"),
            ("보증 문제를 타협으로 마무리한 지 두 달.", "保証の問題に妥協で区切りをつけて2か月。"),
            ("정보 관련 사건을 정리하고 넘어간 지 두 달.", "情報にまつわる一件に区切りをつけ、先へ進んで2か月。"),
            ("부모 빚을 전부 갚은 지 두 달.", "親の借金をすべて返して2か月。"),
            ("집안 빚을 대신 갚아주기로 한 지 두 달.", "家の借金を代わりに返すことにして2か月。"),
            ("이력서 거짓말을 덮고 계속 쌓아가기로 한 지 두 달.", "履歴書の嘘を覆い隠し、そのまま積み重ねていくことにして2か月。"),
            ("이력서에 토익 점수를 부풀린 지 두 달.", "履歴書のTOEICの点数を水増しして2か月。"),
        )
        for source, good in cases:
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_22.json',
                             ('description',), source, 'event_standard')
            number = '3' if '세 달' in source else '2'
            native = {'2': '二', '3': '三'}[number]
            prefix = good[:-len(number + 'か月。')]
            for unit in ('か月', 'ヶ月', 'カ月'):
                for digit in (number, native):
                    for connector in ('', 'から'):
                        self.assertEqual(tool.translation_errors(leaf, 'ja',
                            prefix + connector + digit + unit + '。'), [], (source, digit, unit))
            for altered in ('4か月', '四か月', '12か月', '十二か月',
                            '-' + number + 'か月', '+' + number + 'か月',
                            '−' + number + 'か月', number + '年', number + '週間',
                            number + 'か月後', number + 'か月以上', ''):
                self.assertTrue(tool.translation_errors(leaf, 'ja',
                    good.replace(number + 'か月', altered)), (source, altered))
            for bad in ('友人が' + good, '父が' + good,
                        '別の仕事をして' + number + 'か月。',
                        prefix + 'いないまま' + number + 'か月。',
                        prefix + 'みようと考えて' + number + 'か月。',
                        '計画を立ててから' + number + 'か月。',
                        good + '一か月。', good + '三時間。'):
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))
            for changed in ('친구가 ' + source, source.replace(' 달', ' 년'),
                            source.replace('두 달', '세 달').replace('세 달', '한 달'),
                            '다른 일을 한 지 두 달.'):
                other = tool.Leaf('events', 'example', leaf.source_path, leaf.path,
                                  changed, 'event_standard')
                self.assertTrue(tool.translation_errors(other, 'ja', good), (changed, good))

    def test_callback_japanese_two_month_follower_pace_keeps_people_and_evaluation(self):
        source = '느리다고 느꼈다.\n하지만 두 달에 100명—이 속도가 나쁜 게 아니었다.'
        good = '遅いと感じた。\nだが、2か月で100人――悪いペースではなかった。'
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_22.json',
                         ('choices', 1, 'result_text'), source, 'event_standard')
        for unit in ('か月', 'ヶ月', 'カ月'):
            for digit in ('2', '二'):
                self.assertEqual(tool.translation_errors(leaf, 'ja',
                    good.replace('2か月', digit + unit)), [])
        for old, new in (('2か月', '3か月'), ('2か月', '十二か月'),
                         ('2か月', '-2か月'), ('2か月', '2年'),
                         ('2か月で', '2か月後に'), ('100人', '101人'),
                         ('100人', '100件'), ('100人', '100万ウォン'),
                         ('で100人', 'でまだ100人ではない'),
                         ('だが、', 'だが、友人は'), ('だが、', 'だが、来月から'),
                         ('ではなかった', 'になればいい')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', good.replace(old, new)), (old, new))
        for bad in (good.replace('遅い', '速い'), '友人は' + good,
                    good + '一か月。', good + '100人。',
                    '\n'.join(reversed(good.split('\n')))):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        for changed in (source.replace('두 달', '세 달'), source.replace('100명', '101명'),
                        source.replace('100명', '100개'), source.replace('나쁜 게 아니었다', '나빴다'),
                        '다른 결과를 확인했다.\n두 달이 지났다.'):
            other = tool.Leaf('events', leaf.owner, leaf.source_path, leaf.path,
                              changed, 'event_standard')
            self.assertTrue(tool.translation_errors(other, 'ja', good), changed)

    def test_callback_japanese_reflective_decision_and_five_year_retrospect(self):
        source = ('마지막 단계에서 지나온 길을 돌아보기로 한 지 두 달.\n'
                  '숫자보다 의미를 생각했다.\n오늘 5년을 돌아봤다.')
        good = ('最後の段階で歩んできた道を振り返ろうと決めて2か月。\n'
                '数字よりも意味を考えた。\n今日、5年を振り返った。')
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_25.json',
                         ('description',), source, 'event_standard')
        for months in ('2か月', '二ヶ月', '2カ月'):
            for years in ('5年', '五年'):
                self.assertEqual(tool.translation_errors(leaf, 'ja',
                    good.replace('2か月', months).replace('5年', years)), [])
        for before, after in (('2か月', '3か月'), ('5年', '6年'), ('5年', '五か月'),
                              ('5年', '-5年'), ('5年', '+5年'), ('5年', '15年'),
                              ('今日、', '明日、'), ('今日、', '今日、父は'),
                              ('振り返った。', '振り返る予定だ。'),
                              ('振り返った。', '振り返らなかった。')):
            self.assertTrue(tool.translation_errors(leaf, 'ja',
                good.replace(before, after)), (before, after))
        for bad in (good + '\n5年を振り返った。',
                    '\n'.join(reversed(good.split('\n'))),
                    good.replace('\n今日、5年を振り返った。', ''),
                    good.replace('2か月', '5か月').replace('5年', '2年')):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        for changed in (source.replace('5년', '6년'), source.replace('5년', '5개월'),
                        source.replace('오늘', '내일'), source.replace('오늘', '오늘 아버지가'),
                        source.replace('돌아봤다.', '돌아보기로 했다.')):
            other = tool.Leaf('events', leaf.owner, leaf.source_path, leaf.path,
                              changed, 'event_standard')
            self.assertTrue(tool.translation_errors(other, 'ja', good), changed)

    def test_callback_japanese_completed_hour_conversation(self):
        source = '한 시간을 이야기했다.\n오래 말씀하시게 된 게 — 관계가 달라졌다는 뜻이었다.'
        good = '1時間、話した。\n長く話してくれるようになったのは――関係が変わったということだった。'
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_17.json',
                         ('choices', 0, 'result_text'), source, 'event_standard')
        for target in (good, good.replace('1時間', '一時間')):
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], target)
        for bad in (
            good.replace('1時間', '2時間'), good.replace('1時間', '二時間'),
            good.replace('1時間', '1時'), good.replace('1時間', '一日'),
            good.replace('1時間', '-1時間'), good.replace('1時間', '+1時間'),
            good.replace('1時間', '−1時間'), good.replace('1時間', '十一時間'),
            good.replace('話した', '話す予定だった'), good.replace('話した', '話さなかった'),
            good.replace('1時間、', ''), good+'一時間。',
            good.replace('1時間', '一時間')+'二時間。',
            '\n'.join(reversed(good.split('\n'))),
        ):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        for changed in (source.replace('한 시간', '두 시간'), source.replace('이야기했다', '이야기하기로 했다')):
            mutated = tool.Leaf('events', 'example', 'content/events/callback_events_17.json',
                                ('choices', 0, 'result_text'), changed, 'event_standard')
            self.assertTrue(tool.translation_errors(mutated, 'ja', good))

    def test_callback_japanese_father_call_duration_roles(self):
        source = ('한 시간이 지났다.\n\n'
                  '평소엔 10분이었는데. 날씨, 음식, 서울 집값, 고향 동네 이야기.\n\n'
                  '일요일 오전에 이유 없이 먼저 건 전화 하나가 — 이 대화를 만든 것이다.')
        good = ('1時間が過ぎた。\n\n'
                'いつもは10分だったのに。天気、食べ物、ソウルの住宅価格、故郷の町の話。\n\n'
                '日曜の午前、用事もなく自分からかけた一本の電話が――この会話を生んだのだ。')
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_55.json',
                         ('choices', 1, 'result_text'), source, 'event_standard')
        normals = (
            good,
            good.replace('1時間', '一時間').replace('10分', '十分').replace('一本', '一通'),
            good.replace('1時間', '１時間').replace('10分', '１０分').replace('一本', '１通'),
            good.replace('1時間が過ぎた', '1時間経った')
                .replace('いつもは10分だったのに', 'いつもなら10分で終わるのに')
                .replace('自分から', 'こちらから').replace('生んだのだ', '生み出した'),
            good.replace('1時間が過ぎた', '一時間が経過した')
                .replace('いつもは10分だったのに', '普段は十分だったのに'),
            good.replace('日曜の午前、用事もなく自分からかけた一本の電話が――この会話を生んだのだ。',
                         '日曜日の午前、理由もなく先にかけた一通の電話が、今回の会話につながったのだった。'),
            good.replace('1時間が過ぎた', '一時間がたっていた')
                .replace('いつもは10分だったのに', 'ふだんなら10分なのに'),
            good.replace('1時間が過ぎた', '1時間過ぎていた')
                .replace('いつもは10分だったのに', '普段は10分で済んでいたのに'),
            good.replace('1時間', '一時間').replace('いつもは10分だったのに。', 'いつもは10分だったのだが。'),
        )
        for target in normals:
            self.assertEqual(tool.translation_errors(leaf, 'ja', target), [], target)
        bads = []
        for old, alternatives in (
            ('1時間が過ぎた。', ('2時間が過ぎた。', '二時間が過ぎた。', '11時間が過ぎた。',
                              '1分が過ぎた。', '一日が過ぎた。', '-1時間が過ぎた。',
                              '+1時間が過ぎた。', '−1時間が過ぎた。',
                              '1時間が過ぎなかった。', '1時間話す予定だった。',
                              '父が1時間話した。', '時間が過ぎた。',
                              '二時間が過ぎた。1時間が過ぎた。')),
            ('いつもは10分だったのに。', ('いつもは9分だったのに。', 'いつもは十一分だったのに。',
                                      'いつもは10時間だったのに。', 'いつもは10秒だったのに。',
                                      'いつもは-10分だったのに。', 'いつもは+10分だったのに。',
                                      'いつもは−10分だったのに。', '今回は10分だったのに。',
                                      '父だけは10分だったのに。', 'いつもは10分ではなかった。',
                                      'いつもは短かったのに。',
                                      'いつもは十日だったのに。いつもは10分だったのに。')),
            ('自分からかけた一本の電話', ('父からかかってきた一本の電話', '自分からかける予定の一本の電話',
                                    '自分からかけなかった一本の電話', '自分からかけた二本の電話',
                                    '自分からかけた11通の電話', '自分からかけた一時間の電話',
                                    '自分からかけた一人の電話', '自分からかけた-1通の電話',
                                    '自分からかけた+1通の電話', '自分からかけた−一通の電話',
                                    '自分からかけた電話')),
        ):
            bads.extend(good.replace(old, value) for value in alternatives)
        bads.extend((
            good.replace('天気、', '一時間。天気、'),
            good.replace('天気、', '二通の電話。天気、'),
            good.replace('生んだのだ。', '生まなかったのだ。'),
            good.replace('日曜の午前', '日曜の夜'),
            good.replace('1時間が過ぎた。', '時間が過ぎた。')
                .replace('天気、', '1時間が過ぎた。天気、'),
            good.replace('いつもは10分だったのに。', 'いつもは短かったのに。')
                .replace('故郷の町の話。', '故郷の町の話。いつもは10分だったのに。'),
            good.replace('一本の電話', '二本の電話') + good.split('\n')[-1],
            '\n'.join(reversed(good.split('\n'))),
        ))
        for bad in bads:
            errors = tool.translation_errors(leaf, 'ja', bad)
            self.assertTrue(any('source-bound father call ' in error for error in errors), (bad, errors))

    def test_callback_japanese_father_call_source_scope(self):
        source = ('한 시간이 지났다.\n\n'
                  '평소엔 10분이었는데. 날씨, 음식, 서울 집값, 고향 동네 이야기.\n\n'
                  '일요일 오전에 이유 없이 먼저 건 전화 하나가 — 이 대화를 만든 것이다.')
        good = ('1時間が過ぎた。\n\n'
                'いつもは10分だったのに。天気、食べ物、ソウルの住宅価格、故郷の町の話。\n\n'
                '日曜の午前、用事もなく自分からかけた一本の電話が――この会話を生んだのだ。')
        for changed in (
            source.replace('한 시간', '두 시간'), source.replace('지났다', '지날 것이다'),
            source.replace('10분', '20분'), source.replace('10분', '10시간'),
            source.replace('먼저 건', '아버지에게서 온'), source.replace('전화 하나', '전화 둘'),
            source.replace('일요일 오전', '월요일 오후'), source + '\n그뿐이다.',
        ):
            self.assertIsNone(tool._ja_father_call_time_numbers(changed, good), changed)
            leaf = tool.Leaf('events', 'example', 'content/events/callback_events_55.json',
                             ('choices', 1, 'result_text'), changed, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'ja', good), changed)
        # Native-only source changes can still pass the old generic checker;
        # licence OFF is not a claim that every semantic mutation is rejected.
        native = good.replace('1時間', '一時間')
        changed = source.replace('일요일 오전', '월요일 오후')
        self.assertIsNone(tool._ja_father_call_time_numbers(changed, native))
        leaf = tool.Leaf('events', 'example', 'content/events/callback_events_55.json',
                         ('choices', 1, 'result_text'), changed, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'ja', native), [])

    def test_family_source_bound_minsu(self):
        from zh_translation_audit import _untranslated_english_errors as check
        for source, target in (
            ('옆집 민수 알지?', '知道隔壁家的Minsu吧？'),
            ('민수가 꼴등이었다.', 'Minsu是最後一名。'),
            ('민수를 기억했다.', '記得Minsu。'),
        ):
            self.assertEqual(check(source, target), [], (source, target))
        for source, target in (
            ('민준을 기억했다.', '記得Minsu。'),
            ('옆집 김민수 알지?', '知道Minsu吧？'),
            ('민수가 꼴등이었다.', 'MinsuPlus是最後一名。'),
            ('민수가 꼴등이었다.', 'Minsu_是最後一名。'),
        ):
            self.assertTrue(check(source, target), (source, target))

    def test_family_promise_relative_verb(self):
        from zh_translation_audit import _numeric_errors as check
        source = '잘 될 거라고 다짐했다. 상대방은 웃었고 나는 스스로에게 한 약속이 됐다.'
        for target in ('對方笑了，而這也成了我對自己許下的承諾。',
                       '对方笑了，而我把这当成了对自己的承诺。'):
            self.assertEqual(check(source, target), [], target)
        self.assertTrue(check('두 약속이었다.', '一個承諾。'))
        self.assertTrue(check('나는 스스로에게 두 약속이 됐다.', '一個承諾。'))

    def test_living_japanese_plain_thousands_and_minus(self):
        for source, good in (
            ('1000원을 주머니에 넣었다.', '1,000ウォンをポケットに入れた。'),
            ('산다 — 한 번쯤은 (−1,000원)', '買う――一度くらいは（−1,000ウォン）'),
            ('비용 1000원과 환급 5,000원.', '費用1,000ウォンと返金5,000ウォン。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], (source, good))
            for bad in (good.replace('1,000', '2,000'), good.replace('ウォン', '円'),
                        good.replace('1,000', '+1,000'), good + '1,000ウォン。'):
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))
        leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('title',), '−1,000원', 'event_standard')
        for good in ('−1,000ウォン', '-1,000ウォン'):
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], good)
        for bad in ('1,000ウォン', '+1,000ウォン', '−−1,000ウォン', '−1,000ウォン（円）', '−1,000ウォン%'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('title',), '비용 1000원과 환급 5,000원.', 'event_standard')
        self.assertTrue(tool.translation_errors(leaf, 'ja', '費用5,000ウォンと返金1,000ウォン。'))
        leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('title',), '1000원', 'event_standard')
        self.assertTrue(tool.translation_errors(leaf, 'ja', '1,000ウォン（人民元）'))

    def test_living_japanese_buy_one_get_one_explanation(self):
        leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), '1+1 행사를 발견했다.', 'event_standard')
        good = '1個買うと1個もらえる、1+1キャンペーンを見つけた。'
        self.assertEqual(tool.translation_errors(leaf, 'ja', good), [])
        self.assertEqual(tool.translation_errors(leaf, 'ja', '1+1キャンペーンを見つけた。'), [])
        for bad in (good.replace('1個買う', '2個買う'), good.replace('1個もらえる', '2個もらえる'),
                    good.replace('もらえる', 'もらえない'), good.replace('1+1', '1+2'), good + good,
                    '−' + good, '十' + good):
            self.assertTrue(tool.translation_errors(leaf, 'ja', bad), bad)
        other = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), '행사를 발견했다.', 'event_standard')
        self.assertTrue(tool.translation_errors(other, 'ja', good))

    def test_living_japanese_lottery_ticket_and_ellipsis(self):
        for source, good, bads in (
            ('로또 1장에 1000원.', 'ロト一口、1,000ウォン。',
             ('ロト二口、1,000ウォン。', 'ロト一口、2,000ウォン。', 'ロト一口、1,000円。')),
            ('...3개 일치. 5등. 5,000원.', '……3個一致。5等。5,000ウォン。',
             ('……4個一致。5等。5,000ウォン。', '……3個一致。4等。5,000ウォン。', '……3個一致。5等。6,000ウォン。', '……−3個一致。5等。5,000ウォン。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/life_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'ja', good), [], (source, good))
            for bad in bads + (good + good,):
                self.assertTrue(tool.translation_errors(leaf, 'ja', bad), (source, bad))

    def test_living_source_scoped_chinese_brands(self):
        from zh_translation_audit import _untranslated_english_errors as check
        listing = '당근에 물건을 올렸더니 댓글이 달렸다.'
        index = 'VOO, SPY, TIGER 미국S&P500.'
        for good in ('在Daangn上架物品。', '把物品放上Karrot。'):
            self.assertEqual(check(listing, good), [], good)
        for good in ('VOO、SPY、TIGER美国S&P500。', 'VOO、SPY、TIGER美國S&P500。'):
            self.assertEqual(check(index, good), [], good)
        for source, bad in (
            ('당근을 먹었다.', '吃了Daangn。'), ('물건을 올렸다.', '在Karrot上架物品。'),
            ('빨간당근에 물건을 올렸더니 댓글이 달렸다.', '在Daangn上架物品。'),
            (listing, '在DaangnPlus上架物品。'), (listing, '在KarrotETF上架物品。'),
            (listing, '在Daangn_上架物品。'), (listing, '在Karrot2上架物品。'),
            (listing, '在Daangné上架物品。'), (listing, '在Karrot\u0301上架物品。'),
            ('미국 지수.', '美国S&P500。'), ('미국S&P5000.', '美国S&P500。'),
            ('미국S&P500_.', '美国S&P500。'),
            (index, '美国S&P400。'), (index, '美国S&P500ETF。'),
            (index, '美国S&P500_。'), (index, '美国S&P500é。'),
        ):
            self.assertTrue(check(source, bad), (source, bad))

        # The generic source-token fallback already admits these two suffixes.
        # Assert the new composite licence cannot borrow them; broader legacy
        # English-boundary behavior is not changed by this spending batch.
        from zh_translation_audit import _bounded_latin_matches
        for source in ('S&P500é.', 'S&P500\u0301.'):
            self.assertEqual(_bounded_latin_matches(source, 'S&P500'), [], source)

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

    def test_marriage_brightness_seating_and_branch_counters(self):
        for source, target in (
            ('거실 조명을 한 칸 낮췄다.', '把客廳燈光調暗了一檔。'),
            ('거실 조명을 한 칸 낮췄다.', '把客廳燈光調暗了一格。'),
            ('신랑석. 그 한 줄 뒤에는 현수가 혼자 앉아 있었다.', '新郎席。後面一排，Hyunsu 獨自坐著。'),
            ('두 갈래 사이에 섰다.', '停在兩邊之間。'),
            ('백 명보다 컸다.', '比一百個人還重。'),
            ('서른일곱의 겨울, 카페.', '三十七歲的冬天，咖啡廳。'),
            ('한 접시가 두 집 사이를 건너왔다.', '一盤菜在兩個家之間走過。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_married.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))

    def test_marriage_counter_mutations(self):
        for source, targets in (
            ('거실 조명을 한 칸 낮췄다.', ('調暗兩檔。', '調暗負一檔。', '調暗一檔公里。', '調暗一分鐘。')),
            ('신랑석. 그 한 줄 뒤에는 현수가 혼자 앉아 있었다.', tuple(
                '新郎席。後面' + count + '，Hyunsu 獨自坐著。'
                for count in ('兩排', '負一排', '一排公里', '一分鐘')
            )),
            ('두 갈래 사이에 섰다.', ('三邊', '負兩邊', '兩邊公里', '兩個人')),
            ('백 명보다 컸다.', ('九十九個人', '負一百個人', '一百個人公里', '一百分鐘')),
            ('서른일곱의 겨울, 카페.', ('三十八歲', '負三十七歲', '三十七年')),
            ('한 접시가 두 집 사이를 건너왔다.', ('三個家', '負兩個家', '兩個家具', '兩個家公里', '兩個人')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_married.json', ('description',), source, 'event_standard')
            for target in targets:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))

    def test_marriage_quantity_suffixes(self):
        for source, target in (
            ('신랑석. 그 한 줄 뒤에는 현수가 혼자 앉아 있었다.', 'Hyunsu 坐在後面一排'),
            ('거실 조명을 한 칸 낮췄다.', '一檔'),
            ('두 갈래 사이에 섰다.', '兩邊'),
            ('백 명보다 컸다.', '一百個人'),
            ('두 집 사이를 건넜다.', '兩個家'),
            ('5성급 호텔 그랜드볼룸.', '五星級'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_married.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))
            for separator in ('', ' ', '\t', '\u3000'):
                for suffix in ('分鐘', '分钟', '秒', '歲', '米', '公里', '年', '月', '日', '天', '元', '度', '小時', '小时', '韓元', '韩元', '人', '位'):
                    self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target + separator + suffix), (source, separator, suffix))

    def test_marriage_approximate_won_magnitudes(self):
        for source, target, bad in (
            ('몇백만원 쓰는 거', '花幾百萬韓元', ('花幾千萬韓元', '花300萬韓元', '花幾百萬日元', '花負幾百萬韓元')),
            ('예단만 수천만.', '光婚禮禮金就要數千萬韓元。', ('數百萬韓元', '三千萬韓元', '負數千萬韓元', '數千萬日元')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_daeun_married.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for value in bad:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', value), (source, value))

    def test_marriage_relative_clause_and_counter_context(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_romance_specials.json', ('description',),
                         '도도하게 들리려 한 문장은 끝까지 올라오지 못했다.', 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', '想裝得高傲的話，語氣卻沒能撐到最後。'), [])
        for source, target in (
            ('거실 표의 한 칸을 채웠다.', '填了一檔。'),
            ('문서의 한 줄 뒤에는 글이 있었다.', '文件裡有一排椅子。'),
            ('책에 한 문장이 있었다.', '書裡有兩句話。'),
        ):
            counted = tool.Leaf('events', 'example', 'content/events/arc_romance_specials.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(counted, 'zh-TW', target), (source, target))

    def test_marriage_star_rating_and_plural_characters(self):
        for source, good, bad in (
            ('5성급 호텔 그랜드볼룸.', '五星級飯店宴會廳。', ('六星級飯店', '負五星級飯店', '五星級分鐘', '五個飯店')),
            ('두 이름. 그 두 글자들이 남았다.', '兩個名字。那兩個字留下了。', ('兩個名字。那三個字留下了。', '兩個名字。那兩分鐘留下了。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_jiyeon_married.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], (source, good))
            for target in bad:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))

    def test_marriage_han_chairman_source_bound_surname(self):
        leaf = tool.Leaf('events', 'example', 'content/events/arc_jiyeon_married.json', ('description',), '누군가는 한 회장의 딸 결혼식에 얼굴을 비춘다.', 'event_standard')
        for good in ('Han 董事長女兒的婚禮。', 'Han董事長女兒的婚禮。', '參加Han董事長女兒的婚禮。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [], good)
        for bad in ('韓董事長女兒的婚禮。', 'Han（韓）董事長女兒的婚禮。', 'HanETF 董事長女兒的婚禮。', 'Hané 董事長女兒的婚禮。', 'Han_ 董事長女兒的婚禮。', '_Han 董事長女兒的婚禮。', 'Han\u0301 董事長女兒的婚禮。', 'Han한 董事長女兒的婚禮。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
        for mark in ('\u0301', '\u1ab0', '\u1dc0', '\u20d0', '\ufe20', '\u0903', '\u0488'):
            for bad in ('Han' + mark + ' 董事長女兒的婚禮。', mark + 'Han 董事長女兒的婚禮。'):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), repr(bad))
        absent = tool.Leaf('events', 'example', 'content/events/arc_jiyeon_married.json', ('description',), '회장의 딸 결혼식.', 'event_standard')
        self.assertTrue(tool.translation_errors(absent, 'zh-TW', 'Han 董事長女兒的婚禮。'))
        indefinite = tool.Leaf('events', 'example', 'content/events/arc_jiyeon_married.json', ('description',), '어떤 한 회장이 왔다.', 'event_standard')
        self.assertTrue(tool.translation_errors(indefinite, 'zh-TW', 'Han 董事長來了。'))

    def test_relationship_source_bound_brand_names(self):
        for source, target in (
            ('링크드인에서 알림이 왔다.', 'LinkedIn 傳來通知。'),
            ('인스타 비교 지옥', 'Instagram 的比較地獄'),
            ('인스타그램을 열었다.', '打開 Instagram。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for bad in (target + ' English sentence', target.replace('Instagram', 'InstagramX').replace('LinkedIn', 'LinkedInX')):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
            other = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '종이를 보았다.', 'event_standard')
            self.assertTrue(tool.translation_errors(other, 'zh-TW', target))
        for source, target in (('인스타일을 읽었다.', '讀了 Instagram。'), ('슬랙스 바지.', 'Slack 褲子。')):
            leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target))

    def test_relationship_source_bound_people(self):
        for source, target, name in (
            ('김대리에게 슬랙 DM을 보냈다.', '透過 Slack 傳了 DM 給 Kim 代理。', 'Kim'),
            ('옆 팀 박 씨.', '隔壁組姓 Park 的同事。', 'Park'),
            ('박과장이 왔다.', 'Park 課長來了。', 'Park'),
            ('친구 지수에게서 전화가 왔다.', '朋友 Jisu 打電話來。', 'Jisu'),
            ('준혁이가 말했다.', 'Junhyeok 說。', 'Junhyeok'),
            ('친구 재훈이도 접속 중이다.', '朋友 Jaehun 也在線上。', 'Jaehun'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for bad in (target.replace(name, name + 'X'), target.replace(name, name + '（金）'), target.replace(name, '金智秀')):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '금융 지수가 올랐다.', 'event_standard')
        self.assertTrue(tool.translation_errors(leaf, 'zh-TW', 'Jisu 上漲了。'))
        longer = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '친구 지수연에게서 전화가 왔다.', 'event_standard')
        self.assertTrue(tool.translation_errors(longer, 'zh-TW', '朋友 Jisu 打電話來。'))

    def test_relationship_unicode_name_boundaries(self):
        for source, target, name in (
            ('김대리에게 말했다.', '向Kim代理說了。', 'Kim'),
            ('박과장이 왔다.', 'Park課長來了。', 'Park'),
            ('친구 지수에게서 전화가 왔다.', '朋友Jisu打電話來。', 'Jisu'),
            ('준혁이가 말했다.', 'Junhyeok說。', 'Junhyeok'),
            ('친구 재훈이도 접속 중이다.', '朋友Jaehun也在線上。', 'Jaehun'),
            ('링크드인에서 알림이 왔다.', 'LinkedIn傳來通知。', 'LinkedIn'),
            ('인스타를 열었다.', '打開Instagram。', 'Instagram'),
            ('슬랙을 열었다.', '打開Slack。', 'Slack'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for extension in ('_', 'é', '\u0301', '\u0903', '\u0488'):
                for bad in (target.replace(name, name + extension), target.replace(name, extension + name)):
                    self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)

    def test_relationship_noun_bound_quantities(self):
        for source, target, before, bads in (
            ('자기소개서 세 군데를 고쳤다.', '改了自傳裡的三個地方。', '三個地方', ('兩個地方', '十三個地方', '三個人')),
            ('강남역 10번 출구', '江南站十號出口', '十號出口', ('九號出口', '十一號出口', '十次')),
            ('신호가 두 번 울리다가 끊겼다.', '回鈴音響了兩聲便斷了。', '兩聲', ('三聲', '十二聲', '兩分鐘')),
            ('이거 봐주면 나중에 밥 한 번 사.', '幫你看這個，改天請我吃頓飯。', '頓飯', ('兩頓飯', '十一頓飯')),
            ('일 얘기인지, 인생 얘기인지, 아니면 둘 다인지 알 수 없다.', '不知道要談工作、人生，還是兩者都有。', '兩者', ('三者', '十二者', '兩個人')),
            ('두 이야기는, 그 지점에서 서로를 향하고 있었다.', '兩個故事，在那裡朝向了彼此。', '兩個故事', ('三個故事', '十二個故事', '兩個人')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for bad in bads:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target.replace(before, bad)), bad)

    def test_relationship_video_duration_and_position(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '14분 47초짜리였다.\n회사 이야기가 7분에 나왔다.', 'event_standard')
        target = '片長十四分四十七秒。\n公司的事在第七分鐘出現。'
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
        for old, new in (('十四分', '十三分'), ('四十七秒', '四十六秒'), ('第七分', '第八分'), ('十四分', '十四點')):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target.replace(old, new)))

    def test_relationship_outing_round(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '2차까지 갔다. 팀장님이 노래방에서 마이크를 건네줬다.', 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', '連第二攤也去了。組長在練歌房遞來麥克風。'), [])
        for n in ('一', '三', '十二', '負二'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', f'連第{n}攤也去了。組長在練歌房遞來麥克風。'))

    def test_relationship_new_counter_suffixes(self):
        for source, target, phrase in (
            ('졸업 10주년 동창회', '畢業十週年同學會', '十週年'),
            ('자기소개서 세 군데를 고쳤다.', '改了三個地方。', '三個地方'),
            ('강남역 10번 출구', '江南站十號出口', '十號出口'),
            ('두 이야기는, 그 지점에서 서로를 향하고 있었다.', '兩個故事，在那裡朝向了彼此。', '兩個故事'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for gap in ('', ' ', '\t', '　'):
                for unit in ('秒', '人', '韓元', '公里'):
                    self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target.replace(phrase, phrase + gap + unit)))

    def test_relationship_rice_and_duration_do_not_borrow(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '공기밥 두 개.\n\n두 시간이 지나갔다.', 'event_standard')
        target = '兩碗白飯。\n\n兩個小時過去了。'
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
        for old, new in (('兩碗', '三碗'), ('兩個小時', '三個小時'), ('兩碗白飯', '兩個人'), ('兩個小時', '兩天')):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target.replace(old, new)))

    def test_relationship_hospital_glance_and_shuttle(self):
        source = '아버지는 비어 있는 종이컵을 한 번 보고도 묻지 않았다. 두 사람은 나란히 병동 창가의 긴 의자까지 걸었다. 창밖으로 병원 셔틀이 한 번 멈췄다가 떠났다.'
        target = '父親看了一眼空紙杯，沒有問。兩人並排走到病區窗邊的長椅旁。窗外，醫院接駁車停了一次，又開走了。'
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
        for old, new in (('一眼', '兩眼'), ('兩人', '三人'), ('一次', '兩次'), ('一眼', ''), ('一次', '')):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target.replace(old, new)))

    def test_relationship_father_age_decade(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '20대의 아버지.', 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', '二十多歲的父親。'), [])
        for target in ('三十多歲的父親。', '二十歲的父親。', '二十輛車裡的父親。', '負二十多歲的父親。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)

    def test_relationship_soup_sip(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '국물을 한 모금 마시더니 물었다.', 'event_standard')
        for target in ('喝了口湯，問道。', '喝了一口湯，問道。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
        for target in ('喝了兩口湯，問道。', '喝了十一口湯，問道。', '喝了負一口湯，問道。', '喝了一瓶湯，問道。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)
        tea = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '차를 한 모금 마시고 물었다.', 'event_standard')
        self.assertEqual(tool.translation_errors(tea, 'zh-TW', '喝了口茶，問道。'), [])
        for target in ('喝了兩口茶，問道。', '喝了一口湯，問道。', '喝了十一口茶，問道。'):
            self.assertTrue(tool.translation_errors(tea, 'zh-TW', target), target)

    def test_relationship_elapsed_month_over(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '생각해보니 한 달이 넘었다.', 'event_standard')
        for locale, target in (('zh-CN', '想了想，已经一个多月了。'), ('zh-TW', '仔細一想，已經超過一個月了。')):
            self.assertEqual(tool.translation_errors(leaf, locale, target), [])
        for target in ('一個月', '兩個多月', '十一個多月', '負一個多月', '未超過一個月',
                       '沒有超過一個月', '負超過一個月', '不到一個多月', '少於一個多月',
                       '超過一個月\t秒', '一個多月 公里', '超過兩個月', '一個多星期'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)
        exact = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '한 달이 지났다.', 'event_standard')
        self.assertTrue(tool.translation_errors(exact, 'zh-TW', '一個多月。'))

    def test_relationship_missed_call_count(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '임상철 — 세 번.\n아버지 — 부재중 한 번.', 'event_standard')
        for locale, target in (('zh-CN', 'Im Sangchul——三次。\n父亲——一次未接来电。'),
                               ('zh-TW', 'Im Sangchul——三次。\n父親——一通未接來電。')):
            self.assertEqual(tool.translation_errors(leaf, locale, target), [])
        for fragment in ('兩通未接來電', '十一通未接來電', '負一通未接來電', '一通已接來電',
                         '一次已接來電', '一通訊息', '一通未接來電 公里', '一通未接來電\t秒'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', 'Im Sangchul——三次。\n父親——'+fragment+'。'), fragment)
        other = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '아버지가 한 번 웃었다.', 'event_standard')
        self.assertTrue(tool.translation_errors(other, 'zh-TW', '一通未接來電。'))
        for continuation in ('방문했다.', '택배가 왔다.', '서류를 확인했다.'):
            unrelated = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '아버지 — 부재중 한 번 '+continuation, 'event_standard')
            self.assertTrue(tool.translation_errors(unrelated, 'zh-TW', '父親——一通未接來電。'), continuation)

    def test_relationship_childhood_meal_invitation(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events2.json', ('result_text',), '밥 한 번 먹자고 했다.', 'event_standard')
        for locale, target in (('zh-CN', '说改天一起吃顿饭。'), ('zh-TW', '說下次一起吃頓飯吧。')):
            self.assertEqual(tool.translation_errors(leaf, locale, target), [])
        for target in ('一起吃兩頓飯', '一起吃十一頓飯', '一起吃負一頓飯'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)
        other = tool.Leaf('events', 'example', 'content/events/relationship_events2.json', ('result_text',), '밥 한 번 먹었다.', 'event_standard')
        self.assertTrue(tool.translation_errors(other, 'zh-TW', '一起吃頓飯。'))

    def test_relationship_graduation_anniversary(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('title',), '졸업 10주년 동창회', 'event_standard')
        for target in ('畢業十週年同學會', '畢業10週年同學會'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
        for target in ('畢業九週年同學會', '畢業十一週年同學會', '畢業十年同學會', '畢業負十週年同學會'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)

    def test_relationship_per_person_mixed_won_bill(self):
        leaf = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '1인당 4만 5천원이 나왔다.', 'event_standard')
        for target in ('每人4.5萬韓元。', '每人45,000韓元。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
        for target in ('每人4萬韓元。', '每人5千韓元。', '每人4萬韓元和5千韓元。', '每人4.5萬元。', '兩人分攤4.5萬韓元。', '每人負4.5萬韓元。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)
        # A different source spelling is not silently aggregated by this fix.
        other = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), '4만원과 5천원을 보냈다.', 'event_standard')
        self.assertTrue(tool.translation_errors(other, 'zh-TW', '匯出4.5萬韓元。'))
        self.assertEqual(tool.translation_errors(leaf, 'ja', '1人当たり4万5千ウォンになった。'), [])
        for prefix in ('-', '−', '- ', '−\t', '+ ', '0.', '2.'):
            signed = tool.Leaf('events', 'example', 'content/events/relationship_events.json', ('description',), prefix + leaf.source, 'event_standard')
            for locale, target in (('zh-TW', '每人4.5萬韓元。'), ('zh-CN', '每人4.5万韩元。')):
                self.assertTrue(tool.translation_errors(signed, locale, target), (prefix, locale))
        for target in ('1人当たり4万6千ウォンになった。', '1人当たり4万5千円になった。',
                       '1人当たり負4万5千ウォンになった。', '2人当たり4万5千ウォンになった。'):
            self.assertTrue(tool.translation_errors(leaf, 'ja', target), target)

    def test_subscription_annual_mixed_won_sum(self):
        from decimal import Decimal
        from zh_translation_audit import _source_money_amounts
        source = '구독 서비스를 찾았다.\n두 개 다 해지했다.\n월 23,000원이 절약됐다. 1년에 27만 6천원.'
        self.assertEqual([x.won for x in _source_money_amounts(source)], [Decimal(23000), Decimal(276000)])
        leaf = tool.Leaf('events', 'example', 'content/events/hidden_events.json', ('result_text',), source, 'event_standard')
        targets = (
            ('ja', 'サブスクのサービスを探した。\n二つとも解約した。\n月23,000ウォンの節約になった。1年で276,000ウォン。', 'ウォン'),
            ('zh-CN', '找到了订阅服务。\n两个都取消了。\n每月省下23,000韩元。一年276,000韩元。', '韩元'),
            ('zh-TW', '找到訂閱服務。\n兩個都取消了。\n每月省23,000韓元。一年276,000韓元。', '韓元'),
        )
        for locale, target, currency in targets:
            self.assertEqual(tool.translation_errors(leaf, locale, target), [], locale)
            for replacement in ('270,000', '6,000', '27,600', '276,001', '-276,000'):
                self.assertTrue(tool.translation_errors(leaf, locale, target.replace('276,000', replacement)), (locale, replacement))
            self.assertTrue(tool.translation_errors(leaf, locale, target.replace('276,000'+currency, '276,000円')), locale)
            swapped = target.replace('23,000', '@FIRST@').replace('276,000', '23,000').replace('@FIRST@', '276,000')
            self.assertTrue(tool.translation_errors(leaf, locale, swapped), locale)
        # Explicitly separate payments must stay separate, not become a single sum.
        separate = '1년에 27만원과 6천원을 보냈다.'
        self.assertEqual([x.won for x in _source_money_amounts(separate)], [Decimal(270000), Decimal(6000)])
        other = tool.Leaf('events', 'example', 'content/events/hidden_events.json', ('result_text',), separate, 'event_standard')
        for locale, target in (('ja', '1年で276,000ウォンを送った。'), ('zh-CN', '一年转出276,000韩元。'), ('zh-TW', '一年匯出276,000韓元。')):
            self.assertTrue(tool.translation_errors(other, locale, target), locale)

    def test_prologue_ticket_regional_counters(self):
        source = '[147번 고객님, 4번 창구로 오십시오.]'
        leaf = tool.Leaf('events', 'example', 'content/events/story_events.json', ('result_text',), source, 'event_standard')
        for locale, normal in (
            ('zh-CN', '[147号顾客，请到4号柜台。]'),
            ('zh-CN', '[147号客户，请到4号窗口。]'),
            ('zh-TW', '[147號顧客，請至4號櫃檯。]'),
        ):
            self.assertEqual(tool.translation_errors(leaf, locale, normal), [], locale)
            for wrong in (
                normal.replace('147', '148'),
                normal.replace('4号', '5号').replace('4號', '5號'),
                normal.replace('147', '@FIRST@').replace('4', '147').replace('@FIRST@', '4'),
                normal.replace('147', '-147'),
                normal.replace('4号', '-4号').replace('4號', '-4號'),
                normal.replace('147号', '147年').replace('147號', '147年'),
                normal.replace('4号', '4年').replace('4號', '4年'),
                normal.replace('147', '148') + normal,
            ):
                self.assertTrue(tool.translation_errors(leaf, locale, wrong), (locale, wrong))

    def test_resting_time_is_not_fifty_hours(self):
        from zh_translation_audit import _source_counter_quantities
        source = '폰을 뒤집어 놓고 반나절을 잤다.\n쉰 시간도 어딘가로 사라진 것은 아니었다.'
        self.assertFalse(any(q.kind == 'duration_hour' for q in _source_counter_quantities(source)))
        leaf = tool.Leaf('events', 'example', 'content/events/story_events.json', ('result_text',), source, 'event_standard')
        for locale, target in (
            ('zh-CN', '把手机翻过来放好，睡了半天。\n休息的时间，也不是凭空消失了。'),
            ('zh-TW', '把手機翻面放下，睡了半天。\n休息的時間，也不是就這樣消失在哪裡了。'),
        ):
            self.assertEqual(tool.translation_errors(leaf, locale, target), [], locale)
            wrong = target.replace('休息的时间', '休息了50小时的时间').replace('休息的時間', '休息了50小時的時間')
            self.assertTrue(tool.translation_errors(leaf, locale, wrong), locale)
        other = tool.Leaf('events', 'example', 'content/events/story_events.json', ('result_text',), '쉰 시간이 지났다.', 'event_standard')
        for locale, target in (('zh-CN', '经过了50小时。'), ('zh-TW', '過了50小時。')):
            self.assertEqual(tool.translation_errors(other, locale, target), [], locale)
            self.assertTrue(tool.translation_errors(other, locale, target.replace('50', '49')), locale)

    def test_rest_exception_preserves_worked_fifty_hours(self):
        from zh_translation_audit import _source_counter_quantities
        for source in (
            '폰을 뒤집어 놓고 반나절을 잤다. 그 전에 일한 쉰 시간도 어딘가로 사라진 것은 아니었다.',
            '폰을 뒤집어 놓고 반나절을 잤다.\n그날 밤에는 알람을 미루지 않았다. 그 전에 일한 쉰 시간도 어딘가로 사라진 것은 아니었다.',
        ):
            self.assertTrue(any(q.kind == 'duration_hour' and q.value == 50 for q in _source_counter_quantities(source)), source)
            leaf = tool.Leaf('events', 'example', 'content/events/story_events.json', ('result_text',), source, 'event_standard')
            for locale, target, quantity, omitted, wrong_unit in (
                ('zh-CN', '把手机翻过来放好，睡了半天。之前工作的50小时，也不是凭空消失了。', '50小时', '时间', '50天'),
                ('zh-TW', '把手機翻面放下，睡了半天。之前工作的50小時，也不是憑空消失了。', '50小時', '時間', '50天'),
            ):
                if '\n' in source:
                    alarm = '那天晚上，没有推迟闹钟。' if locale == 'zh-CN' else '那天晚上，沒有把鬧鐘往後調。'
                    target = target.replace('睡了半天。', '睡了半天。\n' + alarm)
                self.assertEqual(tool.translation_errors(leaf, locale, target), [], (source, locale))
                for wrong in (target.replace(quantity, omitted), target.replace('50', '49'), target.replace(quantity, wrong_unit)):
                    self.assertTrue(tool.translation_errors(leaf, locale, wrong), (source, locale, wrong))

    def test_date_can_sound_and_glass_pane(self):
        for source, good, bad in (
            ('캔 안에서 작은 금속 소리가 한 번 났고, 다시 조용해졌다.', '罐子裡輕輕響了一聲金屬聲，又靜了下來。', ('兩聲金屬聲', '負一聲金屬聲', '一分鐘', '一聲 公里')),
            ('유리 한 장 두께의 거리가 아득했다.', '只有一片玻璃厚的距離，卻很遙遠。', ('兩片玻璃', '負一片玻璃', '一張紙', '一片玻璃 公里')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_date_milestones.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [])
            for target in bad:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))
        for source, target in (
            ('캔 안에서 작은 금속 소리가 한 번 났고, 다시 조용해졌다.', '罐子里轻轻响了一声金属声，又静了下来。'),
            ('유리 한 장 두께의 거리가 아득했다.', '只有一片玻璃厚的距离，却很遥远。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_date_milestones.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-CN', target), [])

    def test_date_counter_scope_and_suffix_mutations(self):
        for source, target in (
            ('버튼을 한 번 눌렀다.', '按了一聲。'),
            ('서류 한 장 두께의 거리가 아득했다.', '一片玻璃。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_date_milestones.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))
        for source, target in (
            ('캔 안에서 작은 금속 소리가 한 번 났고, 다시 조용해졌다.', '一聲'),
            ('유리 한 장 두께의 거리가 아득했다.', '一片玻璃'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_date_milestones.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [])
            for separator in ('', ' ', '\t', '\u3000'):
                for suffix in ('分鐘', '秒', '歲', '米', '公里', '年', '月', '日', '天', '元', '度', '小時', '韓元', '人', '位'):
                    self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target + separator + suffix), (source, separator, suffix))

    def test_date_amusement_count_before_only_suffix(self):
        for source in ('놀이기구는 두 개밖에 못 탔다.', '놀이기구는 아직 두 개밖에 못 탔다.'):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_date_milestones.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-CN', '游乐设施才玩了两个。'), [])
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', '遊樂設施只玩了兩項。'), [])
            for count in ('三項', '負兩項', '兩項 公里', '兩個人', '兩個 年', '兩分鐘', '十二項'):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', '遊樂設施只玩了' + count + '。'), (source, count))
        source = '놀이기구가 많았다.'
        leaf = tool.Leaf('events', 'example', 'content/events/arc_date_milestones.json', ('description',), source, 'event_standard')
        self.assertTrue(tool.translation_errors(leaf, 'zh-CN', '游乐设施才玩了两个。'))

    def test_date_petals_and_physical_look(self):
        for source, prefix, good in (
            ('바람에 꽃잎이 내렸고, 한 장이 그녀 머리에 앉았다.', '花瓣落下，', '一片落在她頭上。'),
            ('꽃잎 한 장이 그녀 머리에 앉았다.', '花瓣', '一片落在她頭上。'),
            ('다은이 하늘을 보기 직전 {name}을 한 번 돌아봤다.', 'Daeun 仰望天空前，回頭看了{name}', '一眼。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', prefix + good), [], source)
            for bad in (good.replace('一', '兩', 1), '負' + good, good.replace('一', '十一', 1), good[:2] + ' 公里' + good[2:], '一分鐘。'):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', prefix + bad), (source, bad))
        for source, target in (
            ('서류 한 장이 그녀 머리에 앉았다.', '一片落在她頭上。'),
            ('버튼을 한 번 눌렀다.', '一眼。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), (source, target))

    def test_date_glances_and_reordered_laughter(self):
        for source, target in (
            ('영수증을 한 번 보더니 가방 안에 넣었다.', '看了一眼收據，放進包裡。'),
            ('빈손을 한 번 내려다본 뒤, 숨기지 않았다.', '低頭看了一眼空著的手，沒有藏起來。'),
            ('그 사이로 눈이 한 번 흘겼다.', '從縫隙中瞪來一眼。'),
            ('5년치를 한 번에 웃어버리는 사람.', '一次笑盡了五年份的笑的人。'),
            ('5년치를 한 번에 웃어버리는 사람.', '把五年份的笑一次笑盡的人。'),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))
            for bad in (target.replace('一眼', '兩眼').replace('一次', '兩次'), target.replace('一眼', '負一眼').replace('一次', '負一次'), target.replace('一眼', '一眼 公里').replace('一次', '一次 公里')):
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), (source, bad))

    def test_date_stay_night_ordinal_meeting_and_small_cans(self):
        for source, target, bad in (
            ('내년엔 1박으로 와요.', '明年來住一晚吧。', ('明年來住兩晚吧。', '明年來住負一晚吧。', '明年來住一晚 公里吧。', '明年來住一天吧。')),
            ('회의 두 개째야.', '已經在開第二場會了。', ('已經在開第三場會了。', '已經在開第負二場會了。', '已經在開第二場會 公里了。', '已經在開第二個月了。')),
            ('손에는 작은 캔커피 두 개.', '手裡拿著兩小罐咖啡。', ('手裡拿著三小罐咖啡。', '手裡拿著負兩小罐咖啡。', '手裡拿著兩小罐 公里咖啡。', '手裡拿著兩分鐘咖啡。')),
        ):
            leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], (source, target))
            for value in bad:
                self.assertTrue(tool.translation_errors(leaf, 'zh-TW', value), (source, value))

    def test_date_never_entered_sea_is_not_a_visit(self):
        source = '그 바다에는 한 번도 들어가 본 적 없는 얼굴이었다.'
        leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
        for target in ('像是從來沒下過那片海。', '像是從未下過那片海。', '像是一次也沒有下過那片海。'):
            self.assertEqual(tool.translation_errors(leaf, 'zh-TW', target), [], target)
        for target in ('像是下過那片海。', '像是來過那片海。', '像是從來沒有看過那片海。', '像是兩次也沒有下過那片海。', '像是負一次也沒有下過那片海。', '像是從來沒下過那片海 公里。', '並非從來沒下過那片海。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)

    def test_date_laughter_does_not_borrow_earlier_repetitions(self):
        source = '그때마다 팔을 더 꽉 잡았다. 5년치를 한 번에 웃어버리는 사람.'
        leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
        good = '每一次，都抓得更緊。把五年的份一次笑完的人。'
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', good), [])
        for count in ('兩次', '零次', '十一次', '負一次'):
            bad = good.replace('份一次笑完', '份' + count + '笑完')
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', bad), bad)

    def test_date_quoted_name_after_relative_clause(self):
        source = "{name}이 아는 '한지연'과 같은 사람인가 싶었다."
        leaf = tool.Leaf('events', 'example', 'content/events/arc_season_dates.json', ('description',), source, 'event_standard')
        self.assertEqual(tool.translation_errors(leaf, 'zh-TW', '{name} 所認識的「Han Jiyeon」。'), [])
        for target in ('{name} 所認識的「韓芝妍」。', '{name} 所認識的「Han Jiyeon」韓芝妍。', '{name} 所認識的「Han Jiyeon」（韓芝妍）。', '{name} 韓芝妍「Han Jiyeon」。'):
            self.assertTrue(tool.translation_errors(leaf, 'zh-TW', target), target)

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


    @staticmethod
    def _investment_life_quantity_examples():
        # Observed source/target pairs only; independent ROOT fixtures are not
        # loaded, copied or used by these implementation-owned regressions.
        return (
            ("50만 원을 넣었다. 처음엔 두 배가 됐다.\n그리고 반 토막. 다시 조금 올라와서 -30%에 멈췄다.\n팔아야 하는데, 손에 안 잡혔다.\n코인의 마력은 그거였다. 손절이 불가능하다.", "50万ウォンを入れた。初めは2倍になった。\nそして半減。また少し上がり、-30%で止まった。\n売らなければいけないのに、手が動かなかった。\n暗号資産の魔力はそこだった。損切りができない。", ["2","二","２","3","倍","歳","倍になった","倍になるつもりだ"]),
            ("두 달 뒤 코인 시장이 42% 빠졌을 때 동창의 다온 상태 메시지가 조용해졌다.\n{name}은 아무 말도 안 했다.\n때로 가장 좋은 투자는 안 하는 것이다.", "2か月後、暗号資産市場が42%下落したとき、同級生のダオンのステータスメッセージは静かになった。\n{name}は何も言わなかった。\n時には、何もしないことが最良の投資になる。", ["2","二","２","3","か月","週間","後、暗号資産","前、暗号資産"]),
            ("SNS 피드가 코인 얘기로 도배됐다. 고등학교 동창이 코어코인으로 3000만 원 벌었다는 다온 상태 메시지를 올렸다. 직장 후배는 점심 때마다 코인 얘기만 한다. 나만 모르는 건가, 나만 뒤처진 건가. {name}은 처음으로 업비트 앱을 깔아봤다.", "SNSのフィードが暗号資産の話で埋め尽くされた。高校の同級生が、コアコインで3,000万ウォン儲けたとダオンのステータスメッセージに書いた。職場の後輩も、昼食のたびに暗号資産の話ばかりする。知らないのは自分だけなのか。取り残されているのは自分だけなのか。{name}は初めてアップビットのアプリを入れてみた。", ["3,000万","三千万","3000万","3,001万","ウォン","ドル","同級生が","自分が"]),
            ("완벽한 타이밍을 기다리는 동안 세 달이 지났다. 결국 그 타이밍은 오지 않았다.", "完璧なタイミングを待つうちに、3か月が過ぎた。結局、そのタイミングは来なかった。", ["3","三","３","4","か月","週間","が過ぎた","が過ぎる予定だ"]),
            ("밤 11시, 유튜브 알고리즘이 '미국 대형주 ETF 하나로 끝내는 투자법' 영상을 추천했다. 호기심에 클릭했다가 세 편을 연달아 봤다. 개별 종목을 고르는 스트레스 없이 시장 전체에 투자한다는 개념이 솔깃했다. {name}은 맥주를 내려놓고 메모장을 꺼냈다.", "夜11時、YouTubeのおすすめに『米国大型株ETF一つで完結する投資法』という動画が出てきた。興味を引かれてクリックし、そのまま3本続けて見た。個別銘柄を選ぶストレスなしに、市場全体へ投資するという考え方は魅力的だった。{name}はビールを置き、メモ帳を取り出した。", ["3","三","３","4","本続けて","人続けて","見た。","見るつもりだ。"]),
            ("잘 모르지만 일단 발을 담갔다. 100달러짜리 경험이 앞으로 1000달러를 지켜줄 것이다.", "よく分からないが、ひとまず足を踏み入れた。100ドルの経験が、この先の1,000ドルを守ってくれるだろう。", ["100","百","１００","101","ドルの経験","ウォンの経験","この先の1,000ドルを守ってくれるだろう","この先の1,000ドルを守った"]),
            ("시장 평균보다 낮아도, 원금을 지키며 1년을 버텼다는 게 이미 대단한 일이다. 내일의 {name}은 오늘보다 강하다.", "市場平均を下回っても、元本を守りながら一年間持ちこたえた。それだけで十分すごいことだ。明日の{name}は、今日より強い。", ["一","1","１","二","年間","か月間","持ちこたえた","持ちこたえたい"]),
            ("1월 1일, {name}은 증권사 앱에서 '연간 수익률 리포트'를 열었다. +7.3%. 코스피 기준치는 +11.2%. 1년 동안 열심히 했는데 시장 평균을 못 이겼다는 숫자가 화면에 박혀 있다. 잘한 건지 못한 건지, 뭘 바꿔야 할지, 그냥 괜찮은 건지 — 아무도 정답을 알려주지 않는다.", "1月1日、{name}は証券会社のアプリで『年間収益率レポート』を開いた。+7.3%。KOSPIの基準値は+11.2%。一年間頑張ったのに、市場平均には勝てなかった。その数字が画面に突き刺さっている。よかったのか、悪かったのか。何を変えるべきなのか、このままでいいのか――誰も正解を教えてはくれない。", ["一年間","1年間","１年間","二年間","一年間頑張","一か月間頑張","頑張ったのに","頑張るつもりなのに"]),
            ("1년 수익률 점검", "一年の収益率を振り返る", ["一","1","１","二","年の","か月の","収益率を振り返る","収益率を保証する"]),
            ("저녁 뉴스에서 경제학자 세 명이 동시에 '부동산 버블 붕괴가 임박했다'고 경고했다. 댓글창엔 '이번엔 진짜다'와 '맨날 틀린 소리'가 반반이다. {name}의 포트폴리오에는 부동산 리츠가 꽤 많이 담겨 있다. 불안한 마음에 커피를 마시며 수익률 화면을 계속 새로고침 했다.", "夕方のニュースで、経済学者3人がそろって『不動産バブルの崩壊が迫っている』と警告した。コメント欄は『今度こそ本当だ』と『いつも外れてばかり』が半々だ。{name}のポートフォリオには、不動産REITがかなり入っている。不安を抱え、コーヒーを飲みながら収益率の画面を何度も更新した。", ["3","三","３","4","人が","時間が","経済学者","投資家"]),
            ("세 시간 뒤 결론 없이 영상 탭을 닫았지만, 적어도 리밸런싱의 원칙은 이해했다. 지식이 쌓이면 결정이 조금씩 빨라진다.", "3時間後、結論の出ないまま動画のタブを閉じた。それでも、少なくともリバランスの原則は理解できた。知識が積み重なるほど、決断は少しずつ速くなる。", ["3","三","３","4","時間後","日後","閉じた。","閉じるつもりだ。"]),
            ("요즘 핫한 K-뷰티 스타트업 공모주 청약이 열렸다. SNS에선 '상장 당일 따상 확실'이라는 말이 돈다. 경쟁률은 이미 820대 1을 넘겼고, 증권사 앱은 터질 듯 느리다. {name}은 청약 증거금 50만 원을 준비해두고 클릭을 망설이고 있다.", "今話題のKビューティー系スタートアップが、公募株の申し込みを受け付け始めた。SNSでは『上場日に初値2倍、そのままストップ高は確実』という話が飛び交っている。倍率はすでに820対1を超え、証券会社のアプリはパンクしそうなほど遅い。{name}は申込証拠金50万ウォンを用意して、クリックをためらっている。", ["2","二","２","3","倍、そのまま","歳、そのまま","という話が飛び交っている","と実現した"]),
            ("세금 신고 시즌이 왔다. 홈택스 화면을 열었다가 모르는 항목이 너무 많았다. 친구에게 물어보니 '배당·이자 소득이 2000만 원 넘으면 종합과세 대상이야'라고 한다. {name}의 작년 금융소득을 계산해보니 그 선이 아슬아슬하다. 세금을 잘못 내면 나중에 더 큰 문제가 생길 수 있다.", "税金の申告時期が来た。ホームタックスの画面を開くと、分からない項目だらけだった。友人に聞くと『配当と利子の所得が2,000万ウォンを超えると、総合課税の対象だよ』と言う。{name}が昨年の金融所得を計算すると、その境目にぎりぎりだ。税金を間違えて納めれば、後でもっと大きな問題になりかねない。", ["2,000万","二千万","2000万","2,001万","ウォン","ドル","を超えると","に届かなくても"]),
            ("유튜브 알고리즘이 보여준 영상이었다.\n'3배 레버리지 ETF, 1년 수익률 280%'\n\n댓글창은 열광했고, 몇몇은 '나도 했다'고 썼다.\n\n{name}은 계산기를 꺼냈다.\n지금 가진 돈에 3을 곱하면.", "YouTubeのおすすめに出てきた動画だった。\n『3倍レバレッジETF、一年の収益率280%』\n\nコメント欄は熱狂し、何人かは『自分もやった』と書いていた。\n\n{name}は電卓を取り出した。\n今あるお金に、3を掛けたら。", ["一年","1年","１年","二年","年の収益率","か月の収益率","『3倍レバレッジETF、","自分の3倍レバレッジETF、"]),
            ("3억 2천. 그냥 나를 위한 돈이 아니다.\n\n언젠가 아이를 키우려면, 지금 이 싸움에서 지면 안 된다. 두렵지만, 동시에 목표가 선명해지는 기분이었다.", "3億2,000万。ただ自分のためのお金ではない。\n\nいつか子どもを育てるなら、今のこの戦いには負けられない。怖かったが、同時に目標がはっきりしていく気がした。", ["3億2,000万","三億二千万","320000000","3億2,001万","3億2,000万。","3億2,000万ドル。","ただ自分のためのお金ではない","ただ自分のための借金だった"]),
            ("뉴스 기사를 보다가 손이 멈췄다.\n「자녀 1인당 양육비 평균 3억 2천만 원」\n\n민준은 잠깐 계산기를 켰다. 대학까지 보내면 월 얼마가 드나. 사교육까지 더하면.\n\n숫자가 쌓일수록 가슴 한쪽이 무거워졌다.", "ニュース記事を読んでいて、手が止まった。\n『子ども一人当たりの養育費、平均3億2,000万ウォン』\n\nミンジュンは少しの間、電卓を使った。大学まで行かせたら、月にいくらかかるのか。塾や習い事も加えたら。\n\n数字が積み上がるほど、胸の片側が重くなった。", ["一人","1人","１人","二人","人当たり","年間当たり","平均3億2,000万ウォン","合計3億2,000万ウォン"]),
            ("이모티콘 몇 개 보내고 카톡창을 닫았다.\n\n서른셋. 대체 나는 뭘 하고 있나. 잠깐 그런 생각이 지나갔다. 지워야 할 생각이었지만, 쉽게 안 지워졌다.", "スタンプをいくつか送り、カカオトークを閉じた。\n\n33歳。一体、自分は何をしているんだろう。ふと、そんな考えがよぎった。消すべき考えだったが、簡単には消えなかった。", ["33","三十三","３３","34","歳。一体","年。一体","一体、自分","一体、友人"]),
            ("고등학교 친구에게서 카톡이 왔다.\n「야 나 임신했어. 다음 달에 돌잔치 아니고… 아 그 전에 결혼식 먼저. 하하.」\n\n축하 이모티콘을 보내면서 민준은 잠깐 멈췄다.\n같은 나이다. 서른셋. 그 친구는 이미 다음 챕터로 넘어가고 있다.", "高校時代の友人からカカオトークが来た。\n「ねえ、妊娠したんだ。来月は一歳のお祝いじゃなくて……あ、その前に結婚式が先だね。はは」\n\nお祝いのスタンプを送りながら、ミンジュンはふと手を止めた。\n同い年だ。33歳。その友人は、もう次の章へ進んでいる。", ["33","三十三","３３","34","33歳","33年","同い年だ","年が違う"]),
            ("뉴스 헤드라인이 눈에 들어왔다.\n「국민연금 2055년 완전 고갈 전망... 지금 서른 세대는 한 푼도 못 받을 수도」\n\n2055년. 지금은 멀어 보여도, 민준이 노후를 살아갈 시간 안에 있는 해였다.\n\n그냥 지나치기엔 숫자가 너무 구체적이었다.", "ニュースの見出しが目に入った。\n『国民年金、2055年に完全枯渇の見通し……今30歳の世代は、一銭も受け取れない可能性も』\n\n2055年。今は遠く見えても、ミンジュンが老後を過ごす時間の中にある年だった。\n\n見過ごすには、数字があまりにも具体的だった。", ["30","三十","３０","31","歳の世代","年の世代","可能性も","ことは確実だ"]),
            ("짐을 정리하다가 대학 1학년 때 노트가 나왔다.\n\n「10년 안에 내 이름을 건 회사를 만들겠다. 30살에 세상을 바꾸겠다.」\n\n그때의 글씨가 지금보다 굵었다.", "荷物を整理していたら、大学一年生のときのノートが出てきた。\n\n『10年以内に自分の名を掲げた会社を作る。30歳で世界を変える』\n\nあの頃の字は、今より太かった。", ["一年生","1年生","１年生","二年生","年生のとき","年間後","大学一年生のときの","大学卒業のときの"]),
            ("\"알겠습니다\" 하고 나왔다.\n\n1년을 갈아넣었다. B+. 다음 해도 같은 말을 듣게 될 것 같은 기분이 들었다. 이 회사에서 S는 가능한 걸까.", "「分かりました」と言って出た。\n\n一年をすり減らして働いた。B+。来年も同じことを言われそうな気がした。この会社でSは取れるのだろうか。", ["一年","1年","１年","二年","年をすり減らして","日をすり減らして","働いた。","働くつもりだ。"]),
        )

    def test_investment_life_written_quantity_normals(self):
        for source, target, edits in self._investment_life_quantity_examples():
            old, native, wide, *_ = edits
            leaf = tool.Leaf('events', 'quantity_fixture', 'content/events/source.json',
                             ('description',), source, 'shipping')
            for text in (target, target.replace(old, native, 1), target.replace(old, wide, 1)):
                with self.subTest(source=source, text=text):
                    self.assertEqual(tool.translation_errors(leaf, 'ja', text), [])

    def test_investment_life_quantity_value_role_state_mutations(self):
        for source, target, edits in self._investment_life_quantity_examples():
            old, native, wide, wrong, unit, wrong_unit, state, wrong_state = edits
            leaf = tool.Leaf('events', 'quantity_fixture', 'content/events/source.json',
                             ('description',), source, 'shipping')
            mutants = (
                target.replace(old, wrong, 1),
                target.replace(old, '+' + old, 1),
                target.replace(unit, wrong_unit, 1),
                target.replace(state, wrong_state, 1),
                target.replace(old, wrong, 1) + target,
            )
            for text in mutants:
                with self.subTest(source=source, text=text):
                    self.assertNotEqual(text, target)
                    self.assertTrue(any('source-bound investment/life' in e
                                        for e in tool.translation_errors(leaf, 'ja', text)))
        # Both USD amounts remain assigned to different experience/future roles.
        source, target, _ = self._investment_life_quantity_examples()[5]
        wrong = target.replace('100ドル', '1,000ドル').replace('この先の1,000ドル', 'この先の100ドル')
        leaf = tool.Leaf('events', 'quantity_fixture', 'content/events/source.json',
                         ('description',), source, 'shipping')
        self.assertTrue(any('source-bound investment/life' in e
                            for e in tool.translation_errors(leaf, 'ja', wrong)))
        # Untouched Arabic numbers also retain their attribution/order.
        source, target, _ = self._investment_life_quantity_examples()[7]
        wrong = target.replace('+7.3%', '+TEMP%').replace('+11.2%', '+7.3%').replace('+TEMP%', '+11.2%')
        leaf = tool.Leaf('events', 'quantity_fixture', 'content/events/source.json',
                         ('description',), source, 'shipping')
        self.assertIn('source-bound investment/life ordered numeric ownership mismatch',
                      tool.translation_errors(leaf, 'ja', wrong))

    def test_investment_life_quantity_source_licence_boundaries(self):
        for source, target, _ in self._investment_life_quantity_examples():
            for changed in (source + ' 다른 장면.', '다른 인물. ' + source, source + '\n'):
                with self.subTest(source=changed):
                    self.assertNotEqual(changed, source)
                    # Licence OFF is deliberately not a claim that the generic
                    # semantic checker rejects every altered Korean narrative.
                    self.assertIsNone(tool._ja_investment_life_numbers(changed, target))


    def test_investment_life_three_reported_natural_regressions(self):
        # Only the three disclosed normal readings and implementation-owned
        # value/unit pairs; ROOT/independent hidden input files are not loaded.
        cases = (
            ("1년 수익률 점검", "1年間の収益率を見直す", [["1年間","2年間"],["1年間","1か月間"]]),
            ("\"알겠습니다\" 하고 나왔다.\n\n1년을 갈아넣었다. B+. 다음 해도 같은 말을 듣게 될 것 같은 기분이 들었다. 이 회사에서 S는 가능한 걸까.", "「承知しました」と言って、その場を出た。\n\nこの一年を仕事につぎ込んだ。B+。来年もまた同じ言葉が返ってきそうだった。この会社でS評価を得ることはできるのだろうか。", [["この一年","この二年"],["この一年","この一か月"]]),
            ("잘 모르지만 일단 발을 담갔다. 100달러짜리 경험이 앞으로 1000달러를 지켜줄 것이다.", "詳しくは分からないが、ひとまず踏み込んでみた。ここで得た100ドル分の経験が、これからの1,000ドルを守ってくれるはずだ。", [["100ドル分","1,000ドル分"],["100ドル分","100円分"]]),
        )
        for source, target, edits in cases:
            leaf = tool.Leaf('events', 'quantity_fixture', 'content/events/source.json',
                             ('description',), source, 'shipping')
            with self.subTest(normal=target):
                self.assertEqual(tool.translation_errors(leaf, 'ja', target), [])
            for old, new in edits:
                wrong = target.replace(old, new, 1)
                with self.subTest(wrong=wrong):
                    self.assertNotEqual(wrong, target)
                    self.assertTrue(any('source-bound investment/life' in e
                                        for e in tool.translation_errors(leaf, 'ja', wrong)))
        source, target, _ = cases[2]
        wrong = target.replace('100ドル分', '1,000ドル分').replace(
            'これからの1,000ドル', 'これからの100ドル',
        )
        leaf = tool.Leaf('events', 'quantity_fixture', 'content/events/source.json',
                         ('description',), source, 'shipping')
        self.assertTrue(any('source-bound investment/life' in e
                            for e in tool.translation_errors(leaf, 'ja', wrong)))


    @staticmethod
    def _market_admin_owner_cases():
        # Pre-code implementation-owned fixture b3a1d45c03778a5a35a58cfa2e0d6c334c8abd77a1782e167fe71d8039777b10.
        # ROOT's independent hidden14 are neither read nor loaded here.
        return (
            ["actual-0","actual",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["actual-1","actual",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["actual-2","actual",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の四大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["actual-3","actual",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二次会はカラオケ、三次会はポジャンマチャ。","ja"],
            ["actual-4","actual",4,"1차까지만 — 일찍 빠진다","一次会だけ――早めに抜ける","ja"],
            ["actual-5","actual",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一次会のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["actual-6","actual",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["actual-7","actual",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["actual-8","actual",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、三回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["actual-9","actual",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ウォンを突破」\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["actual-10","actual",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["actual-11","actual",11,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["actual-12","actual",12,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
            ["normal-0-0","natural",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを2件解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["normal-0-1","natural",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二件解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["normal-1-0","natural",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：四百九十六万七千八百ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["normal-1-1","natural",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：4,967,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["normal-2-0","natural",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の4大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["normal-2-1","natural",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の４大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["normal-3-0","natural",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、2次会はカラオケ、3次会はポジャンマチャ。","ja"],
            ["normal-3-1","natural",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、第二次会はカラオケ、第三次会はポジャンマチャ。","ja"],
            ["normal-4-0","natural",4,"1차까지만 — 일찍 빠진다","1次会まで――早めに帰る","ja"],
            ["normal-4-1","natural",4,"1차까지만 — 일찍 빠진다","一軒目だけ――早めに抜ける","ja"],
            ["normal-5-0","natural",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」1次会のサムギョプサルの店を出た。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["normal-5-1","natural",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一次会のサムギョプサルで帰った。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["normal-6-0","natural",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n深夜2時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["normal-6-1","natural",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前２時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["normal-7-0","natural",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n2時間経ってから、再び開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["normal-7-1","natural",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間後、もう一度開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["normal-8-0","natural",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は2〜3回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["normal-8-1","natural",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二～三回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["normal-9-0","natural",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均二十五億ウォンを突破」\n\n二十五億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["normal-9-1","natural",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均2,500,000,000ウォンを突破」\n\n2,500,000,000ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["normal-10-0","natural",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%. REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["normal-10-1","natural",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。REITs -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["normal-11-0","natural",11,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%. REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["normal-12-0","natural",12,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%. REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
            ["target-0-0","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを三つ解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-1","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを-二つ解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-2","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二日解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-3","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約しなかった。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-4","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約するつもりだ。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-5","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約した。\n合計4万9千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-6","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約した。\n合計4万8千ドル。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-0-7","target",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約した。\n合計4万9千ウォン。合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["target-1-0","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,900ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-1","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：-496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-2","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,800ドル。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-3","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：34,200ウォン。\n当座貸越の利用可能残額：496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-4","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用済み金額：496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-5","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,800ウォン／月。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-6","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,900ウォン。496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-1-7","target",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：496万7,800ウォン。\n当座貸越の利用可能残額：496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["target-2-0","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の五大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-1","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の-四大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-2","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の四年間の社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-3","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の四大社会保険が適用されず、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-4","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の四大社会保険が適用される予定で、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-5","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-6","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の五大社会保険が適用され、四大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-2-7","target",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。日本の四大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["target-3-0","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、三次会はカラオケ、二次会はポジャンマチャ。","ja"],
            ["target-3-1","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、-二次会はカラオケ、三次会はポジャンマチャ。","ja"],
            ["target-3-2","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二時間はカラオケ、三次会はポジャンマチャ。","ja"],
            ["target-3-3","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二次会はポジャンマチャ、三次会はポジャンマチャ。","ja"],
            ["target-3-4","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二次会はカラオケ、三次会はカラオケ。","ja"],
            ["target-3-5","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二次会はカラオケではない、三次会はポジャンマチャ。","ja"],
            ["target-3-6","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、三次会はポジャンマチャ。","ja"],
            ["target-3-7","target",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、四次会はカラオケ、二次会はカラオケ、三次会はポジャンマチャ。","ja"],
            ["target-4-0","target",4,"1차까지만 — 일찍 빠진다","二次会だけ――早めに抜ける","ja"],
            ["target-4-1","target",4,"1차까지만 — 일찍 빠진다","-一次会だけ――早めに抜ける","ja"],
            ["target-4-2","target",4,"1차까지만 — 일찍 빠진다","一時間だけ――早めに抜ける","ja"],
            ["target-4-3","target",4,"1차까지만 — 일찍 빠진다","一次会だけ――最後まで残る","ja"],
            ["target-4-4","target",4,"1차까지만 — 일찍 빠진다","一次会だけ――早めには抜けない","ja"],
            ["target-4-5","target",4,"1차까지만 — 일찍 빠진다","一次会も二次会も――早めに抜ける","ja"],
            ["target-4-6","target",4,"1차까지만 — 일찍 빠진다","早めに抜ける","ja"],
            ["target-4-7","target",4,"1차까지만 — 일찍 빠진다","二次会だけ。一次会だけ――早めに抜ける","ja"],
            ["target-5-0","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」二次会のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-1","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」-一次会のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-2","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一日目のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-3","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一次会のサムギョプサルで切り上げなかった。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-4","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一次会のサムギョプサルで切り上げるつもりだ。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-5","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」サムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-6","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」二次会のサムギョプサルで切り上げた。一次会のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-5-7","target",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一次会のカラオケで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["target-6-0","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前三時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["target-6-1","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前-二時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["target-6-2","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二日、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["target-6-3","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午後二時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["target-6-4","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二時、手はまた画面を求めたが、アプリはあった。","ja"],
            ["target-6-5","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n手はまた画面を求めたが、アプリはなかった。","ja"],
            ["target-6-6","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前三時、午前二時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["target-6-7","target",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二時、手はまた画面を求めるだろうが、アプリはなかった。","ja"],
            ["target-7-0","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n三時間後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-1","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n-二時間後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-2","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二日後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-3","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間前に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-4","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間後に、また開かなかった。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-5","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間後に、また開くつもりだ。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-6","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\nまた開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-7-7","target",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n三時間後に、また開いた。二時間後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["target-8-0","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は三、二回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-1","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は-二、三回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-2","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、三年は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-3","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-4","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、四回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-5","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、三回に達した」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-6","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、三回はないらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-8-7","target",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は三、四回、二、三回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["target-9-0","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均26億ウォンを突破」\n\n26億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-1","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均-25億ウォンを突破」\n\n-25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-2","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ドルを突破」\n\n25億ドル。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-3","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25万ウォンを突破」\n\n25万ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-4","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ウォンに届かなかった」\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-5","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ウォンを突破するだろう」\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-6","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ウォンを突破」\n\n\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-9-7","target",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均26億ウォンを突破。平均25億ウォンを突破」\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["target-10-0","target",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 +3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["target-10-1","target",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n%sはポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["target-10-2","target",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。%s REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["target-11-0","target",11,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司+3.2%。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["target-11-1","target",11,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%。REITs -4.1%。房地产平台-2.8%。\n\n%s看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["target-11-2","target",11,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%。%s REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["target-12-0","target",12,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司+3.2%。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
            ["target-12-1","target",12,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%。REITs -4.1%。房地產平台-2.8%。\n\n%s看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
            ["target-12-2","target",12,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%。%s REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
            ["source-0-0","source",0,"구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.\n다른 문맥이다.","サブスクを二つ解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["source-0-1","source",0,"다른 화자: 구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約した。\n合計4万8千ウォン。\n家賃の値上げ分を、ほかのところで埋め合わせた。","ja"],
            ["source-1-0","source",1,"오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.\n다른 문맥이다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["source-1-1","source",1,"다른 화자: 오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n数字：-34,200ウォン。\n当座貸越の利用可能残額：496万7,800ウォン。\n\n{name}はアプリを閉じて、また開いた。\n数字は変わっていなかった。","ja"],
            ["source-2-0","source",2,"편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.\n다른 문맥이다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の四大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["source-2-1","source",2,"다른 화자: 편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.","コンビニのアルバイト募集。時給10,320ウォン。\n最低賃金だ。韓国の四大社会保険が適用され、週休手当を含めると、実質の時給はもう少し高い。\n\nコンビニの店長が履歴書に目を通した。\n「今、ほかのバイトはしていますか？」最初の質問だった。","ja"],
            ["source-3-0","source",3,"팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.\n다른 문맥이다.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二次会はカラオケ、三次会はポジャンマチャ。","ja"],
            ["source-3-1","source",3,"다른 화자: 팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.","チーム長が、カカオトークのグループにメッセージを送った。\n「今夜は飲み会！ みなさん参加をお願いします :)」\n\n疑問符はない。お願いではあるが、断りにくい。\nサムギョプサルの店、二次会はカラオケ、三次会はポジャンマチャ。","ja"],
            ["source-4-0","source",4,"1차까지만 — 일찍 빠진다\n다른 문맥이다.","一次会だけ――早めに抜ける","ja"],
            ["source-4-1","source",4,"다른 화자: 1차까지만 — 일찍 빠진다","一次会だけ――早めに抜ける","ja"],
            ["source-5-0","source",5,"\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.\n다른 문맥이다.","「明日、用事がありまして」一次会のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["source-5-1","source",5,"다른 화자: \"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.","「明日、用事がありまして」一次会のサムギョプサルで切り上げた。\n\nチーム長は「そうか、先に帰りな」と言った。表情は読みにくかった。\nこの空気をどう受け止めればいいのかは、まだ分からない。","ja"],
            ["source-6-0","source",6,"다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.\n다른 문맥이다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["source-6-1","source",6,"다른 화자: 다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二時、手はまた画面を求めたが、アプリはなかった。","ja"],
            ["source-7-0","source",7,"화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.\n다른 문맥이다.","画面を閉じた。\n二時間後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["source-7-1","source",7,"다른 화자: 화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間後に、また開いた。\n市場は上下に揺れたあと、元の位置に戻っていた。","ja"],
            ["source-8-0","source",8,"직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.\n다른 문맥이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、三回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["source-8-1","source",8,"다른 화자: 직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、こっそり情報を教えてくれた。\n「今度のAI半導体関連企業のIPO株、機関投資家がすごく推してるんだ。\n均等配分で申し込めば、ストップ高は二、三回は堅いらしいよ」\n\n申込証拠金は拘束されるし、割り当てられるかは運次第だが、\n今の市場の雰囲気なら、来そうな気がする。\n何にいくら入れるかが肝心だ。","ja"],
            ["source-9-0","source",9,"뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.\n다른 문맥이다.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ウォンを突破」\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["source-9-1","source",9,"다른 화자: 뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n「カンナムのマンション、平均25億ウォンを突破」\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nでも、あのマンションに住む人たちは、どうやって買ったのだろう。","ja"],
            ["source-10-0","source",10,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.\n다른 문맥이다.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["source-10-1","source",10,"다른 화자: 전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja"],
            ["source-11-0","source",11,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.\n다른 문맥이다.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["source-11-1","source",11,"다른 화자: 전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN"],
            ["source-12-0","source",12,"전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.\n다른 문맥이다.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
            ["source-12-1","source",12,"다른 화자: 전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW"],
        )

    def test_market_admin_owned_actual_and_natural_quantities(self):
        for key, group, context, source, target, locale in self._market_admin_owner_cases():
            if group not in ("actual", "natural"):
                continue
            leaf = tool.Leaf("events", "market_admin_fixture", "content/events/source.json",
                             ("description",), source, "shipping")
            with self.subTest(case=key, locale=locale):
                self.assertEqual(tool.translation_errors(leaf, locale, target), [])

    def test_market_admin_owned_value_unit_role_state_mutations(self):
        for key, group, context, source, target, locale in self._market_admin_owner_cases():
            if group != "target":
                continue
            leaf = tool.Leaf("events", "market_admin_fixture", "content/events/source.json",
                             ("description",), source, "shipping")
            with self.subTest(case=key, locale=locale):
                errors = tool.translation_errors(leaf, locale, target)
                self.assertTrue(errors)
                if context < 10:
                    # Do not borrow an unrelated money/placeholder diagnosis as
                    # evidence that the new role/quantity contract rejected it.
                    self.assertTrue(any("source-bound market/admin" in e for e in errors))

    def test_market_admin_owned_source_licence_boundaries(self):
        for key, group, context, source, target, locale in self._market_admin_owner_cases():
            if group != "source":
                continue
            with self.subTest(case=key, locale=locale):
                if context < 10:
                    self.assertIsNone(tool._ja_market_admin_numbers(source, target))
                else:
                    self.assertIsNone(tool._sector_literal_percent_pair(source, target))
                # Licence OFF is not a claim that generic semantic validation
                # detects every changed source narrative.


    def test_sector_percent_literal_repair_preserves_rate_slots(self):
        # Separate 15-case supplement, not a change to the original 152 inputs.
        cases = (
            ["ja-normal","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja","pass"],
            ["ja-unit","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2ドル。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja","typed_reject"],
            ["ja-order","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -4.1%。REIT -3.2%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja","typed_reject"],
            ["ja-line","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n建設会社 -3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n不動産関連の銘柄が、取引開始から下がっていた。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja","typed_reject"],
            ["ja-extra","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","チョンセ詐欺の被害者が300人というニュースが出た。\n\n不動産関連の銘柄が、取引開始から下がっていた。\n建設会社 -3.2%、-3.2%。REIT -4.1%。不動産プラットフォーム -2.8%。\n\n{name}はポートフォリオを見た。\n恐怖が価格を決めるとき、今が好機なのか、まだ底ではないのか。","ja","typed_reject"],
            ["zh-CN-normal","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN","pass"],
            ["zh-CN-unit","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2ドル。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN","typed_reject"],
            ["zh-CN-order","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-4.1%。REITs -3.2%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN","typed_reject"],
            ["zh-CN-line","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n建筑公司-3.2%。REITs -4.1%。房地产平台-2.8%。\n房地产相关股票从开盘起就在下跌。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN","typed_reject"],
            ["zh-CN-extra","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","一则涉及300名受害者的全租诈骗新闻爆了出来。\n\n房地产相关股票从开盘起就在下跌。\n建筑公司-3.2%、-3.2%。REITs -4.1%。房地产平台-2.8%。\n\n{name}看着投资组合。\n当恐惧左右价格，现在是机会，还是尚未见底？","zh-CN","typed_reject"],
            ["zh-TW-normal","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW","pass"],
            ["zh-TW-unit","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2ドル。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW","typed_reject"],
            ["zh-TW-order","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-4.1%。REITs -3.2%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW","typed_reject"],
            ["zh-TW-line","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n建設公司-3.2%。REITs -4.1%。房地產平台-2.8%。\n房地產相關股票從開盤就一路下跌。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW","typed_reject"],
            ["zh-TW-extra","전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가.","全租詐騙受害者達300人的新聞爆了出來。\n\n房地產相關股票從開盤就一路下跌。\n建設公司-3.2%、-3.2%。REITs -4.1%。房地產平台-2.8%。\n\n{name}看著投資組合。\n恐懼正在決定價格，此刻是機會，還是尚未見底？","zh-TW","typed_reject"],
        )
        for key, source, target, locale, expected in cases:
            leaf = tool.Leaf("events", "sector_fixture", "content/events/source.json",
                             ("description",), source, "shipping")
            with self.subTest(case=key):
                errors = tool.translation_errors(leaf, locale, target)
                if expected == "pass":
                    self.assertEqual(errors, [])
                else:
                    self.assertTrue(any("source-bound sector percentage" in e for e in errors))


    def test_market_admin_disclosed_natural_regressions(self):
        # ROOT explicitly disclosed JA6 and Plato JA4 after B1. These 20 inputs
        # are fixed regressions now, not fresh independent evidence.
        cases = (
            ["plato208_01_mixed_won_available_limit-normal","오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n表示された数字は-34,200ウォン。\n当座貸越の残り利用可能額は496万7,800ウォン。\n\n{name}はアプリを閉じ、もう一度開いた。\n数字は変わっていなかった。","pass"],
            ["plato208_01_mixed_won_available_limit-mutant","오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.","午前8時41分。\n銀行アプリの通知が鳴った。\n\n「残高がマイナスです。当座貸越の利息が適用されます」\n\n表示された数字は-34,200ウォン。\n当座貸越の残り利用可能額は496万8,700ウォン。\n\n{name}はアプリを閉じ、もう一度開いた。\n数字は変わっていなかった。","typed_reject"],
            ["plato208_02_purchase_fraction_not_duration-normal","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","三分の一を買い付けた。\n翌日、そこからさらに2%下がった。\nもう三分の一を買い増した。分けて買う理由は、ここにあった。","pass"],
            ["plato208_02_purchase_fraction_not_duration-mutant","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","三分間、買い付けた。\n翌日、そこからさらに2%下がった。\nもう三分の一を買い増した。分けて買う理由は、ここにあった。","typed_reject"],
            ["plato208_08_ipo_reported_two_or_three_limit_ups-normal","직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、そっと情報を教えてくれた。\n「今度のAI半導体関連企業の新規公開株、機関投資家がかなり推しているんだ。\n均等割当で申し込めば、二度、三度のストップ高は当たり前らしいよ」\n\n申込証拠金は拘束され、割り当てられるかどうかは運次第だが、\n今の市場の雰囲気を見ていると、来そうな気がする。\n何をどれだけ入れるかが肝心だ。","pass"],
            ["plato208_08_ipo_reported_two_or_three_limit_ups-mutant","직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.","職場の先輩が、そっと情報を教えてくれた。\n「今度のAI半導体関連企業の新規公開株、機関投資家がかなり推しているんだ。\n均等割当で申し込めば、二十回、三十回のストップ高は当たり前らしいよ」\n\n申込証拠金は拘束され、割り当てられるかどうかは運次第だが、\n今の市場の雰囲気を見ていると、来そうな気がする。\n何をどれだけ入れるかが肝心だ。","typed_reject"],
            ["plato208_10_subscription_count_and_combined_total-normal","구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","利用していたサブスクを二つ解約した。\n合わせて4万8千ウォン。\n家賃の値上げ分を、ほかの支出を削って埋め合わせた。","pass"],
            ["plato208_10_subscription_count_and_combined_total-mutant","구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","利用していたサブスクを三つ解約した。\n合わせて4万8千ウォン。\n家賃の値上げ分を、ほかの支出を削って埋め合わせた。","typed_reject"],
            ["root_events:disasters_001:/choices/1/result_text-normal","구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを二つ解約した。\n合わせて4万8千ウォン。\n家賃の値上がり分を、ほかの出費を削って埋めた。","pass"],
            ["root_events:disasters_001:/choices/1/result_text-mutant","구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.","サブスクを三つ解約した。\n合わせて4万8千ウォン。\n家賃の値上がり分を、ほかの出費を削って埋めた。","typed_reject"],
            ["root_events:disasters_014:/choices/1/result_text-normal","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","三分の一を買った。\n翌日、さらに2%下がった。\nもう三分の一を買い足した。分けて買うのは、そのためだった。","pass"],
            ["root_events:disasters_014:/choices/1/result_text-mutant","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","三分の二を買った。\n翌日、さらに2%下がった。\nもう三分の一を買い足した。分けて買うのは、そのためだった。","typed_reject"],
            ["root_events:market_crash_panic:/choices/0/result_text-normal","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n二か月後、市場は50%反発し、そのポジションの価値は二倍になった。","pass"],
            ["root_events:market_crash_panic:/choices/0/result_text-mutant","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n三か月後、市場は50%反発し、そのポジションの価値は二倍になった。","typed_reject"],
            ["root_events:gambling_002:/choices/0/result_text-normal","다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前二時、手はまた画面に伸びたが、アプリは入っていなかった。","pass"],
            ["root_events:gambling_002:/choices/0/result_text-mutant","다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.","ダウンロード画面を閉じ、グループチャットの通知も切った。\n午前三時、手はまた画面に伸びたが、アプリは入っていなかった。","typed_reject"],
            ["root_events:politics_003:/choices/1/result_text-normal","화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n二時間後、もう一度開いた。\n市場は上下に揺れた末、元の水準に戻っていた。","pass"],
            ["root_events:politics_003:/choices/1/result_text-mutant","화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.","画面を閉じた。\n三時間後、もう一度開いた。\n市場は上下に揺れた末、元の水準に戻っていた。","typed_reject"],
            ["root_events:real_estate_news:/description-normal","뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n『カンナムのマンション平均価格、25億ウォンを突破』\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nあのマンションに住む人たちは、どうやって買ったのだろう。","pass"],
            ["root_events:real_estate_news:/description-mutant","뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.","ニュースをつけた。\n\n『カンナムのマンション平均価格、25万ウォンを突破』\n\n25億ウォン。\n今の{name}の口座残高の何倍なのか、計算できなかった。\n\nあのマンションに住む人たちは、どうやって買ったのだろう。","typed_reject"],
        )
        for key, source, target, expected in cases:
            leaf = tool.Leaf("events", "market_admin_regression", "content/events/source.json",
                             ("description",), source, "shipping")
            with self.subTest(case=key):
                errors = tool.translation_errors(leaf, "ja", target)
                if expected == "pass":
                    self.assertEqual(errors, [])
                else:
                    self.assertTrue(any("source-bound market/admin" in e for e in errors))

    def test_market_admin_fraction_and_rebound_owned_boundaries(self):
        # 24 implementation-owned cases presealed before B2 changes. Fractions
        # retain denominator/numerator and both completed purchase positions.
        cases = (
            ["own-new-0","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買った。\n翌日、さらに2%下がった。\n追加でもう3分の1を買った。分けて買うのは、このためだった。","pass"],
            ["own-new-0-natural","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","1/3を買った。\n翌日、さらに2%下がった。\n追加でもう1/3を買った。分けて買うのは、このためだった。","pass"],
            ["own-new-0-target-0","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の2を買った。\n翌日、さらに2%下がった。\n追加でもう3分の2を買った。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-1","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","-3分の1を買った。\n翌日、さらに2%下がった。\n追加でもう-3分の1を買った。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-2","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分間、買った。\n翌日、さらに2%下がった。\n追加でもう3分間、買った。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-3","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買った。\n翌日、さらに3%下がった。\n追加でもう3分の1を買った。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-4","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買うつもりだ。\n翌日、さらに2%下がった。\n追加でもう3分の1を買うつもりだ。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-5","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買わなかった。\n翌日、さらに2%下がった。\n追加でもう3分の1を買わなかった。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-6","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買った。\n翌日、さらに2%下がった。\n追加でもう4分の1を買った。追加でもう3分の1を買った。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-target-7","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買った。\n先月、さらに2%下がった。\n追加でもう3分の1を買った。分けて買うのは、このためだった。","typed_reject"],
            ["own-new-0-source-0","3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.\n다른 문맥.","3分の1を買った。\n翌日、さらに2%下がった。\n追加でもう3分の1を買った。分けて買うのは、このためだった。","licence_off"],
            ["own-new-0-source-1","別の話。3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.","3分の1を買った。\n翌日、さらに2%下がった。\n追加でもう3分の1を買った。分けて買うのは、このためだった。","licence_off"],
            ["own-new-1","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月後、市場は50%反発し、そのポジションは二倍になった。","pass"],
            ["own-new-1-natural","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n二ヶ月後、市場は50%反発し、そのポジションは2倍になった。","pass"],
            ["own-new-1-target-0","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n3か月後、市場は50%反発し、そのポジションは二倍になった。","typed_reject"],
            ["own-new-1-target-1","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n-2か月後、市場は50%反発し、そのポジションは二倍になった。","typed_reject"],
            ["own-new-1-target-2","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2日後、市場は50%反発し、そのポジションは二倍になった。","typed_reject"],
            ["own-new-1-target-3","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月後、市場は40%反発し、そのポジションは二倍になった。","typed_reject"],
            ["own-new-1-target-4","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月後、市場は50%反発し、そのポジションは三倍になった。","typed_reject"],
            ["own-new-1-target-5","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月後、市場は50%反発し、そのポジションは二年になった。","typed_reject"],
            ["own-new-1-target-6","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月後、市場は50%反発し、そのポジションは二倍になる予定だ。","typed_reject"],
            ["own-new-1-target-7","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月前、市場は50%反発し、そのポジションは二倍になった。","typed_reject"],
            ["own-new-1-source-0","공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.\n다른 문맥.","恐怖の中で買うことができた。\n2か月後、市場は50%反発し、そのポジションは二倍になった。","licence_off"],
            ["own-new-1-source-1","別の話。공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.","恐怖の中で買うことができた。\n2か月後、市場は50%反発し、そのポジションは二倍になった。","licence_off"],
        )
        for key, source, target, expected in cases:
            leaf = tool.Leaf("events", "market_admin_regression", "content/events/source.json",
                             ("description",), source, "shipping")
            with self.subTest(case=key):
                if expected == "licence_off":
                    self.assertIsNone(tool._ja_market_admin_numbers(source, target))
                    continue
                errors = tool.translation_errors(leaf, "ja", target)
                if expected == "pass":
                    self.assertEqual(errors, [])
                else:
                    self.assertTrue(any("source-bound market/admin" in e for e in errors))

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


    @staticmethod
    def _korean_life_guard_cases():
        # Fixed before guard edits; fourth item is a natural typography delta.
        return [
            ["events:kx_cold_snap:/choices/0/result_text","온수 탕에 발을 담그자 온몸이 녹았다.\n\n찜질복 입고 계란 하나 까먹으며 누워 있었다.\n서울 생존의 비밀 중 하나다. 1만 2천 원에 온기, 샤워, 잠자리.","温かい湯船に足を入れると、全身がほどけた。\n\n館内着を着て、卵を一つむいて食べながら横になっていた。\nソウルで生き延びる秘訣の一つだ。1万2,000ウォンで、ぬくもりとシャワーと寝床。",[67,74,"一万二千"]],
            ["events:kx_gosi_study:/choices/0/result_text","\"잘 되시길 바라요.\" 복도에서 짧게 했다.\n\"고맙습니다. 형도요.\" 돌아온 답.\n\n서로의 이름도 모르지만, 이 고시원 복도에서 가장 따뜻한 인사였다.","「うまくいくといいですね」と、廊下で短く声をかけた。\n「ありがとうございます。お兄さんも」と返ってきた。\n\n互いの名前も知らないけれど、このコシウォンの廊下でいちばん温かい挨拶だった。",[28,28,"どうも"]],
            ["events:kx_hangang_chimaek:/choices/1/result_text","라면 기계에서 뽑은 사천 원짜리 행복.\n강바람이 국물 위로 불었다.\n\n치킨 시킨 옆 돗자리가 부럽지 않았다고 하면 거짓말이지만 —\n그래도 오늘 밤 한강은 모두에게 공평했다.","ラーメン調理機から取り出した、4,000ウォンの幸せ。\n川風がスープの上を吹き抜けた。\n\nチキンを頼んだ隣のシートがうらやましくなかったといえば、嘘になるけれど――\nそれでも、今夜の漢江は誰にでも平等だった。",[15,20,"四千"]],
            ["events:kx_mukbang:/description","새벽 1시, 배는 고프고 돈은 없다.\n유튜브를 열었더니 알고리즘이 먹방을 추천한다.\n\n1인분 짜장면을 네 그릇째 먹는 유튜버.\n섬네일만 봐도 침이 고인다.","午前1時。腹は減っているし、お金はない。\nYouTubeを開くと、アルゴリズムがモッパンを勧めてくる。\n\n一人前のチャジャン麺を、すでに四杯目まで食べ進めているユーチューバー。\nサムネイルを見るだけで、よだれが出る。",[0,3,"深夜一"]],
            ["events:kx_open_chat:/description","다온 오픈채팅 '서울 2030 재테크 모임'.\n익명으로 들어왔다.\n\n채팅창이 쉬지 않고 올라온다.\n부동산, 주식, 코인, 그리고 아파트 청약.","ダオンのオープンチャット「ソウル20・30代の資産運用の集い」。\n匿名で参加した。\n\nチャット欄が休みなく流れていく。\n不動産、株、暗号資産、そしてマンションの分譲申込み。",[16,21,"二十代・三十"]],
            ["events:kx_pc_bang:/choices/1/result_text","고화질 모니터로 채용 공고와 부동산 시세를 뒤졌다.\n집보다 빠른 인터넷, 천오백 원어치는 했다.","高画質のモニターで求人情報と不動産相場を探し回った。\n家より速いネット回線で、1,500ウォン分の価値はあった。",[39,44,"千五百"]],
            ["events:kx_pc_bang:/choices/2/result_text","결국 들어가지 않았다. 천오백 원도 아껴야 했다.\n빗속을 걸으며 라면 냄새만 기억에 담았다.","結局、入らなかった。1,500ウォンだって節約しなくては。\n雨の中を歩きながら、ラーメンの匂いだけを記憶にしまった。",[10,15,"千五百"]],
            ["events:kx_pc_bang:/description","비 오는 오후, 갈 데가 없어 PC방에 들어갔다.\n시간당 천오백 원. 알바생이 자리 번호를 찍어준다.\n\n옆자리에서 누군가 시킨 컵라면 냄새가 모니터를 타고 넘어온다.\n— 피방 라면은 왜 더 맛있을까.","雨の午後、行く当てもなくPCバンに入った。\n一時間1,500ウォン。アルバイトの店員が席番号を指定してくれる。\n\n隣の席で誰かが頼んだカップ麺の匂いが、モニター越しに漂ってくる。\n――PCバンのラーメンは、どうしてもっとおいしいんだろう。",[22,30,"1時間あたり千五百"]],
            ["events:kx_spring_cherry:/description","4월 첫째 주, 벚꽃이 폭발했다.\n여의도 둑방, 석촌호수, 경복궁 돌담길.\n\n꽃이 지기까지는 일주일.\n서울 전체가 이 일주일에 몰려든다.","4月の第1週、桜が一気に咲いた。\nヨイドの土手、ソクチョン湖、景福宮の石垣道。\n\n花が散るまで、一週間。\nソウル中が、この一週間に押し寄せる。",[0,5,"四月の第一"]],
            ["events:kx_suneung_day:/description","11월 셋째 주 목요일.\n전투기가 이착륙을 멈추고, 주식 시장이 한 시간 늦게 열렸다.\n\n대한민국이 18세 아이들 시험 하나에\n잠깐 일시정지 버튼을 눌렀다.","11月の第3週の木曜日。\n戦闘機が離着陸をやめ、株式市場が一時間遅く開いた。\n\n韓国という国が、18歳の子どもたちの一つの試験のために、\nしばし一時停止ボタンを押した。",[0,6,"十一月の第三"]],
            ["events:kx_delivery_app:/choices/0/result_text","30분 뒤 문 앞에 도착한 치킨.\n혼자 먹는데도 '문 앞에 두고 가주세요'를 누르는 게 한국식.\n\n배달비가 아깝다가도, 따뜻한 한 끼 앞에선 다 잊힌다.\n오늘 하루를 버틴 나에게 주는 만 9천 원짜리 상.","30分後、ドアの前にチキンが届いた。\n一人で食べるのに「玄関前に置いてください」を選ぶのが、韓国流。\n\n配達料が惜しくても、温かい食事を前にすると忘れてしまう。\n今日一日を耐えた自分への、1万9,000ウォンのご褒美。",[94,101,"一万九千"]],
            ["events:kx_delivery_app:/choices/1/result_text","결국 앱을 껐다. 편의점 도시락에 컵라면.\n\n배달비 3천 5백 원을 아낀 게 뿌듯하면서도 좀 서글펐다.\n이 작은 계산들이 모여 강남으로 가는 거라고, 스스로를 다독였다.","結局、アプリを閉じた。コンビニ弁当にカップ麺。\n\n配達料3,500ウォンを節約できて誇らしい反面、少し寂しかった。\nこういう小さな計算が積み重なってカンナムにつながるのだと、自分に言い聞かせた。",[28,33,"三千五百"]],
            ["events:kx_delivery_app:/description","야근 후 텅 빈 고시원 방.\n배달앱을 켠다. 최소주문 1만 5천, 배달비 3천 5백.\n\n장바구니에 담았다 뺐다를 반복한다.\n별점 4.8과 4.6 사이에서, 또 한참 고민한다.","残業を終えて戻った、がらんとしたコシウォンの部屋。\nデリバリーアプリを開く。最低注文額1万5,000ウォン、配達料3,500ウォン。\n\nカートに入れては、また外す。\n星4.8と4.6の間で、また長いこと迷う。",[43,62,"は一万五千ウォンで、配達料は三千五百"]],
            ["events:kx_gogi_buffet:/description","1인 1만 5천 원 고기 무한리필.\n불판 위에 삼겹살이 지글거린다.\n\n'본전은 뽑아야 한다'는 한국인의 본능이 깨어난다.\n상추에 고기, 마늘, 쌈장 — 한입 가득.","一人1万5,000ウォンの焼肉食べ放題。\n鉄板の上で、サムギョプサルがじゅうじゅう焼ける。\n\n「元は取らなきゃ」という、韓国人の本能が目を覚ます。\nサンチュに肉、ニンニク、サムジャン――口いっぱいに頬張る。",[0,9,"1人あたり一万五千"]],
            ["events:kx_holiday_alone:/choices/0/result_text","아무도 없는 서울을 걸었다.\n\n강변이 비어있었다. 한강 다리가 멀리 보였다.\n1년에 한 번, 이 도시가 숨 쉬는 날이다.","誰もいないソウルを歩いた。\n\n川辺は空いていた。遠くに漢江の橋が見えた。\n年に一度、この街が息をする日だ。",[37,41,"一年に一回"]],
            ["events:kx_tteokbokki:/choices/1/result_text","1인분이라 좀 멋쩍었지만, 아주머니가 떡을 더 얹어줬다.\n\"많이 먹어요, 총각.\"\n그 한마디에 떡볶이보다 마음이 더 데워졌다.","一人前だけで少し気恥ずかしかったけれど、おばさんが餅をおまけしてくれた。\n「たくさん食べなさいね、お兄さん」\nその一言で、トッポッキよりも心が温まった。",[0,1,"1"]],
            ["events:kx_tteokbokki:/choices/1/text","기본 떡볶이 1인분만","普通のトッポッキ、一人前だけ",[9,10,"1"]],
        ]

    def test_korean_life_source_bound_normal_quantities_and_address(self):
        for identity, source, actual, delta in self._korean_life_guard_cases():
            start, end, replacement = delta
            for target in (actual, actual[:start] + replacement + actual[end:]):
                with self.subTest(identity=identity, target=target):
                    leaf = tool.Leaf("events", identity, "own-fixture", ("description",), source, "event")
                    self.assertEqual(tool.translation_errors(leaf, "ja", target), [])

    def test_korean_life_source_bound_values_units_roles_and_address(self):
        # Index and immutable local substitution, not whole target duplication.
        cases = [
            [0,69,70,"3"],
            [0,67,67,"-"],
            [0,74,77,"ドル"],
            [0,77,77,"毎時"],
            [0,92,92,"\n二百万円。"],
            [1,43,43,"のお兄さん"],
            [1,49,50,"こなかっ"],
            [1,39,39,"ジヨンの"],
            [1,0,0,"お兄さん。"],
            [2,15,16,"5"],
            [2,15,15,"-"],
            [2,20,23,"ドル"],
            [2,23,23,"/時間"],
            [2,104,104,"\n二百万円。"],
            [3,53,54,"二"],
            [3,68,69,"三"],
            [3,2,3,"2"],
            [3,69,70,"時間"],
            [3,108,108,"\n二百万円。"],
            [4,19,20,"4"],
            [4,16,16,"-"],
            [4,18,22,"30年"],
            [4,16,20,"30・2"],
            [4,86,86,"\n二百万円。"],
            [5,39,40,"2"],
            [5,39,39,"-"],
            [5,44,47,"ドル"],
            [5,47,47,"毎月"],
            [5,56,56,"\n二百万円。"],
            [6,10,11,"2"],
            [6,10,10,"-"],
            [6,15,18,"ドル"],
            [6,4,7,""],
            [6,58,58,"\n二百万円。"],
            [7,25,26,"2"],
            [7,22,23,"二"],
            [7,23,25,"日"],
            [7,30,33,"ドル"],
            [7,119,119,"\n二百万円。"],
            [8,4,5,"2"],
            [8,48,49,"二"],
            [8,49,51,"か月"],
            [8,0,1,"5"],
            [8,71,71,"\n二百万円。"],
            [9,5,6,"2"],
            [9,29,30,"二"],
            [9,32,33,"早"],
            [9,49,50,"9"],
            [9,84,84,"\n二百万円。"],
            [10,96,97,"8"],
            [10,2,3,"時間"],
            [10,101,104,"ドル"],
            [10,15,16,"かなかっ"],
            [10,109,109,"\n二百万円。"],
            [11,28,29,"4"],
            [11,33,36,"ドル"],
            [11,37,41,"使っ"],
            [11,28,28,"-"],
            [11,97,97,"\n二百万円。"],
            [12,43,60,"3,500ウォン、配達料1万5,0"],
            [12,57,58,"4"],
            [12,86,91,"6と4.8"],
            [12,104,104,"\n二百万円。"],
            [13,0,1,"二"],
            [13,4,5,"6"],
            [13,9,12,"ドル"],
            [13,2,2,"-"],
            [13,103,103,"\n二百万円。"],
            [14,37,38,"月"],
            [14,39,40,"二"],
            [14,37,37,"二"],
            [14,39,40,"-1"],
            [14,53,53,"\n二百万円。"],
            [15,0,1,"二"],
            [15,1,3,"週間"],
            [15,49,49,"ジヨンの"],
            [15,38,45,"食べないでくだ"],
            [15,76,76,"\n一人前。お兄さん。"],
            [16,9,10,"二"],
            [16,10,12,"週間"],
            [16,9,10,"-1"],
            [16,12,14,"ではなく二人前"],
            [16,14,14,"\n二百万円。"],
            [12,50,53,"ドル"],
        ]
        originals = self._korean_life_guard_cases()
        for index, start, end, replacement in cases:
            identity, source, actual, _ = originals[index]
            target = actual[:start] + replacement + actual[end:]
            with self.subTest(identity=identity, target=target):
                leaf = tool.Leaf("events", identity, "own-fixture", ("description",), source, "event")
                self.assertTrue(tool.translation_errors(leaf, "ja", target))

    def test_korean_life_source_licence_does_not_generalize(self):
        cases = [
            [0,87,87," 원문 바깥의 문장."],
            [0,66,66,"변경"],
            [1,84,84," 원문 바깥의 문장."],
            [1,33,33,"변경"],
            [2,96,96," 원문 바깥의 문장."],
            [2,11,11,"변경"],
            [3,86,86," 원문 바깥의 문장."],
            [3,48,48,"변경"],
            [4,79,79," 원문 바깥의 문장."],
            [4,12,12,"변경"],
            [5,53,53," 원문 바깥의 문장."],
            [5,41,41,"변경"],
            [6,51,51," 원문 바깥의 문장."],
            [6,13,13,"변경"],
            [7,111,111," 원문 바깥의 문장."],
            [7,32,32,"변경"],
            [8,76,76," 원문 바깥의 문장."],
            [8,3,3,"변경"],
            [9,87,87," 원문 바깥의 문장."],
            [9,4,4,"변경"],
            [10,114,114," 원문 바깥의 문장."],
            [10,103,103,"변경"],
            [11,94,94," 원문 바깥의 문장."],
            [11,29,29,"변경"],
            [12,97,97," 원문 바깥의 문장."],
            [12,30,30,"변경"],
            [13,91,91," 원문 바깥의 문장."],
            [13,3,3,"변경"],
            [14,67,67," 원문 바깥의 문장."],
            [14,43,43,"변경"],
            [15,70,70," 원문 바깥의 문장."],
            [15,0,0,"변경"],
            [16,11,11," 원문 바깥의 문장."],
            [16,7,7,"변경"],
        ]
        originals = self._korean_life_guard_cases()
        for index, start, end, replacement in cases:
            _, source, target, _ = originals[index]
            source = source[:start] + replacement + source[end:]
            with self.subTest(source=source):
                self.assertIsNone(tool._ja_korean_culture_numbers(source, target))
                self.assertFalse(tool._ja_korean_culture_address(source, target))

    def test_korean_life_ordinary_male_address_is_not_romance_oppa(self):
        originals = self._korean_life_guard_cases()
        for index in (1, 15):
            _, source, target, _ = originals[index]
            for changed in (source.replace("형도요", "오빠도요").replace("총각", "오빠"),
                            '지연이 "오빠"라고 불렀다.'):
                with self.subTest(source=changed):
                    self.assertFalse(tool._ja_korean_culture_address(changed, target))
                    leaf = tool.Leaf("events", "oppa-boundary", "own-fixture", ("description",), changed, "event")
                    self.assertIn("forbidden term お兄さん", tool.translation_errors(leaf, "ja", target))



    def test_korean_life_local_normal_grammar_and_paired_wrong_values(self):
        cases = [
            ["온수 탕에 발을 담그자 온몸이 녹았다.\n\n찜질복 입고 계란 하나 까먹으며 누워 있었다.\n서울 생존의 비밀 중 하나다. 1만 2천 원에 온기, 샤워, 잠자리.","温かい湯船に足を入れると、全身がほどけた。\n\n館内着を着て、卵を一つむいて食べながら横になっていた。\nソウルで生き延びる秘訣の一つだ。12,000ウォンで、ぬくもりとシャワーと寝床。","pass"],
            ["온수 탕에 발을 담그자 온몸이 녹았다.\n\n찜질복 입고 계란 하나 까먹으며 누워 있었다.\n서울 생존의 비밀 중 하나다. 1만 2천 원에 온기, 샤워, 잠자리.","温かい湯船に足を入れると、全身がほどけた。\n\n館内着を着て、卵を一つむいて食べながら横になっていた。\nソウルで生き延びる秘訣の一つだ。13,000ウォンで、ぬくもりとシャワーと寝床。","reject"],
            ["라면 기계에서 뽑은 사천 원짜리 행복.\n강바람이 국물 위로 불었다.\n\n치킨 시킨 옆 돗자리가 부럽지 않았다고 하면 거짓말이지만 —\n그래도 오늘 밤 한강은 모두에게 공평했다.","ラーメン調理機から取り出した、四千ウォンで手に入れた幸せ。\n川風がスープの上を吹き抜けた。\n\nチキンを頼んだ隣のシートがうらやましくなかったといえば、嘘になるけれど――\nそれでも、今夜の漢江は誰にでも平等だった。","pass"],
            ["라면 기계에서 뽑은 사천 원짜리 행복.\n강바람이 국물 위로 불었다.\n\n치킨 시킨 옆 돗자리가 부럽지 않았다고 하면 거짓말이지만 —\n그래도 오늘 밤 한강은 모두에게 공평했다.","ラーメン調理機から取り出した、五千ウォンで手に入れた幸せ。\n川風がスープの上を吹き抜けた。\n\nチキンを頼んだ隣のシートがうらやましくなかったといえば、嘘になるけれど――\nそれでも、今夜の漢江は誰にでも平等だった。","reject"],
            ["비 오는 오후, 갈 데가 없어 PC방에 들어갔다.\n시간당 천오백 원. 알바생이 자리 번호를 찍어준다.\n\n옆자리에서 누군가 시킨 컵라면 냄새가 모니터를 타고 넘어온다.\n— 피방 라면은 왜 더 맛있을까.","雨の午後、行く当てもなくPCバンに入った。\n毎時千五百ウォン。アルバイトの店員が席番号を指定してくれる。\n\n隣の席で誰かが頼んだカップ麺の匂いが、モニター越しに漂ってくる。\n――PCバンのラーメンは、どうしてもっとおいしいんだろう。","pass"],
            ["비 오는 오후, 갈 데가 없어 PC방에 들어갔다.\n시간당 천오백 원. 알바생이 자리 번호를 찍어준다.\n\n옆자리에서 누군가 시킨 컵라면 냄새가 모니터를 타고 넘어온다.\n— 피방 라면은 왜 더 맛있을까.","雨の午後、行く当てもなくPCバンに入った。\n毎時二千五百ウォン。アルバイトの店員が席番号を指定してくれる。\n\n隣の席で誰かが頼んだカップ麺の匂いが、モニター越しに漂ってくる。\n――PCバンのラーメンは、どうしてもっとおいしいんだろう。","reject"],
            ["다온 오픈채팅 '서울 2030 재테크 모임'.\n익명으로 들어왔다.\n\n채팅창이 쉬지 않고 올라온다.\n부동산, 주식, 코인, 그리고 아파트 청약.","ダオンのオープンチャット「ソウルの二十代と三十代の資産運用の集い」。\n匿名で参加した。\n\nチャット欄が休みなく流れていく。\n不動産、株、暗号資産、そしてマンションの分譲申込み。","pass"],
            ["다온 오픈채팅 '서울 2030 재테크 모임'.\n익명으로 들어왔다.\n\n채팅창이 쉬지 않고 올라온다.\n부동산, 주식, 코인, 그리고 아파트 청약.","ダオンのオープンチャット「ソウルの四十代と三十代の資産運用の集い」。\n匿名で参加した。\n\nチャット欄が休みなく流れていく。\n不動産、株、暗号資産、そしてマンションの分譲申込み。","reject"],
            ["11월 셋째 주 목요일.\n전투기가 이착륙을 멈추고, 주식 시장이 한 시간 늦게 열렸다.\n\n대한민국이 18세 아이들 시험 하나에\n잠깐 일시정지 버튼을 눌렀다.","十一月の第三週、木曜日。\n戦闘機が離着陸をやめ、株式市場が一時間遅く開いた。\n\n韓国という国が、18歳の子どもたちの一つの試験のために、\nしばし一時停止ボタンを押した。","pass"],
            ["11월 셋째 주 목요일.\n전투기가 이착륙을 멈추고, 주식 시장이 한 시간 늦게 열렸다.\n\n대한민국이 18세 아이들 시험 하나에\n잠깐 일시정지 버튼을 눌렀다.","十一月の第四週、木曜日。\n戦闘機が離着陸をやめ、株式市場が一時間遅く開いた。\n\n韓国という国が、18歳の子どもたちの一つの試験のために、\nしばし一時停止ボタンを押した。","reject"],
            ["\"잘 되시길 바라요.\" 복도에서 짧게 했다.\n\"고맙습니다. 형도요.\" 돌아온 답.\n\n서로의 이름도 모르지만, 이 고시원 복도에서 가장 따뜻한 인사였다.","「うまくいくといいですね」と、廊下で短く声をかけた。\n「ありがとうございます。お兄さんも頑張ってください」と返ってきた。\n\n互いの名前も知らないけれど、このコシウォンの廊下でいちばん温かい挨拶だった。","pass"],
            ["\"잘 되시길 바라요.\" 복도에서 짧게 했다.\n\"고맙습니다. 형도요.\" 돌아온 답.\n\n서로의 이름도 모르지만, 이 고시원 복도에서 가장 따뜻한 인사였다.","「うまくいくといいですね」と、廊下で短く声をかけた。\n「ありがとうございます。ジヨンのお兄さんも頑張ってください」と返ってきた。\n\n互いの名前も知らないけれど、このコシウォンの廊下でいちばん温かい挨拶だった。","reject"],
            ["아무도 없는 서울을 걸었다.\n\n강변이 비어있었다. 한강 다리가 멀리 보였다.\n1년에 한 번, 이 도시가 숨 쉬는 날이다.","誰もいないソウルを歩いた。\n\n川辺は空いていた。遠くに漢江の橋が見えた。\n毎年一回、この街が息をする日だ。","pass"],
            ["아무도 없는 서울을 걸었다.\n\n강변이 비어있었다. 한강 다리가 멀리 보였다.\n1년에 한 번, 이 도시가 숨 쉬는 날이다.","誰もいないソウルを歩いた。\n\n川辺は空いていた。遠くに漢江の橋が見えた。\n毎年二回、この街が息をする日だ。","reject"],
            ["4월 첫째 주, 벚꽃이 폭발했다.\n여의도 둑방, 석촌호수, 경복궁 돌담길.\n\n꽃이 지기까지는 일주일.\n서울 전체가 이 일주일에 몰려든다.","四月最初の週、桜が一気に咲いた。\nヨイドの土手、ソクチョン湖、景福宮の石垣道。\n\n花が散るまで、一週間。\nソウル中が、この一週間に押し寄せる。","pass"],
            ["4월 첫째 주, 벚꽃이 폭발했다.\n여의도 둑방, 석촌호수, 경복궁 돌담길.\n\n꽃이 지기까지는 일주일.\n서울 전체가 이 일주일에 몰려든다.","四月二週目、桜が一気に咲いた。\nヨイドの土手、ソクチョン湖、景福宮の石垣道。\n\n花が散るまで、一週間。\nソウル中が、この一週間に押し寄せる。","reject"],
        ]
        for source, target, expected in cases:
            with self.subTest(target=target):
                leaf = tool.Leaf("events", "local-grammar", "own-fixture", ("description",), source, "event")
                errors = tool.translation_errors(leaf, "ja", target)
                if expected == "pass":
                    self.assertEqual(errors, [])
                else:
                    self.assertTrue(errors)



    def test_korean_life_public_B2_normal_and_counterexample_pairs(self):
        # The unchanged ROOT/Plato pre-B1 inputs became public only after B1.
        # These are shared regressions now, not a new independent denominator.
        cases = [
            ["events:kx_heatwave:/description","8월, 체감온도 40도.\n지하철역 에어컨이 고장 났다는 공지가 붙었다.\n\n밖은 아스팔트 열기, 안은 습기.\n고시원 방 에어컨은 어젯밤부터 소음만 낸다.","8月、体感温度は40度。\n地下鉄駅の冷房が故障したという貼り紙が出ていた。\n\n外はアスファルトの熱気、中は湿気。\nコシウォンの部屋のエアコンは、昨夜から音を立てるだけだ。","8月、体感温度は41度。\n地下鉄駅の冷房が故障したという貼り紙が出ていた。\n\n外はアスファルトの熱気、中は湿気。\nコシウォンの部屋のエアコンは、昨夜から音を立てるだけだ。"],
            ["events:kx_english_academy:/description","스펙을 올리려고 영어 학원을 등록했다.\n수강생 대부분이 직장인이다. 저녁 7시 반 수업.\n\n선생님이 자기소개를 시킨다.\n\"My name is... I am... working at...\"","スキルアップのため、英語のスクールに申し込んだ。\n受講生の大半は社会人。授業は19:30から。\n\n先生に自己紹介をするよう言われる。\n\"My name is... I am... working at...\"","スキルアップのため、英語のスクールに申し込んだ。\n受講生の大半は社会人。授業は19:00から。\n\n先生に自己紹介をするよう言われる。\n\"My name is... I am... working at...\""],
            ["events:kx_pc_bang:/choices/0/result_text","계란까지 풀어 끓인 라면에 게임 한 판. 한 판이 세 판이 됐다.\n\n죄책감 반, 행복 반.\n그래도 비 오는 날 피방만 한 도피처가 없다는 건 사실이었다.","卵まで溶き入れて煮たラーメンを食べながら、ゲームを一戦。一戦が三戦になった。\n\n罪悪感が半分、幸せが半分。\nそれでも、雨の日にPCバンほどの逃げ場はないのも事実だった。","卵まで溶き入れて煮たラーメンを食べながら、ゲームを一戦。一戦が四戦になった。\n\n罪悪感が半分、幸せが半分。\nそれでも、雨の日にPCバンほどの逃げ場はないのも事実だった。"],
            ["events:kx_namsan_tower:/choices/0/result_text","'5년 안에 강남. 김민준.'\n유치한 걸 알면서도 적었다.\n\n자물쇠를 채우는 '철컥' 소리가 이상하게 단단했다.\n저 수많은 자물쇠 주인들도, 다 각자의 강남이 있었겠지.","『5年以内にカンナム。キム・ミンジュン。』\n子どもっぽいとわかっていても、書いた。\n\n南京錠を掛けるカチリという音が、妙に力強く響いた。\nあの無数の南京錠の持ち主にも、それぞれのカンナムがあったのだろう。","『6年以内にカンナム。キム・ミンジュン。』\n子どもっぽいとわかっていても、書いた。\n\n南京錠を掛けるカチリという音が、妙に力強く響いた。\nあの無数の南京錠の持ち主にも、それぞれのカンナムがあったのだろう。"],
            ["events:kx_open_chat:/description","다온 오픈채팅 '서울 2030 재테크 모임'.\n익명으로 들어왔다.\n\n채팅창이 쉬지 않고 올라온다.\n부동산, 주식, 코인, 그리고 아파트 청약.","ダオンのオープンチャット「ソウルの二十代・三十代、資産づくりの会」。\n匿名で入室した。\n\nチャットは次から次へと流れ、止まらない。\n不動産、株式、暗号資産、それにマンションの分譲申込み。","ダオンのオープンチャット「ソウルの二十代・四十代、資産づくりの会」。\n匿名で入室した。\n\nチャットは次から次へと流れ、止まらない。\n不動産、株式、暗号資産、それにマンションの分譲申込み。"],
            ["events:kx_hagwon:/description","밤 10시, 대치동 학원 거리.\n중고등학생들이 학원에서 쏟아져 나온다.\n\n수학, 영어, 과학, 논술...\n이 거리의 부모들은 강남 집값의 3분의 1을 교육비에 쓴다고 한다.","夜10時のテチドン、塾が並ぶ通り。\n中学生や高校生が、塾からどっとあふれ出してくる。\n\n数学、英語、科学、小論文……。\nこの通りの親たちは、カンナムの住宅価格の三分の一に相当する額を、教育費として使うそうだ。","夜10時のテチドン、塾が並ぶ通り。\n中学生や高校生が、塾からどっとあふれ出してくる。\n\n数学、英語、科学、小論文……。\nこの通りの親たちは、カンナムの住宅価格の四分の一に相当する額を、教育費として使うそうだ。"],
            ["events:kx_coin_noraebang:/description","막차가 끊긴 밤, 골목 코인노래방.\n천 원에 네 곡. 부스 안은 혼자다.\n\n끈적한 소파, 탬버린 하나, 그리고 익숙한 발라드 번호.\n오늘 하루가 무거웠다.","終電が終わった夜、路地にあるコインノレバン。\n1,000ウォン払えば4曲歌える。ブースの中は一人きり。\n\nべたべたするソファに、タンバリンが一つ。それから、おなじみのバラードの曲番号。\n今日という一日は重かった。","終電が終わった夜、路地にあるコインノレバン。\n1,000ウォン払えば4時間歌える。ブースの中は一人きり。\n\nべたべたするソファに、タンバリンが一つ。それから、おなじみのバラードの曲番号。\n今日という一日は重かった。"],
            ["events:kx_suneung_day:/description","11월 셋째 주 목요일.\n전투기가 이착륙을 멈추고, 주식 시장이 한 시간 늦게 열렸다.\n\n대한민국이 18세 아이들 시험 하나에\n잠깐 일시정지 버튼을 눌렀다.","11月、第3週の木曜日。\n戦闘機の離着陸が止まり、株式市場はいつもより1時間遅れて開いた。\n\n韓国が、18歳の子どもたちの一つの試験に合わせて、\nほんのしばらく、一時停止のボタンを押した。","11月、第3週の木曜日。\n戦闘機の離着陸が止まり、株式市場はいつもより1時間早く開いた。\n\n韓国が、18歳の子どもたちの一つの試験に合わせて、\nほんのしばらく、一時停止のボタンを押した。"],
        ]
        for identity, source, normal, wrong in cases:
            with self.subTest(identity=identity):
                leaf = tool.Leaf("events", identity, "public-B2-fixture", ("description",), source, "event")
                self.assertEqual(tool.translation_errors(leaf, "ja", normal), [])
                self.assertTrue(tool.translation_errors(leaf, "ja", wrong))


    @staticmethod
    def _leisure_race_regression_cases():
        # Authored before implementation; independent ROOT fixtures are not
        # included here. Exact source owners remain distinct from target prose.
        # 대형 다국어 fixture는 여러 물리행으로 나누고 실제 Python CLI로 검사한다.
        return [
            {
                "source": (
                    "집에 있던 {name}의 휴대폰이 짧게 울렸다. 앞서 소개받은 카지노 클럽의 숙박 안내였다.\n\n「객실 1박과 조식을 무료로 제공합니다. 이용 가"
                    "능한 날짜를 문의해 주세요.」\n\n누구 이름도 적혀 있지 않은 안내였다. 그래도 {name}은 '무료'라는 단어 위에서 손가락을 멈췄다.\n\n답장을"
                    " 쓰려다 달력을 열었다. 비어 있는 칸 하나에 넓은 침대와 늦은 아침이 먼저 들어왔다. 그다음에는 호텔 아래층의 테이블이 떠올랐다.\n\n화면 밖은"
                    " 여전히 익숙한 방이었다. 메시지 입력 칸의 커서가 깜빡였다."
                ),
                "target": (
                    "家にいた{name}のスマホが短く鳴った。以前紹介されたカジノクラブからの宿泊案内だった。\n\n「一泊のお部屋と朝食を無料でご提供いたします。ご利用可能な日程をお"
                    "問い合わせください」\n\n誰の名前も書かれていない案内だった。それでも{name}は、「無料」という言葉の上で指を止めた。\n\n返事を書きかけて、カレンダーを開いた"
                    "。空いている一枠に、広いベッドと遅い朝が先に入り込んだ。その次に、ホテルの下の階のテーブルが浮かんだ。\n\n画面の外は、相変わらず見慣れた部屋だった。メッセージの"
                    "入力欄でカーソルが点滅していた。"
                ),
                "natural": [
                    (
                        "家にいた{name}のスマホが短く鳴った。以前紹介されたカジノクラブからの宿泊案内だった。\n\n「1泊のお部屋と朝食を無料でご提供いたします。ご利用可能な日程をお"
                        "問い合わせください」\n\n誰の名前も書かれていない案内だった。それでも{name}は、「無料」という言葉の上で指を止めた。\n\n返事を書きかけて、カレンダーを開いた"
                        "。空いている1枠に、広いベッドと遅い朝が先に入り込んだ。その次に、ホテルの下の階のテーブルが浮かんだ。\n\n画面の外は、相変わらず見慣れた部屋だった。メッセージの"
                        "入力欄でカーソルが点滅していた。"
                    ),
                    (
                        "家にいた{name}のスマホが短く鳴った。以前紹介されたカジノクラブからの宿泊案内だった。\n\n「一泊分の客室と朝食を無料で提供します。利用できる日付をお尋ねくだ"
                        "さい」\n\n誰の名前も書かれていない案内だった。それでも{name}は、「無料」という言葉の上で指を止めた。\n\n返事を書きかけて、カレンダーを開いた。空いている一"
                        "枠に、広いベッドと遅い朝が先に入り込んだ。その次に、ホテルの下の階のテーブルが浮かんだ。\n\n画面の外は、相変わらず見慣れた部屋だった。メッセージの入力欄でカーソ"
                        "ルが点滅していた。"
                    ),
                ],
                "changes": [
                    [
                        "一泊",
                        "二泊",
                    ],
                    [
                        "一泊",
                        "一年",
                    ],
                    [
                        "一泊",
                        "+一泊",
                    ],
                    [
                        "空いている一枠",
                        "空いている二枠",
                    ],
                    [
                        "ご利用可能な日程をお問い合わせください",
                        "ご利用日程は予約済みです",
                    ],
                ],
                "source_change": [
                    "1박",
                    "2박",
                ],
                "focus_line": 2,
                "id": "events:casino_comp_offer:/description",
            },
            {
                "source": "발판을 밟다 보니 금세 숨이 찼다. 옆 고수가 흘끔 봤다.\n\n못해도 재밌었다. 이게 한국식 리듬게임.\n오백 원으로 헬스장 한 타임 효과를 봤다.",
                "target": (
                    "パネルを踏んでいるうちに、すぐ息が上がった。隣の上級者がちらりと見た。\n\n下手でも楽しかった。これが韓国式のリズムゲーム。\n500ウォンでジム一回分の運動になっ"
                    "た。"
                ),
                "natural": [
                    (
                        "パネルを踏んでいるうちに、すぐ息が上がった。隣の上級者がちらりと見た。\n\n下手でも楽しかった。これが韓国式のリズムゲーム。\n五百ウォンでジム1度分の運動になった"
                        "。"
                    ),
                    (
                        "パネルを踏んでいるうちに、すぐ息が上がった。隣の上級者がちらりと見た。\n\n下手でも楽しかった。これが韓国式のリズムゲーム。\n五百ウォンで、ジムに一度行った分の運"
                        "動をした。"
                    ),
                ],
                "changes": [
                    [
                        "ジム一回分",
                        "ジム二回分",
                    ],
                    [
                        "500ウォン",
                        "500ドル",
                    ],
                    [
                        "500ウォン",
                        "+500ウォン",
                    ],
                    [
                        "ジム一回分",
                        "ジム一時間分",
                    ],
                    [
                        "運動になった",
                        "運動にはならなかった",
                    ],
                ],
                "source_change": [
                    "오백 원",
                    "육백 원",
                ],
                "focus_line": 3,
                "id": "events:kx_arcade:/choices/0/result_text",
            },
            {
                "source": (
                    "번화가 오락실.\n펌프(댄스 발판), 농구 게임, 그리고 인생네컷 부스.\n\n동전 교환기에 천 원을 넣자 100원짜리가 쏟아진다.\n— 오랜만이다, "
                    "이 소리."
                ),
                "target": (
                    "繁華街のゲームセンター。\nパンプのダンスパネル、バスケットボールゲーム、それから四コマ写真のブース。\n\n両替機に1,000ウォンを入れると、100ウォン硬貨がざ"
                    "らざらと出てくる。\n――久しぶりだな、この音。"
                ),
                "natural": [
                    (
                        "繁華街のゲームセンター。\nパンプのダンスパネル、バスケットボールゲーム、それから4コマ写真のブース。\n\n両替機に千ウォンを入れると、100ウォン硬貨がざらざらと"
                        "出てくる。\n――久しぶりだな、この音。"
                    ),
                    (
                        "繁華街のゲームセンター。\nパンプのダンスパネル、バスケットボールゲーム、それから四コマ写真のブース。\n\n両替機に千ウォンを入れたら、百ウォンの硬貨が出てきた。\n"
                        "――久しぶりだな、この音。"
                    ),
                ],
                "changes": [
                    [
                        "1,000ウォン",
                        "10,000ウォン",
                    ],
                    [
                        "1,000ウォン",
                        "1,000ドル",
                    ],
                    [
                        "1,000ウォン",
                        "+1,000ウォン",
                    ],
                    [
                        "四コマ",
                        "三コマ",
                    ],
                    [
                        "入れると",
                        "入れなかったが",
                    ],
                ],
                "source_change": [
                    "천 원",
                    "이천 원",
                ],
                "focus_line": 3,
                "id": "events:kx_arcade:/description",
            },
            {
                "source": "한강을 따라 달렸다. 바람, 윤슬, 다리 밑 그늘.\n\n천 원으로 이만한 자유가 또 없다.\n페달을 밟는 동안만큼은 30억도, 마감도 뒤로 밀렸다.",
                "target": (
                    "漢江に沿って走った。風、水面のきらめき、橋の下の影。\n\n1,000ウォンで、これほどの自由はほかにない。\nペダルを踏んでいる間だけは、30億ウォンも締め切りも後"
                    "回しになった。"
                ),
                "natural": [
                    (
                        "漢江に沿って走った。風、水面のきらめき、橋の下の影。\n\n千ウォンで、これほどの自由はほかにない。\nペダルを踏んでいる間だけは、三十億ウォンも締め切りも後回しにな"
                        "った。"
                    ),
                    (
                        "漢江に沿って走った。風、水面のきらめき、橋の下の影。\n\n1,000ウォンで、これほどの自由はほかにない。\nペダルをこいでいる間は、三十億ウォンも締め切りも頭の隅"
                        "に追いやられた。"
                    ),
                ],
                "changes": [
                    [
                        "30億ウォン",
                        "31億ウォン",
                    ],
                    [
                        "30億ウォン",
                        "30億ドル",
                    ],
                    [
                        "30億ウォン",
                        "+30億ウォン",
                    ],
                    [
                        "1,000ウォン",
                        "2,000ウォン",
                    ],
                    [
                        "後回しになった",
                        "自分の所有物になった",
                    ],
                ],
                "source_change": [
                    "30억",
                    "31억",
                ],
                "focus_line": 3,
                "id": "events:kx_ddareungi:/choices/0/result_text",
            },
            {
                "source": "서울 공공자전거 따릉이.\n앱으로 QR을 찍고 천 원에 한 시간. 거치대에서 자전거를 뺀다.\n\n날이 좋다. 페달을 밟자 바람이 분다.",
                "target": (
                    "ソウルの公共レンタサイクル、タルンイ。\nアプリでQRコードを読み取り、1,000ウォンで一時間。ラックから自転車を引き出す。\n\nいい天気だ。ペダルを踏むと、風が"
                    "吹く。"
                ),
                "natural": [
                    "ソウルの公共レンタサイクル、タルンイ。\nアプリでQRコードを読み取り、千ウォンで1時間。ラックから自転車を引き出す。\n\nいい天気だ。ペダルを踏むと、風が吹く。",
                    "ソウルの公共レンタサイクル、タルンイ。\nアプリでQRを読み込むと、千ウォンで一時間使える。ラックから自転車を取り出す。\n\nいい天気だ。ペダルを踏むと、風が吹く。",
                ],
                "changes": [
                    [
                        "一時間",
                        "二時間",
                    ],
                    [
                        "一時間",
                        "一日",
                    ],
                    [
                        "一時間",
                        "+一時間",
                    ],
                    [
                        "1,000ウォン",
                        "2,000ウォン",
                    ],
                    [
                        "引き出す",
                        "引き出していない",
                    ],
                ],
                "source_change": [
                    "한 시간",
                    "두 시간",
                ],
                "focus_line": 1,
                "id": "events:kx_ddareungi:/description",
            },
            {
                "source": (
                    "라면 한 그릇 끓여 먹고, 만화 스무 권을 다 봤다.\n\n해가 진 줄도 몰랐다. 목이 뻐근했지만 마음은 가벼웠다.\n이천 원짜리 도피처치고 완벽했다"
                    "."
                ),
                "target": (
                    "ラーメンを一杯作って食べ、漫画二十冊を全部読んだ。\n\n日が沈んだことにも気づかなかった。首は凝ったが、心は軽かった。\n2,000ウォンの逃げ場所としては完璧だっ"
                    "た。"
                ),
                "natural": [
                    "ラーメンを一杯作って食べ、漫画20冊を全部読んだ。\n\n日が沈んだことにも気づかなかった。首は凝ったが、心は軽かった。\n二千ウォンの逃げ場所としては完璧だった。",
                    (
                        "ラーメン一杯を作って食べて、漫画を二十冊すべて読み終えた。\n\n日が沈んだことにも気づかなかった。首は凝ったが、心は軽かった。\n2,000ウォンの逃げ場所としては"
                        "完璧だった。"
                    ),
                ],
                "changes": [
                    [
                        "二十冊",
                        "二十一冊",
                    ],
                    [
                        "二十冊",
                        "二十杯",
                    ],
                    [
                        "二十冊",
                        "+二十冊",
                    ],
                    [
                        "一杯",
                        "二杯",
                    ],
                    [
                        "全部読んだ",
                        "まだ読んでいない",
                    ],
                ],
                "source_change": [
                    "스무 권",
                    "서른 권",
                ],
                "focus_line": 0,
                "id": "events:kx_manhwa_cafe:/choices/0/result_text",
            },
            {
                "source": (
                    "지인들과 방탈출 카페.\n1인 2만 원, 제한시간 60분. 자물쇠, 암호, 자외선 펜.\n\n문이 잠기고 타이머가 빨갛게 줄어들기 시작한다.\n\"단서는"
                    " 다 방 안에 있습니다.\""
                ),
                "target": (
                    "知り合いたちと脱出ゲームカフェへ。\n一人2万ウォン、制限時間60分。南京錠、暗号、紫外線ペン。\n\nドアが施錠され、赤いタイマーが減り始める。\n「手がかりは、すべ"
                    "て部屋の中にあります」"
                ),
                "natural": [
                    (
                        "知り合いたちと脱出ゲームカフェへ。\n1人20,000ウォン、制限時間六十分。南京錠、暗号、紫外線ペン。\n\nドアが施錠され、赤いタイマーが減り始める。\n「手がかり"
                        "は、すべて部屋の中にあります」"
                    ),
                    (
                        "知り合いたちと脱出ゲームカフェへ。\n一人あたり二万ウォン、持ち時間は六十分。南京錠、暗号、紫外線ペン。\n\nドアが施錠され、赤いタイマーが減り始める。\n「手がかり"
                        "は、すべて部屋の中にあります」"
                    ),
                ],
                "changes": [
                    [
                        "2万ウォン",
                        "3万ウォン",
                    ],
                    [
                        "60分",
                        "60秒",
                    ],
                    [
                        "2万ウォン",
                        "+2万ウォン",
                    ],
                    [
                        "一人",
                        "二人",
                    ],
                    [
                        "制限時間",
                        "経過時間",
                    ],
                ],
                "source_change": [
                    "60분",
                    "90분",
                ],
                "focus_line": 1,
                "id": "events:kx_room_escape:/description",
            },
            {
                "source": (
                    "8만원을 썼다. 만회는 없었다.\n\n경마공원역 계단을 내려오면서 총합을 계산했다.\n3주 합산 -23만원.\n\n숫자가 나오자 머릿속이 조용해졌다.\n이"
                    " 조용함이 제일 나쁜 신호라는 걸 — 아직 모르고 있었다."
                ),
                "target": (
                    "8万ウォン使った。取り返せなかった。\n\n競馬公園駅の階段を降りながら、合計を計算した。\n3週間で、合計マイナス23万ウォン。\n\n数字にすると、頭の中が静かになっ"
                    "た。\nこの静けさが最悪の兆候だとは――まだ知らなかった。"
                ),
                "natural": [
                    (
                        "八万ウォン使った。取り返せなかった。\n\n競馬公園駅の階段を降りながら、合計を計算した。\n三週間で、合計−230,000ウォン。\n\n数字にすると、頭の中が静かにな"
                        "った。\nこの静けさが最悪の兆候だとは――まだ知らなかった。"
                    ),
                    (
                        "8万ウォン使った。取り返せなかった。\n\n競馬公園駅の階段を降りながら、合計を計算した。\n三週間の累計は、マイナス二十三万ウォンだった。\n\n数字にすると、頭の中が"
                        "静かになった。\nこの静けさが最悪の兆候だとは――まだ知らなかった。"
                    ),
                ],
                "changes": [
                    [
                        "3週間",
                        "4週間",
                    ],
                    [
                        "3週間",
                        "3か月",
                    ],
                    [
                        "マイナス23万",
                        "プラス23万",
                    ],
                    [
                        "8万ウォン使った",
                        "23万ウォン使った",
                    ],
                    [
                        "取り返せなかった",
                        "取り返した",
                    ],
                ],
                "source_change": [
                    "3주",
                    "4주",
                ],
                "focus_line": 3,
                "id": "events:race_addiction_warning:/choices/1/result_text",
            },
            {
                "source": (
                    "한 시간 동안 경마신문을 읽었다.\n\n3연단, 단승, 연승, 복승, 쌍승 — 베팅 방식만 여섯 가지였다.\n기수 승률, 조교사 기록, 주로별 특성."
                    "\n\n이걸 다 보는 사람들이 있다는 게 신기했다.\n'읽는다'는 게 무슨 말인지 조금 알 것 같았다."
                ),
                "target": (
                    "一時間、競馬新聞を読んだ。\n\n三連単、単勝、複勝、馬連、馬単――賭け方だけでも六種類あった。\n騎手の勝率、調教師の成績、コースごとの特徴。\n\nこんなものまで全部"
                    "見る人がいるのかと、不思議だった。\n「読む」とはどういうことなのか、少しわかった気がした。"
                ),
                "natural": [
                    (
                        "1時間、競馬新聞を読んだ。\n\n3連単、単勝、複勝、馬連、馬単――賭け方だけでも6種類あった。\n騎手の勝率、調教師の成績、コースごとの特徴。\n\nこんなものまで全部"
                        "見る人がいるのかと、不思議だった。\n「読む」とはどういうことなのか、少しわかった気がした。"
                    ),
                    (
                        "競馬新聞を一時間かけて読んだ。\n\n三連単、単勝、複勝、馬連、馬単――賭け方だけでも六種類あった。\n騎手の勝率、調教師の成績、コースごとの特徴。\n\nこんなものまで"
                        "全部見る人がいるのかと、不思議だった。\n「読む」とはどういうことなのか、少しわかった気がした。"
                    ),
                ],
                "changes": [
                    [
                        "一時間",
                        "二時間",
                    ],
                    [
                        "一時間",
                        "一日",
                    ],
                    [
                        "一時間",
                        "+一時間",
                    ],
                    [
                        "三連単",
                        "二連単",
                    ],
                    [
                        "競馬新聞を読んだ",
                        "競馬新聞を読む予定だ",
                    ],
                ],
                "source_change": [
                    "여섯 가지",
                    "일곱 가지",
                ],
                "focus_line": 0,
                "id": "events:race_early_lesson:/choices/0/result_text",
            },
            {
                "source": (
                    "그날의 마지막 경주.\n\n베팅창 앞이 유독 붐볐다. {name}은 줄에 섰다.\n\n앞 사람이 만원짜리를 세고 있었다. 손이 떨렸다. 지폐가 몇 장 "
                    "안 남아 있었다.\n뒤 사람은 혼잣말을 했다. \"이번엔 진짜… 이번엔 돼야 하는데.\"\n\n마지막 경주에는, 오늘 잃은 걸 만회하려는 사람들만 남는다"
                    ".\n\n{name}도 그 줄의 한 명이었다."
                ),
                "target": (
                    "その日、最後のレース。\n\n発売窓口の前が、ひときわ混んでいた。{name}は列に並んだ。\n\n前の人が1万ウォン札を数えていた。手が震えていた。紙幣は、もう数枚し"
                    "か残っていなかった。\n後ろの人は独り言をつぶやいた。「今度こそ、本当に……今度こそ当たってくれないと」\n\n最後のレースには、今日の負けを取り返そうとする人たちだ"
                    "けが残る。\n\n{name}も、その列の一人だった。"
                ),
                "natural": [
                    (
                        "その日、最後のレース。\n\n発売窓口の前が、ひときわ混んでいた。{name}は列に並んだ。\n\n前の人が一万ウォン札を数えていた。手が震えていた。紙幣は、もう数枚し"
                        "か残っていなかった。\n後ろの人は独り言をつぶやいた。「今度こそ、本当に……今度こそ当たってくれないと」\n\n最後のレースには、今日の負けを取り返そうとする人たちだ"
                        "けが残る。\n\n{name}も、その列の1人だった。"
                    ),
                    (
                        "その日、最後のレース。\n\n発売窓口の前が、ひときわ混んでいた。{name}は列に並んだ。\n\n前に並ぶ人は一万ウォンの紙幣を数えていた。手が震えていて、残りはわず"
                        "かだった。\n後ろの人は独り言をつぶやいた。「今度こそ、本当に……今度こそ当たってくれないと」\n\n最後のレースには、今日の負けを取り返そうとする人たちだけが残る。"
                        "\n\n{name}も、その列の一人だった。"
                    ),
                ],
                "changes": [
                    [
                        "1万ウォン札",
                        "2万ウォン札",
                    ],
                    [
                        "1万ウォン札",
                        "1万ドル札",
                    ],
                    [
                        "1万ウォン札",
                        "+1万ウォン札",
                    ],
                    [
                        "前の人",
                        "後ろの人",
                    ],
                    [
                        "数えていた",
                        "数えていなかった",
                    ],
                ],
                "source_change": [
                    "만원짜리",
                    "이만원짜리",
                ],
                "focus_line": 4,
                "id": "events:race_last_bettor:/description",
            },
            {
                "source": (
                    "5위.\n\n만원짜리 한 장이 종이 한 장이 됐다.\n아저씨를 찾았다. 이미 다른 사람에게 다른 번호를 팔고 있었다.\n\n{name}은 계단을 내려오면"
                    "서 다음 경주 시간을 확인했다.\n그게 문제였다."
                ),
                "target": (
                    "5着。\n\n1万ウォンの一枚が、ただの紙一枚になった。\nおじさんを探した。もう別の人に、別の番号を売っていた。\n\n{name}は階段を降りながら、次のレースの時間"
                    "を確かめた。\nそれが問題だった。"
                ),
                "natural": [
                    (
                        "五着。\n\n10,000ウォンの1枚が、ただの紙1枚になった。\nおじさんを探した。もう別の人に、別の番号を売っていた。\n\n{name}は階段を降りながら、次のレー"
                        "スの時間を確かめた。\nそれが問題だった。"
                    ),
                    (
                        "5着。\n\n一万ウォンの馬券一枚が、ただの紙切れ一枚に変わった。\nおじさんを探した。もう別の人に、別の番号を売っていた。\n\n{name}は階段を降りながら、次のレ"
                        "ースの時間を確かめた。\nそれが問題だった。"
                    ),
                ],
                "changes": [
                    [
                        "5着",
                        "4着",
                    ],
                    [
                        "5着",
                        "5人",
                    ],
                    [
                        "1万ウォン",
                        "-1万ウォン",
                    ],
                    [
                        "ウォンの一枚",
                        "ウォンの二枚",
                    ],
                    [
                        "紙一枚になった",
                        "紙一枚になる予定だ",
                    ],
                ],
                "source_change": [
                    "5위",
                    "4위",
                ],
                "focus_line": 2,
                "id": "events:race_number_three_result:/choices/0/result_text",
            },
            {
                "source": "만원치고 괜찮은 구경이었다.\n경주마가 달리는 건 생각보다 웅장했다.\n{name}은 거기서 멈추기로 했다. 오늘은.",
                "target": "1万ウォンにしては、悪くない見物だった。\n競走馬が駆ける姿は、思ったより雄大だった。\n{name}は、そこでやめることにした。今日は。",
                "natural": [
                    "一万ウォンにしては、悪くない見物だった。\n競走馬が駆ける姿は、思ったより雄大だった。\n{name}は、そこでやめることにした。今日は。",
                    "一万ウォンで見たものとしては、悪くない見物だった。\n競走馬が駆ける姿は、思ったより雄大だった。\n{name}は、そこでやめることにした。今日は。",
                ],
                "changes": [
                    [
                        "1万ウォン",
                        "2万ウォン",
                    ],
                    [
                        "1万ウォン",
                        "1万ドル",
                    ],
                    [
                        "1万ウォン",
                        "+1万ウォン",
                    ],
                    [
                        "1万ウォンにしては",
                        "1万ウォン/時間にしては",
                    ],
                    [
                        "見物だった",
                        "見物になるだろう",
                    ],
                ],
                "source_change": [
                    "만원치고",
                    "이만원치고",
                ],
                "focus_line": 0,
                "id": "events:race_number_three_result:/choices/1/result_text",
            },
        ]

    def test_leisure_race_local_quantity_normals(self):
        count = 0
        for case in self._leisure_race_regression_cases():
            for text in [case["target"], *case["natural"]]:
                with self.subTest(identity=case["id"], target=text):
                    leaf = tool.Leaf("events", case["id"], "own-leisure-fixture",
                                     ("description",), case["source"], "event")
                    result = tool._ja_leisure_gambling_numbers(case["source"], text)
                    self.assertIsNotNone(result)
                    self.assertEqual(result[2], [])
                    self.assertEqual(tool.translation_errors(leaf, "ja", text), [])
                    count += 1
        self.assertEqual(count, 36)

    def test_leisure_race_quantity_mutations_are_directly_rejected(self):
        count = 0
        for case in self._leisure_race_regression_cases():
            source, target = case["source"], case["target"]
            mutants = []
            for old, new in case["changes"]:
                self.assertIn(old, target)
                mutants.append(target.replace(old, new, 1))
            line = case["focus_line"]
            original = target.split("\n")
            borrowed = mutants[0].split("\n")
            borrowed[line] += " " + original[line]
            mutants.append("\n".join(borrowed))
            moved = list(original)
            other = 0 if line else 1
            moved[line], moved[other] = moved[other], moved[line]
            mutants.append("\n".join(moved))
            for text in mutants:
                with self.subTest(identity=case["id"], target=text):
                    leaf = tool.Leaf("events", case["id"], "own-leisure-fixture",
                                     ("description",), source, "event")
                    result = tool._ja_leisure_gambling_numbers(source, text)
                    self.assertIsNotNone(result)
                    self.assertTrue(result[2])  # Not borrowed paragraph/money errors.
                    self.assertTrue(tool.translation_errors(leaf, "ja", text))
                    count += 1
        self.assertEqual(count, 84)

    def test_leisure_race_source_boundaries_are_not_licensed(self):
        count = 0
        for case in self._leisure_race_regression_cases():
            old, new = case["source_change"]
            self.assertIn(old, case["source"])
            for source in (case["source"] + " ", case["source"].replace(old, new, 1)):
                with self.subTest(identity=case["id"], source=source):
                    self.assertIsNone(tool._ja_leisure_gambling_numbers(
                        source, case["natural"][0]))
                    count += 1
        # This asserts licence absence, not blanket generic E2E rejection.
        self.assertEqual(count, 24)


    def test_holdem_first_visit_two_bluffs_one_big_pot_public_regression(self):
        # ROOT's unchanged B1 input was disclosed after it exposed the missing
        # written-count check. This is a public regression, not fresh independence.
        source = "2시간에 2만원 손실.\n근데 두 번 블러핑에 성공했고, 한 번은 큰 팟을 땄다가 다시 잃었다.\n\n계단 올라오면서 생각했다. 이거 공부할 게 있는 게임이구나."
        actual = "2時間で2万ウォンの損失。\nでも二回ブラフが成功し、一度は大きなポットを取って、また失った。\n\n階段を上がりながら思った。これは、勉強することのあるゲームなんだ。"
        public = "2時間で2万ウォンの損失。\nでもブラフは二度成功し、一度は大きなポットを取って、また失った。\n\n階段を上りながら思った。これは勉強することがあるゲームなんだ。"
        normals = [actual, public, actual.replace("二回", "2度").replace("一度", "1回")]
        wrong = [public.replace("二度", "三度"), actual.replace("二回", "三回"),
                 actual.replace("一度", "二度")]
        leaf = tool.Leaf("events", "holdem_first_visit", "own-public-B2",
                         ("choices", 0, "result_text"), source, "gambling")
        for target in normals:
            with self.subTest(target=target):
                self.assertEqual(tool._ja_leisure_gambling_numbers(source, target)[2], [])
                self.assertEqual(tool.translation_errors(leaf, "ja", target), [])
        for target in wrong:
            with self.subTest(target=target):
                self.assertTrue(tool._ja_leisure_gambling_numbers(source, target)[2])
                self.assertTrue(tool.translation_errors(leaf, "ja", target))
        for changed_source in (source + " ", source.replace("두 번", "세 번")):
            self.assertIsNone(tool._ja_leisure_gambling_numbers(changed_source, public))


    @staticmethod
    def _cafe_encounter_regression_cases():
        # Large multilingual fixtures use adjacent short physical lines;
        # validate the final suite through the actual Python CLI.
        base = [
            (
                "events:cafe_00:/description",
                "content/events/scenario_cafe.json",
                (
                    "{name}은 6,500원짜리 아메리카노를 시켰다.\n"
                    "그래도 한 번은,\n"
                    "강남에서 큰돈 이야기가 오가는 자리에 앉아 보고 싶었다.\n"
                    "\n"
                    "옆 테이블. 정장 입은 남자가 통화 중이다.\n"
                    "\"그 입주권 마지막 한 자리예요. 오늘 안 잡으면 끝나요.\n"
                    "재개발 확정 났다니까. ...네, 현금 5천이면 됩니다.\"\n"
                    "\n"
                    "{name}의 귀가 저절로 그쪽으로 기운다."
                ),
                (
                    "{name}は6,500ウォンのアメリカーノを頼んだ。\n"
                    "それでも一度は、\n"
                    "カンナムで大きな金の話が飛び交う席に座ってみたかった。\n"
                    "\n"
                    "隣のテーブル。スーツ姿の男が電話をしている。\n"
                    "「その入居権、最後の一枠ですよ。今日押さえなければ終わりです。\n"
                    "再開発は決まったんですって。……ええ、現金5,000万ウォンで大丈夫です」\n"
                    "\n"
                    "{name}の耳が、自然とそちらへ傾く。"
                ),
                (
                    "{name}は6,500ウォンのアメリカーノを頼んだ。\n"
                    "それでも一度は、\n"
                    "カンナムで大きな金の話が飛び交う席に座ってみたかった。\n"
                    "\n"
                    "隣のテーブル。スーツ姿の男が電話をしている。\n"
                    "「その入居権、最後の一枠ですよ。今日押さえなければ終わりです。\n"
                    "再開発は決まったんですって。……ええ、現金は五千万ウォンで大丈夫です」\n"
                    "\n"
                    "{name}の耳が、自然とそちらへ傾く。"
                ),
            ),
            (
                "events:cafe_bluff_01:/description",
                "content/events/scenario_cafe.json",
                (
                    "\"이쪽 일을 하신다. 그래요?\"\n"
                    "남자의 눈이 가늘어진다. 시험하듯 묻는다.\n"
                    "\"매매가 5억, 전세 3억 5천, 대출 1억이면\n"
                    "취득비 빼고 실투자금 얼마 잡아요?\"\n"
                    "\n"
                    "{name}은 계산하지 못했다.\n"
                    "등에서 식은땀이 흐른다."
                ),
                (
                    "「この業界で仕事をしてる。そうなの？」\n"
                    "男の目が細くなる。試すように尋ねる。\n"
                    "「売買価格5億ウォン、チョンセ保証金3億5,000万ウォン、借入1億ウォンなら、\n"
                    "取得費用を除いた実際の自己資金はいくらで見てる？」\n"
                    "\n"
                    "{name}は計算できなかった。\n"
                    "背中を冷たい汗が伝う。"
                ),
                (
                    "「この業界で仕事をしてる。そうなの？」\n"
                    "男の目が細くなる。試すように尋ねる。\n"
                    "「売買価格は5億ウォン、チョンセ保証金は3億5000万ウォン、借入は1億ウォンなら、\n"
                    "取得費用を除いた実際の自己資金はいくらで見てる？」\n"
                    "\n"
                    "{name}は計算できなかった。\n"
                    "背中を冷たい汗が伝う。"
                ),
            ),
            (
                "events:cafe_bluff_caught:/description",
                "content/events/scenario_cafe.json",
                (
                    "\"한 2억쯤...?\" {name}이 아무 숫자나 던졌다.\n"
                    "남자가 코웃음을 쳤다.\n"
                    "\"5억에서 전세 3억 5천, 대출 1억을 빼면 5천이잖아. 학생, 아는 척하려면 계산부터 하고 와.\"\n"
                    "\n"
                    "옆 테이블 사람들이 힐끔거렸다.\n"
                    "{name}의 얼굴이 화끈거렸다. 숫자 하나만으로도 허세는 바로 들켰다."
                ),
                (
                    "「2億ウォンくらい……？」{name}は適当な数字を口にした。\n"
                    "男が鼻で笑った。\n"
                    "「5億ウォンからチョンセの3億5,000万ウォンと借入1億ウォンを引けば、5,000万ウォンだろ。学生さん、知ったか"
                    "ぶりをするなら、計算してから来な」\n"
                    "\n"
                    "隣のテーブルの人たちがちらちら見た。\n"
                    "{name}の顔が熱くなった。たった一つの数字で、虚勢はすぐに見破られた。"
                ),
                (
                    "「2億ウォンくらい……？」{name}は適当な数字を口にした。\n"
                    "男が鼻で笑った。\n"
                    "「5億ウォンからチョンセ保証金の3億5000万ウォンと借入の1億ウォンを引けば、残るのは五千万ウォンだろ。学生さん、"
                    "知ったかぶりをするなら、計算してから来な」\n"
                    "\n"
                    "隣のテーブルの人たちがちらちら見た。\n"
                    "{name}の顔が熱くなった。たった一つの数字で、虚勢はすぐに見破られた。"
                ),
            ),
            (
                "events:cafe_cb_stole_call:/description",
                "content/events/scenario_cafe_callback.json",
                (
                    "신호음 세 번. \"여보세요.\"\n"
                    "김 부장은 {name}을 기억 못 했다. {name}은 둘러댔다.\n"
                    "\"그때 카페에서... 입주권 건 소개받았던 사람입니다.\"\n"
                    "\n"
                    "잠깐의 침묵. 그러더니 목소리가 부드러워진다.\n"
                    "\"아아, 그거. 아직 한 자리 있어요. 근데 프리미엄 올랐어.\n"
                    "지금 7천. 오늘내일 안에 결정해야 돼. 어떻게, 들어와요?\""
                ),
                (
                    "呼び出し音が三回。「もしもし」\n"
                    "キム部長は{name}を覚えていなかった。{name}は話を取り繕った。\n"
                    "「あのときカフェで……入居権の件を紹介していただいた者です」\n"
                    "\n"
                    "短い沈黙。それから、声が柔らかくなる。\n"
                    "「ああ、あれね。まだ一枠ありますよ。ただ、プレミアムが上がってね。\n"
                    "今は7,000万ウォン。今日か明日には決めてもらわないと。どう、入る？」"
                ),
                (
                    "呼び出し音が三回。「もしもし」\n"
                    "キム部長は{name}を覚えていなかった。{name}は話を取り繕った。\n"
                    "「あのときカフェで……入居権の件を紹介していただいた者です」\n"
                    "\n"
                    "短い沈黙。それから、声が柔らかくなる。\n"
                    "「ああ、あれね。まだ一枠ありますよ。ただ、プレミアムが上がってね。\n"
                    "今なら七千万ウォン。今日か明日には決めてもらわないと。どう、入る？」"
                ),
            ),
            (
                "events:cafe_cb_stole_smart:/description",
                "content/events/scenario_cafe_callback.json",
                (
                    "{name}은 김 부장에게 등기를 들이밀었다.\n"
                    "\"2천은 거품이잖아요. 5천에 합시다. 아니면 신고하든가.\"\n"
                    "김 부장의 표정이 일그러졌다. 그러더니, 마지못해 끄덕였다.\n"
                    "\"...물건은 볼 줄 아네. 좋아, 5천.\"\n"
                    "\n"
                    "검증한 자만이 깎을 수 있다. {name}은 제값에 들어갈 문턱까지 왔다."
                ),
                (
                    "{name}はキム部長に登記書類を突きつけた。\n"
                    "「2,000万ウォンは水増しでしょう。5,000万ウォンにしましょう。でなければ通報します」\n"
                    "キム部長の顔がゆがんだ。それから、渋々うなずいた。\n"
                    "「……物件を見る目はあるな。いいよ、5,000万ウォンだ」\n"
                    "\n"
                    "確かめた者だけが値を下げられる。{name}は適正な値段で投資する、その一歩手前まで来た。"
                ),
                (
                    "{name}はキム部長に登記書類を突きつけた。\n"
                    "「二千万ウォンは水増しでしょう。五千万ウォンにしましょう。でなければ通報します」\n"
                    "キム部長の顔がゆがんだ。それから、渋々うなずいた。\n"
                    "「……物件を見る目はあるな。いいよ、五千万ウォンだ」\n"
                    "\n"
                    "確かめた者だけが値を下げられる。{name}は適正な値段で投資する、その一歩手前まで来た。"
                ),
            ),
            (
                "events:cafe_cb_stole_verify:/choices/0/result_text",
                "content/events/scenario_cafe_callback.json",
                (
                    "김 부장에게 등기를 내밀었다. \"2천은 거품이잖아요.\" 그가 눈을 피했다."
                ),
                (
                    "キム部長に登記書類を突きつけた。「2,000万ウォンは水増しでしょう」男が目をそらした。"
                ),
                (
                    "キム部長に登記書類を突きつけた。「二千万ウォンは上乗せ分でしょう」男が目をそらした。"
                ),
            ),
            (
                "events:cafe_cb_stole_verify:/description",
                "content/events/scenario_cafe_callback.json",
                (
                    "{name}은 사흘을 매달렸다. 등기부등본, 부동산 카페, 뉴스.\n"
                    "진실은 절반이었다 — 재개발은 진짜다. 확정도 맞다.\n"
                    "근데 김 부장은 조합원도 뭣도 아닌 그냥 브로커였고,\n"
                    "7천 중 2천은 그의 '수고비'로 부풀려진 거품이었다.\n"
                    "\n"
                    "진짜 기회 위에, 가짜 가격표가 붙어 있었다."
                ),
                (
                    "{name}は三日間、調べ続けた。登記簿謄本、不動産のネット掲示板、ニュース。\n"
                    "本当だったのは半分――再開発は本物だ。決定したのも事実だった。\n"
                    "だが、キム部長は組合員でも何でもない、ただのブローカーで、\n"
                    "7,000万ウォンのうち2,000万ウォンは、彼の「手間賃」として水増しされた分だった。\n"
                    "\n"
                    "本物のチャンスに、偽りの値札がついていた。"
                ),
                (
                    "{name}は三日間、調べ続けた。登記簿謄本、不動産のネット掲示板、ニュース。\n"
                    "本当だったのは半分――再開発は本物だ。決定したのも事実だった。\n"
                    "だが、キム部長は組合員でも何でもない、ただのブローカーで、\n"
                    "七千万ウォンのうち二千万ウォンは、彼の「手間賃」として水増しされた分だった。\n"
                    "\n"
                    "本物のチャンスに、偽りの値札がついていた。"
                ),
            ),
            (
                "events:gig_delivery_night:/choices/0/result_text",
                "content/events/viral_events.json",
                (
                    "비 오는 날은 콜이 많고, 할증이 붙는다.\n"
                    "그만큼 위험하고, 그만큼 번다.\n"
                    "\n"
                    "{name}은 새벽 한 시까지 뛰었다.\n"
                    "젖은 옷, 시린 손, 통장에 찍힌 4만 8천원.\n"
                    "\n"
                    "몸은 부서질 것 같았지만, 숫자는 정직했다.\n"
                    "이렇게라도 메워야, 본업 월급이 온전히 남는다.\n"
                    "\n"
                    "강남은 이 빗속 어딘가에서, 한 콜씩 가까워지고 있었다."
                ),
                (
                    "雨の日は依頼が多く、割増もつく。\n"
                    "その分危険で、その分稼げる。\n"
                    "\n"
                    "{name}は午前一時まで走った。\n"
                    "濡れた服、冷え切った手、口座に記された4万8千ウォン。\n"
                    "\n"
                    "体は壊れそうだったが、数字は正直だった。\n"
                    "こうしてでも穴を埋めてこそ、本業の給料をまるごと残せる。\n"
                    "\n"
                    "カンナムはこの雨のどこかで、依頼一件ずつ近づいていた。"
                ),
                (
                    "雨の日は依頼が多く、割増もつく。\n"
                    "その分危険で、その分稼げる。\n"
                    "\n"
                    "{name}は午前1時まで走った。\n"
                    "濡れた服、冷え切った手、口座に入った四万八千ウォン。\n"
                    "\n"
                    "体は壊れそうだったが、数字は正直だった。\n"
                    "こうしてでも穴を埋めてこそ、本業の給料をまるごと残せる。\n"
                    "\n"
                    "カンナムはこの雨のどこかで、依頼一件ずつ近づいていた。"
                ),
            ),
            (
                "events:rare_night_alva_find:/description",
                "content/events/rare_encounter_events.json",
                (
                    "야간 알바 마감 정리 중. 마지막 손님이 나가고 자동문이 잠긴 뒤였다.\n"
                    "\n"
                    "{name}은 의자를 올리고 테이블 아래를 닦다가 검은 봉투 하나를 발견했다. 안에는 고무줄로 묶인 5만"
                    "원권이 들어 있었다. 두 번 세어도 50만원이었다.\n"
                    "\n"
                    "천장 모서리의 CCTV 표시등이 붉게 깜박였다. 쓰레기봉투를 묶는 동안에도 자동문 너머로 돌아오는 사람은"
                    " 없었다."
                ),
                (
                    "夜勤のアルバイトで閉店作業をしていた。最後の客が出て、自動ドアを施錠したあとだった。\n"
                    "\n"
                    "{name}は椅子を上げ、テーブルの下を拭いていて、黒い袋を一つ見つけた。中には輪ゴムで束ねた五万ウォン札が入ってい"
                    "た。二度数えても50万ウォンだった。\n"
                    "\n"
                    "天井の隅で、防犯カメラの表示灯が赤く点滅していた。ごみ袋の口を縛っているあいだも、自動ドアの向こうに戻ってくる人はい"
                    "なかった。"
                ),
                (
                    "夜勤のアルバイトで閉店作業をしていた。最後の客が出て、自動ドアを施錠したあとだった。\n"
                    "\n"
                    "{name}は椅子を上げ、テーブルの下を拭いていて、黒い袋を一つ見つけた。中には輪ゴムで束ねた5万ウォンの紙幣が入っ"
                    "ていた。二度数えても50万ウォンだった。\n"
                    "\n"
                    "天井の隅で、防犯カメラの表示灯が赤く点滅していた。ごみ袋の口を縛っているあいだも、自動ドアの向こうに戻ってくる人はい"
                    "なかった。"
                ),
            ),
            (
                "events:rare_wallet_executive:/choices/1/result_text",
                "content/events/rare_encounter_events.json",
                (
                    "5만원짜리 세 장이 있었다.\n"
                    "\n"
                    "역무원이 지나갔다. {name}은 계단을 내려갔다.\n"
                    "\n"
                    "집까지 오는 내내 발걸음이 무거웠다.\n"
                    "15만원이 생겼는데 아무것도 안 생긴 것 같았다."
                ),
                (
                    "五万ウォン札が三枚あった。\n"
                    "\n"
                    "駅員が通り過ぎた。{name}は階段を下りた。\n"
                    "\n"
                    "家に着くまで、ずっと足取りが重かった。\n"
                    "15万ウォンが手に入ったのに、何も手に入っていない気がした。"
                ),
                (
                    "5万ウォンの紙幣が3枚あった。\n"
                    "\n"
                    "駅員が通り過ぎた。{name}は階段を下りた。\n"
                    "\n"
                    "家に着くまで、ずっと足取りが重かった。\n"
                    "15万ウォンが手に入ったのに、何も手に入っていない気がした。"
                ),
            ),
            (
                "events:rare_wallet_executive:/description",
                "content/events/rare_encounter_events.json",
                (
                    "퇴근 인파가 빠진 지하철역 계단. 벽 쪽에 검은 지갑 하나가 펼쳐진 채 떨어져 있었다.\n"
                    "\n"
                    "{name}은 지나쳤다가 두 칸을 다시 올라왔다. 안에는 ○○그룹 전무이사라고 적힌 명함, 카드 여러 장"
                    ", 5만원권 세 장이 가지런히 끼워져 있었다.\n"
                    "\n"
                    "개찰구 쪽에서는 안내 방송이 반복됐다. 지갑을 든 손 앞에서 계단을 오르내리는 사람들은 아무도 멈추지 않"
                    "았다."
                ),
                (
                    "帰宅客の波が引いた地下鉄駅の階段。壁際に、黒い財布が開いたまま落ちていた。\n"
                    "\n"
                    "{name}は通り過ぎてから、二段上り直した。中には○○グループ専務取締役と書かれた名刺、数枚のカード、五万ウォン札"
                    "三枚が、きちんと差し込まれていた。\n"
                    "\n"
                    "改札のほうでは案内放送が繰り返されていた。財布を持つ手の前を行き交う人は、誰も足を止めなかった。"
                ),
                (
                    "帰宅客の波が引いた地下鉄駅の階段。壁際に、黒い財布が開いたまま落ちていた。\n"
                    "\n"
                    "{name}は通り過ぎてから、二段上り直した。中には○○グループ専務取締役と書かれた名刺、数枚のカード、5万ウォンの"
                    "紙幣が三枚、きちんと差し込まれていた。\n"
                    "\n"
                    "改札のほうでは案内放送が繰り返されていた。財布を持つ手の前を行き交う人は、誰も足を止めなかった。"
                ),
            ),
        ]
        # index, identity, category, source edit, target variant, target edit
        operations = [
            (0, "cafe_cash.actual", "actual",
                None, 3, None),
            (0, "cafe_cash.natural", "natural",
                None, 4, None),
            (0, "cafe_cash.wrong_value", "target_value",
                None, 3, (142, "5", "6")),
            (0, "cafe_cash.wrong_currency", "target_currency",
                None, 3, (148, "ウォン", "ドル")),
            (0, "cafe_cash.source_off", "source_context_off",
                (25, "켰", "키려 했"), 3, None),
            (1, "cafe_arithmetic_question.actual", "actual",
                None, 3, None),
            (1, "cafe_arithmetic_question.natural", "natural",
                None, 4, None),
            (1, "cafe_arithmetic_question.wrong_value", "target_value",
                None, 3, (59, "5", "4")),
            (1, "cafe_arithmetic_question.wrong_currency", "target_currency",
                None, 3, (65, "ウォン", "ドル")),
            (1, "cafe_arithmetic_question.source_off", "source_context_off",
                (37, "묻는", "대답한"), 3, None),
            (2, "cafe_arithmetic_caught.actual", "actual",
                None, 3, None),
            (2, "cafe_arithmetic_caught.natural", "natural",
                None, 4, None),
            (2, "cafe_arithmetic_caught.wrong_value", "target_value",
                None, 3, (78, "5", "6")),
            (2, "cafe_arithmetic_caught.wrong_currency", "target_currency",
                None, 3, (84, "ウォン", "ドル")),
            (2, "cafe_arithmetic_caught.source_off", "source_context_off",
                (20, "아무 숫자나 던졌", "외운 숫자를 정확히 답했"), 3, None),
            (3, "cafe_call_quote.actual", "actual",
                None, 3, None),
            (3, "cafe_call_quote.natural", "natural",
                None, 4, None),
            (3, "cafe_call_quote.wrong_value", "target_value",
                None, 3, (141, "7", "8")),
            (3, "cafe_call_quote.wrong_currency", "target_currency",
                None, 3, (147, "ウォン", "ドル")),
            (3, "cafe_call_quote.source_off", "source_context_off",
                (105, "부드러", "날카로"), 3, None),
            (4, "cafe_bargain.actual", "actual",
                None, 3, None),
            (4, "cafe_bargain.natural", "natural",
                None, 4, None),
            (4, "cafe_bargain.wrong_value", "target_value",
                None, 3, (43, "5", "6")),
            (4, "cafe_bargain.wrong_currency", "target_currency",
                None, 3, (49, "ウォン", "ドル")),
            (4, "cafe_bargain.source_off", "source_context_off",
                (83, "마지못해 끄덕였", "끝내 거절했"), 3, None),
            (5, "cafe_markup_confront.actual", "actual",
                None, 3, None),
            (5, "cafe_markup_confront.natural", "natural",
                None, 4, None),
            (5, "cafe_markup_confront.wrong_value", "target_value",
                None, 3, (17, "2", "3")),
            (5, "cafe_markup_confront.wrong_currency", "target_currency",
                None, 3, (23, "ウォン", "ドル")),
            (5, "cafe_markup_confront.source_off", "source_context_off",
                (11, "내밀었", "감췄"), 3, None),
            (6, "cafe_markup_discovery.actual", "actual",
                None, 3, None),
            (6, "cafe_markup_discovery.natural", "natural",
                None, 4, None),
            (6, "cafe_markup_discovery.wrong_value", "target_value",
                None, 3, (114, "2", "3")),
            (6, "cafe_markup_discovery.wrong_currency", "target_currency",
                None, 3, (120, "ウォン", "ドル")),
            (6, "cafe_markup_discovery.source_off", "source_context_off",
                (87, "그냥 브로커였", "실제 조합원이었"), 3, None),
            (7, "delivery_earned.actual", "actual",
                None, 3, None),
            (7, "delivery_earned.natural", "natural",
                None, 4, None),
            (7, "delivery_earned.wrong_value", "target_value",
                None, 3, (72, "8", "9")),
            (7, "delivery_earned.wrong_currency", "target_currency",
                None, 3, (74, "ウォン", "ドル")),
            (7, "delivery_earned.source_off", "source_context_off",
                (77, "통장에 찍힌", "목표로 잡은"), 3, None),
            (8, "envelope_denomination.actual", "actual",
                None, 3, None),
            (8, "envelope_denomination.natural", "natural",
                None, 4, None),
            (8, "envelope_denomination.wrong_value", "target_value",
                None, 3, (91, "五", "四")),
            (8, "envelope_denomination.wrong_currency", "target_currency",
                None, 3, (93, "ウォン", "ドル")),
            (8, "envelope_denomination.source_off", "source_context_off",
                (123, "이었", "일 것이라 짐작했"), 3, None),
            (9, "wallet_cash_result.actual", "actual",
                None, 3, None),
            (9, "wallet_cash_result.natural", "natural",
                None, 4, None),
            (9, "wallet_cash_result.wrong_value", "target_value",
                None, 3, (0, "五", "四")),
            (9, "wallet_cash_result.wrong_currency", "target_currency",
                None, 3, (2, "ウォン", "ドル")),
            (9, "wallet_cash_result.source_off", "source_context_off",
                (22, "지나갔", "다가와 말을 걸었"), 3, None),
            (10, "wallet_cash_description.actual", "actual",
                None, 3, None),
            (10, "wallet_cash_description.natural", "natural",
                None, 4, None),
            (10, "wallet_cash_description.wrong_value", "target_value",
                None, 3, (91, "五", "四")),
            (10, "wallet_cash_description.wrong_currency", "target_currency",
                None, 3, (93, "ウォン", "ドル")),
            (10, "wallet_cash_description.source_off", "source_context_off",
                (87, "전무이", "택시기"), 3, None),
            (10, "wallet_description.wrong_count", "target_counter",
                None, 3, (97, "三", "四")),
            (9, "wallet_result.wrong_count", "target_counter",
                None, 3, (7, "三", "四")),
            (8, "envelope.wrong_count", "target_counter",
                None, 3, (104, "二", "三")),
            (0, "cafe_cash.wrong_sign", "target_sign",
                None, 3, (142, "", "−")),
            (7, "delivery.wrong_sign", "target_sign",
                None, 3, (70, "", "−")),
            (2, "cafe_wrong_answer.wrong_sign", "target_sign",
                None, 3, (1, "", "−")),
            (8, "envelope.English_residue", "target_english_residue",
                None, 4, (187, "", " Please contact the owner.")),
            (10, "wallet.English_residue", "target_english_residue",
                None, 4, (166, "", " This is not my wallet.")),
            (7, "delivery.wrong_rate", "target_money_topology",
                None, 3, (77, "", "／時間")),
            (5, "cafe_markup.duplicate_amount", "target_money_topology",
                None, 3, (26, "", "、2,000万ウォン")),
            (6, "cafe_discovery.role_swap", "target_money_topology",
                None, 3, (102, "7,000万ウォンのうち2", "2,000万ウォンのうち7")),
            (0, "source_cash_changed", "source_quantity_changed",
                (152, "5", "6"), 3, None),
            (5, "source_markup_changed", "source_quantity_changed",
                (18, "2", "3"), 3, None),
            (7, "source_delivery_changed", "source_quantity_changed",
                (87, "8", "9"), 3, None),
            (10, "source_count_changed", "source_quantity_changed",
                (115, "세", "네"), 3, None),
        ]
        cases = []
        for index, identity, category, source_edit, variant, target_edit in operations:
            row = base[index]
            source, target = row[2], row[variant]
            if source_edit:
                at, old, new = source_edit
                assert source[at:at + len(old)] == old
                source = source[:at] + new + source[at + len(old):]
            if target_edit:
                at, old, new = target_edit
                assert target[at:at + len(old)] == old
                target = target[:at] + new + target[at + len(old):]
            cases.append((identity, category, row[0], row[1], source, target))
        return cases

    def test_cafe_encounter_money_source_scoped_regression(self):
        counts = {"actual": 0, "natural": 0, "target": 0, "source": 0}
        for identity, category, leaf_id, source_path, source, target in self._cafe_encounter_regression_cases():
            _, owner, pointer = leaf_id.split(":")
            path = tuple(int(part) if part.isdigit() else part for part in pointer[1:].split("/"))
            leaf = tool.Leaf("events", owner, source_path, path, source, "event_standard")
            with self.subTest(identity=identity):
                helper = tool._ja_cafe_encounter_money_numbers(source, target)
                errors = tool.translation_errors(leaf, "ja", target)
                if category.startswith("source_"):
                    # Licence OFF and inherited E2E rejection are separate checks.
                    self.assertIsNone(helper)
                    self.assertTrue(errors)
                    counts["source"] += 1
                elif category in ("actual", "natural"):
                    self.assertIsNotNone(helper)
                    self.assertEqual(helper[2], [])
                    self.assertEqual(errors, [])
                    counts[category] += 1
                elif category == "target_english_residue":
                    # Existing nonnumeric English limitation: not part of this
                    # numeric repair and not counted as a rejected mutation.
                    self.assertIsNotNone(helper)
                    self.assertEqual(helper[2], [])
                    self.assertEqual(errors, [])
                    counts["target"] += 1
                else:
                    self.assertIsNotNone(helper)
                    self.assertTrue(helper[2])
                    self.assertTrue(errors)
                    counts["target"] += 1
        self.assertEqual(counts, {"actual": 11, "natural": 11, "target": 33, "source": 15})


    @staticmethod
    def _cafe_encounter_disclosed_ja_cases():
        # These four JA inputs were disclosed only after the independent B1
        # failed. Their B2 replay is a public regression, not new independence.
        return [
            (
                "events:cafe_humble:/choices/0/result_text",
                (
                    "십 분이 삼십 분이 됐다.\n"
                    "갭투자, 레버리지, 입주권, 프리미엄 —\n"
                    "{name}은 처음 듣는 부동산 용어를 수첩에 적었다.\n"
                    "\n"
                    "남자는 명함도 주지 않았고 이름도 알려 주지 않았다. 그래도 오늘 들은 숫자와 용어는 수첩에 남았다"
                    "."
                ),
                (
                    "十分が三十分になった。\n"
                    "チョンセの保証金との差額を使う投資、レバレッジ、再開発住宅の入居権、プレミアム——\n"
                    "{name}は初めて聞く不動産用語を手帳に書き留めた。\n"
                    "\n"
                    "男は名刺も渡さず、名前も教えなかった。それでも、今日聞いた数字と言葉は手帳に残った。"
                ),
                (
                    "十分が四十分になった。\n"
                    "チョンセの保証金との差額を使う投資、レバレッジ、再開発住宅の入居権、プレミアム——\n"
                    "{name}は初めて聞く不動産用語を手帳に書き留めた。\n"
                    "\n"
                    "男は名刺も渡さず、名前も教えなかった。それでも、今日聞いた数字と言葉は手帳に残った。"
                ),
            ),
            (
                "events:rare_wallet_executive:/choices/1/result_text",
                (
                    "5만원짜리 세 장이 있었다.\n"
                    "\n"
                    "역무원이 지나갔다. {name}은 계단을 내려갔다.\n"
                    "\n"
                    "집까지 오는 내내 발걸음이 무거웠다.\n"
                    "15만원이 생겼는데 아무것도 안 생긴 것 같았다."
                ),
                (
                    "五万ウォン札が三枚あった。\n"
                    "\n"
                    "駅員が通り過ぎた。{name}は階段を下りた。\n"
                    "\n"
                    "家に着くまで、ずっと足取りが重かった。\n"
                    "十五万ウォンを手にしたのに、何も得ていない気がした。"
                ),
                (
                    "五万ウォン札が四枚あった。\n"
                    "\n"
                    "駅員が通り過ぎた。{name}は階段を下りた。\n"
                    "\n"
                    "家に着くまで、ずっと足取りが重かった。\n"
                    "十五万ウォンを手にしたのに、何も得ていない気がした。"
                ),
            ),
            (
                "events:rare_junk_sale_mentor:/choices/0/result_text",
                (
                    "남자가 잠깐 생각했다.\n"
                    "\"저도 33살에 서울 올라왔어요. 편하게 얘기 한 번 해요.\"\n"
                    "\n"
                    "명함을 받았다. 작은 투자사 대표였다.\n"
                    "\n"
                    "물건 3만원을 팔고, 연락처를 얻었다.\n"
                    "중고 거래가 이렇게 쓰이는 줄은 몰랐다."
                ),
                (
                    "男は少し考えた。\n"
                    "「私も三十三歳でソウルに出てきたんです。気軽にお話ししましょう」\n"
                    "\n"
                    "名刺を受け取った。小さな投資会社の代表だった。\n"
                    "\n"
                    "品物を三万ウォンで売り、連絡先を得た。\n"
                    "中古品の取引に、こんな使い道があるとは知らなかった。"
                ),
                (
                    "男は少し考えた。\n"
                    "「私も三十四歳でソウルに出てきたんです。気軽にお話ししましょう」\n"
                    "\n"
                    "名刺を受け取った。小さな投資会社の代表だった。\n"
                    "\n"
                    "品物を三万ウォンで売り、連絡先を得た。\n"
                    "中古品の取引に、こんな使い道があるとは知らなかった。"
                ),
            ),
            (
                "events:rare_lottery_result:/choices/0/result_text",
                (
                    "5만원.\n"
                    "\n"
                    "2등도 1등도 아니지만 5만원이었다.\n"
                    "\n"
                    "{name}은 그걸 다시 투자하거나 복권을 더 사지 않았다.\n"
                    "그냥 밥을 사먹었다. 좋은 거 먹었다.\n"
                    "\n"
                    "그게 복권의 올바른 사용법인지는 모르겠지만, 기분은 좋았다."
                ),
                (
                    "五万ウォン。\n"
                    "\n"
                    "二等でも一等でもないが、五万ウォンだった。\n"
                    "\n"
                    "{name}はそれをまた投資に回したり、宝くじを買い足したりしなかった。\n"
                    "ただ食事をした。うまいものを食べた。\n"
                    "\n"
                    "それが宝くじの正しい使い方かどうかはわからないが、気分はよかった。"
                ),
                (
                    "五万ウォン。\n"
                    "\n"
                    "三等でも一等でもないが、五万ウォンだった。\n"
                    "\n"
                    "{name}はそれをまた投資に回したり、宝くじを買い足したりしなかった。\n"
                    "ただ食事をした。うまいものを食べた。\n"
                    "\n"
                    "それが宝くじの正しい使い方かどうかはわからないが、気分はよかった。"
                ),
            ),
        ]

    def test_cafe_encounter_disclosed_ja_regression(self):
        cases = self._cafe_encounter_disclosed_ja_cases()
        self.assertEqual(len(cases), 4)
        for leaf_id, source, normal, mutant in cases:
            _, owner, pointer = leaf_id.split(":")
            path = tuple(int(part) if part.isdigit() else part for part in pointer[1:].split("/"))
            leaf = tool.Leaf("events", owner, "disclosed-JA-only", path, source, "event_standard")
            with self.subTest(identity=leaf_id):
                self.assertEqual(tool._ja_cafe_encounter_money_numbers(source, normal)[2], [])
                self.assertEqual(tool.translation_errors(leaf, "ja", normal), [])
                self.assertTrue(tool._ja_cafe_encounter_money_numbers(source, mutant)[2])
                self.assertTrue(tool.translation_errors(leaf, "ja", mutant))


    @staticmethod
    def _chain_support_salary_regression_cases():
        # Keep multilingual fixtures on short physical lines; verify via Python CLI.
        exposed = [
            (
                "events:chain_exec_meal:/choices/0/result_text",
                (
                    "{name}은 답장 칸에 가능한 시간을 먼저 적었다.\n"
                    "\"감사합니다. 이번 주 토요일 낮이라면 괜찮습니다.\"\n"
                    "\n"
                    "잠시 뒤 새 메시지가 왔다.\n"
                    "\"그럼 토요일 12시 30분, 강남 ○○한정식에서 뵙죠.\"\n"
                    "\n"
                    "{name}은 날짜와 주소를 다시 확인해 보냈다.\n"
                    "\"네, 그때 뵙겠습니다.\"\n"
                    "두 사람의 확인이 끝난 뒤에야 달력에 약속을 넣었다."
                ),
                (
                    "{name}は返信欄に、まず自分の都合のよい時間を書いた。\n"
                    "「ありがとうございます。今週の土曜日の昼でしたら大丈夫です」\n"
                    "\n"
                    "少しして、新しいメッセージが届いた。\n"
                    "「では土曜日の12時30分、江南の○○韓定食で会いましょう」\n"
                    "\n"
                    "{name}は日付と住所をもう一度確認して送った。\n"
                    "「はい、その時間に伺います」\n"
                    "二人の確認が済んでから、ようやくカレンダーに予定を入れた。"
                ),
                (
                    "{name}は返信欄に、まず自分の都合のよい時間を書いた。\n"
                    "「ありがとうございます。今週の土曜日の昼でしたら大丈夫です」\n"
                    "\n"
                    "少しして、新しいメッセージが届いた。\n"
                    "「では土曜日の12時40分、江南の○○韓定食で会いましょう」\n"
                    "\n"
                    "{name}は日付と住所をもう一度確認して送った。\n"
                    "「はい、その時間に伺います」\n"
                    "二人の確認が済んでから、ようやくカレンダーに予定を入れた。"
                ),
            ),
            (
                "events:butterfly_resume_lie:/description",
                (
                    "취업 지원서를 쓰다가 멈췄다.\n"
                    "\n"
                    "자격증 칸. 토익 900이라고 적었다.\n"
                    "\n"
                    "실제 점수는 745.\n"
                    "\n"
                    "지원 마감이 2시간 뒤다. 재시험을 볼 시간이 없다."
                ),
                (
                    "応募書類を書いていて、手が止まった。\n"
                    "\n"
                    "資格欄。TOEIC 900と書いた。\n"
                    "\n"
                    "実際の点数は745。\n"
                    "\n"
                    "応募締め切りまであと2時間。試験を受け直す時間はない。"
                ),
                (
                    "応募書類を書いていて、手が止まった。\n"
                    "\n"
                    "資格欄。TOEIC 900と書いた。\n"
                    "\n"
                    "実際の点数は754。\n"
                    "\n"
                    "応募締め切りまであと2時間。試験を受け直す時間はない。"
                ),
            ),
            (
                "events:chain_neighbor_civil_servant:/choices/0/result_text",
                (
                    "서류를 갖춰 신청했다. 선정됐다.\n"
                    "\n"
                    "월세 지원 6개월. 총 120만원.\n"
                    "\n"
                    "{name}은 선정 문자 화면을 캡처해 보냈다.\n"
                    "'덕분에 신청했어요. 고마워요.'\n"
                    "\n"
                    "잠시 뒤 엄지손가락 이모티콘 하나가 도착했다."
                ),
                (
                    "書類をそろえて申請した。選ばれた。\n"
                    "\n"
                    "家賃補助は6か月。総額百二十万ウォン。\n"
                    "\n"
                    "{name}は選定を知らせるメッセージ画面を撮って送った。\n"
                    "「おかげで申請できました。ありがとう」\n"
                    "\n"
                    "少しして、親指を立てた絵文字が一つ届いた。"
                ),
                (
                    "書類をそろえて申請した。選ばれた。\n"
                    "\n"
                    "家賃補助は8か月。総額百二十万ウォン。\n"
                    "\n"
                    "{name}は選定を知らせるメッセージ画面を撮って送った。\n"
                    "「おかげで申請できました。ありがとう」\n"
                    "\n"
                    "少しして、親指を立てた絵文字が一つ届いた。"
                ),
            ),
            (
                "events:chain_exec_interview:/choices/0/result_text",
                (
                    "\"지하철역에서 지갑을 주워서 돌려드렸습니다. 그게 전부입니다.\"\n"
                    "\n"
                    "면접관들이 서로를 봤다. 한 명이 웃었다.\n"
                    "\"그 얘기 들었어요. 본인 입으로 듣고 싶었습니다.\"\n"
                    "\n"
                    "합격 통보는 사흘 뒤에 왔다. 기본급은 월 455만원이었다.\n"
                    "\n"
                    "첫 출근 날, {name}은 목에 건 사원증의 계열사 로고를 엄지로 한 번 문질렀다."
                ),
                (
                    "「地下鉄の駅で財布を拾って、お返ししました。それだけです」\n"
                    "\n"
                    "面接官たちが顔を見合わせた。一人が笑った。\n"
                    "「その話は聞きました。ご本人の口から聞きたかったんです」\n"
                    "\n"
                    "合格の知らせは3日後に届いた。基本給は月455万ウォンだった。\n"
                    "\n"
                    "初出勤の日、{name}は首から下げた社員証の系列会社のロゴを、親指で一度こすった。"
                ),
                (
                    "「地下鉄の駅で財布を拾って、お返ししました。それだけです」\n"
                    "\n"
                    "面接官たちが顔を見合わせた。一人が笑った。\n"
                    "「その話は聞きました。ご本人の口から聞きたかったんです」\n"
                    "\n"
                    "合格の知らせは3日後に届いた。基本給は月445万ウォンだった。\n"
                    "\n"
                    "初出勤の日、{name}は首から下げた社員証の系列会社のロゴを、親指で一度こすった。"
                ),
            ),
        ]
        cases = []
        for i, (leaf_id, source, normal, mutant) in enumerate(exposed):
            cases.extend((
                (f"exposed-{i}-normal", "exposed_normal", leaf_id, source, normal),
                (f"exposed-{i}-mutant", "exposed_mutant", leaf_id, source, mutant),
            ))
        actuals = (
            (
                "書類をそろえて申請した。支給対象に選ばれた。\n"
                "\n"
                "家賃の補助は6か月。合計120万ウォン。\n"
                "\n"
                "{name}は選定通知のメッセージ画面のスクリーンショットを送った。\n"
                "『おかげで申請できました。ありがとうございます』\n"
                "\n"
                "少しして、親指を立てた絵文字が一つ届いた。"
            ),
            (
                "「地下鉄の駅で財布を拾って、お返ししました。それだけです」\n"
                "\n"
                "面接官たちが顔を見合わせた。一人が笑った。\n"
                "「その話は聞いています。ご本人の口から聞きたかったんです」\n"
                "\n"
                "合格の通知は三日後に来た。基本給は月455万ウォンだった。\n"
                "\n"
                "初出勤の日、{name}は首から下げた社員証の系列会社のロゴを、親指で一度こすった。"
            ),
        )
        natural_rewrites = (
            (("6か月", "六か月"), ("120万ウォン", "百二十万ウォン")),
            (("455万ウォン", "四百五十五万ウォン"),),
        )
        mutations = (
            (
                ("百二十万", "百三十万"),
                ("六か月", "六年"),
                ("百二十万", "-百二十万"),
                ("百二十万ウォン", "百二十万円"),
                ("百二十万ウォン", "百二十万ウォン/月"),
                ("一つ届いた", "二つ届いた"),
            ),
            (
                ("四百五十五万", "四百四十五万"),
                ("三日後", "三か月後"),
                ("四百五十五万", "-四百五十五万"),
                ("四百五十五万ウォン", "四百五十五万円"),
                ("月四百五十五万", "年四百五十五万"),
                ("一度こすった", "二度こすった"),
            ),
        )
        source_changes = (
            (
                ("서류", "서류들"),
                ("120만원", "130만원"),
            ),
            (
                ("지하철역", "기차역"),
                ("455만원", "445만원"),
            ),
        )
        for i, actual in enumerate(actuals):
            leaf_id, source, _, _ = exposed[i + 2]
            natural = actual
            for old, new in natural_rewrites[i]:
                natural = natural.replace(old, new, 1)
            cases.extend((
                (f"actual-{i}", "own_actual", leaf_id, source, actual),
                (f"natural-{i}-0", "own_natural", leaf_id, source, natural),
            ))
            for j, (old, new) in enumerate(mutations[i]):
                cases.append((f"target-{i}-{j}", "own_target", leaf_id,
                              source, natural.replace(old, new, 1)))
            for j, (old, new) in enumerate(source_changes[i]):
                cases.append((f"source-{i}-{j}", "source_off", leaf_id,
                              source.replace(old, new, 1), natural))
        return cases

    def test_chain_support_salary_disclosed_regression(self):
        cases = self._chain_support_salary_regression_cases()
        self.assertEqual(len(cases), 28)
        for identity, category, leaf_id, source, target in cases:
            _, owner, pointer = leaf_id.split(":")
            path = tuple(int(part) if part.isdigit() else part
                         for part in pointer[1:].split("/"))
            leaf = tool.Leaf("events", owner, "chain-support-control", path,
                             source, "event_standard")
            with self.subTest(identity=identity):
                helper = tool._ja_chain_support_salary_numbers(source, target)
                errors = tool.translation_errors(leaf, "ja", target)
                if category == "source_off":
                    # Licence absence is the assertion; generic E2E is separate.
                    self.assertIsNone(helper)
                elif category in ("exposed_normal", "own_actual", "own_natural"):
                    self.assertEqual(errors, [])
                    if helper is not None:
                        self.assertEqual(helper[2], [])
                else:
                    self.assertTrue(errors)
                    if helper is not None:
                        self.assertTrue(helper[2])


    @staticmethod
    def _amb_tradeoff_regression_cases():
        # Keep multilingual fixture strings on short physical lines and check
        # the real Python CLI, not merely decode/compile, in the final lane.
        base = (
            (
                "events:amb_credit_confront:/choices/0/result_text",
                (
                    "{name}은 분명히 선을 그었다. 부장은 떨떠름하게 \"알았어\" 했다.\n"
                    "호구는 면했다. 부장도 함부로 못 하게 됐다.\n"
                    "대신 둘 사이엔 서늘한 거리가 생겼다.\n"
                    "존중은 요구해야 얻어지지만 — 그 대가는 편안함이다."
                ),
                (
                    "{name}ははっきり一線を引いた。部長は渋々「わかった」と言った。\n"
                    "カモにならずに済んだ。部長も好き勝手はできなくなった。\n"
                    "代わりに、2人の間には冷えた距離が生まれた。\n"
                    "尊重は求めなければ得られないが――その代償は居心地のよさだ。"
                ),
            ),
            (
                "events:amb_credit_confront:/title",
                (
                    "독대"
                ),
                (
                    "2人きりで"
                ),
            ),
            (
                "events:amb_credit_steal_00:/choices/2/result_text",
                (
                    "{name}은 임원에게 따로 자료 원본을 보냈다. '참고하시라'며.\n"
                    "임원은 알아챘다. {name}의 이름이 윗선에 각인됐다.\n"
                    "대신 부장은 — 누가 찔렀는지 안다. 보이지 않는 칼이 갈리기 시작했다.\n"
                    "인정을 얻은 값으로, {name}은 적을 하나 만들었다."
                ),
                (
                    "{name}は役員に別途、元の資料を送った。『ご参考までに』と添えて。\n"
                    "役員は察した。上層部に{name}の名前が刻まれた。\n"
                    "その代わり部長は――誰が告げたか知っている。見えない刃が研がれ始めた。\n"
                    "認められた代償に、{name}は敵を1人作った。"
                ),
            ),
            (
                "events:amb_guarantee_00:/choices/1/result_text",
                (
                    "{name}은 결국 도장을 찍었다. 친구는 눈물까지 글썽이며 고마워했다.\n"
                    "우정은 지켰다. 대신 — 남의 빚이 {name}의 어깨에 얹혔다.\n"
                    "그 사업이 잘되길, {name}은 매일 빌게 됐다.\n"
                    "호의로 찍은 도장 하나가, 평생의 불안이 될 줄도 모르고."
                ),
                (
                    "{name}は結局、ハンコを押した。友人は涙まで浮かべて礼を言った。\n"
                    "友情は守った。代わりに――他人の借金が{name}の肩に載った。\n"
                    "あの事業がうまくいくようにと、{name}は毎日祈るようになった。\n"
                    "好意で押したハンコ1つが、一生の不安になるとも知らずに。"
                ),
            ),
            (
                "events:amb_guarantee_00:/description",
                (
                    "고등학교 친구가 오랜만에 술을 사겠다며 불러냈다.\n"
                    "몇 잔 돌고 나서야 본론이 나온다.\n"
                    "\"사업 자금 대출인데, 보증인 한 명이 모자라. 도장만 찍어주면 돼.\n"
                    "절대 너한테 피해 안 가. 우리 사이에 이 정도도 못 해줘?\"\n"
                    "\n"
                    "{name}은 안다. 보증은 남의 빚을 내 빚으로 만드는 일이라는 걸.\n"
                    "그리고 — 거절은, 20년 우정에 금을 낸다는 것도."
                ),
                (
                    "高校の友人が、久しぶりに飲もう、おごるからと呼び出した。\n"
                    "何杯か飲んで、ようやく本題が出る。\n"
                    "「事業資金の融資なんだけど、保証人が1人足りないんだ。ハンコを押すだけでいい。\n"
                    "絶対に迷惑はかけない。俺たちの仲で、そのくらいも駄目か？」\n"
                    "\n"
                    "{name}は知っている。保証人になるとは、他人の借金を自分の借金にすることだと。\n"
                    "そして――断れば、20年の友情にひびが入ることも。"
                ),
            ),
            (
                "events:amb_guarantee_00:/title",
                (
                    "도장 하나만"
                ),
                (
                    "ハンコ1つだけ"
                ),
            ),
            (
                "events:amb_hoesik_00:/title",
                (
                    "한 잔 더"
                ),
                (
                    "もう1杯"
                ),
            ),
            (
                "events:amb_hoesik_drink:/choices/0/result_text",
                (
                    "{name}은 숙취해소제를 털어넣고 출근했다.\n"
                    "비틀거리며 하루를 버텼다. 결근은 면했지만,\n"
                    "몸은 한참을 회복하지 못했다. 관계를 산 값은, 늘 몸으로 치른다."
                ),
                (
                    "{name}は二日酔い対策の薬を流し込み、出勤した。\n"
                    "ふらつきながら1日を乗り切った。欠勤は免れたが、\n"
                    "体はなかなか回復しなかった。関係を買った代金は、いつも体で払う。"
                ),
            ),
            (
                "events:amb_hoesik_drink:/choices/1/result_text",
                (
                    "{name}은 반차를 냈다. 종일 앓았다.\n"
                    "어제 쌓은 점수가 오늘 조금 깎였다.\n"
                    "관계도, 건강도 다 가질 수는 없다는 걸 — 또 배웠다."
                ),
                (
                    "{name}は半休を取った。1日中苦しんだ。\n"
                    "昨日稼いだ点数が、今日少し削れた。\n"
                    "関係も健康も、両方は手に入らない――また思い知らされた。"
                ),
            ),
            (
                "events:amb_holiday_00:/choices/1/result_text",
                (
                    "{name}은 \"일이 있다\"고 둘러댔다. 비교당할 일도, 차비 쓸 일도 없었다.\n"
                    "대신 명절 내내 지금 사는 방에 혼자 있었다.\n"
                    "아버지가 보낸 '밥은 챙겨 먹어라' 문자에 — 한참 답을 못 했다."
                ),
                (
                    "{name}は「仕事がある」とごまかした。比較もされず、交通費もかからなかった。\n"
                    "その代わり、旧正月の間ずっと、今暮らしている部屋で1人だった。\n"
                    "父から届いた『ちゃんと飯を食えよ』というメッセージに――長いこと返事ができなかった。"
                ),
            ),
            (
                "events:amb_holiday_00:/choices/2/result_text",
                (
                    "{name}은 큰집은 건너뛰고, 아버지만 따로 찾아뵀다.\n"
                    "둘이 먹은 국밥 한 그릇. 비교도, 잔소리도 없었다.\n"
                    "차비는 들었지만 — 가장 보고 싶던 사람만, 조용히 보고 왔다."
                ),
                (
                    "{name}は本家には寄らず、父だけに会いに行った。\n"
                    "2人で食べた1杯のクッパ。比較も、小言もなかった。\n"
                    "交通費はかかったが――いちばん会いたかった人だけに、静かに会ってきた。"
                ),
            ),
            (
                "events:amb_jeonse_00:/choices/2/result_text",
                (
                    "신호음이 세 번 울렸다. 집주인은 \"별 문제 없다\"며 말을 짧게 잘랐다."
                ),
                (
                    "呼び出し音が3回鳴った。大家は「何も問題ありません」と、話を短く切り上げた。"
                ),
            ),
            (
                "events:amb_jeonse_00:/description",
                (
                    "옆집 아주머니가 {name}을 붙잡고 속삭인다.\n"
                    "\"그 집주인 양반, 이 건물 말고도 빚이 산더미래.\n"
                    "등기부는 떼봤어? 요즘 전세 사기 무서워.\"\n"
                    "\n"
                    "{name}의 전세보증금 — 몇 년을 모은 전 재산이 —\n"
                    "그 집에 묶여 있다. '깡통전세' 네 글자가 머릿속을 맴돈다."
                ),
                (
                    "隣の奥さんが{name}を呼び止め、声をひそめる。\n"
                    "「ここの大家さん、この建物以外にも借金が山ほどあるんだって。\n"
                    "登記は取ってみた？　最近、チョンセ詐欺は怖いよ」\n"
                    "\n"
                    "高額な保証金を預ける賃貸制度、チョンセ。その保証金に――何年もかけて貯めた{name}の全財産が――\n"
                    "あの家で縛られている。保証金が戻らない『カントンチョンセ』。その韓国語4文字が頭の中を回る。"
                ),
            ),
            (
                "events:amb_jeonse_check:/description",
                (
                    "등기부를 떼보니 — 근저당이 시세의 80%.\n"
                    "집주인이 무너지면 보증금은 한 푼도 못 건진다.\n"
                    "다행히 아직 전세보증보험에 들 수 있는 마지노선은 넘기지 않았다.\n"
                    "\n"
                    "보험료 30만원. {name}의 한 달 식비보다 많다."
                ),
                (
                    "登記を取ってみると――根抵当権の額が相場の80%。\n"
                    "大家が倒れれば、保証金は一銭も戻らない。\n"
                    "幸い、チョンセ保証金の返還保証保険に入れるぎりぎりの線は、まだ越えていなかった。\n"
                    "\n"
                    "保険料は30万ウォン。{name}の1か月の食費より高い。"
                ),
            ),
            (
                "events:amb_jobswitch_in:/description",
                (
                    "{name}은 사직서를 냈다. 안정된 월급을 제 손으로 버렸다.\n"
                    "새 사무실은 활기차고, 사람들은 눈이 반짝였다.\n"
                    "그리고 — 야근은 두 배, 미래는 안갯속.\n"
                    "스톡옵션 종이 한 장이, 휴지가 될지 인생이 될지."
                ),
                (
                    "{name}は退職届を出した。安定した給料を、自分の手で捨てた。\n"
                    "新しいオフィスには活気があり、人々の目は輝いていた。\n"
                    "そして――残業は2倍、未来は霧の中。\n"
                    "ストックオプションの紙1枚が、紙くずになるのか、人生になるのか。"
                ),
            ),
            (
                "events:amb_mlm_00:/choices/0/result_text",
                (
                    "카페에서 두 시간을 보냈다. 화이트보드 그림과 \"수익구조\"라는 단어가 반복됐다."
                ),
                (
                    "カフェで2時間過ごした。ホワイトボードの図と「収益構造」という言葉が繰り返された。"
                ),
            ),
            (
                "events:amb_mlm_00:/choices/1/result_text",
                (
                    "{name}은 \"관심 없어\" 하고 대화를 닫았다.\n"
                    "동창은 \"기회를 발로 찬다\"며 비아냥댔고, 인연은 거기서 끊겼다.\n"
                    "월 천의 환상도 함께 접었다. 절박할수록, 단호해야 했다."
                ),
                (
                    "{name}は「興味ない」と会話を終えた。\n"
                    "同級生は「チャンスを蹴るんだな」と嫌みを言い、縁はそこで切れた。\n"
                    "月に1000万ウォンという幻想も畳んだ。追い詰められているときほど、きっぱり断らなくてはならなかった。"
                ),
            ),
            (
                "events:amb_mlm_00:/description",
                (
                    "연락 끊겼던 동창에게서 카톡이 왔다. 반가운 인사.\n"
                    "\"잘 지내? 요즘 뭐 해? 나 좋은 사업 하나 하는데,\n"
                    "무자본으로 월 천도 가능해. 너 같은 사람한테 딱이야.\n"
                    "시간 되면 한번 보자, 응?\"\n"
                    "\n"
                    "무직에 통장은 바닥. {name}은 그게 뭔지 어렴풋이 안다.\n"
                    "그래도 — '월 천'이라는 네 글자가 자꾸 눈에 밟힌다."
                ),
                (
                    "連絡の途絶えていた同級生からカカオトークが来た。懐かしい挨拶。\n"
                    "「元気？　最近どうしてる？　いいビジネスを始めたんだけど、\n"
                    "元手なしで月に1000万ウォンもいけるんだ。お前みたいな人にぴったりでさ。\n"
                    "時間があったら会おうよ。な？」\n"
                    "\n"
                    "無職で、口座は底をついている。{name}にも、それが何なのか薄々わかる。\n"
                    "それでも――『月に千万』の4文字が、何度も目にちらついた。"
                ),
            ),
            (
                "events:amb_mlm_aftermath:/description",
                (
                    "다단계로 떠안은 물건은 창고에 그대로다. 한 개도 못 팔았다.\n"
                    "그리고 — 300만원 카드값이 돌아왔다. 독촉 전화가 빗발친다.\n"
                    "그 동창은 연락이 끊겼다. 처음부터 {name}은 '고객'이 아니라 '먹잇감'이었다.\n"
                    "\n"
                    "그날의 '한 번뿐인 기회'가, 매일 울리는 빚 독촉으로 돌아왔다."
                ),
                (
                    "マルチ商法で抱え込んだ商品は、倉庫に置いたままだ。1つも売れなかった。\n"
                    "そして――300万ウォンのカード請求が来た。督促の電話が鳴り続ける。\n"
                    "あの同級生とは連絡が取れない。最初から{name}は『客』ではなく『獲物』だった。\n"
                    "\n"
                    "あの日の『一度きりのチャンス』が、毎日鳴る借金の督促になって戻ってきた。"
                ),
            ),
            (
                "events:amb_mlm_aftermath_father_passed:/choices/2/result_text",
                (
                    "{name}은 어머니에게 전화를 걸어 처음부터 끝까지 말했다.\n"
                    "어머니는 아버지와 함께 비상금으로 남겨 둔 돈에서 300만원을 보냈다. \"왜 이 지경이 될 때까지 혼자 있었니.\"\n"
                    "카드값은 막았지만, 이미 떠난 사람의 몫까지 모아 둔 돈을 빌렸다는 사실이 오래 남았다."
                ),
                (
                    "{name}は母に電話をかけ、最初から最後まで話した。\n"
                    "母は父と2人でいざというときのために残しておいた金から、300万ウォンを送った。「どうしてこんなことになるまで、1人で抱えていたの」\n"
                    "カードの支払いは済んだが、もういない人の分まで貯めてあった金を借りたという事実が、長く残った。"
                ),
            ),
            (
                "events:amb_mlm_aftermath_father_passed:/description",
                (
                    "다단계로 떠안은 물건은 창고에 그대로다. 한 개도 못 팔았다.\n"
                    "그리고 — 300만원 카드값이 돌아왔다. 독촉 전화가 빗발친다.\n"
                    "그 동창은 연락이 끊겼다. 처음부터 {name}은 '고객'이 아니라 '먹잇감'이었다.\n"
                    "\n"
                    "그날의 '한 번뿐인 기회'가, 매일 울리는 빚 독촉으로 돌아왔다."
                ),
                (
                    "マルチ商法で抱え込んだ商品は、倉庫に置いたままだ。1つも売れなかった。\n"
                    "そして――300万ウォンのカード請求が来た。督促の電話が鳴り続ける。\n"
                    "あの同級生とは連絡が取れない。最初から{name}は『客』ではなく『獲物』だった。\n"
                    "\n"
                    "あの日の『一度きりのチャンス』が、毎日鳴る借金の督促になって戻ってきた。"
                ),
            ),
            (
                "events:amb_wallet_00:/choices/2/result_text",
                (
                    "{name}은 모른 척 발걸음을 옮겼다.\n"
                    "남의 돈도, 양심의 짐도 지지 않았다.\n"
                    "다만 버스 안에서 내내 그 지갑이 생각났다.\n"
                    "아무것도 안 하는 것도, 하나의 선택이었다."
                ),
                (
                    "{name}は知らないふりで歩き出した。\n"
                    "他人の金も、良心の重荷も背負わなかった。\n"
                    "ただ、バスに乗っている間ずっと、あの財布が頭に浮かんだ。\n"
                    "何もしないのも、1つの選択だった。"
                ),
            ),
            (
                "events:amb_wallet_payoff:/choices/0/result_text",
                (
                    "{name}은 주말마다 사장님 가게에 나갔다. 일당도, 배움도 쏠쏠했다.\n"
                    "사장님은 장사 노하우와 사람 쓰는 법을 아낌없이 알려줬다.\n"
                    "대신 {name}의 주말은 사라졌다. 쉴 틈은 줄었지만,\n"
                    "정직이 만든 인연 하나가 — 든든한 뒷배가 되어갔다."
                ),
                (
                    "{name}は週末になると社長の店へ行った。日当も、学びも悪くなかった。\n"
                    "社長は商売のこつや人の使い方を、惜しみなく教えてくれた。\n"
                    "代わりに{name}の週末は消えた。休む暇は減ったが、\n"
                    "正直さが生んだ1つの縁が――心強い後ろ盾になっていった。"
                ),
            ),
        )
        natural = (
            [["2人","二人"]],
            [["2人きりで","二人だけで"]],
            [["1人","一人"]],
            [["ハンコ1つ","一つのハンコ"]],
            [["1人","一名"],["20年","二十年"]],
            [["ハンコ1つだけ","一つのハンコだけ"]],
            [["もう1杯","あと一杯"]],
            [["1日を","一日を"]],
            [["1日中","一日じゅう"]],
            [["1人だった","ひとりだった"]],
            [["2人で","二人で"],["1杯の","一杯の"]],
            [["3回","三度"]],
            [["韓国語4文字","韓国語の四文字"]],
            [["80%","八十%"],["30万","三十万"],["1か月","一ヶ月"]],
            [["2倍","二倍"],["紙1枚","一枚の紙"]],
            [["2時間","二時間"]],
            [["1000万","千万"]],
            [["1000万","千万"],["4文字","四文字"]],
            [["1つも","一個も"]],
            [["2人で","二人で"],["300万","三百万"],["1人で","ひとりで"]],
            [["1つも","一個も"]],
            [["1つの選択","一つの選択"]],
            [["1つの縁","一つの縁"]],
        )
        mutations = (
            [["2人","3人"],["2人","2日"],["冷えた距離が生まれた","冷えた距離は生まれなかった"]],
            [["2人","3人"],["2人","2日"]],
            [["1人","2人"],["敵を1人","味方を1人"]],
            [["1つ","2つ"],["押したハンコ","押さなかったハンコ"]],
            [["1人","2人"],["20年","21年"],["1人足りない","1人そろった"]],
            [["1つ","2つ"],["1つ","1年"]],
            [["1杯","2杯"],["1杯","1年"]],
            [["1日","2日"],["1日","1時間"],["乗り切った","乗り切るつもりだ"]],
            [["1日","2日"],["1日","1時間"],["苦しんだ","苦しまなかった"]],
            [["1人","2人"],["1人","1日"],["1人だった","1人になる予定だった"]],
            [["2人","3人"],["1杯","2杯"],["食べた","食べる予定の"]],
            [["3回","4回"],["3回","3分"],["鳴った","鳴らなかった"]],
            [["4文字","5文字"],["4文字","4年"]],
            [["80%","81%"],["30万","31万"],["1か月","2か月"],["1か月","1年"]],
            [["2倍","3倍"],["1枚","2枚"],["1枚","1年"]],
            [["2時間","3時間"],["2時間","2日"],["過ごした","過ごす予定だ"]],
            [["1000万","2000万"],["1000万ウォン","1000万円"],["月に","年に"]],
            [["1000万","2000万"],["4文字","5文字"],["月に1000","年に1000"]],
            [["1つ","2つ"],["300万","301万"],["売れなかった","売れた"]],
            [["2人","3人"],["300万","301万"],["1人","2人"]],
            [["1つ","2つ"],["300万","301万"],["一度きり","二度きり"]],
            [["1つ","2つ"],["選択だった","選択ではなかった"]],
            [["1つ","2つ"],["縁が","借金が"]],
        )

        def replace(text, changes):
            for before, after in changes:
                assert before in text
                text = text.replace(before, after, 1)
            return text

        import re

        cases = []
        for index, (identity, source, target) in enumerate(base):
            base_case = dict(id=identity, source=source, target=target)
            cases.append(dict(base_case, key=f"{index}:actual", category="actual", expect="pass"))
            cases.append(dict(base_case, key=f"{index}:natural", category="natural", expect="pass",
                              target=replace(target, natural[index])))
            for counter, change in enumerate(mutations[index]):
                cases.append(dict(base_case, key=f"{index}:mutation:{counter}", category="target",
                                  expect="reject", target=replace(target, [change])))
            number = re.search(r"\d+", target)
            assert number
            signed = target[:number.start()] + "-" + target[number.start():]
            cases.append(dict(base_case, key=f"{index}:sign", category="target",
                              expect="reject", target=signed))
            cases.append(dict(base_case, key=f"{index}:duplicate", category="target",
                              expect="reject", target=target + " 追加で二人。"))
            cases.append(dict(base_case, key=f"{index}:source-context", category="source_off",
                              expect="off", source="별" + source))
            source_number = re.search(r"\d+", source)
            if source_number:
                start, end = source_number.span()
                changed = source[:start] + str(int(source_number.group()) + 1) + source[end:]
                cases.append(dict(base_case, key=f"{index}:source-number", category="source_changed",
                                  expect="off", source=changed))
        return cases

    def test_amb_tradeoff_source_bound_quantities(self):
        cases = self._amb_tradeoff_regression_cases()
        self.assertEqual(len(cases), 182)
        for case in cases:
            _, owner, pointer = case["id"].split(":")
            path = tuple(int(part) if part.isdigit() else part
                         for part in pointer[1:].split("/"))
            leaf = tool.Leaf("events", owner, "amb-own-controls", path,
                             case["source"], "event_standard")
            with self.subTest(identity=case["key"]):
                helper = tool._ja_amb_tradeoff_numbers(case["source"], case["target"])
                errors = tool.translation_errors(leaf, "ja", case["target"])
                if case["expect"] == "off":
                    # A changed source has no new licence. E2E results are
                    # observed separately, not declared a generic guarantee.
                    self.assertIsNone(helper)
                elif case["expect"] == "pass":
                    self.assertEqual(errors, [])
                    self.assertIsNotNone(helper)
                    self.assertEqual(helper[2], [])
                else:
                    self.assertTrue(errors)
                    self.assertIsNotNone(helper)
                    self.assertTrue(helper[2])

    @staticmethod
    def _amb_bare_double_regression_cases():
        original = next(case for case in ExchangeTests._amb_tradeoff_regression_cases()
                        if case["key"] == "14:actual")
        source = original["source"]
        normal = original["target"].replace("残業は2倍", "残業は倍")
        cases = []
        for index, expression in enumerate(("残業は倍", "残業が倍", "残業は2倍", "残業は二倍")):
            cases.append(dict(key=f"normal-{index}", expect="pass", source=source,
                              target=normal.replace("残業は倍", expression)))
        for index, expression in enumerate((
            "残業は1倍", "残業は3倍", "残業は-2倍", "残業は-倍", "残業は半倍",
            "残業は倍以上", "残業は倍以下", "残業は倍半", "残業は2倍以上", "残業は倍、さらに二倍",
        )):
            cases.append(dict(key=f"target-{index}", expect="reject", source=source,
                              target=normal.replace("残業は倍", expression)))
        cases.append(dict(key="target-sheet", expect="reject", source=source,
                          target=normal.replace("紙1枚", "紙2枚")))
        cases.append(dict(key="target-extra", expect="reject", source=source, target=normal + " 二時間。"))
        cases.append(dict(key="source-context", expect="off", source="별" + source, target=normal))
        cases.append(dict(key="source-number", expect="off", source=source.replace("두 배", "세 배"), target=normal))
        return cases

    def test_amb_bare_double_exposed_regression(self):
        cases = self._amb_bare_double_regression_cases()
        self.assertEqual(len(cases), 18)
        for case in cases:
            leaf = tool.Leaf("events", "amb_jobswitch_in", "amb-own-B2-controls", ("description",),
                             case["source"], "event_standard")
            with self.subTest(identity=case["key"]):
                helper = tool._ja_amb_tradeoff_numbers(case["source"], case["target"])
                errors = tool.translation_errors(leaf, "ja", case["target"])
                if case["expect"] == "off":
                    self.assertIsNone(helper)
                elif case["expect"] == "pass":
                    self.assertEqual(errors, [])
                    self.assertEqual(helper[2], [])
                else:
                    self.assertTrue(errors)
                    self.assertTrue(helper[2])

    @staticmethod
    def _callback_shadow_regression_cases():
        # Keep multilingual fixtures on short physical lines; validate via Python CLI.
        data = json.loads((
            "[{\"id\":\"events:callback_gambling_memory:/choices/1/result_text\",\"source\":\"토"
            "요일. 과천. 4호선.\\n\\n'딱 한 번'은 다섯 경주가 됐다. 15만원이 녹았다.\\n\\n90만원의 기억이 문제였다.\\n그 기억이 있는"
            " 한 '한 번만'은 거짓말이다.\\n자신에게 하는 거짓말. 제일 잘 속는 상대에게.\\n\\n돌아오는 지하철에서 {name}은 창에 비친 얼"
            "굴을 봤다.\\n낯익은 표정이었다. 어디서 봤더라.\\n\\n— 베팅창 앞 아저씨들 표정이었다.\",\"target\":\"土曜日。クァチョン。地下鉄"
            "4号線。\\n\\n「一度だけ」が5レースになった。15万ウォンが溶けた。\\n\\n90万ウォンの記憶が問題だった。\\nあの記憶がある限り、「一度だけ」は嘘"
            "だ。\\n自分につく嘘。いちばん簡単に騙せる相手に。\\n\\n帰りの地下鉄で、{name}は窓に映った顔を見た。\\n見覚えのある表情だった。どこで見たんだ"
            "っけ。\\n\\n――馬券売り場の前にいた、おじさんたちの顔だった。\",\"natural\":[[\"一度だけ\",\"1回だけ\"],[\"5レース\",\"五レース\""
            "],[\"15万ウォン\",\"十五万ウォン\"],[\"90万ウォン\",\"九十万ウォン\"]],\"mutations\":[[\"5レース\",\"六レース\"],[\"5"
            "レース\",\"5週間\"],[\"一度だけ\",\"二度だけ\"],[\"地下鉄4号線\",\"地下鉄3号線\"],[\"15万ウォン\",\"90万ウォン\"],[\"90万ウォ"
            "ン\",\"15万ウォン\"],[\"5レース\",\"-5レース\"],[\"5レース\",\"6レース、5レース\"]],\"sourceChange\":[\"다섯 경주\""
            ",\"여섯 경주\"]},{\"id\":\"events:callback_gambling_memory:/description\",\"source\":\"월"
            "급날. 통장에 숫자가 찍혔다.\\n\\n한 달을 갈아 넣은 돈.\\n\\n그런데 머릿속에 다른 숫자가 떠올랐다.\\n과천에서 쌍승이 터졌던 날."
            " 5만원이 90만원이 되는 데 걸린 시간 — 2분.\\n\\n한 달 vs 2분.\\n\\n이 비교가 시작되는 순간이 제일 위험하다는 걸, 어디"
            "선가 읽은 적이 있다.\",\"target\":\"給料日。口座に数字が刻まれた。\\n\\n1か月をすり減らして得た金。\\n\\nなのに、頭の中に別の数字が浮"
            "かんだ。\\nクァチョンで馬単が当たった日。5万ウォンが90万ウォンになるまで――2分。\\n\\n1か月と2分。\\n\\nこの比較を始める瞬間がいちばん危な"
            "いと、どこかで読んだことがある。\",\"natural\":[[\"1か月\",\"一ヶ月\"],[\"5万ウォン\",\"五万ウォン\"],[\"90万ウォン\",\"九十万"
            "ウォン\"],[\"2分\",\"二分\"]],\"mutations\":[[\"1か月\",\"2か月\"],[\"1か月\",\"1週間\"],[\"2分\",\"二時間\"],[\""
            "5万ウォン\",\"六万ウォン\"],[\"90万ウォン\",\"九万ウォン\"],[\"2分\",\"-2分\"],[\"1か月と2分\",\"2分と1か月\"]],\"sourc"
            "eChange\":[\"2분\",\"3분\"]},{\"id\":\"events:callback_jeonse_auction_insured:/choice"
            "s/0/result_text\",\"source\":\"서류 접수, 심사, 두 달.\\n\\n보증금 전액이 돌아왔다.\\n\\n같은 건물 다른 세입자"
            "들은 배당 순위에서 밀려 절반도 못 건졌다.\\n복도에서 마주친 옆집 사람의 얼굴을 잊을 수가 없다.\\n\\n30만원. 한 달 식비.\\n그"
            "게 수천만원을 지켰다.\\n\\n보험은 손해 보는 게임이라고들 한다.\\n맞다. 단 한 번만 빼고.\",\"target\":\"書類の受理、審査、2か"
            "月。\\n\\n保証金が全額戻ってきた。\\n\\n同じ建物のほかの入居者は、配当順位が後になり半分も取り戻せなかった。\\n廊下ですれ違った隣人の顔が忘れられ"
            "ない。\\n\\n30万ウォン。1か月分の食費。\\nそれが数千万ウォンを守った。\\n\\n保険は損をするゲームだと、人は言う。\\nそのとおりだ。たった一度を"
            "除いては。\",\"natural\":[[\"2か月\",\"二ヶ月\"],[\"30万ウォン\",\"三十万ウォン\"],[\"1か月\",\"一ヶ月\"],[\"数千万\",\"何"
            "千万\"],[\"一度\",\"1回\"]],\"mutations\":[[\"2か月\",\"三か月\"],[\"2か月\",\"二年\"],[\"30万ウォン\",\"三万ウォン\""
            "],[\"1か月\",\"二か月\"],[\"数千万\",\"数百万\"],[\"一度\",\"二度\"],[\"2か月\",\"-2か月\"],[\"2か月\",\"3か月、2か月\"]]"
            ",\"sourceChange\":[\"두 달\",\"세 달\"]},{\"id\":\"events:callback_jeonse_auction_uninsu"
            "red:/choices/0/result_text\",\"source\":\"법원, 등기소, 주민센터를 한 달 동안 돌았다.\\n\\n최우선변제금과"
            " 배당으로 보증금의 60%를 건졌다.\\n40%는 — 800만원은 사라졌다.\\n\\n그날 보험료 30만원이 아까웠다.\\n그 30만원이 80"
            "0만원이었다.\\n\\n수업료치고 너무 비쌌다. 근데 이런 수업은 한 번이면 평생 간다.\",\"target\":\"裁判所、登記所、住民センターを1"
            "か月かけて回った。\\n\\n最優先弁済と配当で、保証金の60％を取り戻した。\\n40％は――800万ウォンは消えた。\\n\\nあの日、30万ウォンの保険料"
            "が惜しかった。\\nその30万ウォンが、800万ウォンだった。\\n\\n授業料にしては高すぎた。けれど、こんな授業は一度で一生身に残る。\",\"natura"
            "l\":[[\"1か月\",\"一ヶ月\"],[\"60％\",\"六十％\"],[\"40％\",\"四十％\"],[\"800万ウォン\",\"八百万ウォン\"],[\"30万ウォン"
            "\",\"三十万ウォン\"],[\"一度\",\"1回\"]],\"mutations\":[[\"1か月\",\"二ヶ月\"],[\"60％\",\"六十一％\"],[\"40％\",\""
            "四十一％\"],[\"800万ウォン\",\"八十万ウォン\"],[\"30万ウォン\",\"三万ウォン\"],[\"一度\",\"二度\"],[\"1か月\",\"-1か月\"],["
            "\"1か月\",\"一日\"]],\"sourceChange\":[\"60%\",\"61%\"]},{\"id\":\"events:callback_jeonse_au"
            "ction_uninsured:/choices/1/result_text\",\"source\":\"임대인 주소지를 찾아갔다. 이미 비어 있었다."
            "\\n\\n같은 피해자가 열일곱 명이라는 걸 거기서 알았다.\\n집단 소송에 이름을 올렸지만 — 회수 가능성은 낮다고 했다.\\n\\n법적 절차"
            "를 놓친 사이 배당요구 기한이 지났다.\\n분노가 절차를 잡아먹었다.\\n\\n1,200만원. 서울이 가르치는 방식은 늘 이렇게 비싸다.\","
            "\"target\":\"大家の住所を訪ねた。すでに空き家だった。\\n\\n同じ被害に遭った人が17人いると、そこで知った。\\n集団訴訟に名を連ねたが――回収"
            "の見込みは低いと言われた。\\n\\n法的な手続きを逃すうちに、配当要求の期限が過ぎた。\\n怒りに、手続きが食われた。\\n\\n1,200万ウォン。ソウルが"
            "何かを教えるときは、いつもこんなに高くつく。\",\"natural\":[[\"17人\",\"十七人\"],[\"1,200万ウォン\",\"千二百万ウォン\"]],\""
            "mutations\":[[\"17人\",\"十八人\"],[\"17人\",\"17件\"],[\"1,200万ウォン\",\"百二十万ウォン\"],[\"1,200万ウォン"
            "\",\"1200ウォン\"],[\"17人\",\"-17人\"],[\"17人\",\"18人、17人\"],[\"17人\",\"17人以上\"]],\"sourceChang"
            "e\":[\"열일곱 명\",\"열여덟 명\"]},{\"id\":\"events:callback_lied_interview_surfaces:/choic"
            "es/0/result_text\",\"source\":\"2차 끝나고 팀장을 따로 잡았다.\\n\\n\\\"사실은 사업이 아니라 — 아버지 빚을 갚았"
            "습니다. 6년.\\\"\\n\\n팀장이 소주를 한 잔 따랐다. 한참 말이 없었다.\\n\\n\\\"발표는 내가 미룰게. 근데 — 빚 6년 갚은 놈이 "
            "사업 준비한 놈보다 나아.\\n끈기는 못 꾸며내거든.\\\"\\n\\n거짓말은 사라졌다. 이상하게, 더 단단해진 채로.\",\"target\":\"二次"
            "会が終わってから、チーム長を呼び止めて二人で話した。\\n\\n「本当は事業じゃなくて――父の借金を返していました。6年間」\\n\\nチーム長がソジュを一杯"
            "注いだ。しばらく何も言わなかった。\\n\\n「発表は俺が延期させる。ただな――借金を6年返した奴は、事業を準備していた奴より頼もしいぞ。\\n粘り強さは、"
            "嘘じゃ作れないからな」\\n\\n嘘は消えた。不思議と、自分は前より揺るがなくなっていた。\",\"natural\":[[\"二次会\",\"2次会\"],[\"二人で"
            "話した\",\"個別に話した\"],[\"6年間\",\"六年間\"],[\"一杯\",\"1杯\"],[\"6年返した\",\"六年返した\"]],\"mutations\":[[\""
            "二次会\",\"三次会\"],[\"二人で\",\"三人で\"],[\"6年間\",\"七年間\"],[\"一杯\",\"二杯\"],[\"6年返した\",\"六か月返した\"],[\"二次"
            "会\",\"-2次会\"],[\"二次会\",\"二次面接\"],[\"一杯\",\"二杯、一杯\"]],\"sourceChange\":[\"2차\",\"3차\"]},{\"id\""
            ":\"events:callback_lied_interview_surfaces:/choices/1/result_text\",\"source\":"
            "\"일주일 동안 새벽 3시까지 사업계획서 양식을 공부했다.\\n\\n발표는 — 통과됐다. 임원이 고개를 끄덕였다.\\n\\n돌아오는 길에 팀장이"
            " 어깨를 쳤다. \\\"역시 경험자네.\\\"\\n\\n그 말이 칭찬인데 체했다.\\n\\n거짓말은 이제 실력이 됐다. 근데 거짓말이 사라진 건 아니"
            "었다.\\n더 깊이 들어갔을 뿐.\",\"target\":\"1週間、明け方3時まで事業計画書の書き方を勉強した。\\n\\n発表は――通った。役員が頷いた。"
            "\\n\\n戻る途中、チーム長が肩を叩いた。「さすが経験者だな」\\n\\n褒め言葉なのに、胸につかえた。\\n\\n嘘は今や実力になった。けれど、嘘が消えたわけ"
            "ではなかった。\\nもっと深く潜っただけだ。\",\"natural\":[[\"1週間\",\"一週間\"],[\"明け方3時\",\"午前三時\"]],\"mutation"
            "s\":[[\"1週間\",\"二週間\"],[\"1週間\",\"一ヶ月\"],[\"明け方3時\",\"明け方四時\"],[\"明け方3時\",\"午後3時\"],[\"1週間\",\""
            "-1週間\"],[\"1週間\",\"2週間、1週間\"],[\"明け方3時まで\",\"明け方3時から\"]],\"sourceChange\":[\"3시\",\"4시\"]}"
            ",{\"id\":\"events:callback_mlm_friend_escaped:/description\",\"source\":\"카톡이 왔다. "
            "그 동창이었다.\\n\\n호텔 세미나실에서 어깨를 감싸던. 등록비 300만원을 말하던.\\n\\n'야. 나 그거 나왔다. 너 박차고 나간 날 "
            "— 사실 그날부터 흔들렸어.\\n빚 1,400 남았는데 그래도 나왔다.\\n물류 일 시작했어. 한 번 보자. 내가 국밥 산다.'\",\"tar"
            "get\":\"KakaoTalkにメッセージが来た。あの同級生だった。\\n\\nホテルのセミナールームで肩を抱いてきた。登録料300万ウォンを口にした。\\"
            "n\\n「なあ、俺、あれ抜けたよ。お前が席を蹴って出ていった日――実はあの日から迷ってた。\\n借金はまだ1,400万ウォンあるけど、それでも抜けた。\\n"
            "物流の仕事を始めたんだ。今度会おう。クッパおごるよ」\",\"natural\":[[\"300万ウォン\",\"三百万ウォン\"],[\"1,400万ウォン\",\"千"
            "四百万ウォン\"]],\"mutations\":[[\"1,400万ウォン\",\"1,400ウォン\"],[\"1,400万ウォン\",\"14,000ウォン\"],["
            "\"300万ウォン\",\"三十万ウォン\"],[\"1,400万ウォン\",\"1,400万円\"],[\"1,400万ウォン\",\"-1,400万ウォン\"],[\"1,"
            "400万ウォン\",\"1,500万ウォン、1,400万ウォン\"],[\"1,400万ウォン\",\"1,400万ウォン/月\"]],\"sourceChange\""
            ":[\"1,400\",\"1,500\"]},{\"id\":\"events:shadow_old_promise:/choices/1/result_text"
            "\",\"source\":\"{name}은 지금은 답을 확정할 수 없고 칠 주 안에 자기 쪽 결정을 다시 보내겠다고 적었다. 화면에는 발신 시"
            "각만 남았다. 상대가 기다리겠다는 답이나 약속은 생기지 않았다.\",\"target\":\"{name}は今は答えを確定できないので、7週間以内に自"
            "分の決断を改めて送ると書いた。画面には送信時刻だけが残った。相手から待つという返事も約束もなかった。\",\"natural\":[[\"7週間以内\",\"七週"
            "間のうち\"]],\"mutations\":[[\"7週間\",\"八週間\"],[\"7週間\",\"七ヶ月\"],[\"7週間以内\",\"7週間後\"],[\"7週間\",\"-"
            "7週間\"],[\"7週間\",\"8週間、7週間\"]],\"sourceChange\":[\"칠 주\",\"팔 주\"]},{\"id\":\"events:shadow"
            "_promise_again:/description\",\"source\":\"칠 주 전에 자기 손으로 넣어 둔 달력 알림이 떴다. 예전 DM에"
            "는 그날 보낸 말과 발신 시각만 남아 있었다. 읽음도 답장도 없었으므로 상대가 기다렸는지, 이미 떠났는지는 알 수 없었다.\\n\\n{na"
            "me}이 확인할 수 있는 것은 자기 쪽에서 약속한 날짜가 오늘이라는 사실뿐이었다.\",\"target\":\"7週間前、自分で設定したカレンダーの"
            "通知が出た。以前のDMには、あの日送った言葉と送信時刻だけが残っていた。既読も返事もなかったので、相手が待っていたのか、もう離れてしまったのかはわから"
            "なかった。\\n\\n{name}が確かめられるのは、自分から約束した日が今日だという事実だけだった。\",\"natural\":[[\"7週間前\",\"七週間前"
            "\"]],\"mutations\":[[\"7週間\",\"八週間\"],[\"7週間\",\"七ヶ月\"],[\"7週間前\",\"7週間後\"],[\"7週間\",\"-7週間\"]"
            ",[\"7週間\",\"8週間、7週間\"]],\"sourceChange\":[\"칠 주\",\"팔 주\"]}]"
        ))
        cases = []
        for index, row in enumerate(data):
            base = {key: row[key] for key in ("id", "source", "target")}
            cases.append(dict(base, key=f"{index}:actual", category="actual", expect="pass"))
            natural = row["target"]
            for old, new in row["natural"]:
                natural = natural.replace(old, new)
            cases.append(dict(base, key=f"{index}:natural", category="natural",
                              expect="pass", target=natural))
            for number, (old, new) in enumerate(row["mutations"]):
                cases.append(dict(base, key=f"{index}:target-{number}", category="target",
                                  expect="reject", target=row["target"].replace(old, new, 1)))
            cases.append(dict(base, key=f"{index}:source-context", category="source_context",
                              expect="off", source="별" + row["source"]))
            old, new = row["sourceChange"]
            cases.append(dict(base, key=f"{index}:source-number", category="source_quantity",
                              expect="off", source=row["source"].replace(old, new, 1)))
        return cases

    def test_callback_shadow_typed_numeric_slots(self):
        cases = self._callback_shadow_regression_cases()
        self.assertEqual(len(cases), 110)
        for case in cases:
            _, owner, pointer = case["id"].split(":")
            path = tuple(int(part) if part.isdigit() else part
                         for part in pointer[1:].split("/"))
            leaf = tool.Leaf("events", owner, "callback-own-controls", path,
                             case["source"], "event_standard")
            with self.subTest(identity=case["key"]):
                helper = tool._ja_callback_shadow_numbers(case["source"], case["target"])
                errors = tool.translation_errors(leaf, "ja", case["target"])
                if case["expect"] == "off":
                    # OFF is a licence boundary, not a universal semantic claim.
                    self.assertIsNone(helper)
                elif case["expect"] == "pass":
                    self.assertEqual(errors, [])
                    self.assertIsNotNone(helper)
                    self.assertEqual(helper[2], [])
                else:
                    self.assertTrue(errors)
                    self.assertIsNotNone(helper)
                    self.assertTrue(helper[2])

    def test_callback_shadow_colloquial_remaining_debt(self):
        base = next(row for row in self._callback_shadow_regression_cases()
                    if row["id"] == "events:callback_mlm_friend_escaped:/description"
                    and row["category"] == "actual")
        source = base["source"]
        target = base["target"].replace("万ウォンあるけど", "万ウォン残ってるけど")
        cases = [(source, target.replace("残ってる", form), "pass")
                 for form in ("残ってる", "残っている")]
        for old, new in (
                ("1,400万ウォン", "1,400ウォン"),
                ("1,400万ウォン", "14,000ウォン"),
                ("1,400万ウォン", "-1,400万ウォン"),
                ("1,400万ウォン", "1,400万ウォン/日"),
                ("登録料300万ウォン", "登録料3,000万ウォン"),
                ("1,400万ウォン", "1,400万ウォン、1,400万ウォン")):
            cases.append((source, target.replace(old, new, 1), "reject"))
        for old, new in (("카톡", "문자"), ("1,400", "1,500")):
            cases.append((source.replace(old, new, 1), target, "off"))
        self.assertEqual(len(cases), 10)
        for source_text, target_text, expected in cases:
            with self.subTest(target=target_text, expected=expected):
                helper = tool._ja_callback_shadow_numbers(source_text, target_text)
                leaf = tool.Leaf("events", "callback_mlm_friend_escaped",
                                 "callback-colloquial-controls", ("description",),
                                 source_text, "event_standard")
                errors = tool.translation_errors(leaf, "ja", target_text)
                if expected == "off":
                    self.assertIsNone(helper)
                elif expected == "pass":
                    self.assertEqual(errors, [])
                    self.assertIsNotNone(helper)
                    self.assertEqual(helper[2], [])
                else:
                    self.assertTrue(errors)
                    self.assertIsNotNone(helper)
                    self.assertTrue(helper[2])

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
