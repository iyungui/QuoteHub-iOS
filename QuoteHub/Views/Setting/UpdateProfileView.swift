//
//  UpdateProfileView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import SwiftUI
import PhotosUI

struct UpdateProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserViewModel.self) private var userViewModel
    
    // 폼 상태
    @State private var nickname: String = ""
    @State private var statusMessage: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var profileImageURL: String = ""
    
    // UI 상태
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                profileImageSection
                
                inputFieldsSection
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
        }
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    dismiss()
                }
                .foregroundColor(.primary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("저장") {
                    Task {
                        await saveProfile()
                    }
                }
                .foregroundColor(.blue)
                .disabled(userViewModel.isLoadingProfile || nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            loadCurrentUserData()
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                await loadSelectedImage(from: newValue)
            }
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(/*userViewModel.errorMessage ??*/ "알 수 없는 오류가 발생했습니다.")
        }
        .alert("성공", isPresented: $showSuccessAlert) {
            Button("확인", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(/*userViewModel.successMessage ??*/ "프로필이 업데이트되었습니다.")
        }
    }
    
    // MARK: - Profile Image Section
    
    private var profileImageSection: some View {
        VStack(spacing: 15) {
            if let selectedUIImage = selectedUIImage {
                Image(uiImage: selectedUIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                ProfileImage(
                    profileImageURL: profileImageURL,
                    size: 100
                )
            }
            
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("사진 변경")
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.blue)
            }
            .disabled(userViewModel.isLoadingProfile)
        }
        .progressOverlay(viewModel: userViewModel, opacity: true)
    }
    
    // MARK: - Input Fields Section
    
    private var inputFieldsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            // 닉네임 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("닉네임")
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.primary)
                
                TextField("닉네임을 입력하세요", text: $nickname)
                    .font(.scoreDream(.regular, size: .body))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(userViewModel.isLoadingProfile)
            }
            
            // 상태메시지 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("상태메시지")
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.primary)
                
                TextField("상태메시지를 입력하세요", text: $statusMessage, axis: .vertical)
                    .font(.scoreDream(.regular, size: .body))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                    .disabled(userViewModel.isLoadingProfile)
            }
            
            // 로딩 메시지
            if userViewModel.isLoadingProfile {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text(userViewModel.loadingMessage ?? "저장 중...")
                        .font(.scoreDream(.regular, size: .subheadline))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadCurrentUserData() {
        if let currentUser = userViewModel.currentUser {
            nickname = currentUser.nickname ?? ""
            statusMessage = currentUser.statusMessage ?? ""
            profileImageURL = currentUser.profileImage ?? ""
        }
    }
    
    private func loadSelectedImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedUIImage = uiImage
            }
        } catch {
            print("이미지 로드 실패: \(error)")
        }
    }
    
    private func saveProfile() async {
        let success = await userViewModel.updateProfile(
            nickname: nickname,
            profileImage: selectedUIImage,
            statusMessage: statusMessage
        )
        
        if success {
            showSuccessAlert = true
        } else {
            showErrorAlert = true
        }
    }
}

#Preview {
    UpdateProfileView()
        .environment(UserViewModel())
}
