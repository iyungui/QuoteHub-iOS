//
//  CommentEditView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

// MARK: - 댓글 수정 뷰
struct CommentEditView: View {
    let originalContent: String
    let onSave: (String) -> Void
    
    @State private var editedContent: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    init(originalContent: String, onSave: @escaping (String) -> Void) {
        self.originalContent = originalContent
        self.onSave = onSave
        self._editedContent = State(initialValue: originalContent)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("댓글을 수정하세요", text: $editedContent, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .font(.appFont(.regular, size: .body))
                    .lineLimit(5...10)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("댓글 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        onSave(editedContent)
                        dismiss()
                    }
                    .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
