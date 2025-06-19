//
//  ReportSheetView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import SwiftUI

struct ReportSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    let story: BookStory
    @Binding var reportReason: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
//    @StateObject var reportViewModel = ReportViewModel()
    
    var body: some View {
        VStack {
            Text("신고 사유를 입력해주세요")
                .font(.headline)
                .padding(.top)

            TextField("사유", text: $reportReason)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text("신고하면 해당 게시물은 더 이상 나에게 보이지 않습니다.\n\n모든 신고는 개발자에게 전달되어 신중하게 검토되며, 이 과정은 일반적으로 24시간 이내에 완료됩니다.\n\n신고 내역은 커뮤니티 지침을 준수하기 위해 필요한 조치를 취하는 데 사용됩니다.")
                .font(.callout)
                .foregroundColor(.gray)
                .padding()

            Button(action: {
//                reportViewModel.reportBookStory(targetId: story.id, reason: reportReason) { result in
//                    switch result {
//                    case .success:
//                        DispatchQueue.main.async {
//                            viewModel.updateFollowStatus(forUserId: story.userId.id, withStatus: .blocked) { _,_  in }
//                            alertMessage = "신고가 성공적으로 접수되었습니다."
//                            showAlert = true
//                        }
//                    case .failure:
//                        alertMessage = "신고 중 오류가 발생했습니다."
//                        showAlert = true
//                    }
//                }
            }) {
                Text("신고하기")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(reportReason.isEmpty ? Color.gray : Color.appAccent)
                    .cornerRadius(8)
            }
            .disabled(reportReason.isEmpty)


        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인")) {
                    if alertMessage == "신고가 성공적으로 접수되었습니다." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}


struct UserReportSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    let userId: String
    @Binding var reportReason: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
//    @StateObject var reportViewModel = ReportViewModel()
//    @EnvironmentObject var viewModel: FollowViewModel
    
    var body: some View {
        VStack {
            Text("신고 사유를 입력해주세요")
                .font(.headline)
                .padding(.top)

            TextField("사유", text: $reportReason)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text("신고하면 해당 유저는 더 이상 나에게 보이지 않습니다.\n\n모든 신고는 개발자에게 전달되어 신중하게 검토되며, 이 과정은 일반적으로 24시간 이내에 완료됩니다.\n\n신고 내역은 커뮤니티 지침을 준수하기 위해 필요한 조치를 취하는 데 사용됩니다.")
                .font(.callout)
                .foregroundColor(.gray)
                .padding()

            Button(action: {
//                reportViewModel.reportUser(targetId: userId, reason: reportReason) { result in
//                    switch result {
//                    case .success:
//                        DispatchQueue.main.async {
//                            viewModel.updateFollowStatus(forUserId: userId, withStatus: .blocked) { _,_  in }
//                            alertMessage = "신고가 성공적으로 접수되었습니다."
//                            showAlert = true
//                        }
//                    case .failure:
//                        alertMessage = "신고 중 오류가 발생했습니다."
//                        showAlert = true
//                    }
//                }
            }) {
                Text("신고하기")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(reportReason.isEmpty ? Color.gray : Color.appAccent)
                    .cornerRadius(8)
            }
            .disabled(reportReason.isEmpty)

        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인")) {
                    if alertMessage == "신고가 성공적으로 접수되었습니다." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}
