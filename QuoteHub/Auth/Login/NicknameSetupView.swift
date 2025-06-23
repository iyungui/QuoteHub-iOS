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
    
    @Environment(UserAuthenticationManager.self) private var authManager
    @Environment(UserViewModel.self) var userViewModel
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel
    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    
    private let authService = AuthService.shared
    
    init(initialNickname: String) {
        self.initialNickname = initialNickname
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            
            // 제목
            HStack {
                Text("닉네임을 설정해주세요")
                    .font(ScoreDreamFont.font(.medium, size: .title1))
                    .fontWeight(.black)
                    .padding(.top)
                Spacer()
            }
            .padding(.leading, 50)
            
            // 설명
            HStack {
                Text("나중에 설정에서 변경할 수 있어요")
                    .font(.scoreDreamBody)
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
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: nickname) { _, _ in
                            // 닉네임이 변경되면 체크 상태 초기화
                            isNicknameChecked = false
                            feedbackMessage = ""
                        }
                    
                    // 랜덤 닉네임 버튼
//                    Button(action: generateRandomNickname) {
//                        if isGeneratingNickname {
//                            ProgressView()
//                                .scaleEffect(0.8)
//                        } else {
//                            Text("🎲")
//                                .font(.title2)
//                        }
//                    }
//                    .frame(width: 44, height: 44)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//                    .disabled(isGeneratingNickname)
                    
                    // 중복확인 버튼
                    Button(action: checkNicknameDuplicate) {
                        if isCheckingNickname {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("중복확인")
                                .font(.scoreDream(.medium, size: .subheadline))
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(nickname.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(nickname.isEmpty || isCheckingNickname)
                }
                .padding(.horizontal, 50)
                
                // 피드백 메시지
                HStack {
                    if !feedbackMessage.isEmpty {
                        Text(feedbackMessage)
                            .font(.scoreDream(.regular, size: .caption))
                            .foregroundColor(feedbackColor)
                    }
                    Spacer()
                }
                .padding(.horizontal, 50)
                .frame(height: 20)
            }
            
            Spacer()
            
            // 다음 버튼
            Button(action: completeNicknameSetup) {
                Text("다음")
                    .font(.scoreDream(.extraBold, size: .medium))
                    .foregroundColor(.white)
                    .frame(width: 280, height: 60, alignment: .center)
                    .background(isNicknameChecked ? Color.black : Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .padding(.bottom, 10)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!isNicknameChecked)
            
            // 건너뛰기 버튼
            Button(action: skipNicknameSetup) {
                Text("건너뛰기")
                    .font(.scoreDream(.regular, size: .callout))
                    .underline()
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .onAppear {
            nickname = initialNickname
        }
        .progressOverlay(viewModel: authManager, opacity: true)
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
        // 닉네임 변경 API 호출 후 데이터 로딩 및 라이브러리뷰로 이동
        authManager.isLoading = true
        
        Task {
            do {
                let _ = try await authService.changeNickname(nickname)
                
                // 닉네임 변경 성공 후 사용자 데이터 로딩
                await loadLoginUserData()
                
                await MainActor.run {
                    authManager.completeLoginProcess()
                }
            } catch {
                await MainActor.run {
                    authManager.isLoading = false
                    feedbackMessage = "닉네임 변경에 실패했습니다"
                    feedbackColor = .red
                }
            }
        }
    }
    
    private func skipNicknameSetup() {
        authManager.isLoading = true
        
        Task {
            // 건너뛰기해도 사용자 데이터는 로딩
            await loadLoginUserData()
            
            await MainActor.run {
                authManager.completeLoginProcess()
            }
        }
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
    NicknameSetupView(initialNickname: "테스트닉네임")
        .environment(UserAuthenticationManager())
        .environment(UserViewModel())
        .environment(MyBookStoriesViewModel())
        .environment(PublicBookStoriesViewModel())
        .environment(MyThemesViewModel())
}
