//
//  UpdateStoryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpdateStoryView: View {
    var storyId: String
    @State private var selectedImages: [UIImage] = []

    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel

    @State private var keywords: [String] = []
    @State private var currentInput: String = ""
    @State private var isShowingDuplicateWarning = false
    
    @Environment(\.presentationMode) var presentationMode

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var quote: String = ""
    let quotePlaceholder: String = "간직하고 싶은 문장을 기록해보세요."
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingGallery = false
    

    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var content: String = ""
    let contentPlaceholder: String = "문장을 읽고 떠오른 생각을 기록해보세요."
    
    @State private var isPublic: Bool = true
    @State private var folderIds: [String] = []
    
    @State private var bookImage: String = ""
    @State private var bookTitle: String = "제목 없음"
    @State private var bookAuthor: [String] = ["저자 미상"]
    @State private var bookPublisher: String = "출판사 정보 없음"
    @State private var showingModal: Bool = false

    enum Field: Hashable {
        case keywords
        case quote
        case content
    }
    
    @FocusState private var focusField: Field?
    
    enum AlertType {
        case authorized
        case make
    }
    @State private var alertType: AlertType = .authorized
    
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
                storyImagesView
                Divider()
                selectThemaView
                Divider()
                publicToggleView
                Divider()
                infoBookView
                buttonView
            }
        }
        .onAppear {
            if let story = myStoriesViewModel.bookStories.first(where: { $0.id == storyId}) {
                keywords = story.keywords ?? []
                quote = story.quote ?? quotePlaceholder
                content = story.content ?? contentPlaceholder
                folderIds = story.folderIds ?? []
                isPublic = story.isPublic
                bookImage = story.bookId.bookImageURL
                bookTitle = story.bookId.title
                bookAuthor = story.bookId.author
                bookPublisher = story.bookId.publisher
                
                story.storyImageURLs?.forEach { imageURLString in
                    if let imageURL = URL(string: imageURLString) {
                        SDWebImageDownloader.shared.downloadImage(with: imageURL) { image, _, _, _ in
                            DispatchQueue.main.async {
                                if let image = image {
                                    selectedImages.insert(image, at: 0)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitle("북스토리 수정", displayMode: .inline)
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
        .sheet(isPresented: $showingModal) {
            settingThemaView(selectedFolderIds: $folderIds)
                .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImages: self.$selectedImages, sourceType: self.sourceType)
                .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showingGallery) {
            MultipleImagePicker(selectedImages: self.$selectedImages, selectionLimit: max(0, 10 - selectedImages.count))
                .ignoresSafeArea(.all)
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
    
    private var keywordView: some View {
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
                HStack(spacing: 10) {  // Added spacing between tags for better separation
                    ForEach(keywords, id: \.self) { keyword in
                        ZStack(alignment: .trailing) {  // Changed to ZStack to overlay the delete button
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
                                    .foregroundColor(.secondary)  // Use the secondary color for the button
                                    .background(Color.secondary.opacity(0.1).cornerRadius(10))
                            }
                            .offset(x: 10, y: 0)  // Offset the button to the right of the text
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .padding(.bottom)
    }

    //     사용자가 Enter를 누를 때 실행될 함수
    private func addKeyword() {
        let trimmedKeyword = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedKeyword.isEmpty && keywords.count < 5 {
            if keywords.contains(trimmedKeyword) {
                isShowingDuplicateWarning = true
                // 일정 시간 후 경고 메시지 숨기기
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
    
    
    private var quoteView: some View {
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

    
    private var storyImagesView: some View {
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

    private var addButton: some View {
        Button(action: {
            if selectedImages.count < 10 {
                showingImagePicker = true
            }
        }) {
            VStack() {
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

    private func imageCell(for image: UIImage, at index: Int) -> some View {
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

    
    private var inputContentView: some View {
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

    
    private var selectThemaView: some View {
        HStack {
            Button(action: {
                showingModal = true
            }) {
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
    
    private var publicToggleView: some View {
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
    
    private var infoBookView: some View {
        HStack {
            WebImage(url: URL(string: bookImage))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(bookTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(bookAuthor.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(bookPublisher)
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
    
    private var buttonView: some View {
        Button(action: {
            if filledField(images: selectedImages, quote: quote, content: content, keywords: keywords) {
                myStoriesViewModel.updateBookStory(storyID: storyId, images: selectedImages, quote: quote, content: content, isPublic: isPublic, keywords: keywords, folderIds: folderIds) { isSuccess in
                    if isSuccess {
//                        self.alertType = .make
//                        self.alertMessage = "북스토리가 성공적으로 등록되었어요!"
//                        self.showAlert = true
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
                .background(filledField(images: selectedImages, quote: quote, content: content, keywords: keywords) ? Color.appAccent : Color.gray.opacity(0.5))
                .cornerRadius(6)
        }
        .padding(.horizontal, 30)
        .buttonStyle(PlainButtonStyle())
    }

    private func filledField(images: [UIImage]?, quote: String?, content: String?, keywords: [String]?) -> Bool {
        // Check if all the required fields are non-empty.
        let areTextFieldsFilled = !(quote?.isEmpty ?? true) && !(content?.isEmpty ?? true)
        let areKeywordsAndFoldersFilled = !(keywords?.isEmpty ?? true)
        let areImagesFilled = !(images?.isEmpty ?? true) // Check for images is independent of isPublic.

        // All fields need to be filled.
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


struct settingThemaView: View {
    @Binding var selectedFolderIds: [String]
    @StateObject var myFolderViewModel = MyFolderViewModel()
    @Environment(\.presentationMode) var presentationMode

    // 폴더 선택 상태를 관리하는 Set
    @State private var selectedSet = Set<String>()

    var body: some View {
        VStack {
            buttonView
            ScrollView {
                listThemaView
            }
        }
    }
    private var buttonView: some View {
        Button(action: {
            selectedFolderIds = Array(selectedSet)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("완료")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
        }
    }
    
    private var listThemaView: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("내 테마 목록")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading)
            
            if myFolderViewModel.folder.isEmpty {
                Spacer()
                Text("지금 바로 나만의 테마를 만들어보세요!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            } else {
                let spacing: CGFloat = 20
                let horizontalPadding: CGFloat = 10
                let columns: Int = 2
                let totalSpacing: CGFloat = spacing * CGFloat(columns - 1)
                let screenWidth: CGFloat = UIScreen.main.bounds.width
                let contentWidth: CGFloat = screenWidth - (horizontalPadding * 2) - totalSpacing

                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: columns), spacing: spacing) {
                    ForEach(myFolderViewModel.folder, id: \.id) { folder in
                        Button(action: {
                            // Toggle selection state
                            if selectedSet.contains(folder.id) {
                                selectedSet.remove(folder.id)
                            } else {
                                selectedSet.insert(folder.id)
                            }
                            print("Selected Folders: \(selectedSet)")

                        }) {
                            VStack(alignment: .leading) {
                                WebImage(url: URL(string: folder.folderImageURL))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: contentWidth / CGFloat(columns) - 10, height: (contentWidth / CGFloat(columns)) * 5 / 8)
                                    .cornerRadius(10)
                                    .clipped()
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedSet.contains(folder.id) ? Color.black : Color.clear, lineWidth: 1))
                                
                                Text(folder.name)
                                    .font(.callout)
                                    .fontWeight(.semibold)

                            }
                            .overlay(
                                Image(systemName: selectedSet.contains(folder.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(selectedSet.contains(folder.id) ? Color.black : Color.gray.opacity(0.5))
                                    .padding(4),
                                alignment: .topTrailing
                            )
                        }
                    }
                    if !myFolderViewModel.isLastPage {
                        ProgressView().onAppear {
                            myFolderViewModel.loadMoreIfNeeded(currentItem: myFolderViewModel.folder.last)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top)
            }
            
        }
        .padding(10)
    }
}
