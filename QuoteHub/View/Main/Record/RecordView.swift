//
//  RecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecordView: View {
    
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let book: Book
    
    @State private var keywords: [String] = []
    @State private var currentInput: String = ""
    @State private var isShowingDuplicateWarning = false
    
    @State private var quote: String = ""
    let quotePlaceholder: String = "간직하고 싶은 문장을 기록해보세요."
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var selectedImages: [UIImage] = []
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var content: String = ""
    let contentPlaceholder: String = "문장을 읽고 떠오른 생각을 기록해보세요."
    
    @State private var isPublic: Bool = true
    @State private var folderIds: [String] = []
    
    enum Field: Hashable {
        case keywords
        case quote
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
            VStack(spacing: 20) {
                keywordView
                Divider()
                quoteView
                    .padding()
                Divider()
                Spacer()
                inputContentView
                StoryImagesView(selectedImages: $selectedImages, showingImagePicker: $showingImagePicker)
                Divider()
                selectThemaView
                Divider()
                publicToggleView
                Divider()
                infoBookView
                
                VStack(alignment:.center) {
                    if let message = feedbackMessage, !filledField(images: selectedImages, quote: quote, content: content, keywords: keywords) {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    buttonView
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImages: self.$selectedImages, sourceType: self.sourceType)
                .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showingGallery) {
            MultipleImagePicker(selectedImages: self.$selectedImages, selectionLimit: max(0, 10 - selectedImages.count))
                .ignoresSafeArea(.all)
        }
        .navigationBarTitle("북스토리 기록", displayMode: .inline)
        .actionSheet(isPresented: $showingImagePicker) {
            ActionSheet(title: Text("이미지 선택"), message: nil, buttons: [
                .default(Text("카메라")) {
                    self.sourceType = .camera
                    PermissionsManager.shared.checkCameraAuthorization { authorized in
                        if authorized {
                            self.showingCamera = true
                        } else {
                            self.alertType = .authorized
                            self.alertMessage = "북스토리에 이미지를 업로드하려면 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                            self.showAlert = true
                        }
                    }
                },
                .default(Text("사진 라이브러리")) {
                    self.sourceType = .photoLibrary
                    PermissionsManager.shared.checkPhotosAuthorization { authorized in
                        if authorized {
                            self.showingGallery = true
                        } else {
                            self.alertType = .authorized
                            self.alertMessage = "북스토리에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                            self.showAlert = true
                        }
                    }
                },
                .cancel()
            ])
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
    }
    
    var keywordView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if keywords.count < 5 {
                TextField("", text: $currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusField, equals: .keywords)
                    .submitLabel(.done)
                    .onChange(of: currentInput) { newValue in
                        if newValue.count > 8 {
                            currentInput = String(newValue.prefix(8))
                        }
                    }
                    .onSubmit(addKeyword)
                    .padding(.horizontal)
                    .overlay(
                        HStack {
                            Spacer()
                            if currentInput.isEmpty {
                                Text("#키워드를   #입력   #하세요")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 30)
                                    .allowsHitTesting(false)

                            }
                        }
                    )
                
                if isShowingDuplicateWarning {
                    Text("중복된 키워드입니다.")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .opacity, removal: .slide))
                }
                if keywords.isEmpty {
                    Text("키워드를 입력하시고, 반드시 키보드 위의 '완료'를 눌러주세요.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(keywords, id: \.self) { keyword in
                        ZStack(alignment: .trailing) {
                            Text("#\(keyword)")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(10)
                            
                            Button(action: {
                                withAnimation { removeKeyword(keyword) }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .padding(4)
                                    .foregroundColor(.secondary)
                                    .background(Color.secondary.opacity(0.1).cornerRadius(10))
                            }
                            .offset(x: 10, y: 0)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .padding(.bottom)
    }

    private func addKeyword() {
        let trimmedKeyword = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedKeyword.isEmpty && keywords.count < 5 {
            if keywords.contains(trimmedKeyword) {
                isShowingDuplicateWarning = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isShowingDuplicateWarning = false
                }
            } else {
                keywords.append(trimmedKeyword)
                currentInput = ""
                focusField = .keywords
            }
        }
    }
    
    // 키워드를 삭제하는 함수
    private func removeKeyword(_ keyword: String) {
        if let index = keywords.firstIndex(of: keyword) {
            keywords.remove(at: index)
        }
    }
    
    var quoteView: some View {
        VStack(alignment: .leading) {
            Text("Quote").font(.headline).foregroundColor(.secondary)
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                TextEditor(text: $quote)
                    .font(.body)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary, lineWidth: 1))
                if quote.isEmpty {
                    Text(quotePlaceholder)
                        .foregroundColor(.gray)
                        .padding()
                        .padding(.leading, 12)
                        .padding(.top, 5)
                        .allowsHitTesting(false)
                }
            }
            .onTapGesture {
                self.focusField = .quote
            }
            .frame(minHeight: 100)
        }
    }
    
    var inputContentView: some View {
        VStack(alignment: .leading) {
            Text("Your Thoughts").font(.headline).foregroundColor(.secondary)
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {

                TextEditor(text: $content)
                    .font(.body)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary, lineWidth: 1))
                    .frame(minHeight: 150)
                if content.isEmpty {
                    Text(contentPlaceholder)
                        .foregroundColor(.gray)
                        .padding(.all, 10)
                        .padding(.leading, 12)
                        .padding(.top, 5)
                        .allowsHitTesting(false)
                }
            }
            .onTapGesture {
                self.focusField = .content
            }
        }
        .padding(.horizontal)
    }

    
    var selectThemaView: some View {
        HStack {
            NavigationLink(destination: SetThemaView(selectedFolderIds: $folderIds)) {
                Text("테마 선택하기")
                    .font(.callout)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.callout)
            }
        }
        .padding(.horizontal, 20)
    }
    
    var publicToggleView: some View {
        Toggle(isOn: $isPublic, label: {
            Text("내 북스토리 나만 보기")
                .font(.callout)
                .fontWeight(.semibold)
            Image(systemName: "lock.fill")
                .font(.callout)
        })
        .padding(.horizontal, 20)
        .toggleStyle(CheckboxStyle())
    }
    
    var infoBookView: some View {
        HStack {
            WebImage(url: URL(string: book.bookImageURL ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title ?? "제목 없음")
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(book.author?.joined(separator: ", ") ?? "저자 미상")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(book.publisher ?? "출판사 정보 없음")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .padding(.all, 10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - BUTTON
    
    var buttonView: some View {
        Button(action: {
            if filledField(images: selectedImages, quote: quote, content: content, keywords: keywords) {
                myStoriesViewModel.createBookStory(images: selectedImages, bookId: book.id, quote: quote, content: content, isPublic: isPublic, keywords: keywords, folderIds: folderIds) { isSuccess in
                    if isSuccess {
                        self.alertType = .make
                        self.alertMessage = "북스토리가 성공적으로 등록되었어요!"
                        self.showAlert = true
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        self.alertType = .make
                        self.alertMessage = "북스토리 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
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
                .background(filledField(images: selectedImages, quote: quote, content: content, keywords: keywords) ? Color.appAccent : Color.gray)
                .cornerRadius(6)
        }
        .padding(.horizontal, 30)
        .buttonStyle(PlainButtonStyle())
    }

    private func filledField(images: [UIImage]?, quote: String?, content: String?, keywords: [String]?) -> Bool {
        let areTextFieldsFilled = !(quote?.isEmpty ?? true) && !(content?.isEmpty ?? true)
        let areKeywordsAndFoldersFilled = !(keywords?.isEmpty ?? true)
        let areImagesFilled = !(images?.isEmpty ?? true)
        return areTextFieldsFilled && areKeywordsAndFoldersFilled && areImagesFilled
    }

    private func updateFeedbackMessage() {
        if keywords.isEmpty {
            feedbackMessage = "키워드를 입력해주세요."
        } else if quote.isEmpty {
            feedbackMessage = "인용문을 입력해주세요."
        } else if content.isEmpty {
            feedbackMessage = "내용을 입력해주세요."
        } else if selectedImages.isEmpty {
            feedbackMessage = "이미지를 추가해주세요."
        } else {
            feedbackMessage = nil
        }
    }

}

// only iOS
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif




struct StoryImagesView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showingImagePicker: Bool

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 10) {
                    addButton
                    ForEach(selectedImages.indices, id: \.self) { index in
                        imageCell(for: selectedImages[index], at: index)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    var addButton: some View {
        Button(action: {
            if selectedImages.count < 10 {
                showingImagePicker = true
            }
        }) {
            VStack {
                Image(systemName: "plus.circle").foregroundColor(.gray)
                Text("사진추가\n\(selectedImages.count)/10")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(.gray, lineWidth: 1)
            )
        }
        .accessibilityLabel("Add photo")
    }

    func imageCell(for image: UIImage, at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(4)
                .clipped()
            
            Button(action: {
                DispatchQueue.main.async {
                    selectedImages.remove(at: index)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .background(Color.white.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(2)
        }
        .accessibilityLabel("Photo \(index + 1)")
    }
}
