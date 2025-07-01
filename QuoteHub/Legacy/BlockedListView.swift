////
////  BlockedListView.swift
////  QuoteHub
////
////  Created by 이융의 on 11/26/23.
////
//
//import SwiftUI
//
//struct BlockedListView: View {
//    @State private var blockedUsers: [User] = []
//    @State private var isLoading: Bool = true
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        List(blockedUsers) { user in
//            HStack {
//                ProfileImage(profileImageURL: user.profileImage, size: 50)
//
//                VStack(alignment: .leading) {
//                    Text(user.nickname)
//                        .font(.headline)
//                    Text(user.statusMessage ?? "")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//                Spacer()
//                
//                Button(action: {
//                    unblockUser(userId: user.id)
//                }) {
//                    Text("차단 해제")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 8)
//                        .background(Color.appAccent)
//                        .cornerRadius(4)
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
//        }
//        .onAppear {
//            loadBlockedList()
//        }
//        .navigationTitle("차단된 사용자")
//        .alert(isPresented: Binding<Bool>.constant(errorMessage != nil), content: {
//            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown Error"))
//        })
//    }
//
//    private func loadBlockedList() {
////        FollowService().getBlockedList { result in
////            isLoading = false
////            switch result {
////            case .success(let users):
////                self.blockedUsers = users
////            case .failure(let error):
////                self.errorMessage = error.localizedDescription
////            }
////        }
//    }
//    
//    private func unblockUser(userId: String) {
////        FollowService().updateFollowStatus(userId: userId, status: "FOLLOWING") { result in
////            switch result {
////            case .success(let response):
////                print("Unblock Success: \(response)")
////                if let index = blockedUsers.firstIndex(where: { $0.id == userId }) {
////                    blockedUsers.remove(at: index)
////                }
////            case .failure(let error):
////                print("Unblock Error: \(error.localizedDescription)")
////                // 오류 처리
////            }
////        }
//    }
//}
