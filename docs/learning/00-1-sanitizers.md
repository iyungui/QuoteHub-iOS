# 0.1 — Sanitizer / Checker란 무엇인가

## 핵심 질문
- "Thread Sanitizer가 race를 잡는다"는데, **무슨 원리로** 잡는가?
- 왜 평소엔 꺼두고, 디버그할 때만 켜는가?
- Sanitizer / Checker / Static Analyzer는 어떻게 다른가?

---

## CS 원리 (코치 설명)

### 1. Instrumentation(계측)이란
컴파일러가 내 코드를 기계어로 바꿀 때, **원래 없던 감시 코드를 몰래 끼워 넣는 것**.
- 내가 `x = 1` 이라고 쓰면 → 컴파일러가 `[감시: x를 누가 건드리는지 기록] x = 1` 로 바꿈.
- 그래서 느려진다(2~20배). → 출시 빌드에선 끄고, 디버그할 때만 켠다.

### 2. Thread Sanitizer (TSan) — race 탐지기
- **Shadow Memory**: 진짜 메모리 1바이트마다, "이 메모리를 마지막에 누가/언제 접근했는지"를 적는 그림자 장부를 따로 둔다.
- **Happens-before 관계**: 두 접근 사이에 "반드시 먼저 일어남"을 보장하는 동기화(lock, actor, await 등)가 있었는지 추적한다.
- 두 스레드가 같은 메모리를 만졌는데 그 사이에 happens-before가 **없고**, 그중 하나라도 쓰기(write)면 → **data race**라고 빨간 경고.
- 핵심: TSan은 "실제로 그 코드 경로가 실행됐을 때만" 잡는다. → 테스트로 그 경로를 밟아줘야 한다.

### 3. Main Thread Checker — UI 위반 탐지기
- UIKit/AppKit 함수 호출 직전에 "지금 main thread냐?"를 검사하는 후크를 끼운다.
- 백그라운드에서 UI를 건드리면 즉시 경고.

### 4. Address Sanitizer (ASan) — 메모리 오염 탐지기
- 할당된 메모리 주변에 **redzone(지뢰밭)**을 깔아둔다. 배열 범위를 벗어나 읽/쓰면 지뢰를 밟아 즉시 잡힌다.

### Sanitizer vs Static Analyzer
- **Sanitizer = 런타임**: 실제로 실행해봐야 잡는다. (동적)
- **Static Analyzer = 컴파일 타임**: 실행 안 하고 코드만 분석. (정적)
- 그래서 race는 주로 Sanitizer(런타임)로 잡는다 — 타이밍 문제니까.

---

## 도구로 증명 (직접 한 것 기록)

### Before
`QuoteHub.xcscheme`의 `<LaunchAction>`에 sanitizer 속성 없음 → 한 번도 켠 적 없음.

### 한 일
1. Xcode → Product → Scheme → Edit Scheme → Run → Diagnostics
2. [ ] Thread Sanitizer 체크
3. [ ] Main Thread Checker 확인(보통 기본 켜짐)
4. 앱 실행 → 무엇이 떴는가?

### 결과 (내가 본 것)
> (여기에: TSan 켜고 앱 돌렸을 때 경고가 떴는지, 떴다면 어느 파일/줄인지 붙여넣기)
![alt text](<Screenshot 2026-06-06 at 1.13.42 AM.png>)
---

## 내 언어로 정리 (내가 직접 작성 — 코치가 검사함)

> Q1. TSan은 무슨 원리로 data race를 잡는가? (shadow memory, happens-before 단어 써서)
> 
> - Shadow Memory: 프로그램 실행 중 메인 메모리의 특정 정보(변수, 상태 등)를 추적하고 저장하기 위해 원래 프로그램에서는 보이지 않게 뒤에서 데이터를 기록하는 기술
- Happens-before: 두 접근 사이에 "반드시 먼저 일어남"을 보장하는 동기화(lock, actor, await, @MainActor)가 있었는지 본다.

즉 두 스레드가 같은 메모리를 만졌는데, 그 사이에 happens-before 보장이 없고(@MainActor 같은게 없고) 그 중 하나가 쓰기(write)이면, data race 빨간 경고.


> Q2. 왜 sanitizer는 출시 빌드(프로덕션에 올리는 빌드)에서 끄는가?
>
> 코드 한줄마다 이 코드가 어떤 스레드가 어떤 자원에 접근하려 했는지를 기록하고 또 갱신하는 작업을 하기 때문에 속도가 느려질 수 밖에 없기때문.

> Q3. race는 왜 Static Analyzer로 못 잡고 Sanitizer로 잡는가?
> race는 sanitizer = 런타임 환경에서(실제로 실행해봐야)만 탐지할 수 있다. 따라서 컴파일 단계(static analyer) 처럼 프로그램을 실행하지 않고 코드만 분석하는 정적 분석으로는 race를 잡을 수 없다. (race는 타이밍 관련 문제니까.)

---

## 막힌 점 / 다음에 볼 것
> (작성)
