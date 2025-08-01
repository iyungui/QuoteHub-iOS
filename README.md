# 문장모아 (QuoteHub)
## iOS App Development

### Version 1.0 (2023.10)
Backend Server: Node.js

문장모아(QuoteHub)는 저의 첫 번째 iOS 앱개발 프로젝트입니다. 

사용자들이 책에서 인상 깊었던 문장을 기록하고, 다른 독자들과 공유하며 소통하는 커뮤니티 플랫폼을 구축하는 데 중점을 두었습니다. 

아직 미흡한 부분이 있으나, 이 프로젝트를 통해 처음으로 iOS 개발자로서 필요한 다양한 기술을 습득하고 적용해 볼 수 있었습니다. 

개발 과정, 사용된 기술, 그리고 향후 발전 방향을 제시하여 저의 성장 과정을 보여드리고자 합니다. 

자세한 내용은 [노션](https://silicon-distance-ef3.notion.site/1ebf678b2fe28144b7c1ed561be284d7?pvs=4)에서 pdf 문서 파일을 통해 확인할 수 있습니다.

## **프로젝트 목표 및 개요**

문장모아는 책을 읽으며 마음에 와닿았던 문장을 기록하고, 다른 사람들과 함께 공유하는 공간을 만들고자 하는 아이디어에서 출발했습니다. 

단순한 문장 저장 기능을 넘어, 사용자들이 서로의 생각에 공감하고, 더욱 풍부한 독서 경험을 나눌 수 있도록 지원하는 것을 목표로 하였습니다. 


## **주요 학습 내용 및 적용 기술**

### **SwiftUI를 사용한 UI/UX 개발**

앱의 사용자 인터페이스는 SwiftUI로 개발했습니다. 최신 Apple 디자인 트렌드를 반영하고, 선언형 프로그래밍 방식의 장점을 활용하여 개발 생산성을 향상시킬 수 있었습니다.
`Text`, `Image`, `List`, `ScrollView`와 같은 다양한 SwiftUI 컴포넌트와 `.padding()`, `.font()`, `.foregroundColor()` 등의 주요 모디파이어를 사용하여 사용자 인터페이스를 구성하고 스타일을 적용했습니다. 또한, `HStack`, `VStack`, `ZStack`, `Spacer()`를 활용하여 화면의 다양한 요소를 배치하고 정렬하는 방법을 익힐 수 있었습니다.
특히,  `NavigationStack`와 `TabView`를 사용하여 처음 앱의 구조를 설계하고, `@State`와 `@Binding`, `@StateObject`을 통해 SwiftUI에서 화면이동 간에 데이터를 어떻게 전달해야하는지 이해할 수 있게되었습니다.

### **HIG, 앱스토어 배포 가이드라인**

처음 디자인부터 배포까지 해본 경험인 만큼 앱 배포에 성공하기 위해 여러가지 노력을 진행하였는데, 우선 앱 디자인 전반에 걸쳐 Apple의 Human Interface Guidelines를 철저히 준수하고자 노력했습니다. 또한, 소셜 로그인 + 게스트로그인을 구현하여 사용자가 로그인을 하지 않아도 앱을 바로 이용할 수 있게하고, 커뮤니티 기능이 있는 앱 특성 상 차단/신고 기능을 구현해야 하는 것도 놓치지 않았습니다.

### **MVVM 아키텍처** 
앱 아키텍처는 MVVM (Model-View-ViewModel) 디자인 패턴을 채택했습니다. 덕분에 코드의 모듈성을 높이고, UI 로직과 비즈니스 로직을 분리하여 유지보수성과 테스트 용이성을 향상시킬 수 있었습니다. (향후 앱 규모가 커지더라도 안정적으로 확장할 수 있는 기반을 마련하고자 노력했습니다.)

이 외에도,
* **Figma를 사용한 UI/UX 디자인:** Figma를 활용하여 앱의 UI/UX 디자인을 설계하고 프로토타입을 제작했습니다. 개발 초기 단계에서 사용자 경험을 미리 시각화하고, 팀원 및 잠재 사용자로부터 피드백을 수집하여 디자인을 개선하는 데 활용했습니다.
* **오픈소스 라이브러리 활용:** 웹 이미지 표시를 위한 SDWebImageSwiftUI, 서버 통신을 위한 Alamofire를 사용하는 등 주요 오픈소스 라이브러리를 사용해보는 경험을 가졌습니다. 이와 함께 Swift Package Manager 의존성 관리 도구에 대한 이해도 넓혔습니다.
* 서버 호스팅은 AWS EB를 통해서 배포하였는데, 이 때 http, https 에 대한 이해, http에서 https로 전환하기 위해 무엇을 해야하는 지를 이해하게 되었습니다.
  
### **구현된 주요 기능**

문장모아의 주요 기능입니다!

* **로그인/게스트 로그인 기능** 
사용자가 처음 앱을 시작할 때 사용자 경험을 향상 시킬 수 있도록 온보딩 뷰를 개발하고, 게스트로그인(로그인 없이 사용)을 구현했습니다. 소셜 로그인의 경우, Apple 로그인으로 구현했습니다. 처음 백엔드 개발 당시, passport를 사용하지 않아 소셜 로그인 구현을 하나하나 구현하는 데 다소 어려움을 겪어, 제한된 개발 기간의 이유로 애플 로그인 우선 구현을 채택했습니다. (소셜 로그인만 한다면 애플로그인이 최우선이었기 때문입니다)

* **메인화면**
로그인 후 처음 시작하는 뷰에는 TabView를 사용하였고, 각 섹션은 메인화면, 사용자 프로필, 도서 검색(북스토리 추가)으로 구성하였습니다. 특히 북스토리 추가버튼을 누르면, 커스텀 시트가 나오도록 구현하였는데 -- (이 때 presentationDetents 는 사용하지 않고, ZStack으로 구현했습니다)

* **북스토리 및 공유:** 사용자들이 책에서 영감을 받은 문장 (quote)을 기록하고, 다른 사람들도 자신의 스토리를 메인 홈에서 볼 수 있도록 하였습니다. (비공개 글은 자신만 보이도록 했습니다.) 텍스트뿐만 아니라 이미지와 함께 문장을 기록하고 공유할 수 있도록 하였습니다. (이미지를 보낼 때는 multipart form data 사용했습니다)
  
* **사용자 프로필 라이브러리 관리:** **사용자가 자신의 기록을 "테마"와 "키워드"로 분류해서 관리할 수 있도록 하였습니다. 이를 통해 많은 데이터가 있더라도 키워드 검색이나 테마 별로 정리되어 직관적으로 보이게하도록 노력했습니다.** 다시 말해, 관심 있는 책의 문장을 모아 자신만의 라이브러리를 구축할 수 있는 기능을 제공하고자 했습니다. 또한 타사용자 프로필을 친구 추가하여, 서로의 스토리를 공유할 수 있는 장을 마련하고자 했습니다.
  
* **도서 검색 기능:** 앱 내에서 원하는 책을 검색하고,(백엔드에서는 카카오 검색 API를 가져와서 구현했습니다.) 해당 책에 대한 정보를 얻을 수 있는 기능을 구현했습니다. 이 때 책이 검색되는 정보가 많아, 데이터를 한 번에 부르게 되면 과부하가 오거나 사용자 경험을 저해할 수 있다고 판단했습니다. 백엔드에서 반환하는 json 데이터를 페이지네이션으로 전환 후, SwiftUI에서는 LazyVStack과 스크롤뷰, 그리고 스크롤을 하다가 하단의 마지막 데이터에 도달했을 때, 다음 데이터(검색결과)를 가져올 수 있도록 구현했습니다. - 즉 무한 스크롤을 구현했습니다.
  
* **커뮤니티 기능 (신고 기능):** 앱스토어 배포 가이드라인에 명시된, 부적절한 게시물을 신고/차단하는 기능도 포함했습니다.

**스크린샷:**

<table>
<tr>
<td align="center"><img src="https://github.com/user-attachments/assets/a24a96c3-8b35-4c7a-b246-bae32aba1537" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/6520d256-f163-471f-84e0-bdb10efa35af" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/001a7aea-46b3-4553-b9e6-44ceea733a80" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/f9a99100-54f6-42d3-bbf6-76ac66ed3c12" width="200"></td>
</tr>
<tr>
<td align="center"><img src="https://github.com/user-attachments/assets/c236d30c-c20f-4357-b002-dfd22d992b90" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/5c51373c-cf79-4a84-80de-ad5c2db62c70" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/5b19fb5b-d47b-4085-bdea-58b75822fc93" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/98d0bbe8-022a-483a-8b6e-d32cd8b44f8c" width="200"></td>
</tr>
<tr>
<td align="center"><img src="https://github.com/user-attachments/assets/52383d08-5ea6-4d3b-8fa6-bd38d1838c8e" width="200"></td>
<td align="center"><img src="https://github.com/user-attachments/assets/228931f1-e4bc-46b7-bcb6-3d8afcdb8cbb" width="200"></td>
</tr>
</table>

**향후 개발 계획:** (아직 구현하지는 못한 상태)

* **이미지에서 텍스트 추출 기능 OCR:** OCR 기술을 통합하여 사용자가 이미지에서 텍스트를 추출하고, 추출된 텍스트를 기반으로 문장을 기록할 수 있도록 기능을 확장할 계획입니다.
* **UI/UX 디자인 개선
* **AI 기능 추가:**
    * **책 추천 기능:** 사용자의 독서 기록과 취향을 분석하여 맞춤형 책 추천 기능을 제공하고, 사용자가 새로운 책을 발견하도록 도우는 기능
    * **책 내용 요약 기능:** 책의 주요 내용을 요약하는 기능을 제공하여 사용자가 시간을 절약하고, 효율적으로 독서할 수 있도록 지원
* **Localizable 기능 확장:** 현재 지원하는 언어 외에 중국어, 영어, 아랍어 등 더 많은 언어를 지원하도록 Localizable 기능을 확장
* **손쉬운 사용 기능 추가:** 장애를 가진 사용자들도 불편함 없이 앱을 사용할 수 있도록 손쉬운 사용 기능을 추가하여 앱의 접근성을 향상


"문장모아"는 iOS 개발자로서 저의 성장 가능성을 보여주는 첫걸음이라고 생각합니다. 
이 프로젝트를 통해 Swift, SwiftUI, iOS 개발 프로세스 전반에 대한 깊은 이해를 얻었으며, 앞으로 더 발전된 앱을 개발할 수 있다는 자신감을 얻었습니다. 앞으로도 사용자 중심의 혁신적인 앱을 개발하고, iOS 개발 커뮤니티에 기여하는 개발자로 성장해 나가겠습니다.

---

### Version 2.0 (2025.05.25 ~ 2025.07.01) - 37일간 전면 리팩토링

기존 문장모아 앱을 새롭게 리뉴얼했습니다.


## 🔧 **핵심 개선사항**

### **불필요한 기능 제거 및 핵심 기능 강화**
- **[중요하지 않은 기능 삭제]**: 팔로우 기능이나 유저 검색 기능은 필요하지 않은 기능이라 생각되어 삭제했습니다. 대신 이미 구현된 기능을 제대로 다시 설계하는 데 집중했습니다.

### **외부 의존성 최적화**
- **[필요하지 않는 외부 라이브러리 삭제]**: Alamofire 라이브러리를 굳이 사용할 이유가 없었습니다. URLSession으로도 네트워크 호출을 하기에 충분했기에 변경했습니다.

### **UI/UX 전면 재설계**
- **[화면을 아예 새롭게 디자인]**: 이 과정에서 모든 코드를 하나씩 고쳐갔습니다. 유지보수성을 높이기 위해서 여러가지 시도를 했는데, 이 중 **뷰 화면을 작은 단위로 나누는 것**이 가장 큰 도움이 되었습니다. 수정할 부분이 생기면 그 부분만 빠르게 캐치하여 수정이 가능하기 때문입니다.

- LoadingView나 ProfileView 처럼 **여러 화면에서 공통으로 사용하는 UI를 하나로 하기 위해** 여러가지 시도를 했고, 그 과정에서 시행착오도 있었습니다.

```swift
// ViewModifier로 재사용성 극대화 (CustomProgressView.swift)
struct ProgressOverlay<VM: LoadingViewModel>: ViewModifier {
    @ObservedObject var viewModel: VM
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if viewModel.isLoading {
                    CustomProgressView(message: viewModel.loadingMessage)
                        .transition(.opacity)
                }
            }
    }
}

extension View {
    func progressOverlay<VM: LoadingViewModel>(viewModel: VM) -> some View {
        self.modifier(ProgressOverlay(viewModel: viewModel))
    }
}
```

### **컴포넌트 기반 개발 체득**
- **ViewBuilder 뿐만 아니라, modifier를 extension 하여** 모든 뷰에서 같은 컴포넌트를 사용하는 방법을 체득했습니다. 이 과정을 통해 **코드의 재사용성을 크게 높이고 개발 속도도 크게 향상**시킬 수 있었습니다.

### **사용자 경험 중심의 반복 개선**
- **어떻게 해야 사용자 입장에서 좀 더 편한 UI를 느끼게 할 수 있을까**를 끊임없이 고민했습니다. 화면을 완성하고 여러번 처음부터 다시 작성하는 과정도 있어서, 시간이 꽤 오래걸렸습니다. 

- 그러나 그 과정에서 **화면을 짜는 저만의 방법**(대표적으로 입력화면을 설계할 때, 뷰모델에 입력 프로퍼티를 먼저 정의하고 입력값 제한이나 alert 등을 하나씩 뷰와 함께 설계해나가는 방법)부터, **AI를 사용하여 빠르고 정확하게 구체적으로 원하는 화면을 구현하는 능력**도 향상시킬 수 있었습니다.

```swift
// 실시간 키워드 입력 처리 (StoryFormViewModel.swift)
func processInlineKeywordInput(_ newValue: String) {
    if newValue.contains(" ") || newValue.contains("\n") {
        addInlineKeyword(from: newValue)
    }
}

private func isValidInlineKeyword(_ keyword: String) -> Bool {
    return keyword.count <= keywordMaxLength &&
           !keywords.contains(keyword) &&
           keywords.count < 10
}
```

- 대표적으로 **인스타그램에서 자주 볼 수 있는 UI(Sticky Header)를 구현**하는 데에는 AI의 도움을 많이 받았습니다. 이미 어느정도 구조화된 틀이 있었고, 각각의 코드가 무엇을 의미하는지 이해하고 있었기에 **디버깅을 하는 시간도 크게 단축**시킬 수 있었습니다.

```swift
// Sticky Header 핵심 로직 (LibraryBaseView.swift)
private func updateStickyState(currentY: CGFloat) {
    let safeAreaTop = getSafeAreaTop()
    let shouldShowSticky = currentY <= safeAreaTop + 44
    
    if shouldShowSticky != stickyTabVisible {
        withAnimation(.none) {
            stickyTabVisible = shouldShowSticky
        }
    }
}
```

---

## **핵심 기술 도전과 해결**

### **Race Condition 해결 과정**
**가장 큰 고민을 했던 부분은 바로 Race Condition이 발생하지 않도록 어떻게 설계해야할까?** 입니다.

#### **문제 발견**
문장모아는 1.0 버전을 설계했을 당시 북스토리를 fetch를 할 때, 모든 사용자의 공개된 북스토리 불러오기, 특정 사용자의 북스토리 불러오기, 그리고 자신(인증된 사용자)의 북스토리 불러오기로 나누어서 설계했습니다. 

이 때 뷰코드도, 네트워크 요청 코드도 모두 중복이 되는 코드가 많았기에, **enum으로 LoadType을 설계하고 딕셔너리로 `var bookStories: [LoadType: [BookStory]]` 이렇게 설계**했습니다. 즉 public bookstories viewmodel, my bookstories viewmodel, friend book stories viewmodel을 따로따로 만들지 않고, **하나의 북스토리 뷰모델로 만드려는 시도**를 했습니다.

#### **문제 발생**
그러나 화면을 왔다갔다 하는 과정에서, 여러번 LoadType에 따라 북스토리를 로드하는 과정이 있었고, **이 때 레이스 컨디션이 발생**했습니다.

#### **해결 과정**
저는 이렇게 나눈 방식이 잘못되었다는 것을 깨닫고, **다시 역할과 책임 분리를 시도**했습니다. 그 과정에서 **protocol을 사용하여, 코드의 유지보수성을 높이고 실수를 최대한 줄이기 위해** 노력했습니다.

```swift
// 프로토콜 기반 역할과 책임 분리 (BookStoriesViewModelProtocols.swift)

// 기본 읽기 전용 프로토콜
protocol BookStoriesViewModelProtocol: LoadingViewModel {
    var bookStories: [BookStory] { get }
    func loadBookStories() async
    func refreshBookStories() async
}

// CRUD 확장 프로토콜 (내 뷰모델만)
protocol EditableBookStoriesViewModelProtocol: BookStoriesViewModelProtocol {
    func createBookStory(...) async -> BookStory?
    func updateBookStory(...) async -> BookStory?
    func deleteBookStory(storyId: String) async -> Bool
}

// 명확한 구분을 위한 Typealias
typealias ReadOnlyBookStoriesViewModel = BookStoriesViewModelProtocol
typealias EditableBookStoriesViewModel = EditableBookStoriesViewModelProtocol
```

### **Swift Concurrency 전면 도입**
**또 하나 이번 프로젝트를 하면서 가장 저 자신에게 칭찬하고 싶은 부분은 바로 동시성 프로그래밍 활용입니다.**

#### **목표 설정**
이번 리팩토링은 **Swift Concurrency (async, await, Task)를 최대한 활용하는 것**이 목표였습니다. 기존 1.0 코드는 completion Handler와 Result 타입으로 네트워크를 호출하는 코드가 각각 뷰모델에 작성되어 있었습니다.

#### **네트워크 레이어 통합**
이 동시성 프로그래밍을 적용하기 전에 여러 과제가 있었는데, 먼저 각 서비스 파일에서도 AF.request를 호출하는 코드가 중복되어 있었습니다. '**코드의 중복성을 줄이고 async await 패턴으로 보다 간결하고 가독성 좋은 코드를 만들자**'가 이번 리팩토링 목표 중 하나였습니다.

- 이 **네트워크 요청 메서드를 APIClient.swift 파일 하나로 작성**하고, JSON을 파싱하는 코드와 네트워크 요청 제네릭 메서드를 만들어서, 각 서비스 파일에서 URLSession을 호출하는 코드를 작성했습니다. 이 과정을 통해 **이전보다 매우 효율적으로 네트워크 호출 부분을 리팩토링**했다고 확신하고 있습니다.

#### **병렬 처리 최적화**
- 나아가 서비스 레이어와 뷰모델 레이어를 리팩토링 하고, 각 뷰모델에ㅔ서 메서드를 호출할 때에는 단순히 await로 각 화면에서 호출하고 결과를 반환하도록 하였습니다. 예를 들어 라이브러리뷰로 가면 프로필 로드를 하고, 북스토리를 불러오는 로직을 실행하는 로직을 async await 패턴으로 구현했습니다.

- 특히 **앱을 처음 실행할 때 즉, LaunchScreen이 잠깐 나타날 때 그 때 taskgroup으로 메서드를 병렬로 호출하여 여러 데이터를 동시에 불러오도록 했습니다.** (이는 각 메서드에서 처리하는 것이 독립적인 데이터일 때. 즉 데이터 레이스가 발생하지 않을 때 호출하였습니다.)

```swift
// TaskGroup을 활용한 병렬 데이터 로딩 (ContentView.swift)
struct ContentView: View {
    @State private var isSplashView = true  // 런치스크린 표시
    
    var body: some View {
        if isSplashView {
            LaunchScreenView()
                .task {
                    // 각 작업이 독립적이므로 병렬 실행
                    await withTaskGroup(of: Void.self) { group in
                        // 현재 앱스토어 버전 확인
                        group.addTask {
                            await versionManager.checkVersionFromAppStore()
                        }
                        // 인증 확인
                        group.addTask {
                            await authManager.validateAndRenewTokenNeeded()
                        }
                    }
                    
                    // 인증된 사용자는 프로필, 내 북스토리와 내 테마 불러오기
                    if authManager.isUserAuthenticated {
                        await withTaskGroup(of: Void.self) { group in
                            // 현재 사용자 정보 가져오기 (유저모델의 currentUser 업데이트)
                            group.addTask {
                                await userViewModel.loadUserProfile(userId: nil)
                            }
                            // 현재 사용자 정보의 북스토리 카운트도 동시에 가져오기
                            group.addTask {
                                await userViewModel.loadStoryCount(userId: nil)
                            }
                            group.addTask {
                                await myBookStoriesViewModel.loadBookStories()
                            }
                            group.addTask {
                                await myThemesViewModel.loadThemes()
                            }
                        }
                    }
                    
                    // 모든 사용자가 공통으로 보는 공개 북스토리와 테마 불러오기
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await publicBookStoriesViewModel.loadBookStories()
                        }
                        group.addTask {
                            await publicThemesViewModel.loadThemes()
                        }
                    }
                    
                    // 데이터 로딩 완료 후 스플래시 화면 종료
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    withAnimation {
                        isSplashView = false
                    }
                }
        } else {
            // 메인 앱 화면
            MainView()
        }
    }
}
```


#### **Task.detached 활용**
UserAuthenticationManager에서는 **Task.detached를 사용해서 토큰 관련 로직을 백그라운드 스레드에서 실행**되도록 보장했습니다. Task.detached는 독립적인 컨텍스트에서 실행되도록 하는데, **@MainActor에서 컨텍스트가 상속되기 때문에, 토큰 관련 로직을 백그라운드에서 실행시키고 싶다면 Task.detached를 사용해야** 했습니다.

토큰 관리가 시간이 오래 걸리는 작업은 아니지만 **UI 관련된 로직이 아니기에 분리를 해야한다고 생각**해서 설계했습니다. 이 부분에 부족한 점이나 틀린 점이 있다면 피드백 부탁드립니다.

```swift
                // 새 토큰 Keychain에 업데이트
                Task.detached { // 토큰 저장 완료되면 Task는 자동으로 메모리에서 해제
                    try? await self.authService.updateBothTokens(
                        newAccessToken: newAccessToken,
                        newRefreshToken: newRefreshToken
                    )
                }
```

---

## 📱 **현재 상태**

문장모아 2.0은 현재 아래 링크를 통해 **앱스토어에서도 만나볼 수 있습니다**. 혼자서 애정을 가지고 다듬고 있는 프로젝트입니다. 

[AppStore](https://apps.apple.com/kr/app/%EB%AC%B8%EC%9E%A5%EB%AA%A8%EC%95%84/id6469527373?l=en-GB)

그러나 **잘못된 부분이 있다면, 개선의 여지가 있다면 어김없이 제 코드를 바꾸고 개선해나갈 마음가짐**이 있습니다. 피드백 주시면 감사하겠습니다!

