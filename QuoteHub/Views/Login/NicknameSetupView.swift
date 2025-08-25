//
//  NicknameSetupView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import SwiftUI

struct NicknameSetupView: View {
    let initialNickname: String
    
    @State private var nickname: String = ""
    @State private var isNicknameChecked: Bool = false
    @State private var feedbackMessage: String = ""
    @State private var feedbackColor: Color = .gray
    @State private var isCheckingNickname: Bool = false
    @State private var isGeneratingNickname: Bool = false
    @State private var wantsExampleBookStoryData: Bool = false
    
    @Environment(UserAuthenticationManager.self) private var authManager
    @Environment(UserViewModel.self) var userViewModel
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel
    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    
    private let authService = AuthService.shared
    private let sampleDataManager = SampleDataManager()
    
    init(initialNickname: String) {
        self.initialNickname = initialNickname
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 10) {
                Spacer()
                // 제목
                HStack {
                    Text("닉네임을 설정해주세요")
                        .font(.appTitle)
                        .padding(.top)
                    Spacer()
                }
                .overlay(alignment: .topLeading) {
                    Image(systemName: "quote.bubble")
                        .font(.title2)
                        .foregroundColor(.appAccent)
                        .rotationEffect(.degrees(-15))
                        .offset(y: -25)
                }
                .padding(.leading, 50)

                // 설명
                HStack {
                    Text("나중에 설정에서도 변경할 수 있어요")
                        .font(.appBody)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.leading, 50)
                
                Spacer().frame(height: 20)
                
                // 닉네임 입력 영역
                VStack(spacing: 10) {
                    // 텍스트필드와 버튼들
                    HStack(spacing: 10) {
                        TextField("닉네임을 입력하세요", text: $nickname)
                            .font(.appFont(.regular, size: .subheadline))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: nickname) { _, _ in
                                // 닉네임이 변경되면 체크 상태 초기화
                                isNicknameChecked = false
                                feedbackMessage = ""
                            }
                        
                        // 중복확인 버튼
                        Button(action: checkNicknameDuplicate) {
                            Text("중복확인")
                                .font(.appFont(.regular, size: .subheadline))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(nickname.isEmpty ? Color.gray.opacity(0.3) : Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(nickname.isEmpty || isCheckingNickname)
                    }
                    .padding(.horizontal, 50)
                    
                    // 피드백 메시지
                    HStack {
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(.appFont(.regular, size: .caption))
                                .foregroundColor(feedbackColor)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .frame(height: 20)
                }
                
                Spacer()
                
                Toggle(isOn: $wantsExampleBookStoryData) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("예시 북스토리와 함께 시작할까요?")
                                .font(.appFont(.regular, size: .footnote))
                            
                            Text("추천")
                                .font(.appFont(.bold, size: .caption2))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appAccent)
                                .cornerRadius(4)
                            
                        }
                        Text("처음에 앱을 쉽게 둘러볼 수 있도록,\n샘플 북스토리를 넣어드릴게요.")
                            .font(.appFont(.light, size: .caption))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 50)
                .toggleStyle(CheckboxStyle())
                
                // 다음 버튼
                Button(action: completeNicknameSetup) {
                    Text("다음")
                        .font(.appFont(.extraBold, size: .medium))
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60, alignment: .center)
                        .background(isNicknameChecked ? Color.black : Color.gray.opacity(0.6))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!isNicknameChecked)
                .padding(.top)

                // 건너뛰기 버튼
                Button(action: skipNicknameSetup) {
                    Text("건너뛰기")
                        .font(.appFont(.regular, size: .callout))
                        .underline()
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .toolbar {
                Button {
                    completeNicknameSetup()
                } label: {
                    Text("다음")
                        .font(.appBody)
                }
                .disabled(!isNicknameChecked)
            }
            // 메인 VStack에 적용할 배경
            .backgroundGradient()
            .onAppear {
                nickname = initialNickname
            }
            .progressOverlay(viewModel: authManager, opacity: true)
        }
    }
    
    // MARK: - Actions
    
    private func generateRandomNickname() {
        isGeneratingNickname = true
        
        Task {
            do {
                let response = try await authService.generateUniqueNickname()
                
                await MainActor.run {
                    if response.success, let data = response.data {
                        nickname = data.nickname
                        isNicknameChecked = false
                        feedbackMessage = ""
                    }
                    isGeneratingNickname = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingNickname = false
                    feedbackMessage = "닉네임 생성에 실패했습니다"
                    feedbackColor = .red
                }
            }
        }
    }
    
    private func checkNicknameDuplicate() {
        isCheckingNickname = true
        
        Task {
            do {
                let response = try await authService.checkNickname(nickname, withAuth: true)
                
                await MainActor.run {
                    if response.success, let data = response.data {
                        if data.available {
                            feedbackMessage = "사용 가능한 닉네임입니다"
                            feedbackColor = .blue
                            isNicknameChecked = true
                        } else {
                            feedbackMessage = "이미 사용 중인 닉네임입니다"
                            feedbackColor = .red
                            isNicknameChecked = false
                        }
                    }
                    isCheckingNickname = false
                }
            } catch {
                await MainActor.run {
                    isCheckingNickname = false
                    feedbackMessage = "중복확인에 실패했습니다"
                    feedbackColor = .red
                    isNicknameChecked = false
                }
            }
        }
    }
    
    private func completeNicknameSetup() {
        authManager.isLoading = true
        authManager.loadingMessage = wantsExampleBookStoryData ?
        "계정 설정 및 예시 데이터 생성 중..." : "계정 설정 중..."
        
        Task {
            do {
                // 1. 닉네임 변경
                let _ = try await authService.changeNickname(nickname)
                
                // 2. 예시 데이터 생성 (선택적)
                if wantsExampleBookStoryData {
                    await createSampleData()
                }
                
                // 3. 사용자 데이터 로딩
                await loadLoginUserData()
                
                await MainActor.run {
                    authManager.completeLoginProcess()
                }
            } catch {
                await MainActor.run {
                    authManager.isLoading = false
                    authManager.loadingMessage = nil
                    feedbackMessage = "닉네임 변경에 실패했습니다"
                    feedbackColor = .red
                }
            }
        }
    }
    
    private func skipNicknameSetup() {
        authManager.isLoading = true
        authManager.loadingMessage = wantsExampleBookStoryData ?
        "예시 데이터 생성 중..." : "데이터 로딩 중..."
        
        Task {
            // 예시 데이터 생성 (선택적)
            if wantsExampleBookStoryData {
                await createSampleData()
            }
            
            // 사용자 데이터 로딩
            await loadLoginUserData()
            
            await MainActor.run {
                authManager.goToLibraryView()   // 폰트 설정 화면도 스킵
            }
        }
    }
    
    // MARK: - 샘플 데이터 생성
    
    private func createSampleData() async {
        // 1. 샘플 테마 생성
        guard let sampleTheme = await createSampleTheme() else {
            return
        }
        
        // 2. 샘플 북스토리들 생성
        await createSampleBookStories(themeId: sampleTheme.id)
    }
    
    private func createSampleTheme() async -> Theme? {
        guard let themeData = sampleDataManager.getSampleThemeData() else {
            print("❌ JSON에서 테마 데이터를 로드할 수 없습니다.")
            return nil
        }
        
        return await myThemesViewModel.createTheme(
            image: loadImageFromBundle(themeData.imageName),
            name: themeData.name,
            description: themeData.description,
            isPublic: false
        )
    }
    
    private func createSampleBookStories(themeId: String) async {
        let bookStoriesData = sampleDataManager.getSampleBookStoriesData()
        
        guard !bookStoriesData.isEmpty else {
            print("❌ JSON에서 북스토리 데이터를 로드할 수 없습니다.")
            return
        }
        
        var successCount = 0
        
        for (index, bookStoryData) in bookStoriesData.enumerated() {
            print("📚 북스토리 \(index + 1)/\(bookStoriesData.count) 생성 중...")
            
            // 이미지 로드
            let images = bookStoryData.imageNames?.compactMap { imageName in
                loadImageFromBundle(imageName)
            }
            
            // 북스토리 생성
            let result = await myBookStoriesViewModel.createBookStory(
                bookId: bookStoryData.bookId,
                quotes: bookStoryData.quotes,
                images: images?.isEmpty == true ? nil : images,
                content: bookStoryData.content,
                isPublic: false,
                keywords: bookStoryData.keywords,
                themeIds: [themeId]
            )
            
            if result != nil {
                successCount += 1
                print("✅ 샘플 북스토리 \(index + 1) 생성 완료")
            } else {
                print("❌ 샘플 북스토리 \(index + 1) 생성 실패")
            }
            
            // 서버 부하 방지를 위한 딜레이
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
        }
    }
    
    private func loadImageFromBundle(_ imageName: String?) -> UIImage? {
        guard let imageName = imageName else { return nil }
        return UIImage(named: imageName)
    }
    
    private func loadLoginUserData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userViewModel.loadUserProfile(userId: nil)
            }
            group.addTask {
                await userViewModel.loadStoryCount(userId: nil)
            }
            group.addTask {
                await myBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await publicBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await myThemesViewModel.loadThemes()
            }
        }
    }
}

#Preview {
    NicknameSetupView(initialNickname: "")
        .environment(UserAuthenticationManager())
        .environment(UserViewModel())
        .environment(MyBookStoriesViewModel())
        .environment(PublicBookStoriesViewModel())
        .environment(MyThemesViewModel())
}
