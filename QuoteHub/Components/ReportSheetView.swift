//
//  ReportSheetView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import SwiftUI

struct ReportSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockReportViewModel.self) var blockReportViewModel
    let targetId: String
    let reportType: Report.ReportType
    
    @State var reportReason: String = ""
    @State private var showAlert = false
    @State private var alertMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("신고 사유를 입력해주세요")
                    .font(.appFont(.medium, size: .body))
                    .padding(.top)
                
                TextField("사유", text: $reportReason)
                    .font(.appFont(.regular, size: .subheadline))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("신고하면 해당 유저 및 해당 유저의 게시물은 더 이상 나에게 보이지 않습니다.\n\n모든 신고는 개발자에게 전달되어 신중하게 검토되며, 이 과정은 일반적으로 24시간 이내에 완료됩니다.\n\n신고 내역은 커뮤니티 지침을 준수하기 위해 필요한 조치를 취하는 데 사용됩니다.")
                    .font(.appFont(.light, size: .footnote))
                    .foregroundColor(.gray)
                    .padding()
                
                Button(action: {
                    Task {
                        let isSuccess = await blockReportViewModel.reportAndBlock(targetId: targetId, type: reportType, reason: reportReason)
                        alertMessage = isSuccess ? blockReportViewModel.successMessage : blockReportViewModel.errorMessage
                        showAlert = true
                    }
                }) {
                    Text("신고하기")
                        .font(.appBody)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(reportReason.isEmpty ? Color.gray : Color.appAccent)
                        .cornerRadius(8)
                }
            }
            .padding()
            .alert("알림", isPresented: $showAlert) {
                Button("확인") { dismiss() }
            } message: {
                Text(alertMessage ?? "")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .font(.appBody)
                }

            }
        }
    }
}
