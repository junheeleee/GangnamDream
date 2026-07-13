#!/usr/bin/env python3
"""밸런스 회귀 검사 — audit.sh가 호출한다.

balance_sim의 핵심 정책 3개를 줄인 런 수로 돌리고, 결과가 허용 밴드를
벗어나면 exit 1. 시드 고정이라 결정적 — 밴드 이탈은 "코드의 경제 파라미터가
바뀌었다"는 뜻이다. 의도된 밸런스 변경이면 BALANCE.md에 기록하고
아래 밴드를 함께 갱신할 것.

밴드 근거 (BALANCE.md 2026-06-11 QA 감사, 현실 모드):
  ① 무직 방치   → 거의 전부 실패로 끝나야 한다 (방치가 생존 가능하면 압박 붕괴)
  ② 성실 직장   → 실패 없이 ~1억 (정석만으론 강남 불가 = 게임 테마)
  ③ 가끔 베팅   → 30억 도달 8~25% (이 밖이면 베팅 EV가 무너졌거나 지배 전략화)
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from balance_sim import run_policy, run_route_policy

RUNS = 1200
ROUTE_RUNS = 3000
failures = []


def band(name, value, lo, hi):
    ok = lo <= value <= hi
    mark = "✓" if ok else "✗"
    print("  %s %s = %.1f%%  (허용 %.0f~%.0f%%)" % (mark, name, value * 100, lo * 100, hi * 100))
    if not ok:
        failures.append("%s %.1f%% — 허용 밴드 %.0f~%.0f%% 이탈" % (name, value * 100, lo * 100, hi * 100))


print("● 밸런스 회귀 검사 (%d런/정책, 시드 고정)" % RUNS)
r0 = run_policy("①무직 방치", 0, runs=RUNS)
r1 = run_policy("②성실 직장(무베팅)", 1, runs=RUNS)
r2 = run_policy("③직장+가끔 베팅(25%)", 2, runs=RUNS)
startup = run_route_policy("④창업 공동창업→엑싯", "startup", runs=ROUTE_RUNS)
property_route = run_route_policy("⑤임상철 급매→재개발 사다리", "property", runs=ROUTE_RUNS)

print("\n● 밴드 판정")
band("① 무직 실패율", r0["fail_rate"], 0.95, 1.00)
band("② 직장 실패율", r1["fail_rate"], 0.00, 0.02)
band("③ 베팅 30억 도달률", r2["win_rate"], 0.08, 0.25)
band("③ 베팅 실패율", r2["fail_rate"], 0.00, 0.05)
band("④ 창업 30억 도달률", startup["win_rate"], 0.03, 0.25)
band("⑤ 부동산 30억 도달률", property_route["win_rate"], 0.03, 0.25)
med_ok = 50_000_000 <= r1["median"] <= 150_000_000
print("  %s ② 직장 최종자산 중앙값 = %s  (허용 5천만~1.5억)"
      % ("✓" if med_ok else "✗", f"{r1['median']/100_000_000:.2f}억"))
if not med_ok:
    failures.append("② 직장 중앙값 %.2f억 — 허용 0.5~1.5억 이탈" % (r1["median"] / 100_000_000))

if failures:
    print("\n✗ 밸런스 회귀 발견:")
    for f in failures:
        print("   - " + f)
    print("   의도된 변경이면 BALANCE.md 기록 후 tools/balance_check.py 밴드를 갱신하세요.")
    sys.exit(1)
print("\n✓ 밸런스 밴드 전부 통과")
