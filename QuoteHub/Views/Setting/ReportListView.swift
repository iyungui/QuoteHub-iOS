//
//  ReportListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReportListView: View {
//    @StateObject var viewModel = ReportViewModel()
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
                        
//                        ForEach(viewModel.reportedUsers, id: \.id) { report in
//                            VStack(alignment: .leading, spacing: 20) {
//                                HStack {
//                                    ProfileImage(profileImageURL: report.targetId.profileImage, size: 50)
//                                    
//                                    VStack(alignment: .leading) {
//                                        // Displaying the nickname and report reason
//                                        Text(report.targetId.nickname)
//                                            .font(.headline)
//                                        Text("신고 상태: \(report.status.rawValue)")
//                                            .font(.subheadline)
//                                    }
//                                    .padding(.leading)
//                                    
//                                    Spacer()
//                                }
//                                
//                                Text("신고 사유: \(report.reason)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                    .multilineTextAlignment(.leading)
//
//                            }
//                            .padding()
//                            Divider()
//                        }
                        
                    }
                    .padding()
                    .onAppear {
//                        viewModel.getReportedUsers()
                    }
                }
                .tag(0)
                
                
                

                ScrollView {
                    VStack {
//                        ForEach(viewModel.reportedStories) { story in
//                            VStack(alignment: .leading, spacing: 20) {
//                                HStack {
//                                    // Displaying the profile image
//                                    WebImage(url: URL(string: story.targetId.storyImageURLs?.first ?? ""))
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 50, height: 50)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
//                                        .shadow(radius: 3)
//                                    
//                                    VStack(alignment: .leading) {
//                                        Text("신고 상태: \(story.status.rawValue)")
//                                            .font(.subheadline)
//                                    }
//                                    .padding(.leading)
//                                    
//                                    Spacer()
//                                }
//                                
//                                Text("신고 사유: \(story.reason)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                    .multilineTextAlignment(.leading)
//
//                            }
//                            .padding()
//                            Divider()
//                        }
                        
                    }
                    .padding()
                    .onAppear {
//                        viewModel.getReportedStories()
                    }
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}
