# QuoteHub 심화 학습 로그

> 목표: AI가 짜준 코드를 **내 언어로 100% 설명할 수 있는 상태**로 만든다.
> 방법: 설명(CS) → 도구로 증명 → 내가 직접 수정·검토 → 단위별 md 기록 → 피드백

각 단위는 "도구로 증명"을 반드시 거친다. 말로 아는 것은 아는 게 아니다.

## 진행 현황

| Phase | 단위 | 주제 | 교재(내 코드) | 도구 | 상태 |
|---|---|---|---|---|---|
| 0 | 0.1 | Sanitizer/Checker란 무엇인가 | xcscheme | TSan, Main Thread Checker | 🔄 진행중 |
| 0 | 0.2 | Breakpoint & LLDB 기본기 | - | LLDB | ⬜ |
| 0 | 0.3 | View / Memory Graph Debugger | - | Xcode Debugger | ⬜ |
| 1 | 1.1 | data race vs race condition vs ordering | UserViewModel, AuthManager | TSan | ⬜ |
| 2 | 2.1 | Task vs Task.detached, self 캡처 | UserAuthenticationManager | Memory Graph | ⬜ |
| 3 | 3.1 | 토큰 갱신 stampede → single-flight | APIClient | TSan + 로그 | ⬜ |
| 4 | 4.1 | "가짜 await" 고치기 | LaunchScreenView + PublicBookStoriesViewModel | Breakpoint | ⬜ |
| 5 | 5.1 | 메모리 누수 / retain cycle | ViewModel, Task | Instruments(Leaks) | ⬜ |
| 6 | 6.1 | 뷰 identity와 렌더링 | (재선정 예정 — `.id` 이슈는 리팩토링으로 해소됨) | Time Profiler | ⬜ |
| 7 | 7.1 | 테스트 제대로 (Mock 살리기) | BookStoryServiceTests | XCTest | ⬜ |
| 8 | 8.1 | release-notes 재작성 | v2.0-release-notes | (증거 스크린샷) | ⬜ |

상태: ⬜ 예정 / 🔄 진행중 / ✅ 완료(내 언어 설명 통과)
