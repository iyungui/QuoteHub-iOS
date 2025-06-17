////
////  UserProfileView.swift
////  QuoteHub
////
////  Created by 이융의 on 2023/10/02.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//struct UserProfileImage: View {
//    let profileImageURL: String?
//    @Binding var inputImage: UIImage?
//    @State private var showingImagePicker = false
//    @State private var showingPermissionAlert = false
//    @State private var permissionAlertMessage = ""
//    
//    var body: some View {
//        Group {
//            if let inputImg = inputImage { // User has selected a new image to upload
//                Image(uiImage: inputImg)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 120, height: 120)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//            } else if let urlString = profileImageURL, let url = URL(string: urlString) { // Existing profile image
//                WebImage(url: url)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 120, height: 120)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//            } else {
//                Circle()
//                    .stroke(Color.gray, lineWidth: 1)
//                    .frame(width: 120, height: 120)
//                    .overlay(
//                        Image(systemName: "photo.badge.plus")
//                            .font(.title)
//                            .foregroundColor(Color.gray),
//                        alignment: .center
//                    )
//            }
//        }
//        .onTapGesture {
//            PermissionsManager.shared.checkPhotosAuthorization { authorized in
//                if authorized {
//                    self.showingImagePicker = true
//                } else {
//                    self.permissionAlertMessage = "프로필 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
//                    self.showingPermissionAlert = true
//                }
//            }
//        }
//        .sheet(isPresented: $showingImagePicker) {
//            SingleImagePicker(selectedImage: self.$inputImage)
//                .ignoresSafeArea(.all)
//        }
//        .alert(isPresented: $showingPermissionAlert) {
//            Alert(
//                title: Text("권한 필요"),
//                message: Text(permissionAlertMessage),
//                primaryButton: .default(Text("설정으로 이동"), action: {
//                    // 사용자를 설정 앱으로 이동
//                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
//                       UIApplication.shared.canOpenURL(settingsUrl) {
//                        UIApplication.shared.open(settingsUrl)
//                    }
//                }),
//                secondaryButton: .cancel()
//            )
//        }
//    }
//}
//
//
//struct UserProfileView: View {
//    @EnvironmentObject var userViewModel: UserViewModel
//    
//    @State private var inputImage: UIImage?
//    @State private var nickname: String = ""
//    @State private var statusMessage: String = ""
//    
//    @State private var showAlert: Bool = false
//    @State private var alertMessage: String = ""
//    
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            Spacer()
//            UserProfileImage(profileImageURL: userViewModel.user?.profileImage, inputImage: $inputImage)
//            Spacer()
//            
//            Group {
//                TextField("닉네임", text: $nickname)
//                    .font(.system(size: 14))
//                    .foregroundColor(.primary)
//                    .padding()
//                    .cornerRadius(4.0)
//                    .overlay(RoundedRectangle(cornerRadius: 4.0).stroke(Color.secondary, lineWidth: 1))
//                    .frame(width: 280)
//                
//                TextField("상태메시지", text: $statusMessage)
//                    .font(.system(size: 14))
//                    .foregroundColor(.primary)
//                    .padding()
//                    .cornerRadius(4.0)
//                    .overlay(RoundedRectangle(cornerRadius: 4.0).stroke(Color.secondary, lineWidth: 1))
//                    .frame(width: 280)
//                
//            
//                
//            }
//            Spacer()
//            
//            Button(action: updateProfile) {
//                Text("완료")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .background(Color.appAccent)
//                    .cornerRadius(6)
//            }
//            .buttonStyle(PlainButtonStyle())
//            .padding(.horizontal, 30)
//            .padding(.bottom)
//        }
//        .navigationBarTitle("내 프로필", displayMode: .inline)
//        
//        .onAppear {
//            if let user = userViewModel.user {
//                self.nickname = user.nickname
//                self.statusMessage = user.statusMessage ?? ""
//            }
//        }
//        .alert(isPresented: $showAlert, content: {
//            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")) {
//                if alertMessage == "프로필이 성공적으로 업데이트되었습니다." {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            })
//        })
//    }
//    
//    
//    func updateProfile() {
//        print(#fileID, #function, #line, "- ")
//        userViewModel.updateProfile(nickname: nickname, profileImage: inputImage, statusMessage: statusMessage, monthlyReadingGoal: monthlyReadingGoal) { result in
//            switch result {
//            case .success:
//                alertMessage = "프로필이 성공적으로 업데이트되었습니다."
//                showAlert = true
//            case .failure(let error as NSError):
//                if error.domain == "UserService" && error.code == 400 {
//                    alertMessage = "이미 사용 중인 닉네임입니다. 다른 닉네임을 사용해주세요."
//                } else {
//                    alertMessage = "프로필 수정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
//                }
//                showAlert = true
//            }
//        }
//    }
//}
