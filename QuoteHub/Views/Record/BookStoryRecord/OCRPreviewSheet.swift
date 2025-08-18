//
//  OCRPreviewSheet.swift
//  QuoteHub
//
//  Created by iyungui on 8/18/25.
//

import SwiftUI

struct OCRPreviewSheet: View {
    @Binding var extractedText: String
    @State private var editableText: String = ""
    
    let originalImage: UIImage?
    let onApply: (String) -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool
    
    private let maxTextLength = 500 // Quote 최대 길이와 동일
    
    init(
        extractedText: Binding<String>,
        originalImage: UIImage? = nil,
        onApply: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
    ) {
        self._extractedText = extractedText
        self.originalImage = originalImage
        self.onApply = onApply
        self.onCancel = onCancel
    }
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let image = originalImage {
                    originalImageSection(image)
                }
                
                textEditingSection
                
                bottomButtonsSection
            }
            .navigationTitle("텍스트 확인")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        handleCancel()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("적용") {
                        handleApply()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .disabled(editableText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear { editableText = extractedText }
    }
    
    // MARK: - View Components
    
    private func originalImageSection(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 150)
            .padding()
    }
    
    private var textEditingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("추출된 텍스트")
                    .font(.appFont(.medium, size: .subheadline))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 글자수 표시
                StoryCharacterCountView(
                    currentInputCount: editableText.count,
                    maxCount: maxTextLength
                )
            }
            .padding(.horizontal, 16)
            
            // 텍스트 편집기
            ScrollView {
                CustomTextEditor(
                    text: $editableText,
                    placeholder: "추출된 텍스트가 여기에 표시됩니다.\n필요시 수정하실 수 있습니다.",
                    minHeight: 200,
                    maxLength: maxTextLength,
                    isFocused: isTextEditorFocused
                )
                .focused($isTextEditorFocused)
                .padding(.horizontal, 16)
            }
            
            // 도움말 텍스트
            Text("텍스트가 정확하지 않다면 수정하신 후 적용해주세요.")
                .font(.appFont(.light, size: .caption))
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 16)
                .padding(.top, 4)
        }
        .padding(.top, 16)
    }
    
    private var bottomButtonsSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 16) {
                // 취소 버튼
                Button {
                    handleCancel()
                } label: {
                    Text("취소")
                        .font(.appFont(.medium, size: .body))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                
                // 적용 버튼
                Button {
                    handleApply()
                } label: {
                    Text("인용구에 추가")
                        .font(.appFont(.medium, size: .body))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(editableText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                      Color.gray : Color.blue)
                        )
                }
                .disabled(editableText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    
    // MARK: - Actions
    
    private func handleApply() {
        let cleanedText = editableText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedText.isEmpty else {
            return
        }
        
        // 텍스트 적용
        onApply(cleanedText)
        
        // 시트 닫기
        dismiss()
    }
    
    private func handleCancel() {
        onCancel()
        dismiss()
    }

}

#Preview {
    OCRPreviewSheet(
        extractedText: .constant("샘플 추출된 텍스트"),
        originalImage: nil,
        onApply: { text in
            print("적용된 텍스트: \(text)")
        },
        onCancel: {
            print("취소됨")
        }
    )
}
