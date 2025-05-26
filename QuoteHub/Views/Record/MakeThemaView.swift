//
//  MakeThemaView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI

struct MakeThemaView: View {
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var isPublic: Bool = true

    enum Field: Hashable {
        case title
        case content
    }
    
    enum AlertType {
        case authorized
        case make
    }
    @State private var alertType: AlertType = .authorized
    
    @FocusState private var focusField: Field?
    @State private var feedbackMessage: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    backButton
                    Spacer()
                }
                .padding(10)
                .padding(.leading, 5)
                
                inputThemaImageView
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .clipped()

                contentTextEditor
                Divider()

                publicToggleView
                    .padding(.horizontal)
                    .padding(.vertical, 5)

                Divider()

                imagePickerSection
                
                VStack(alignment:.center) {
                    if let message = feedbackMessage, title.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    registerButton
                }
            }
            .navigationBarTitle("새 테마 만들기", displayMode: .inline)
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .authorized:
                return Alert(title: Text("권한 필요"),
                             message: Text(alertMessage),
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
                             message: Text(alertMessage),
                             dismissButton: .default(Text("확인")))
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showingImagePicker) {
            SingleImagePicker(selectedImage: self.$inputImage)
                .ignoresSafeArea(.all)
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
    
    private var inputThemaImageView: some View {
        ZStack(alignment: .bottom) {
            if let inputImage = inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.4))
            }
            
            titleTextField
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.black.opacity(0.66))
                .foregroundColor(.white)
        }
    }

    private var titleTextField: some View {
        TextField("", text: $title, prompt: Text("어떤 테마로 이야기를 시작할까요?").font(.title3).foregroundColor(.gray))
            .focused($focusField, equals: .title)
            .submitLabel(.next)
            .onSubmit {
                focusField = .content
            }
            .padding(.vertical, 10)
    }

    
    private var contentTextEditor: some View {
        VStack(alignment: .leading) {
            Text("Your Thoughts").font(.headline).foregroundColor(.secondary)
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {

                TextEditor(text: $content)
                    .font(.body)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary, lineWidth: 1))
                    .frame(minHeight: 150)
                if content.isEmpty {
                    Text("테마를 설명해주세요.")
                        .foregroundColor(.gray)
                        .padding(.all, 8)
                        .allowsHitTesting(false)
                }
            }
            .onTapGesture {
                self.focusField = .content
            }
        }
        .padding(20)
        .padding(.horizontal, 10)
    }
    
    private var imagePickerSection: some View {
        Button(action: {
            PermissionsManager.shared.checkPhotosAuthorization { authorized in
                if authorized {
                    self.showingImagePicker = true
                } else {
                    self.alertType = .authorized
                    self.alertMessage = "테마에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                    self.showAlert = true
                }
            }
        }) {
            Label("이미지 업로드", systemImage: "photo.fill.on.rectangle.fill")
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? .white : .black)
                .cornerRadius(10)
        }
        .padding(.horizontal, 30)
        .buttonStyle(PlainButtonStyle())
        .environment(\.colorScheme, colorScheme)
    }
    
    private var publicToggleView: some View {
        Toggle(isOn: $isPublic, label: {
            Text("내 테마 나만 보기")
                .font(.callout)
                .fontWeight(.semibold)
            Image(systemName: "lock.fill")
                .font(.callout)
        })
        .padding(.horizontal, 20)
        .toggleStyle(CheckboxStyle())
    }
    
    private var registerButton: some View {
        Button(action: {
            if !title.isEmpty {
                myFolderViewModel.createFolder(image: inputImage, name: title, description: content, isPublic: isPublic) { isSuccess in
                    if isSuccess {
    //                    self.alertType = .make
    //                    self.alertMessage = "테마가 성공적으로 등록되었어요!"
    //                    self.showAlert = true
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        self.alertType = .make
                        self.alertMessage = myFolderViewModel.errorMessage ?? "테마 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                        self.showAlert = true
                    }
                }
            } else {
                updateFeedbackMessage()
            }

        }) {
            Text("등록하기")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(title.isEmpty ? Color.gray : Color.appAccent)
                .cornerRadius(6)
        }
        .padding(.horizontal, 30)
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 5)
    }
    
    private func updateFeedbackMessage() {
        if title.isEmpty {
            feedbackMessage = "테마의 제목을 입력해주세요."
        } else {
            feedbackMessage = nil
        }
    }
    
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}
