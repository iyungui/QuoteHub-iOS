//
//  CreateThemeView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI

struct CreateThemeView: View {
    
    // MARK: - PROPERTIES
    
    let themeId: String?    // 테마 수정 시 사용
    var isEditMode: Bool { themeId != nil }
    
    enum DisplayMode {
        case fullScreenSheet    // 홈뷰에서 접근했을 때
        case embedded   // record뷰의 setTheme 뷰에서 접근했을 때
    }
    
    let mode: DisplayMode
    
    init(mode: DisplayMode, themeId: String? = nil) {
        self.mode = mode
        self.themeId = themeId
    }
    
    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var formViewModel = ThemeFormViewModel()
    
    // focus
    enum Field: Hashable {
        case title
        case content
    }
    
    @FocusState private var focusField: Field?
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 테마 이미지 카드
                    themeImageCard
                    
                    // 테마 정보 입력 카드
                    themeInfoCard
                    
                    // 설정 카드
                    settingsCard
                    
                    // 하단 여백
                    spacer(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle(isEditMode ? "테마 수정" : "새 테마 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 취소 버튼 (fullScreenSheet 모드에서)
            if mode == .fullScreenSheet {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            
            // 등록 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                submitButton
            }
            
            // 피드백 메시지
            ToolbarItem(placement: .bottomBar) {
                if let message = formViewModel.feedbackMessage, !formViewModel.isFormValid {
                    feedbackView(message: message)
                }
            }
        }
        .task {
            await loadThemeDataIfNeeded()
        }
        .progressOverlay(viewModel: myThemesViewModel, opacity: true)
        .alert(isPresented: $formViewModel.showAlert) { alertView }
        .sheet(isPresented: $formViewModel.showingImagePicker) {
            SingleImagePicker(selectedImage: $formViewModel.inputImage)
                .ignoresSafeArea(.all)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - UI Components
    
    private var submitButton: some View {
        Button(action: submitTheme) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(formViewModel.isFormValid ? .appAccent : .gray)
                    .scaleEffect(formViewModel.isFormValid ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: formViewModel.isFormValid)
                if formViewModel.isFormValid {
                    Text(isEditMode ? "수정" : "등록")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }
    
    private var themeImageCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "테마 이미지", icon: "photo.fill")
            
            VStack(spacing: 16) {
                // 이미지 표시 영역
                imageDisplayArea
                
                // 이미지 선택 버튼
                imageSelectButton
            }
        }
        .padding(20)
        .backgroundCard(cornerRadius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var imageDisplayArea: some View {
        ZStack {
            if let inputImage = formViewModel.inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.paperBeige.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.brownLeather.opacity(0.6))
                            
                            Text("테마 이미지를 선택해주세요")
                                .font(.scoreDream(.light, size: .subheadline))
                                .foregroundColor(.secondaryText)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    )
            }
        }
    }
    
    private var imageSelectButton: some View {
        Button(action: { formViewModel.selectImage() }) {
            HStack(spacing: 12) {
                Image(systemName: formViewModel.inputImage == nil ? "plus.circle.fill" : "arrow.triangle.2.circlepath.circle.fill")
                    .font(.body.weight(.medium))
                    .foregroundColor(.brownLeather)
                
                Text(formViewModel.inputImage == nil ? "이미지 선택" : "이미지 변경")
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondaryText.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
            )
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var themeInfoCard: some View {
        VStack(spacing: 20) {
            // 테마 제목 입력
            VStack(spacing: 16) {
                cardHeader(title: "테마 제목", icon: "textformat", subtitle: "테마의 이름을 입력해주세요")
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .font(.body)
                            .foregroundColor(.brownLeather.opacity(0.7))
                            .frame(width: 20)
                        
                        TextField("예: 인생 명언, 사랑 이야기", text: $formViewModel.title)
                            .focused($focusField, equals: .title)
                            .submitLabel(.next)
                            .onChange(of: formViewModel.title) { _, newValue in
                                formViewModel.validateTitleLength(newValue)
                            }
                            .onSubmit {
                                focusField = .content
                            }
                            .font(.scoreDream(.medium, size: .body))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusField == .title ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: focusField)
                    
                    // 글자수 표시
                    HStack {
                        Spacer()
                        Text("\(formViewModel.titleCount)/\(formViewModel.titleMaxCount)")
                            .font(.scoreDream(.light, size: .caption2))
                            .foregroundColor(formViewModel.titleCount >= formViewModel.titleMaxCount ? .orange : .secondaryText)
                    }
                }
            }
            
            // 테마 설명 입력
            VStack(spacing: 16) {
                cardHeader(title: "테마 설명", icon: "text.quote", subtitle: "테마에 대한 간단한 설명을 입력해주세요")
                
                VStack(spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.paperBeige.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(focusField == .content ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                            .frame(minHeight: 120)
                            .animation(.easeInOut(duration: 0.2), value: focusField)
                        
                        if formViewModel.content.isEmpty {
                            Text("이 테마는 어떤 내용을 담고 있나요?")
                                .font(.scoreDream(.light, size: .body))
                                .foregroundColor(.secondaryText.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $formViewModel.content)
                            .font(.scoreDream(.regular, size: .body))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .focused($focusField, equals: .content)
                            .scrollContentBackground(.hidden)
                            .onChange(of: formViewModel.content) { _, newValue in
                                formViewModel.validateContentLength(newValue)
                            }
                    }
                    
                    // 글자수 표시
                    HStack {
                        Spacer()
                        Text("\(formViewModel.contentCount)/\(formViewModel.contentMaxCount)")
                            .font(.scoreDream(.light, size: .caption2))
                            .foregroundColor(formViewModel.contentCount >= formViewModel.contentMaxCount ? .orange : .secondaryText)
                    }
                }
            }
        }
        .padding(20)
        .backgroundCard(cornerRadius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var settingsCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "공개 설정", icon: "eye.fill")
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formViewModel.isPublic ? "공개 테마" : "비공개 테마")
                        .font(.scoreDream(.medium, size: .body))
                        .foregroundColor(.primaryText)
                    
                    Text(formViewModel.isPublic ? "다른 사용자들도 볼 수 있습니다" : "나만 볼 수 있습니다")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Toggle("", isOn: $formViewModel.isPublic)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.9)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
            )
        }
        .padding(20)
        .backgroundCard(cornerRadius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    private func feedbackView(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.body)
            
            Text(message)
                .font(.scoreDream(.medium, size: .subheadline))
                .foregroundColor(.orange)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.asymmetric(insertion: .opacity, removal: .slide))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: formViewModel.feedbackMessage)
    }
    
    // MARK: - Helper Views
    
    private func cardHeader(title: String, icon: String, subtitle: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundColor(.brownLeather)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                }
            }
            
            Spacer()
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.antiqueGold.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 60)
        }
    }
    
    // MARK: - Methods
    
    private func submitTheme() {
        guard formViewModel.validateForSubmission() else {
            return
        }
        
        Task {
            let themeData = formViewModel.prepareThemeData()
            
            let resultTheme: Theme?
            
            if isEditMode, let themeId = themeId {
                resultTheme = await myThemesViewModel.updateTheme(
                    themeId: themeId,
                    image: themeData.image,
                    name: themeData.name,
                    description: themeData.description,
                    isPublic: themeData.isPublic
                )
            } else {
                resultTheme = await myThemesViewModel.createTheme(
                    image: themeData.image,
                    name: themeData.name,
                    description: themeData.description,
                    isPublic: themeData.isPublic
                )
            }
            
            if resultTheme != nil {
                formViewModel.showSuccessAlert()
            } else {
                formViewModel.showErrorAlert(myThemesViewModel.errorMessage)
            }
        }
    }
    
    private var alertView: Alert {
        switch formViewModel.alertType {
        case .authorized:
            return Alert(title: Text("권한 필요"),
                         message: Text(formViewModel.alertMessage),
                         primaryButton: .default(Text("설정으로 이동"), action: {
                             if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                                UIApplication.shared.canOpenURL(settingsUrl) {
                                 UIApplication.shared.open(settingsUrl)
                             }
                         }),
                         secondaryButton: .cancel()
            )
        case .make:
            return Alert(title: Text("알림"),
                         message: Text(formViewModel.alertMessage),
                         dismissButton: .default(Text("확인"), action: {
                             if formViewModel.alertMessage.contains("성공적으로") {
                                 dismiss()
                             }
                         }))
        }
    }
    
    private func loadThemeDataIfNeeded() async {
        guard let themeId = themeId else {
            return
        }
        
        let loadedTheme = await myThemesViewModel.fetchSpecificTheme(themeId: themeId)
        
        guard let loadedTheme = loadedTheme else {
            formViewModel.showLoadErrorAlert(myThemesViewModel.errorMessage)
            return
        }
        
        formViewModel.loadFromTheme(loadedTheme)
    }
}

#Preview {
    NavigationStack {
        CreateThemeView(mode: .fullScreenSheet)
            .environment(MyThemesViewModel())
    }
}
