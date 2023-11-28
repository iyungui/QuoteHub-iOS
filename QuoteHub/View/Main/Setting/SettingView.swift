//
//  SettingView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/09.
//

import SwiftUI

struct SettingView: View {
    
    @State private var showLogoutActionSheet: Bool = false
    @State private var showDeleteUserActionSheet: Bool = false
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @EnvironmentObject var userViewModel: UserViewModel

    @State private var isLoading = false
    @State private var navigateToUserProfile = false
        
    var body: some View {
        
        if isLoading {
            ProgressView()
        }
        
        NavigationLink(destination: UserProfileView()
            .environmentObject(userViewModel)
            .onAppear {
                self.isLoading = false
            }, isActive: $navigateToUserProfile) {
            EmptyView()
        }

        
        List {
            Section(header: Text("내 정보")) {
                Button(action: {
                    self.isLoading = true
                    // 잠시 후에 navigateToUserProfile을 true로 설정하여 이동을 트리거
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateToUserProfile = true
                    }
                }) {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("내 프로필 수정")
                    }
                }
            }
            
            Section(header: Text("지원")) {
//                NavigationLink(destination: ReportListView()) {
//                    HStack {
//                        Image(systemName: "exclamationmark.bubble")
//                        Text("신고 목록")
//                    }
//                }
                
                NavigationLink(destination: BlockedListView()) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.xmark")
                        Text("차단 목록")
                    }
                }
                
                NavigationLink(destination: DeveloperInfoView()) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("개발자 정보")
                    }
                }
                
                NavigationLink(destination: VersionInfoView()) {
                    HStack {
                        Image(systemName: "number.circle")
                        Text("버전 정보")
                    }
                }
            }
            
            Section(header: Text("계정 관리")) {

                Button(action: {
                    showLogoutActionSheet = true
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("로그아웃")
                    }
                }
                .actionSheet(isPresented: $showLogoutActionSheet) {
                    ActionSheet(title: Text("로그아웃"), message: Text("정말로 로그아웃 하시겠습니까?"), buttons: [
                        .destructive(Text("로그아웃")) {
                            userAuthManager.logout { result in
                                if case .failure(let error) = result {
                                    print("로그아웃 실패: \(error.localizedDescription)")
                                }
                            }
                        },
                        .cancel()
                    ])
                }
                
                Button(action: {
                    showDeleteUserActionSheet = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("회원탈퇴")
                            .foregroundColor(.red)
                    }
                }
                .actionSheet(isPresented: $showDeleteUserActionSheet) {
                    ActionSheet(title: Text("회원 탈퇴"), message: Text("회원 탈퇴를 진행하면 모든 개인 데이터와 정보가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다. 정말로 계속하시겠습니까?"), buttons: [
                        .destructive(Text("회원 탈퇴")) {
                            userAuthManager.revokeUser { result in
                                if case .failure(let error) = result {
                                    print("회원 탈퇴 실패: \(error.localizedDescription)")
                                }
                            }
                        },
                        .cancel()
                    ])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("설정")
    }
}
