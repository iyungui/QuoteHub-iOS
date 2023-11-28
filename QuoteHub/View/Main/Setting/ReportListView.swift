//
//  ReportListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import SwiftUI

struct ReportListView: View {
    @StateObject var viewModel = ReportViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("Select", selection: $selectedTab) {
                    Text("유저 신고 목록").tag(0)
                    Text("게시물 신고 목록").tag(1)
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            
            Divider()
 
            TabView(selection: $selectedTab) {
                ScrollView {
                    VStack {
                        ForEach(viewModel.reportedUsers, id: \.id) { report in
                            Text("\(report.targetDisplayName) - \(report.reason)")
                            // 여기에 신고한 유저의 상세 정보를 표시하는 UI 구성
                        }
                    }
                    .onAppear {
                        viewModel.getReportedUsers()
                    }
                }
                .tag(0)

                ScrollView {
                    VStack {
                        ForEach(viewModel.reportedStories) { report in
                            Text("\(report.targetDisplayName) - \(report.reason)")
                            // 여기에 신고한 북스토리의 상세 정보를 표시하는 UI 구성
                        }
                    }
                    .onAppear {
                        viewModel.getReportedStories()
                    }
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}
