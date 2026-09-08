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
