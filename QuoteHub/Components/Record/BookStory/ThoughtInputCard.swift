//
//  ThoughtInputCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

/// 북스토리 기록 - 느낀점 입력 카드
struct ThoughtInputCard: View {
    @EnvironmentObject var viewModel: StoryFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var contentFocused: BookStoryFormField?
    let book: Book
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 10) {
                // 이미지를 텍스트 위에 표시
                if !viewModel.selectedImages.isEmpty {
                    StoryImagesGridView()
                }
                
                Text("\(book.title)을(를) 읽고...")
                    .font(.appFont(.medium, size: .body))
                    .foregroundColor(.primaryText)
                
                if viewModel.selectedImages.isEmpty {
                    StoryCreateGuideSection(message: "이미지를 추가하여 기록을 풍부하게 해보세요.")
                }
                
                VStack(spacing: 8) {
                    CustomTextEditor(
                        text: $viewModel.content,
                        placeholder: viewModel.contentPlaceholder,
                        minHeight: 150,
                        maxLength: viewModel.contentMaxLength,
                        isFocused: (contentFocused == .content)
                    )
                    .focused($contentFocused, equals: .content)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    
                    StoryCharacterCountView(currentInputCount: viewModel.content.count, maxCount: viewModel.contentMaxLength)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    contentFocused = .content
                }
            }
            .legacyImagePicker(
                isPresented: $viewModel.showingCamera,
                selectedImages: $viewModel.selectedImages,
                sourceType: .camera
            )
            .multipleImagePicker(
                isPresented: $viewModel.showingGallery,
                selectedImages: $viewModel.selectedImages,
                selectionLimit: max(0, 10 - viewModel.selectedImages.count)
            )
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .authorized:
                    return Alert(
                        title: Text("권한 필요"),
                        message: Text(viewModel.alertMessage),
                        primaryButton: .default(Text("설정으로 이동"), action: {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }),
                        secondaryButton: .cancel()
                    )
                case .make:
                    return Alert(
                        title: Text("알림"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("확인"), action: {
                            if viewModel.alertMessage.contains("성공적으로") {
                                dismiss()
                            }
                        })
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소").font(.appBody)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("완료").font(.appBody).foregroundStyle(Color.blue)
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: viewModel.openPhotoLibrary) {
                            Image(systemName: "photo.badge.plus")
                        }
                        .disabled(viewModel.selectedImages.count >= 10)
                        
                        Button(action: viewModel.openCamera) {
                            Image(systemName: "camera.fill")
                        }
                        .disabled(viewModel.selectedImages.count >= 10)

                        Spacer()
                        
                        Button {
                            contentFocused = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - StoryImagesGridView

struct StoryImagesGridView: View {
    @EnvironmentObject var viewModel: StoryFormViewModel
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5),
            spacing: 8
        ) {
            ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                StoryImageCell(image: image, index: index)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - StoryImageCell

struct StoryImageCell: View {
    // MARK: - 이미지를 여러장 올릴 때 크래시 해결
    @EnvironmentObject var viewModel: StoryFormViewModel
    let image: UIImage
    let index: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 이미지
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            // 삭제 버튼
            Button(action: {
                viewModel.removeImage(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 20, height: 20)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .offset(x: 6, y: -6)
            
            // 이미지 순서 번호
            VStack {
                Spacer()
                HStack {
                    Text("\(index + 1)")
                        .font(.appFont(.bold, size: .caption2))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        .accessibilityLabel("Photo \(index + 1)")
    }
}

#Preview {
    ThoughtInputCard(book: Book(title: "", author: [], translator: [], introduction: "", publisher: "", publicationDate: "", bookImageURL: "", bookLink: "", ISBN: [], _id: "")).environmentObject(StoryFormViewModel())
}
