# ORDER-218 — 승인된 자각 알림과 역사 소스 지문 정합

> [~] 검증 중 — 제품 구현·자가 회귀 완료, 독립 검토·명시 차선 대기. 전체 HOLD.

## 원인과 수리

원격 a283a4e의 CI34328097684/job102389983534는 year5 지문6건과 causal
지문1건으로 실패했다. ROOT의 수리 전 직접 재현도6/1이다. 정적 job 성공을
전체 CI 성공으로 합산하지 않는다. 원래 실패는 private order218-ci-preflight.json에 남긴다.

ORDER215가 승인한 MainGame metadata5줄(4삽입/1삭제)의 고정183B 전이만 연결했다.
현재77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd에서
고정 두 구간을 역치환하면 predecessor
3e15f8e44839857a4ad04ee3b1727f9869f72ebbb7cfe9153dfcf9f1d756629d가 된다.
현재 전체 raw·정확한 경로·원 registry·고정 inverse를 함께 확인한 뒤에만 옛 감사에
옛 소스를 보여준다. 현재 파일로 expected를 재계산하거나 옛 pin을 덮지 않았다.
MainGame·제품 manifest·human 원장·기존 승인 근거는 수정0이다.

## 구현자 회귀

Poincare가 코드 전에 봉인한22개/guard, 총44개가 기대대로 통과했다.
정상 current만 허용하며 rollback·다른 경로·raw15변조·registry 덮기를 거부했다.
새 inline27개/guard는 이44개와 중복하며 독립 표본으로 합산하지 않는다.
registry 제거/확장·역치환 손상·역사 pin을 current로 덮는 경계도 직접 검사했다.
기존 전역244/277은 그대로다. 지정 관측 hook과 새 helper를 역제거하면
두 전체 AST가 baseline과 정확히 같다. 기존 assert를 없애지 않았다.

- year5 전체 self487 = 기존460 + 신규27, exit0.
- causal 전체 self564 = 기존537 + 신규27, exit0(첫 실행641.61초).
- 신규 첫 실패0. 이전 원격/로컬6+1 실패와 별도이며 덮어쓰지 않았다.

검토 제품 C1:27baec9718ca62d498df2c1bd8481f4ed1bbca71.
동결 guard 지문:

- year5:609238B/bc25d913c1e6e7d760f21363320334ee41a1b4f18e32e0ae1b4f2ad150b93c93
- causal:1447618B/1bb65227fbd4de11017afa624d9c13e1f5b33596725336189357e2a1bee55cc2

private order218-own-final.json:11778B/
bdb0a40c5c5e08dad4bcc12afac669ae347f5da1ad183295bb2b41a1bf5d67fe.
이는 작성자 회귀이고 독립 검사·새 원격 CI·실제 플레이 증거가 아니다.
입력 관찰은 변경하지 않은 [ORDER215](ORDER-215.md)의 controlled W17뿐이다.
원어민·인간 독해·물리 패드·새240주·전체 품질은 미판정이다.
