extends Control
## ArubaGame v3 — 직종별 전용 알바 미니게임
## job_01 편의점 야간: 손님 응대 게임 (3-슬롯 멀티태스킹, 오버쿡 스타일)
## job_02 배달 라이더: 루트 최적화 퍼즐
## 그 외: 상황 카드 선택
## MainGame이 overlay로 붙이고 open()으로 표시. AP는 호출 전에 소비.

signal closed(earned: int, stress_delta: int, health_delta: int)

enum Mode { CARDS, CONVENIENCE, DELIVERY }

# 2026 최저임금 10,320원 × 8시간 = 82,560원. 게임에서는 야간/단기 가산을 둥글게 반영한다.
const BASE_PAY := 90_000
const BASE_SHIFT_HEALTH_DELTA := -3

# ── 상황 카드 데이터 ──────────────────────────────────────────────
const SCENARIOS_CONVENIENCE = [
	{
		"scene": "밤 11시. 술 취한 손님이 계산대에 기대며 시비를 건다.",
		"scene_en": "11 PM. A drunk customer leans on the counter and starts picking a fight.",
		"choices": [
			{"text": "조용히 계산만 빠르게 끝낸다", "text_en": "Stay quiet and finish the checkout quickly.", "money": 0, "stress": 3, "health": 0, "tip": "별 탈 없이 넘어갔다.", "tip_en": "You got through it without trouble."},
			{"text": "\"금방 계산해드릴게요\" 차분하게 대응한다", "text_en": "\"I'll ring that up right away.\" Respond calmly.", "money": 3000, "stress": 0, "health": 0, "tip": "손님이 고맙다며 팁을 남겼다.", "tip_en": "The customer thanked you and left a tip."},
			{"text": "점장에게 메시지를 보낸다", "text_en": "Text the store manager.", "money": 0, "stress": -2, "health": 0, "tip": "점장이 나와줬다. 짧게 훈수만 들었다.", "tip_en": "The manager came out and gave you a short lecture."},
		]
	},
	{
		"scene": "새벽 2시. 재고 정리 도중 냉동고 문이 고장났다. 혼자다.",
		"scene_en": "2 AM. While organizing stock, the freezer door breaks. You are alone.",
		"choices": [
			{"text": "응급처치 테이프로 임시 고정한다", "text_en": "Patch it temporarily with emergency tape.", "money": 0, "stress": 2, "health": -1, "tip": "아침에 점장이 솜씨를 칭찬했다.", "tip_en": "In the morning, the manager praised your handiwork."},
			{"text": "점장에게 즉시 전화한다", "text_en": "Call the manager immediately.", "money": 0, "stress": 5, "health": 0, "tip": "심야에 불러냈다. 눈치가 보인다.", "tip_en": "You dragged them out at night. It feels awkward."},
			{"text": "보고서를 꼼꼼하게 남겨두고 계속 일한다", "text_en": "Leave a detailed report and keep working.", "money": 5000, "stress": -1, "health": 0, "tip": "다음날 점장이 보너스를 줬다.", "tip_en": "The manager gave you a bonus the next day."},
		]
	},
	{
		"scene": "손님이 유통기한 지난 샌드위치를 들고 왔다.",
		"scene_en": "A customer brings back an expired sandwich.",
		"choices": [
			{"text": "죄송하다며 즉시 교환해준다", "text_en": "Apologize and exchange it immediately.", "money": 0, "stress": 2, "health": 0, "tip": "손님은 만족했다.", "tip_en": "The customer was satisfied."},
			{"text": "점장 오기 전에 조용히 처리한다", "text_en": "Handle it quietly before the manager arrives.", "money": 0, "stress": -2, "health": 0, "tip": "아무도 모르게 넘어갔다.", "tip_en": "No one ever found out."},
			{"text": "솔직하게 내 실수였다고 인정한다", "text_en": "Admit honestly that it was your mistake.", "money": -5000, "stress": 4, "health": 0, "tip": "점장은 정직함을 높이 샀다.", "tip_en": "The manager valued your honesty."},
		]
	},
	{
		"scene": "단골 할머니가 계산이 틀렸다며 화를 낸다. 실제로 계산은 맞다.",
		"scene_en": "A regular elderly customer says the checkout was wrong. The total is actually correct.",
		"choices": [
			{"text": "영수증을 보여드리며 차분히 설명한다", "text_en": "Show the receipt and explain calmly.", "money": 2000, "stress": 2, "health": 0, "tip": "오해가 풀렸다.", "tip_en": "The misunderstanding cleared up."},
			{"text": "그냥 200원을 돌려드린다", "text_en": "Just give back 200 won.", "money": -200, "stress": -3, "health": 0, "tip": "갈등은 사라졌다.", "tip_en": "The conflict disappeared."},
			{"text": "모른 척 묻어간다", "text_en": "Pretend not to know and let it slide.", "money": 0, "stress": 1, "health": -1, "tip": "기분이 영 안 좋다.", "tip_en": "It leaves a bad taste."},
		]
	},
	{
		"scene": "복권 당첨자가 나왔다! 5만원 당첨. 손님이 현금으로 즉시 달라고 한다.",
		"scene_en": "A lottery ticket wins 50,000 won. The customer wants cash immediately.",
		"choices": [
			{"text": "절차대로 본사 처리를 안내한다", "text_en": "Follow procedure and direct them to headquarters processing.", "money": 0, "stress": 2, "health": 0, "tip": "규정대로 처리됐다.", "tip_en": "It was handled by the book."},
			{"text": "점장에게 먼저 확인한다", "text_en": "Check with the manager first.", "money": 0, "stress": -1, "health": 0, "tip": "문제없이 마무리됐다.", "tip_en": "It ended without any problem."},
			{"text": "내 돈으로 먼저 주고 정산한다", "text_en": "Pay with your own money first and settle it later.", "money": -50000, "stress": -2, "health": 0, "tip": "나중에 돌려받았다.", "tip_en": "You got reimbursed later."},
		]
	},
]

const SCENARIOS_DELIVERY = [
	{
		"scene": "비가 쏟아진다. 포장이 젖을 것 같다.",
		"scene_en": "Rain is pouring down. The packaging may get soaked.",
		"choices": [
			{"text": "속도를 올려 빠르게 배달한다", "text_en": "Speed up and deliver it quickly.", "money": 3000, "stress": 3, "health": -2, "tip": "음식은 겨우 살았다.", "tip_en": "The food barely survived."},
			{"text": "편의점에서 봉지를 사서 싼다", "text_en": "Buy a plastic bag at a convenience store and wrap it.", "money": -1000, "stress": -1, "health": 0, "tip": "손님이 별 5개를 줬다.", "tip_en": "The customer gave you five stars."},
			{"text": "배달 앱에 상황을 알린다", "text_en": "Report the situation through the delivery app.", "money": 0, "stress": 1, "health": 0, "tip": "아무 일 없이 넘어갔다.", "tip_en": "It passed without incident."},
		]
	},
	{
		"scene": "손님이 주소를 틀리게 써놨다. 전화가 안 된다.",
		"scene_en": "The customer entered the wrong address and will not answer the phone.",
		"choices": [
			{"text": "인근을 돌며 찾아본다", "text_en": "Circle the area and search nearby.", "money": 0, "stress": 4, "health": -1, "tip": "10분 뒤 손님이 다시 전화했다.", "tip_en": "Ten minutes later, the customer called back."},
			{"text": "배달 앱 고객센터에 연락한다", "text_en": "Contact customer support through the delivery app.", "money": 5000, "stress": -1, "health": 0, "tip": "고객센터가 처리비를 줬다.", "tip_en": "Customer support paid a handling fee."},
			{"text": "입구에 두고 사진 찍어 알린다", "text_en": "Leave it at the entrance, take a photo, and notify them.", "money": 0, "stress": 0, "health": 0, "tip": "별점 3개.", "tip_en": "Three stars."},
		]
	},
	{
		"scene": "오토바이 접촉사고가 났다. 작은 긁힘이고 상대방이 그냥 가자고 한다.",
		"scene_en": "A minor scooter accident leaves a small scratch. The other driver says to forget it.",
		"choices": [
			{"text": "번호판 찍어두고 보험 처리한다", "text_en": "Photograph the plate and file an insurance report.", "money": -10000, "stress": 3, "health": 0, "tip": "정식 처리. 시간이 걸렸다.", "tip_en": "Officially handled. It took time."},
			{"text": "상대방 말대로 그냥 넘어간다", "text_en": "Do as they say and let it go.", "money": 0, "stress": -2, "health": -2, "tip": "나중에 찜찜했다.", "tip_en": "It bothers you later."},
			{"text": "현장에서 합의금을 받는다", "text_en": "Take a cash settlement on the spot.", "money": 30000, "stress": 1, "health": 0, "tip": "빠르게 해결됐다.", "tip_en": "It was resolved quickly."},
		]
	},
	{
		"scene": "같은 구역 배달 기사가 콜을 가로채는 것 같다.",
		"scene_en": "Another rider in the same area seems to be snatching orders.",
		"choices": [
			{"text": "증거를 모아 신고한다", "text_en": "Gather evidence and report them.", "money": 0, "stress": 3, "health": 0, "tip": "플랫폼에서 패널티가 부과됐다.", "tip_en": "The platform issued a penalty."},
			{"text": "직접 말을 건다", "text_en": "Confront them directly.", "money": 10000, "stress": 1, "health": 0, "tip": "이후로 달라졌다.", "tip_en": "Things changed after that."},
			{"text": "무시하고 더 빠르게 치고 나간다", "text_en": "Ignore it and beat them with speed.", "money": 5000, "stress": 2, "health": -1, "tip": "속도로 따돌렸다.", "tip_en": "You outran the competition."},
		]
	},
]

const SCENARIOS_GENERAL = [
	{
		"scene": "내일 마감인 보고서가 있는데 부장이 야근을 부탁했다.",
		"scene_en": "A report is due tomorrow, but your manager asks you to work overtime.",
		"choices": [
			{"text": "자정까지 남아서 끝낸다", "text_en": "Stay until midnight and finish it.", "money": 20000, "stress": 6, "health": -2, "tip": "초과 수당이 붙었다.", "tip_en": "You earned overtime pay."},
			{"text": "내 업무만 끝내고 퇴근한다", "text_en": "Finish only your work and leave.", "money": 0, "stress": 0, "health": 0, "tip": "원칙적이다.", "tip_en": "Strictly by the book."},
			{"text": "다음날 일찍 나와서 마무리하겠다 제안한다", "text_en": "Offer to come in early tomorrow and finish it.", "money": 5000, "stress": -2, "health": 0, "tip": "상사가 만족했다.", "tip_en": "Your manager was satisfied."},
		]
	},
	{
		"scene": "카페 마감 청소 중. 손님이 15분 전에 들어와 자리를 잡았다.",
		"scene_en": "During cafe closing cleanup, a customer comes in 15 minutes before closing and sits down.",
		"choices": [
			{"text": "영업시간 종료를 정중히 알린다", "text_en": "Politely explain that the shop is closing.", "money": 0, "stress": -1, "health": 0, "tip": "손님이 이해하고 나갔다.", "tip_en": "The customer understood and left."},
			{"text": "그냥 청소하면서 눈치를 준다", "text_en": "Keep cleaning and silently pressure them.", "money": 0, "stress": 2, "health": 0, "tip": "분위기가 어색해졌다.", "tip_en": "The mood turned awkward."},
			{"text": "청소를 미루고 손님이 갈 때까지 기다린다", "text_en": "Delay cleanup and wait until they leave.", "money": 3000, "stress": -3, "health": 0, "tip": "손님이 팁을 남기고 갔다.", "tip_en": "The customer left a tip."},
		]
	},
	{
		"scene": "오전 오픈 담당인데 키를 잃어버렸다. 30분 뒤 오픈이다.",
		"scene_en": "You are opening the shop this morning, but you lost the key. Opening is in 30 minutes.",
		"choices": [
			{"text": "사장에게 즉시 연락한다", "text_en": "Contact the owner immediately.", "money": -10000, "stress": 5, "health": 0, "tip": "잔소리를 들었다.", "tip_en": "You got scolded."},
			{"text": "가방을 샅샅이 다시 뒤진다", "text_en": "Search your bag again from top to bottom.", "money": 0, "stress": 2, "health": 0, "tip": "사물함 안에 있었다.", "tip_en": "It was inside the locker."},
			{"text": "인근 직원에게 부탁한다", "text_en": "Ask a nearby coworker for help.", "money": -5000, "stress": -1, "health": 0, "tip": "저녁에 커피 한 잔 샀다.", "tip_en": "You bought them coffee that evening."},
		]
	},
	{
		"scene": "월급날인데 사장이 이번 달 하루 늦는다고 한다. 두 번째다.",
		"scene_en": "It is payday, but the owner says payment will be one day late. This is the second time.",
		"choices": [
			{"text": "그러시겠냐고 넘어간다", "text_en": "Say you understand and let it pass.", "money": 0, "stress": 3, "health": 0, "tip": "속이 쓰리다.", "tip_en": "It eats at you."},
			{"text": "근로계약서 조항을 언급하며 부탁한다", "text_en": "Mention the employment contract and ask firmly.", "money": 0, "stress": 1, "health": 0, "tip": "다음날 입금됐다.", "tip_en": "The money arrived the next day."},
			{"text": "노동부 신고를 검토한다", "text_en": "Consider filing a labor complaint.", "money": 0, "stress": -2, "health": 0, "tip": "결국 제때 입금됐다.", "tip_en": "In the end, the payment arrived on time."},
		]
	},
]

# ── 편의점 손님 유형 (10명 풀, 매 시프트 랜덤) ───────────────────
const CUSTOMER_TYPES = [
	{
		"id": "checkout", "name": "계산 손님", "name_en": "Customer at Checkout",
		"text": "저기요, 계산이요.",
		"text_en": "Excuse me, could you ring me up?",
		"patience": 12.0, "urgency": 1,
		"actions": [
			{"text": "빠르게 스캔한다", "text_en": "Scan quickly.", "bonus": 2_000, "stress": 0, "tip": "점장이 빠른 응대 기록을 보고 성과수당 2천 원을 붙였다.", "tip_en": "The manager added a 2,000 won performance bonus for the quick checkout."},
			{"text": "\"잠깐만요\" 다른 손님 먼저", "text_en": "\"One moment, please.\" Help another customer first.", "bonus": 0, "stress": 1, "tip": "손님은 한숨을 쉬며 기다렸다.", "tip_en": "The customer waited with a sigh."},
		]
	},
	{
		"id": "angry", "name": "화를 내는 손님", "name_en": "Angry Customer",
		"text": "야! 왜 이렇게 느려!",
		"text_en": "Hey! Why are you so slow?",
		"patience": 6.0, "urgency": 3,
		"actions": [
			{"text": "\"죄송합니다\" 차분히 대응", "text_en": "\"I'm sorry.\" Respond calmly.", "bonus": 0, "stress": 2, "tip": "간신히 진정됐다.", "tip_en": "The customer calmed down, but only just."},
			{"text": "\"많이 기다리셨죠. 바로 계산해 드릴게요\"", "text_en": "\"You've been waiting a while. I'll ring you up right away.\"", "bonus": 1_000, "stress": 1, "tip": "손님은 미안했다며 팁 천 원을 계산대에 두고 갔다.", "tip_en": "The customer apologized and left a 1,000 won tip on the counter."},
			{"text": "무시하고 다른 손님 먼저", "text_en": "Ignore them and help another customer first.", "bonus": 0, "stress": 5, "tip": "손님은 점장에게 항의하겠다고 했다.", "tip_en": "They threatened to complain to the manager."},
		]
	},
	{
		"id": "regular_elder", "name": "단골 할머니", "name_en": "Elderly Regular",
		"text": "총각, 오늘 대타예요? 나는 매일 이 시간에 오는데.",
		"text_en": "Young man, are you filling in today? I'm here at this time every day.",
		"patience": 16.0, "urgency": 0,
		"actions": [
			{"text": "반갑게 인사하며 응대한다", "text_en": "Greet her warmly and help her.", "bonus": 5_000, "stress": -1, "tip": "세뱃돈 같은 거라며 주셨다.", "tip_en": "She told you to think of it as a little New Year's gift."},
			{"text": "바쁜 척 빠르게 처리한다", "text_en": "Pretend to be busy and rush through the transaction.", "bonus": 0, "stress": 1, "tip": "섭섭해하셨다.", "tip_en": "She looked disappointed."},
		]
	},
	{
		"id": "drunk", "name": "취한 손님", "name_en": "Drunk Customer",
		"text": "야... 소주 어디 있어요?",
		"text_en": "Hey... where's the soju?",
		"patience": 9.0, "urgency": 2,
		"actions": [
			{"text": "친절하게 안내한다", "text_en": "Politely show them where it is.", "bonus": 0, "stress": 1, "tip": "고맙다며 갔다.", "tip_en": "They thanked you and left."},
			{"text": "\"많이 드신 것 같은데, 물도 같이 찾으세요?\"", "text_en": "\"Looks like you've had quite a bit. Would you like some water too?\"", "bonus": 2_000, "stress": 0, "tip": "손님은 고맙다며 2천 원을 계산대에 두고 갔다.", "tip_en": "The customer thanked you and left 2,000 won on the counter."},
			{"text": "못 본 척한다", "text_en": "Pretend not to see them.", "bonus": 0, "stress": 2, "tip": "손님은 혼자 한참 매장을 헤맸다.", "tip_en": "The customer wandered around the store alone for a while."},
		]
	},
	{
		"id": "return", "name": "교환 손님", "name_en": "Customer Requesting an Exchange",
		"text": "이거 어제 샀는데 불량이에요.",
		"text_en": "I bought this yesterday, and it's defective.",
		"patience": 10.0, "urgency": 1,
		"actions": [
			{"text": "영수증 확인 후 즉시 교환", "text_en": "Check the receipt and exchange it immediately.", "bonus": 2_000, "stress": 1, "tip": "점장이 교환 기록을 확인하고 성과수당 2천 원을 붙였다.", "tip_en": "The manager reviewed the exchange and added a 2,000 won performance bonus."},
			{"text": "점장에게 물어봐야 한다고 설명", "text_en": "Explain that you need to ask the manager.", "bonus": 0, "stress": 2, "tip": "손님은 기다려야 한다며 불만을 보였다.", "tip_en": "The customer was unhappy about having to wait."},
		]
	},
	{
		"id": "parcel", "name": "택배 손님", "name_en": "Parcel Pickup Customer",
		"text": "택배 여기 맡겼는데요.",
		"text_en": "I'm here to pick up a parcel.",
		"patience": 11.0, "urgency": 1,
		"actions": [
			{"text": "등록번호 확인 후 찾아준다", "text_en": "Check the pickup number and retrieve the parcel.", "bonus": 1_000, "stress": 0, "tip": "손님은 고맙다며 팁 천 원을 두고 갔다.", "tip_en": "The customer thanked you and left a 1,000 won tip."},
			{"text": "뒤에 있을 거라고 알아서 찾으라 한다", "text_en": "Tell them it should be in the back and to find it themselves.", "bonus": 0, "stress": 1, "tip": "손님은 불만스러운 표정으로 택배를 찾았다.", "tip_en": "The customer searched for the parcel with an unhappy look."},
		]
	},
	{
		"id": "points", "name": "포인트 손님", "name_en": "Rewards Card Customer",
		"text": "포인트 카드요! 이거 적립됐어요?",
		"text_en": "My rewards card—did I get the points for this?",
		"patience": 9.0, "urgency": 1,
		"actions": [
			{"text": "영수증 보고 재적립 처리", "text_en": "Check the receipt and add the missing points.", "bonus": 1_000, "stress": 0, "tip": "점장이 사후 적립 기록을 보고 성과수당 천 원을 붙였다.", "tip_en": "The manager reviewed the points correction and added a 1,000 won performance bonus."},
			{"text": "\"계산 전에 말씀해 주셔야 해요\"", "text_en": "\"You have to tell me before I ring you up.\"", "bonus": 0, "stress": 2, "tip": "손님은 다시 오지 않겠다며 나갔다.", "tip_en": "They left saying they would never return."},
		]
	},
	{
		"id": "lost", "name": "상품 위치를 묻는 손님", "name_en": "Customer Looking for an Item",
		"text": "저기, 삼각김밥 어디 있어요?",
		"text_en": "Excuse me, where can I find the triangle gimbap?",
		"patience": 13.0, "urgency": 0,
		"actions": [
			{"text": "진열대까지 함께 가서 안내한다", "text_en": "Walk them over to the shelf.", "bonus": 1_000, "stress": 0, "tip": "손님은 고맙다며 팁 천 원을 두고 갔다.", "tip_en": "The customer thanked you and left a 1,000 won tip."},
			{"text": "방향만 손으로 가리킨다", "text_en": "Just point in the general direction.", "bonus": 0, "stress": 0, "tip": "찾아갔다.", "tip_en": "They found it."},
		]
	},
]

const CONV_TOTAL := 10           # 시프트당 총 손님 수
const CONV_SLOTS := 3            # 동시 처리 슬롯
const CONV_SLOT_H := 112.0       # 슬롯 패널 높이 (px)
const CONV_TIMEOUT_STRESS := 2   # 타임아웃당 스트레스 (기본; urgency 3이면 +1 추가)

# ── 배달 루트 상수 ────────────────────────────────────────────────
const DEL_TIME_BUDGET := 120
const DEL_BASE_BONUS := 8_000
const DEL_RAIN_SURGE_PER_ORDER := 5_000
const DEL_ORDERS_DATA = [
	{"name": "홍대 치킨", "name_en": "Hongdae Chicken", "time": 18, "tip": 5_000, "info": "1층 · 18분", "info_en": "1F · 18 min"},
	{"name": "신촌 피자", "name_en": "Sinchon Pizza", "time": 30, "tip": 11_000, "info": "3층 · 30분", "info_en": "3F · 30 min"},
	{"name": "여의도 사무실 야식", "name_en": "Yeouido Office Late-Night Meal", "time": 45, "tip": 18_000, "info": "22층 · 45분", "info_en": "22F · 45 min"},
	{"name": "이대 야식", "name_en": "Ewha Late-Night Meal", "time": 25, "tip": 8_000, "info": "4층 · 25분", "info_en": "4F · 25 min"},
	{"name": "공덕역 카페", "name_en": "Gongdeok Station Cafe", "time": 14, "tip": 4_000, "info": "1층 · 14분", "info_en": "1F · 14 min"},
	{"name": "마포 공사장 도시락", "name_en": "Mapo Construction Site Lunchbox", "time": 8, "tip": 2_500, "info": "1층 · 8분", "info_en": "1F · 8 min"},
]

# ── 상태 변수 ─────────────────────────────────────────────────────
var _rng := RandomNumberGenerator.new()
var _mode: Mode = Mode.CARDS
var _earned: int = BASE_PAY
var _stress_delta: int = 0
var _health_delta: int = 0

# CARDS 상태
var _scenarios: Array = []
var _card_idx: int = 0
var _card_waiting: bool = false
var _card_timer: float = 0.0

# CONVENIENCE 상태
var _conv_queue: Array = []                          # 아직 미등장 손님
var _conv_slots: Array = [null, null, null]          # 현재 슬롯 손님 데이터
var _conv_slot_patience: Array = [0.0, 0.0, 0.0]    # 잔여 인내심 (초)
var _conv_selected: int = -1                         # 선택된 슬롯 (-1 = 없음)
var _conv_feedback_slot: int = -1                    # 피드백 표시 중인 슬롯
var _conv_action_cooldown: float = 0.0               # 액션 후 짧은 대기
var _conv_served: int = 0                            # 처리 완료 손님 수 (성공+실패)
var _conv_good: int = 0                              # 성공 응대 수
var _conv_last_focus_slot: int = 0                   # 패드 포커스 복귀 슬롯
# 패널 참조
var _conv_slot_panels: Array = []                    # 3개 Button 슬롯
var _conv_slot_bars: Array = []                      # 3개 ProgressBar 노드
var _conv_slot_name_lbls: Array = []                 # 3개 이름 Label
var _conv_slot_text_lbls: Array = []                 # 3개 대사/상태 Label
var _conv_fill_styles: Array = []                    # 3개 ProgressBar fill StyleBox
var _conv_action_vb: VBoxContainer = null            # 액션 버튼 영역
var _conv_score_lbl: Label = null

# DELIVERY 상태
var _del_selected: Array = []
var _del_order_btns: Array = []
var _del_status_lbl: Label = null
var _del_confirm_btn: Button = null
var _shift_context: Dictionary = {}
var _last_shift_receipt: Dictionary = {}

# ── UI 참조 ───────────────────────────────────────────────────────
var _root_vb: VBoxContainer
var _header_lbl: Label
var _progress_lbl: Label
var _content_vb: VBoxContainer
var _scene_bg: TextureRect

# CARDS UI
var _scene_lbl: Label
var _choice_vb: VBoxContainer
var _feedback_lbl: Label

# ── 초기화 ───────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_base_ui()
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	match _mode:
		Mode.CONVENIENCE:
			if _conv_action_cooldown > 0.0:
				_conv_action_cooldown -= delta
				if _conv_action_cooldown <= 0.0:
					if _conv_feedback_slot >= 0:
						_conv_free_slot(_conv_feedback_slot)
						_conv_feedback_slot = -1
			else:
				for i in range(CONV_SLOTS):
					if _conv_slots[i] == null:
						continue
					if i == _conv_feedback_slot:
						continue
					_conv_slot_patience[i] -= delta
					_conv_refresh_bar(i)
					if _conv_slot_patience[i] <= 0.0:
						_conv_timeout(i)
						break  # avoid modifying array mid-iteration
		Mode.CARDS:
			if _card_waiting:
				_card_timer -= delta
				if _card_timer <= 0.0:
					_card_waiting = false
					_card_idx += 1
					if _card_idx >= _scenarios.size():
						_show_result()
					else:
						_show_scenario(_card_idx)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _mode == Mode.CONVENIENCE and _conv_selected >= 0:
			_conv_reset_selection()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and _mode == Mode.CONVENIENCE:
		var focus := get_viewport().gui_get_focus_owner()
		if focus == null or not is_ancestor_of(focus):
			_conv_focus_slot()
			get_viewport().set_input_as_handled()

# ── 진입 ─────────────────────────────────────────────────────────
func open(shift_context: Dictionary = {}) -> void:
	_earned = BASE_PAY
	_stress_delta = 0
	_health_delta = 0
	_shift_context = shift_context.duplicate(true)
	_last_shift_receipt = {}
	_del_selected = []
	_card_idx = 0
	_card_waiting = false
	_conv_served = 0
	_conv_good = 0
	_conv_selected = -1
	_conv_feedback_slot = -1
	_conv_action_cooldown = 0.0
	_conv_last_focus_slot = 0
	_conv_slots = [null, null, null]
	_conv_slot_patience = [0.0, 0.0, 0.0]
	_conv_queue = []

	var job_id: String = GameState.current_job.get("id", "")
	match job_id:
		"job_01": _mode = Mode.CONVENIENCE
		"job_02": _mode = Mode.DELIVERY
		_:        _mode = Mode.CARDS

	_clear_content()
	visible = true

	match _mode:
		Mode.CONVENIENCE:
			_set_scene_surface("res://assets/backgrounds/convenience_store_night_v2.png", "convenience")
			_header_lbl.text = LocaleManager.ui("편의점 야간 근무", "Convenience Store Night Shift")
			_start_convenience()
		Mode.DELIVERY:
			_set_scene_surface("res://assets/backgrounds/aruba_delivery_street.png", "street")
			_header_lbl.text = LocaleManager.ui(
				"비 오는 저녁 배달" if _is_rain_surge_shift() else "배달 루트 설정",
				"Rainy Evening Delivery" if _is_rain_surge_shift()
				else "Delivery Route Planning")
			_start_delivery()
		Mode.CARDS:
			_set_scene_surface("res://assets/backgrounds/office_desk.png", "office")
			_header_lbl.text = LocaleManager.ui("알바 근무", "Part-Time Shift")
			_start_cards()

func get_base_pay() -> int:
	return BASE_PAY

func is_rain_surge_shift() -> bool:
	return _is_rain_surge_shift()

func get_last_shift_receipt() -> Dictionary:
	return _last_shift_receipt.duplicate(true)

func _is_rain_surge_shift() -> bool:
	return (
		str(_shift_context.get("weather", "")) == "rain"
		and bool(_shift_context.get("surge_pay", false))
	)

func _clear_content() -> void:
	for ch in _content_vb.get_children():
		ch.queue_free()
	_conv_slot_panels = []
	_conv_slot_bars = []
	_conv_slot_name_lbls = []
	_conv_slot_text_lbls = []
	_conv_fill_styles = []
	_conv_action_vb = null
	_conv_score_lbl = null
	_del_order_btns = []
	_del_status_lbl = null
	_del_confirm_btn = null

# ── 기반 UI ──────────────────────────────────────────────────────
func _build_base_ui() -> void:
	_scene_bg = TextureRect.new()
	_scene_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scene_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_scene_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_scene_bg.modulate = Color(0.42, 0.44, 0.48, 1.0)
	_scene_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_scene_bg)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#03060b", 0.58)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var frame := PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var frame_st := StyleBoxFlat.new()
	frame_st.bg_color = Color("#070b12", 0.84)
	frame_st.border_color = Color("#526071", 0.54)
	frame_st.set_border_width_all(1)
	frame_st.border_width_left = 3
	frame_st.set_corner_radius_all(7)
	frame_st.content_margin_left = 24
	frame_st.content_margin_right = 24
	frame_st.content_margin_top = 19
	frame_st.content_margin_bottom = 19
	frame.add_theme_stylebox_override("panel", frame_st)
	margin.add_child(frame)

	_root_vb = VBoxContainer.new()
	_root_vb.add_theme_constant_override("separation", 12)
	frame.add_child(_root_vb)

	var hdr := HBoxContainer.new()
	_root_vb.add_child(hdr)
	_header_lbl = Label.new()
	_header_lbl.text = LocaleManager.ui("알바 근무", "Part-Time Shift")
	_header_lbl.add_theme_font_size_override("font_size", 24)
	_header_lbl.add_theme_color_override("font_color", Color("#f0c36a"))
	_header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(_header_lbl)
	_progress_lbl = Label.new()
	_progress_lbl.add_theme_font_size_override("font_size", 14)
	_progress_lbl.add_theme_color_override("font_color", Color("#a9b4c4"))
	_progress_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hdr.add_child(_progress_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	_root_vb.add_child(sep)

	_content_vb = VBoxContainer.new()
	_content_vb.add_theme_constant_override("separation", 8)
	_content_vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root_vb.add_child(_content_vb)

func _set_scene_surface(path: String, ambience_key: String) -> void:
	if is_instance_valid(_scene_bg):
		_scene_bg.texture = load(path) if ResourceLoader.exists(path) else null
	BGMPlayer.enter_activity_ambience(ambience_key)

# ══════════════════════════════════════════════════════════════════
# CARDS 모드
# ══════════════════════════════════════════════════════════════════
func _start_cards() -> void:
	var job_id: String = GameState.current_job.get("id", "")
	var pool: Array
	match job_id:
		"job_01": pool = SCENARIOS_CONVENIENCE
		"job_02": pool = SCENARIOS_DELIVERY
		_:        pool = SCENARIOS_GENERAL

	var shuffled := pool.duplicate()
	shuffled.shuffle()
	var mastery := MetaProgression.get_mastery("aruba")
	var count := 3
	if GameState.social_skill >= 50: count = 4
	if mastery >= 2: count = maxi(count, 4)
	if mastery >= 3: count = 5
	_scenarios = shuffled.slice(0, mini(count, shuffled.size()))

	var scene_panel := PanelContainer.new()
	scene_panel.custom_minimum_size = Vector2(0, 160)
	var scene_st := StyleBoxFlat.new()
	scene_st.bg_color = Color("#0d141e", 0.92)
	scene_st.border_color = Color("#344454", 0.86)
	scene_st.set_border_width_all(1)
	scene_st.border_width_left = 4
	scene_st.set_corner_radius_all(6)
	scene_st.content_margin_left = 22
	scene_st.content_margin_right = 22
	scene_st.content_margin_top = 20
	scene_st.content_margin_bottom = 20
	scene_panel.add_theme_stylebox_override("panel", scene_st)
	_content_vb.add_child(scene_panel)

	_scene_lbl = Label.new()
	_scene_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scene_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_scene_lbl.add_theme_font_size_override("font_size", 19)
	_scene_lbl.add_theme_color_override("font_color", Color("#e4e8ed"))
	scene_panel.add_child(_scene_lbl)

	_feedback_lbl = Label.new()
	_feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_lbl.add_theme_font_size_override("font_size", 15)
	_feedback_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
	_feedback_lbl.custom_minimum_size = Vector2(0, 32)
	_content_vb.add_child(_feedback_lbl)

	_choice_vb = VBoxContainer.new()
	_choice_vb.add_theme_constant_override("separation", 7)
	_content_vb.add_child(_choice_vb)

	set_process(true)
	_show_scenario(0)

func _show_scenario(idx: int) -> void:
	var sc: Dictionary = _scenarios[idx]
	_scene_lbl.text = _loc(sc, "scene")
	_feedback_lbl.text = ""
	_progress_lbl.text = "%d / %d" % [idx + 1, _scenarios.size()]
	for ch in _choice_vb.get_children():
		ch.queue_free()
	var first_btn: Button = null
	for ci in range(sc["choices"].size()):
		var btn := _make_btn("%02d  %s" % [ci + 1, _loc(sc["choices"][ci], "text")], "#0e1a2a", 16)
		btn.custom_minimum_size = Vector2(0, 58)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _on_cards_choice(sc, ci))
		_choice_vb.add_child(btn)
		if first_btn == null:
			first_btn = btn
	if first_btn != null:
		first_btn.call_deferred("grab_focus")

func _on_cards_choice(sc: Dictionary, ci: int) -> void:
	var choice: Dictionary = sc["choices"][ci]
	_earned += int(choice.get("money", 0))
	_stress_delta += int(choice.get("stress", 0))
	_health_delta += int(choice.get("health", 0))
	_feedback_lbl.text = LocaleManager.ui("결과: ", "Result: ") + _loc(choice, "tip")
	for ch in _choice_vb.get_children():
		if ch is Button:
			ch.disabled = true
	AudioManager.play("click")
	_card_waiting = true
	_card_timer = 0.9

# ══════════════════════════════════════════════════════════════════
# CONVENIENCE 모드 — 오버쿡 스타일 손님 응대 게임
# ══════════════════════════════════════════════════════════════════
func _start_convenience() -> void:
	# 손님 큐 준비 (CUSTOMER_TYPES를 가중치로 섞어 10명)
	var pool: Array = CUSTOMER_TYPES.duplicate()
	pool.shuffle()
	# 진상 손님은 1명 이하
	var angry_added := false
	for c in pool:
		if _conv_queue.size() >= CONV_TOTAL:
			break
		if c.get("id", "") == "angry":
			if angry_added:
				continue
			angry_added = true
		_conv_queue.append(c.duplicate(true))
	# 부족하면 일반 손님으로 채우기
	while _conv_queue.size() < CONV_TOTAL:
		_conv_queue.append(CUSTOMER_TYPES[0].duplicate(true))

	# fill StyleBox 3개 미리 생성
	for i in range(CONV_SLOTS):
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("#2a7a3a")
		_conv_fill_styles.append(fill)

	var scene_line := Label.new()
	scene_line.text = LocaleManager.ui(
		"새벽 1시 47분. 냉장고 모터음 사이로 계산대 앞 손님 셋이 겹쳤다.",
		"1:47 AM. Three customers converge at the counter over the refrigerator hum.")
	scene_line.add_theme_font_size_override("font_size", 16)
	scene_line.add_theme_color_override("font_color", Color("#d7dee8"))
	scene_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_vb.add_child(scene_line)

	# 슬롯 카드 3개 생성. Button으로 만들어 마우스·키보드·패드가 같은 경로를 쓴다.
	var slots_vb := VBoxContainer.new()
	slots_vb.add_theme_constant_override("separation", 9)
	_content_vb.add_child(slots_vb)

	for i in range(CONV_SLOTS):
		var panel := Button.new()
		panel.text = ""
		panel.custom_minimum_size = Vector2(0, CONV_SLOT_H)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.focus_mode = Control.FOCUS_ALL
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		panel.clip_contents = true
		slots_vb.add_child(panel)
		_conv_slot_panels.append(panel)
		_conv_slot_bars.append(null)
		_conv_slot_name_lbls.append(null)
		_conv_slot_text_lbls.append(null)
		var cap_i: int = i
		panel.pressed.connect(func(): _conv_click_slot(cap_i))
		_conv_apply_slot_style(i)

	# 점수 라벨
	_conv_score_lbl = Label.new()
	_conv_score_lbl.add_theme_font_size_override("font_size", 14)
	_conv_score_lbl.add_theme_color_override("font_color", Color("#9eb8a7"))
	_content_vb.add_child(_conv_score_lbl)

	# 액션 영역 (클릭 시 동적 버튼 표시)
	var action_sep := HSeparator.new()
	action_sep.add_theme_color_override("color", Color("#1a2030"))
	_content_vb.add_child(action_sep)

	_conv_action_vb = VBoxContainer.new()
	_conv_action_vb.add_theme_constant_override("separation", 8)
	_conv_action_vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_vb.add_child(_conv_action_vb)

	var hint := Label.new()
	hint.text = LocaleManager.ui("누구를 먼저 상대할지 고른다.", "Choose who gets your attention first.")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("#778596"))
	_conv_action_vb.add_child(hint)

	_conv_update_score_lbl()
	set_process(true)

	# 첫 손님 3명 즉시 등장
	for i in range(CONV_SLOTS):
		_conv_spawn_into(i)
	_progress_lbl.text = LocaleManager.ui("심야  01:47", "NIGHT  01:47")
	_conv_focus_slot.call_deferred(0)

func _conv_spawn_into(slot_idx: int) -> void:
	if _conv_queue.is_empty():
		return
	var customer: Dictionary = _conv_queue.pop_front()
	_conv_slots[slot_idx] = customer
	_conv_slot_patience[slot_idx] = float(customer.get("patience", 10.0))
	_conv_build_slot_content(slot_idx)

func _conv_build_slot_content(slot_idx: int) -> void:
	var panel: Button = _conv_slot_panels[slot_idx]
	# 기존 콘텐츠 제거
	for ch in panel.get_children():
		ch.queue_free()

	var customer: Dictionary = _conv_slots[slot_idx]
	if customer == null:
		return

	panel.disabled = false
	panel.focus_mode = Control.FOCUS_ALL
	_conv_apply_slot_style(slot_idx)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 13)
	margin.add_theme_constant_override("margin_bottom", 13)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 14)
	margin.add_child(hb)

	var slot_no := Label.new()
	slot_no.text = "%02d" % (slot_idx + 1)
	slot_no.custom_minimum_size = Vector2(42, 0)
	slot_no.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	slot_no.add_theme_font_size_override("font_size", 22)
	slot_no.add_theme_color_override("font_color", Color("#667789"))
	slot_no.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(slot_no)

	# 짧은 태그 + 이름
	var info_vb := VBoxContainer.new()
	info_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(info_vb)

	var name_lbl := Label.new()
	name_lbl.text = "%s  %s" % [_customer_tag(customer), _loc(customer, "name", LocaleManager.ui("손님", "Customer"))]
	name_lbl.add_theme_font_size_override("font_size", 17)
	name_lbl.add_theme_color_override("font_color", Color("#dde8f0"))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vb.add_child(name_lbl)
	_conv_slot_name_lbls[slot_idx] = name_lbl

	var text_lbl := Label.new()
	text_lbl.text = "\"%s\"" % _loc(customer, "text")
	text_lbl.add_theme_font_size_override("font_size", 14)
	text_lbl.add_theme_color_override("font_color", Color("#96a9b8"))
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vb.add_child(text_lbl)
	_conv_slot_text_lbls[slot_idx] = text_lbl

	# 인내심 바 + 긴급도
	var bar_vb := VBoxContainer.new()
	bar_vb.custom_minimum_size = Vector2(132, 0)
	bar_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(bar_vb)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(132, 13)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("fill", _conv_fill_styles[slot_idx])
	bar_vb.add_child(bar)
	_conv_slot_bars[slot_idx] = bar

	var urg: int = int(customer.get("urgency", 1))
	var urg_lbl := Label.new()
	urg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	urg_lbl.add_theme_font_size_override("font_size", 12)
	urg_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	match urg:
		0:
			urg_lbl.text = LocaleManager.ui("느긋", "Calm")
			urg_lbl.add_theme_color_override("font_color", Color("#5a9a5a"))
		1:
			urg_lbl.text = LocaleManager.ui("보통", "Normal")
			urg_lbl.add_theme_color_override("font_color", Color("#6a8a9a"))
		2:
			urg_lbl.text = LocaleManager.ui("급함", "Urgent")
			urg_lbl.add_theme_color_override("font_color", Color("#c8a020"))
		_:
			urg_lbl.text = LocaleManager.ui("긴급!", "Critical!")
			urg_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	bar_vb.add_child(urg_lbl)

func _conv_clear_slot_panel(slot_idx: int) -> void:
	var panel: Button = _conv_slot_panels[slot_idx]
	for ch in panel.get_children():
		ch.queue_free()
	_conv_slot_bars[slot_idx] = null
	_conv_slot_name_lbls[slot_idx] = null
	_conv_slot_text_lbls[slot_idx] = null
	panel.disabled = true
	panel.focus_mode = Control.FOCUS_NONE
	_conv_apply_slot_style(slot_idx, true)

func _conv_slot_style(bg: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(border_width)
	st.border_width_left = maxi(3, border_width)
	st.set_corner_radius_all(6)
	return st

func _conv_apply_slot_style(slot_idx: int, empty: bool = false) -> void:
	if slot_idx < 0 or slot_idx >= _conv_slot_panels.size():
		return
	var panel := _conv_slot_panels[slot_idx] as Button
	if not is_instance_valid(panel):
		return
	if empty:
		var empty_st := _conv_slot_style(Color("#080b11", 0.72), Color("#26303b", 0.72), 1)
		panel.add_theme_stylebox_override("normal", empty_st)
		panel.add_theme_stylebox_override("disabled", empty_st)
		return
	var selected := slot_idx == _conv_selected
	var normal := _conv_slot_style(
		Color("#13202c", 0.95) if selected else Color("#0d141e", 0.94),
		Color("#d4ad58", 0.86) if selected else Color("#344454", 0.90),
		2 if selected else 1)
	var hover := normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.06)
	hover.border_color = Color("#8799aa")
	var focus := normal.duplicate()
	focus.bg_color = normal.bg_color.lightened(0.09)
	focus.border_color = Color("#f0d18a")
	focus.set_border_width_all(2)
	focus.border_width_left = 5
	var pressed := focus.duplicate()
	pressed.bg_color = focus.bg_color.darkened(0.08)
	panel.add_theme_stylebox_override("normal", normal)
	panel.add_theme_stylebox_override("hover", hover)
	panel.add_theme_stylebox_override("focus", focus)
	panel.add_theme_stylebox_override("pressed", pressed)

func _conv_focus_slot(preferred: int = -1) -> void:
	if not visible or _mode != Mode.CONVENIENCE:
		return
	var start := preferred if preferred >= 0 else _conv_last_focus_slot
	for offset in range(CONV_SLOTS):
		var idx := posmod(start + offset, CONV_SLOTS)
		if _conv_slots[idx] == null:
			continue
		var panel := _conv_slot_panels[idx] as Button
		if is_instance_valid(panel) and not panel.disabled:
			_conv_last_focus_slot = idx
			panel.grab_focus()
			return

func _conv_reset_selection(refocus: bool = true) -> void:
	var previous := _conv_selected
	_conv_selected = -1
	for ch in _conv_action_vb.get_children():
		ch.queue_free()
	var hint := Label.new()
	hint.text = LocaleManager.ui("누구를 먼저 상대할지 고른다.", "Choose who gets your attention first.")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("#778596"))
	_conv_action_vb.add_child(hint)
	_conv_highlight_selected()
	if refocus:
		_conv_focus_slot.call_deferred(previous if previous >= 0 else _conv_last_focus_slot)

func _conv_refresh_bar(slot_idx: int) -> void:
	var bar: ProgressBar = _conv_slot_bars[slot_idx]
	if not is_instance_valid(bar) or _conv_slots[slot_idx] == null:
		return
	var max_p: float = float(_conv_slots[slot_idx].get("patience", 10.0))
	var ratio: float = clampf(_conv_slot_patience[slot_idx] / max_p, 0.0, 1.0)
	bar.value = ratio * 100.0
	var fill: StyleBoxFlat = _conv_fill_styles[slot_idx]
	if ratio > 0.5:
		fill.bg_color = Color("#2a7a3a")
	elif ratio > 0.25:
		fill.bg_color = Color("#c8a020")
	else:
		fill.bg_color = Color("#c83030")

func _conv_click_slot(slot_idx: int) -> void:
	if _conv_slots[slot_idx] == null:
		return
	if slot_idx == _conv_feedback_slot:
		return
	if _conv_action_cooldown > 0.0:
		return

	_conv_selected = slot_idx
	_conv_last_focus_slot = slot_idx
	_conv_highlight_selected()
	_conv_show_actions(slot_idx)
	AudioManager.play("click")

func _conv_highlight_selected() -> void:
	for i in range(CONV_SLOTS):
		_conv_apply_slot_style(i, _conv_slots[i] == null)

func _conv_show_actions(slot_idx: int) -> void:
	for ch in _conv_action_vb.get_children():
		ch.queue_free()

	var customer: Dictionary = _conv_slots[slot_idx]
	var who_lbl := Label.new()
	who_lbl.text = LocaleManager.ui("%s · %s에게 뭐라고 할까", "%s · %s · How do you respond?") % [_customer_tag(customer), _loc(customer, "name")]
	who_lbl.add_theme_font_size_override("font_size", 16)
	who_lbl.add_theme_color_override("font_color", Color("#d8c28f"))
	_conv_action_vb.add_child(who_lbl)

	var actions: Array = customer.get("actions", [])
	var first_action: Button = null
	for ai in range(actions.size()):
		var action: Dictionary = actions[ai]
		var btn := _make_btn("%02d  %s" % [ai + 1, _loc(action, "text")], "#101923", 15)
		btn.custom_minimum_size = Vector2(0, 48)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var cap_slot: int = slot_idx
		var cap_ai: int = ai
		btn.pressed.connect(func(): _conv_handle(cap_slot, cap_ai))
		_conv_action_vb.add_child(btn)
		if first_action == null:
			first_action = btn
	if first_action != null:
		first_action.call_deferred("grab_focus")

func _conv_handle(slot_idx: int, action_idx: int) -> void:
	if _conv_slots[slot_idx] == null or _conv_feedback_slot == slot_idx:
		return

	var customer: Dictionary = _conv_slots[slot_idx]
	var action: Dictionary = customer["actions"][action_idx]

	var bonus: int = int(action.get("bonus", 0))
	_earned += bonus
	_stress_delta += int(action.get("stress", 0))
	if bonus > 0:
		_conv_good += 1
		AudioManager.play("money_gain")
	elif bonus < 0:
		AudioManager.play("money_loss")
	else:
		_conv_good += 1
		AudioManager.play("click")

	# 슬롯에 결과 텍스트 잠깐 표시
	var text_lbl: Label = _conv_slot_text_lbls[slot_idx]
	if is_instance_valid(text_lbl):
		text_lbl.text = LocaleManager.ui("결과: ", "Result: ") + _loc(action, "tip", LocaleManager.ui("처리 완료", "Handled"))
		text_lbl.add_theme_color_override("font_color", Color("#3dba6a") if bonus >= 0 else Color("#e85d5d"))
	var name_lbl: Label = _conv_slot_name_lbls[slot_idx]
	if is_instance_valid(name_lbl):
		name_lbl.text = LocaleManager.ui("처리  ", "OK  ") + _loc(customer, "name")

	# 액션 영역 지우기
	for ch in _conv_action_vb.get_children():
		ch.queue_free()
	var wait_lbl := Label.new()
	wait_lbl.text = LocaleManager.ui("다음 손님이 계산대로 다가온다.", "The next customer steps up to the counter.")
	wait_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wait_lbl.add_theme_font_size_override("font_size", 14)
	wait_lbl.add_theme_color_override("font_color", Color("#789387"))
	_conv_action_vb.add_child(wait_lbl)
	_conv_selected = -1
	_conv_highlight_selected()

	_conv_served += 1
	_conv_feedback_slot = slot_idx
	_conv_action_cooldown = 0.7
	_conv_update_score_lbl()

func _conv_timeout(slot_idx: int) -> void:
	if _conv_slots[slot_idx] == null:
		return
	var customer: Dictionary = _conv_slots[slot_idx]
	var urgency: int = int(customer.get("urgency", 1))
	_stress_delta += CONV_TIMEOUT_STRESS + (1 if urgency >= 3 else 0)

	var text_lbl: Label = _conv_slot_text_lbls[slot_idx]
	if is_instance_valid(text_lbl):
		text_lbl.text = LocaleManager.ui("참다가 나가버렸다", "They lost patience and left")
		text_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	var name_lbl: Label = _conv_slot_name_lbls[slot_idx]
	if is_instance_valid(name_lbl):
		name_lbl.text = LocaleManager.ui("실패  ", "MISS  ") + _loc(customer, "name")

	if _conv_selected == slot_idx:
		_conv_reset_selection(false)

	_conv_served += 1
	_conv_feedback_slot = slot_idx
	_conv_action_cooldown = 0.5
	AudioManager.play("money_loss")
	_conv_update_score_lbl()

func _conv_free_slot(slot_idx: int) -> void:
	_conv_slots[slot_idx] = null
	_conv_slot_patience[slot_idx] = 0.0
	_conv_clear_slot_panel(slot_idx)

	# 종료 조건: 모든 손님 처리 완료
	var all_done: bool = _conv_queue.is_empty()
	if all_done:
		for i in range(CONV_SLOTS):
			if _conv_slots[i] != null:
				all_done = false
				break
	if all_done:
		_show_result()
		return

	# 다음 손님 즉시 투입
	_conv_spawn_into(slot_idx)
	_conv_update_score_lbl()
	# 다른 손님 응답을 고르는 중이라면 새 손님이 포커스를 빼앗지 않는다.
	if _conv_selected < 0:
		_conv_focus_slot.call_deferred(slot_idx)

func _conv_update_score_lbl() -> void:
	if not is_instance_valid(_conv_score_lbl):
		return
	var remaining := _conv_queue.size() + _conv_slots.filter(func(s): return s != null).size()
	_conv_score_lbl.text = LocaleManager.ui(
		"응대 %d/%d · 성공 %d · 남은 손님 %d · 기본 수당 %s",
		"SERVED %d/%d · GOOD %d · LEFT %d · BASE %s") % [
		_conv_served, CONV_TOTAL, _conv_good, remaining, _fmt(BASE_PAY)]

# ══════════════════════════════════════════════════════════════════
# DELIVERY 모드 — 배달 루트 최적화 퍼즐
# ══════════════════════════════════════════════════════════════════
func _start_delivery() -> void:
	set_process(false)
	_progress_lbl.text = LocaleManager.ui("루트 설정", "Route")

	var guide := Label.new()
	if _is_rain_surge_shift():
		guide.text = LocaleManager.ui(
			"8시간 근무 중 비가 오는 저녁 피크 %d분입니다. 완료한 건마다 비 할증 %s이 붙고, 빗길 운행으로 건강이 1 더 줄어듭니다.",
			"This is the rainy %d-minute evening peak of an eight-hour shift. Each completed delivery adds a %s rain surge, and riding in the rain costs 1 extra Health.") % [
				DEL_TIME_BUDGET, _fmt(DEL_RAIN_SURGE_PER_ORDER)]
	else:
		guide.text = LocaleManager.ui(
			"8시간 근무 중 저녁 피크 %d분입니다. 배달할 순서대로 선택하세요. 다시 선택하면 취소됩니다.",
			"This is the %d-minute evening peak of an eight-hour shift. Select deliveries in order; select again to cancel.") % DEL_TIME_BUDGET
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_font_size_override("font_size", 15)
	guide.add_theme_color_override("font_color", Color("#b1c0cc"))
	_content_vb.add_child(guide)

	var orders_vb := VBoxContainer.new()
	orders_vb.add_theme_constant_override("separation", 5)
	_content_vb.add_child(orders_vb)

	for i in range(DEL_ORDERS_DATA.size()):
		var o: Dictionary = DEL_ORDERS_DATA[i]
		var btn := _make_btn(
			_delivery_label(o),
			"#0e1a2e", 15)
		btn.custom_minimum_size = Vector2(0, 54)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var cap_i: int = i
		btn.pressed.connect(func(): _del_toggle(cap_i))
		orders_vb.add_child(btn)
		_del_order_btns.append(btn)

	_del_status_lbl = Label.new()
	_del_status_lbl.add_theme_font_size_override("font_size", 15)
	_del_status_lbl.add_theme_color_override("font_color", Color("#c8a060"))
	_del_status_lbl.custom_minimum_size = Vector2(0, 22)
	_content_vb.add_child(_del_status_lbl)

	_del_confirm_btn = _make_btn(LocaleManager.ui("배달 출발", "Start Delivery"), "#0d3a1a", 16)
	_del_confirm_btn.custom_minimum_size = Vector2(0, 58)
	_del_confirm_btn.disabled = true
	_del_confirm_btn.pressed.connect(_del_confirm)
	_content_vb.add_child(_del_confirm_btn)

	_del_refresh_ui()
	if not _del_order_btns.is_empty():
		(_del_order_btns[0] as Button).call_deferred("grab_focus")

func _del_toggle(idx: int) -> void:
	var pos := _del_selected.find(idx)
	if pos >= 0:
		_del_selected.remove_at(pos)
	else:
		_del_selected.append(idx)
	_del_refresh_ui()

func _del_refresh_ui() -> void:
	var time_used := 0
	for i in _del_selected:
		time_used += int(DEL_ORDERS_DATA[i]["time"])

	for i in range(_del_order_btns.size()):
		var btn: Button = _del_order_btns[i]
		if not is_instance_valid(btn):
			continue
		var o: Dictionary = DEL_ORDERS_DATA[i]
		var sel_pos := _del_selected.find(i)
		var would_exceed := (time_used + int(o["time"])) > DEL_TIME_BUDGET and sel_pos < 0

		if sel_pos >= 0:
			btn.text = LocaleManager.ui("%d번째  %s", "#%d  %s") % [sel_pos + 1, _delivery_label(o)]
			var st := StyleBoxFlat.new()
			st.bg_color = Color("#1a3a1a")
			st.set_corner_radius_all(5)
			st.content_margin_left = 18
			st.content_margin_right = 18
			st.content_margin_top = 8
			st.content_margin_bottom = 8
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_color_override("font_color", Color("#6af0a0"))
			btn.disabled = false
		else:
			btn.text = _delivery_label(o)
			var st := StyleBoxFlat.new()
			st.bg_color = Color("#0e1a2e" if not would_exceed else "#1a1218")
			st.set_corner_radius_all(5)
			st.content_margin_left = 18
			st.content_margin_right = 18
			st.content_margin_top = 8
			st.content_margin_bottom = 8
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_color_override("font_color",
				Color("#c8d8e8") if not would_exceed else Color("#4a3a4a"))
			btn.disabled = would_exceed

	var tip_preview := 0
	var bonus_preview := 0
	var surge_preview := 0
	for i in _del_selected:
		tip_preview += int(DEL_ORDERS_DATA[i]["tip"])
		bonus_preview += DEL_BASE_BONUS
		if _is_rain_surge_shift():
			surge_preview += DEL_RAIN_SURGE_PER_ORDER

	var remaining := DEL_TIME_BUDGET - time_used
	var status_color := "#3dba6a" if remaining >= 20 else "#f0b429" if remaining >= 0 else "#e85d5d"
	if is_instance_valid(_del_status_lbl):
		var target_extra_income := _fmt(tip_preview + bonus_preview + surge_preview)
		var english_extra_income := LocaleManager.format_money_english(
			float(tip_preview + bonus_preview + surge_preview))
		var target_surge_suffix := LocaleManager.ui_format(
			" (비 할증 %s)", " (%s rain surge)",
			_fmt(surge_preview),
			LocaleManager.format_money_english(float(surge_preview))) \
			if _is_rain_surge_shift() else ""
		var english_surge_suffix := " (%s rain surge)" \
			% LocaleManager.format_money_english(float(surge_preview)) \
			if _is_rain_surge_shift() else ""
		_del_status_lbl.text = LocaleManager.ui_format(
			"소요 %d분 / %d분 (여유 %d분)  |  예상 추가 수입 +%s%s",
			"Time %d / %d min (%d min spare)  |  Expected extra income +%s%s",
			[
				time_used,
				DEL_TIME_BUDGET,
				remaining,
				target_extra_income,
				target_surge_suffix,
			],
			[
				time_used,
				DEL_TIME_BUDGET,
				remaining,
				english_extra_income,
				english_surge_suffix,
			])
		_del_status_lbl.add_theme_color_override("font_color", Color(status_color))

	if is_instance_valid(_del_confirm_btn):
		_del_confirm_btn.disabled = _del_selected.is_empty()

func _del_confirm() -> void:
	var tip_total := 0
	var route_minutes := 0
	for i in _del_selected:
		tip_total += int(DEL_ORDERS_DATA[i]["tip"])
		route_minutes += int(DEL_ORDERS_DATA[i]["time"])
	var delivery_count := _del_selected.size()
	var surge_total := (
		delivery_count * DEL_RAIN_SURGE_PER_ORDER
		if _is_rain_surge_shift() else 0
	)
	_earned += tip_total + delivery_count * DEL_BASE_BONUS + surge_total
	_stress_delta += maxi(delivery_count - 2, 0)
	_health_delta -= delivery_count
	if _is_rain_surge_shift() and delivery_count > 0:
		_health_delta -= 1
	_last_shift_receipt = {
		"mode": "delivery",
		"weather": "rain" if _is_rain_surge_shift() else "clear",
		"base_pay": BASE_PAY,
		"delivery_count": delivery_count,
		"route_minutes": route_minutes,
		"tip_total": tip_total,
		"route_bonus_total": delivery_count * DEL_BASE_BONUS,
		"surge_per_delivery": (
			DEL_RAIN_SURGE_PER_ORDER if _is_rain_surge_shift() else 0
		),
		"surge_total": surge_total,
		"earned": _earned,
	}
	_show_result()

# ══════════════════════════════════════════════════════════════════
# 결과 화면
# ══════════════════════════════════════════════════════════════════
func _show_result() -> void:
	set_process(false)
	_clear_content()
	_progress_lbl.text = LocaleManager.ui("완료", "Done")

	AudioManager.play("money_gain" if _earned >= BASE_PAY else "money_loss")

	var finish_lbl := Label.new()
	finish_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_lbl.add_theme_font_size_override("font_size", 15)
	finish_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_content_vb.add_child(finish_lbl)

	match _mode:
		Mode.CONVENIENCE:
			finish_lbl.text = LocaleManager.ui("근무 종료  %d / %d명 응대 성공", "Shift Complete  %d / %d served successfully") % [_conv_good, CONV_TOTAL]
		Mode.DELIVERY:
			if _is_rain_surge_shift():
				finish_lbl.text = LocaleManager.ui(
					"빗속 배달 완료 — %d건 · 비 할증 +%s",
					"Rain Delivery Complete — %d orders · +%s surge") % [
						_del_selected.size(),
						_fmt(int(_last_shift_receipt.get("surge_total", 0))),
					]
			else:
				finish_lbl.text = LocaleManager.ui(
					"배달 완료 — %d건",
					"Delivery Complete — %d orders") % _del_selected.size()
		Mode.CARDS:
			finish_lbl.text = LocaleManager.ui("근무 종료", "Shift Complete")

	var earn_lbl := Label.new()
	earn_lbl.text = "+%s" % _fmt(_earned)
	earn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	earn_lbl.add_theme_font_size_override("font_size", 28)
	earn_lbl.add_theme_color_override("font_color",
		Color("#3dba6a") if _earned >= BASE_PAY else Color("#e85d5d"))
	_content_vb.add_child(earn_lbl)

	var stat_row := HBoxContainer.new()
	stat_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stat_row.add_theme_constant_override("separation", 16)
	_content_vb.add_child(stat_row)
	var total_health_delta := BASE_SHIFT_HEALTH_DELTA + _health_delta
	if _stress_delta != 0:
		stat_row.add_child(_mini_lbl(
			LocaleManager.ui("정신력 %+d", "Mental %+d") % (-_stress_delta),
			"#e85d5d" if _stress_delta > 0 else "#3dba6a"))
	if total_health_delta != 0:
		stat_row.add_child(_mini_lbl(
			LocaleManager.ui("건강 %+d", "Health %+d") % total_health_delta,
			"#e85d5d" if total_health_delta < 0 else "#3dba6a"))

	var ok_btn := _make_btn(LocaleManager.ui("퇴근하기", "Clock Out"), "#0e3a2a", 15)
	ok_btn.custom_minimum_size = Vector2(0, 46)
	ok_btn.pressed.connect(_on_finish)
	_content_vb.add_child(ok_btn)
	ok_btn.call_deferred("grab_focus")

func _on_finish() -> void:
	MetaProgression.record_minigame_play("aruba")
	BGMPlayer.leave_activity_ambience()
	visible = false
	closed.emit(
		_earned,
		_stress_delta,
		BASE_SHIFT_HEALTH_DELTA + _health_delta)

# ── 헬퍼 ─────────────────────────────────────────────────────────
func _customer_tag(customer: Dictionary) -> String:
	match str(customer.get("id", "")):
		"checkout":
			return LocaleManager.ui("계산", "CHECKOUT")
		"angry":
			return LocaleManager.ui("불만", "COMPLAINT")
		"regular_elder":
			return LocaleManager.ui("단골", "REGULAR")
		"drunk":
			return LocaleManager.ui("취객", "DRUNK")
		"return":
			return LocaleManager.ui("교환", "RETURN")
		"parcel":
			return LocaleManager.ui("택배", "PARCEL")
		"points":
			return LocaleManager.ui("포인트", "POINTS")
		"lost":
			return LocaleManager.ui("문의", "ASK")
		_:
			return LocaleManager.ui("손님", "GUEST")

func _make_btn(text: String, bg_hex: String, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg_hex)
	st.set_corner_radius_all(6)
	st.content_margin_left = 18
	st.content_margin_right = 18
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	var hov := st.duplicate()
	hov.bg_color = st.bg_color.lightened(0.1)
	hov.border_color = Color("#66788a")
	hov.set_border_width_all(1)
	var focus := hov.duplicate()
	focus.bg_color = st.bg_color.lightened(0.14)
	focus.border_color = Color("#f0d18a")
	focus.set_border_width_all(2)
	focus.border_width_left = 5
	var dis := st.duplicate()
	dis.bg_color = st.bg_color.darkened(0.4)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("focus", focus)
	btn.add_theme_stylebox_override("pressed", focus)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_color_override("font_color", Color("#e8eaf0"))
	btn.add_theme_color_override("font_disabled_color", Color("#4a5a6a"))
	btn.add_theme_font_size_override("font_size", font_size)
	btn.focus_mode = Control.FOCUS_ALL
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return btn

func _mini_lbl(text: String, color_hex: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(color_hex))
	return lbl

func _fmt(v: int) -> String:
	return GameState.format_money(float(v))

func _loc(data: Dictionary, key: String, fallback := "") -> String:
	var en_key := "%s_en" % key
	var korean := str(data.get(key, fallback))
	var english := str(data.get(en_key, fallback))
	return LocaleManager.ui(korean, english)

func _delivery_label(order: Dictionary) -> String:
	return LocaleManager.ui("%s  [%s]  팁 +%s", "%s  [%s]  Tip +%s") % [
		_loc(order, "name"),
		_loc(order, "info"),
		_fmt(int(order.get("tip", 0))),
	]
