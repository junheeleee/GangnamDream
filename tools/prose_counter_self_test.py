#!/usr/bin/env python3
"""Narrow source-bound472 counters; no legacy corpus or repository proof run."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from unittest import mock

import zh_translation_audit as audit

ROOT = Path(__file__).resolve().parents[1]


def run():
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    # Real source identity is asserted independently of the literal aliases.
    sources = {}
    for name in ("arc_hyunsu", "arc_year_close"):
        sources.update({row["id"]: row for row in json.loads((ROOT / "content/events" / (name + ".json")).read_text())})
    live = {"quiet_span": sources["hyunsu_year5_call"]["choices"][1]["result_text"],
            "map_pair": sources["hyunsu_year5_call"]["description"],
            "snowflakes": sources["arc_year2_close"]["description"],
            "pen_click": sources["arc_year2_close"]["description_if_known"]["year1_numb"],
            "list_three": sources["arc_year2_close"]["description_if_known"]["jaehyuk_stood_up"]}
    check(live == audit.SOURCE_PROSE_RECALL, "exact current five source identities")
    check({(kind, locale) for kind, locale, _target in FIXTURES}
          == {(kind, locale) for kind in live for locale in ("zh-CN", "zh-TW")}
          and len(FIXTURES) == 10, "complete five-kind two-locale fixture population")
    check(sources["hyunsu_year5_call_father_passed"]["choices"][1]["result_text"] == live["quiet_span"],
          "father-passed branch uses the same quiet source identity")
    for kind, locale, target in FIXTURES:
        source = live[kind]
        ss, ts, errors = audit._next_life_slots(source, target)
        label = kind + "/" + locale
        check(not errors and (len(ss), len(ts)) == ((3, 2) if kind == "snowflakes" else (1, 1)), label + "/typed")
        check(not audit._numeric_errors(source, target), label + "/numeric")
        for changed_source in (source + " ", source.replace("{name}", "{other}", 1)):
            check(audit._next_life_slots(changed_source, target) == ([], [], []), label + "/source-off")
        if not ts:
            continue
        slot = ts[-1]
        phrase = target[slot.start:slot.end]
        if kind == "quiet_span":
            wrong_value = phrase.replace("几分", "两分").replace("一分", "二分")
            wrong_unit = phrase.replace("几分", "几米").replace("一分", "一米")
        elif kind == "map_pair":
            wrong_value = phrase.replace("兩人", "三人").replace("本来就", "三个人本来就")
            wrong_unit = phrase.replace("地图", "公里").replace("地圖", "公里")
        elif kind == "snowflakes":
            wrong_value = phrase.replace("两", "三").replace("兩", "三")
            wrong_unit = phrase.replace("片", "米")
        elif kind == "pen_click":
            wrong_value = phrase.replace("两", "三").replace("兩", "三")
            wrong_unit = phrase.replace("声", "年").replace("聲", "年")
        else:
            wrong_value = phrase.replace("三", "二")
            wrong_unit = phrase.replace("项", "年").replace("者", "年")
        for name, replacement in (("value", wrong_value), ("unit", wrong_unit),
                                  ("sign", "+" + phrase), ("rate", phrase + "/年"),
                                  ("duplicate", phrase + "，" + phrase), ("line", "\n" + phrase)):
            check(replacement != phrase, label + "/fixture-" + name)
            mutant = target[:slot.start] + replacement + target[slot.end:]
            check(bool(audit._numeric_errors(source, mutant)), label + "/reject-" + name)
        check(bool(audit._numeric_errors(source, target + "\n另外有3人。")), label + "/extra-entity")
        check(bool(audit._numeric_errors(source, target + "\n另外花了100韩元。")), label + "/extra-money")
        if kind == "snowflakes":
            first = ts[0]
            first_phrase = target[first.start:first.end]
            for name, mutant in (
                ("first-value", target[:first.start] + first_phrase.replace("一", "二") + target[first.end:]),
                ("first-missing", target[:first.start] + target[first.end:]),
                ("first-unit", target[:first.start] + first_phrase.replace("片", "米") + target[first.end:]),
            ):
                check(bool(audit._numeric_errors(source, mutant)), label + "/reject-" + name)
            for replacement in ("두 이름", "세 이름"):
                variant = source.replace("둘 이름들", replacement)
                check(audit._next_life_slots(variant, target) == ([], [], []),
                      label + "/source-variant-grants-no-slot-" + replacement)
                # The legacy generic parser does not type the noun 이름.
                # Record that unchanged coverage, rather than claiming this
                # exact-source repair rejects every unowned Korean sentence.
                actual_errors = audit._numeric_errors(variant, target)
                with mock.patch.dict(audit.SOURCE_PROSE_RECALL, {}, clear=True):
                    baseline_errors = audit._numeric_errors(variant, target)
                check(actual_errors == baseline_errors,
                      label + "/source-variant-preserves-generic-parser-" + replacement)
        if kind in {"snowflakes", "pen_click", "list_three"}:
            changed_source = source.replace({"snowflakes": "두 송이", "pen_click": "두 번", "list_three": "셋은"}[kind],
                                            {"snowflakes": "세 송이", "pen_click": "세 번", "list_three": "넷은"}[kind])
            check(audit._next_life_slots(changed_source, target) == ([], [], [])
                  and bool(audit._numeric_errors(changed_source, target)), label + "/changed-source-value")
    for locale, targets in LEGACY_TARGETS.items():
        for kind, target in targets.items():
            source = audit.SOURCE_NEXT_LIFE[kind]
            check(not audit._numeric_errors(source, target), kind + "/" + locale + "/legacy-preserved")
    for source, target in (("종이가 두 개 있었다.", "有两片纸。"),
                           ("두 번 울렸다.", "响了两声咔哒。"), ("셋은 남았다.", "三者留下了。")):
        check(audit._next_life_slots(source, target) == ([], [], [])
              and bool(audit._numeric_errors(source, target)), "no generic classifier expansion: " + source)
    return failures, cases


def main():
    failures, cases = run()
    for failure in failures:
        print(failure, file=sys.stderr)
    print(f"PROSE_COUNTER_SELF_TEST_{'FAIL' if failures else 'OK'} cases={cases} failures={len(failures)}")
    return int(bool(failures))


FIXTURES = (('quiet_span',
  'zh-CN',
  '“那我等着，哥！”\n\n挂掉了电话。屏幕暗下去，房间仿佛又静了几分。\n\n说了“很快”的是自己。{name}又坐回书桌前。映在暗下的屏幕里的那张脸，有一瞬，像极了考试院厨房里的那张脸。'),
 ('map_pair',
  'zh-CN',
  '已经是最后一年了。手机目标页面上，剩余的周数明显变少了。\n'
  '\n'
  'Hyunsu打来了电话。视频通话。\n'
  '\n'
  '“哥！真的好久不见了。最近过得怎么样？”\n'
  '\n'
  '屏幕里，Hyunsu身后是办公室的荧光灯和一叠叠文件。似乎在加班，神情却很安稳。那是已经在自己的生活里落了脚的人的脸。通话中有人叫他，他回答“好，马上来”的声音也干净利落。\n'
  '\n'
  '{name}看着屏幕角落里自己的脸。从考试院那时起走过的岁月，都在那里。\n'
  '\n'
  '决定不去衡量谁走得更远。本来就没有走在同一张地图上。'),
 ('snowflakes',
  'zh-CN',
  '第二个十二月的最后一夜，{name}在回家路上，走到巷子的路灯下停住了。大路边银行里打出的明细单，在外套口袋里已经揉皱。巴掌大的纸上，只印着一行银行账户余额，还有日期和时间。手机上显示着今年的总资产{assets}；日历和聊天窗口里，十二个月中真正发出的回复、定下又删掉的安排，按日期留在那里。\n'
  '\n'
  '明细单上只印着金额。回复过谁，又让谁等着，纸上哪里都没有。背面是空白的。{name}从内侧口袋拿出圆珠笔，把纸抵在电线杆上按住。一片雪花落在背面，很快洇成一个小点。\n'
  '\n'
  '一张纸，写不下所有事。要移到新年第一周日历上的一个安排，要与金额并排写下的名字，离目标还差的数字。笔尖停在明细单背面上方时，又有两片雪花落在纸角。'),
 ('pen_click',
  'zh-CN',
  '第二个十二月的最后一夜，{name}在回家路上的巷子路灯下，拿着明细单站了很久。去年记事本的最后一页，还是空白的。余额、手机上的总资产{assets}、发出回复的时间、最终删掉的日程。有记录，却找不到一句能把它们叫到一起的话。\n'
  '\n'
  '删掉所有手机通知，屏幕就可以干净。揉掉明细单，空格也就看不见了。可手还是没有揉皱那张纸。{name}拔下笔帽，又盖了回去。空荡的巷子里响了两声咔哒。'),
 ('list_three',
  'zh-CN',
  '第二个十二月的最后一夜，{name}在回家路上的巷子路灯下，在手机上划过 Jaehyuk '
  '的名字，打开今年的总资产{assets}。重新站起来以后，数字还在继续，却没能回到相信别人之前的自己。这个事实，没有印在口袋里明细单的任何一行上。\n'
  '\n'
  '重新去相信的事、先偿还的事、明年也要守住的人。这三项，没法在一张明细单背面并排放下。{name}握着明细单，望着落入路灯光里的雪，看了很久。'),
 ('quiet_span',
  'zh-TW',
  '「我等著喔，哥！」\n\n掛了電話。螢幕暗下來，房間又多了一分寂靜。\n\n說了「快了」的是自己。{name}再次坐回書桌前。映在暗下來的螢幕上的臉，有一瞬間，像極了考試院廚房裡的那張臉。'),
 ('map_pair',
  'zh-TW',
  '已經是最後一年了。手機目標畫面上的剩餘週數，明顯少了許多。\n'
  '\n'
  'Hyunsu 打來電話。視訊通話。\n'
  '\n'
  '「哥！真的好久不見。最近過得怎麼樣？」\n'
  '\n'
  '螢幕裡，Hyunsu 身後是辦公室的日光燈和堆疊的文件。看來是在加班，神情卻很放鬆。那是一張已經在自己的生活裡安頓下來的臉。通話中有人叫他，他回答「好，我馬上過去」，語氣也俐落乾脆。\n'
  '\n'
  '{name}看著螢幕角落裡自己的臉。從住考試院起走過的日子，全在那裡。\n'
  '\n'
  '不打算比較誰走得更遠。從一開始，兩人走的就不是同一張地圖。'),
 ('snowflakes',
  'zh-TW',
  '第二個十二月的最後一晚，{name}走在回家的巷子裡，在路燈下停住腳步。從大路旁銀行印出的明細單，已在外套口袋裡壓皺。巴掌大的紙上，只印著一行銀行帳戶餘額，以及日期、時間。手機上顯示今年總資產{assets}；月曆與對話框裡，十二個月間真正傳出的回覆、排好又刪去的行程，都依日期留著。\n'
  '\n'
  '明細單只印了金額。回覆過誰、讓誰等了，紙上哪裡都沒有。背面還空著。{name}從內袋拿出原子筆，把紙抵著電線桿壓住。一片雪花落在背面，很快化成一小點水漬。\n'
  '\n'
  '一張紙寫不下全部。要移到新年第一週月曆的一個行程、要和金額並排寫下的名字、離目標還差的數字。筆尖停在明細單背面上方時，又有兩片雪花落在紙角。'),
 ('pen_click',
  'zh-TW',
  '第二個十二月的最後一晚，{name}在回家巷子裡的路燈下，拿著明細單站了很久。去年隨身筆記本的最後一頁，依舊留白。餘額、手機上的總資產{assets}、傳出回覆的時間、終究刪掉的行程。有紀錄，卻沒有能用一句話稱呼它們的詞。\n'
  '\n'
  '刪掉所有手機通知，畫面就能乾淨。揉掉明細單，也就看不見空格。手卻仍沒有把紙揉皺。{name}拔下筆蓋，又蓋了回去。空巷子裡響了兩聲喀噠。'),
 ('list_three',
  'zh-TW',
  '第二個十二月的最後一晚，{name}在回家巷子裡的路燈下，從手機裡滑過 Jaehyuk '
  '的名字，打開今年總資產{assets}。重新站起來之後，數字仍在延續，卻回不到相信人之前的自己。這件事，沒有印在口袋裡明細單的任何一行。\n'
  '\n'
  '要重新相信的事、要先還的事、明年也要守住的人。三者無法並排擠進一張明細單的背面。{name}握著明細單，久久看著落入路燈光裡的雪。'))
LEGACY_TARGETS = {'zh-CN': {'quiet_span': '“那我等着，哥！”\n'
                         '\n'
                         '挂掉了电话。屏幕暗下去，房间仿佛又静了几分。\n'
                         '\n'
                         '很快，真的很快了。{name}又坐回书桌前。映在暗下的屏幕里的那张脸，有一瞬，像极了五年前厨房里的那张脸。',
           'map_pair': '已是最后关头。离江南真的没剩多远了。\n'
                       '\n'
                       'Hyunsu打来了电话。视频通话。\n'
                       '\n'
                       '“哥！真的好久不见了。最近过得怎么样？”\n'
                       '\n'
                       '屏幕里，Hyunsu身后是办公室的荧光灯和一叠叠文件。似乎在加班，神情却很安稳。那是已经在自己的生活里落了脚的人的脸。通话中有人叫他，他回答“好，马上来”的声音也干净利落。\n'
                       '\n'
                       '{name}看着屏幕角落里自己的脸。五年都在那里。\n'
                       '\n'
                       '决定不去衡量谁走得更远。本来就没有走在同一张地图上。'},
 'zh-TW': {'quiet_span': '「我等著喔，哥！」\n'
                         '\n'
                         '掛了電話。螢幕暗下來，房間又多了一分寂靜。\n'
                         '\n'
                         '快了，真的快了。{name}再次坐回書桌前。映在暗下來的螢幕上的臉，有一瞬間，像極了五年前廚房裡的那張臉。',
           'map_pair': '已經到了最後關頭。離江南，真的只差一點了。\n'
                       '\n'
                       'Hyunsu 打來電話。視訊通話。\n'
                       '\n'
                       '「哥！真的好久不見。最近過得怎麼樣？」\n'
                       '\n'
                       '螢幕裡，Hyunsu '
                       '身後是辦公室的日光燈和堆疊的文件。看來是在加班，神情卻很放鬆。那是一張已經在自己的生活裡安頓下來的臉。通話中有人叫他，他回答「好，我馬上過去」，語氣也俐落乾脆。\n'
                       '\n'
                       '{name}看著螢幕角落裡自己的臉。五年，全在那裡。\n'
                       '\n'
                       '不打算比較誰走得更遠。從一開始，兩人走的就不是同一張地圖。'}}


if __name__ == "__main__":
    raise SystemExit(main())
