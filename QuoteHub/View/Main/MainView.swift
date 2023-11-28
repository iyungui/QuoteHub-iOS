//
//  MainView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case search, thema
    var id: Int {
        self.hashValue
    }
}

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var showAlert: Bool = false
    @State private var shouldShowOverlay: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @StateObject var userViewModel = UserViewModel()
    @StateObject var myStoriesViewModel = BookStoriesViewModel(mode: .myStories)

    @StateObject var myFolderViewModel = MyFolderViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                            .environmentObject(userAuthManager)
                            .environmentObject(userViewModel)
                            .environmentObject(myStoriesViewModel)
                            .environmentObject(myFolderViewModel)
                    case 1:
                        EmptyView()
                    case 2:
                        LibraryView()
                            .environmentObject(userAuthManager)
                            .environmentObject(myStoriesViewModel)
                            .environmentObject(userViewModel)
                            .environmentObject(myFolderViewModel)
                    default:
                        EmptyView()
                    }
                }
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab, shouldShowOverlay: $shouldShowOverlay, showAlert: {
                        // 로그인 알림을 표시하도록 showAlert 상태를 true로 설정
                        showAlert = true
                    })
                    .environmentObject(userAuthManager)
                    .padding(.bottom, 10)
                    .background(Color(UIColor.secondarySystemBackground).opacity(0.98))
                }
                
                NavigationLink(destination: LoginView().environmentObject(userAuthManager), isActive: $userAuthManager.showingLoginView) {
                    EmptyView()
                }
                
                // Overlay
                if shouldShowOverlay {
                    OverlayView(shouldShowOverlay: $shouldShowOverlay, activeSheet: $activeSheet, showAlert: {
                        showAlert = true
                    })
                    .environmentObject(userAuthManager)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }
            .alert(isPresented: $showAlert) {  // Alert presentation
                Alert(
                    title: Text("로그인 필요"),
                    message: Text("이 기능을 사용하려면 로그인이 필요합니다."),
                    primaryButton: .default(Text("로그인"), action: {
                        userAuthManager.showingLoginView = true
                    }),
                    secondaryButton: .cancel(Text("취소")) {
                        userAuthManager.showingLoginView = false
                    }
                )
            }
            .animation(.default, value: shouldShowOverlay)
            .fullScreenCover(item: $activeSheet) { item in
                switch item {
                case .search:
                    SearchBookView().environmentObject(myStoriesViewModel)
                case .thema:
                    MakeThemaView()
                        .environmentObject(myFolderViewModel)
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear(perform: onAppear)
        }
    }
    private func onAppear() {
        if (userAuthManager.isUserAuthenticated) {
            userViewModel.getProfile(userId: nil)
        } else {
            print("토큰 만료 표시")
        }
    }
}

struct OverlayView: View {
    @Binding var shouldShowOverlay: Bool
    @Binding var activeSheet: ActiveSheet?
    var showAlert: () -> Void  // 로그인 알림을 표시하기 위한 클로저 추가
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    var body: some View {
        // Full screen background that will fade in and out
        Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                withAnimation {
                    shouldShowOverlay = false
                }
            }
            .zIndex(0)
            .animation(.easeInOut, value: shouldShowOverlay)
            .transition(.opacity) // Fade transition for background

        // Overlay content that will slide up from the bottom
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Button(action: {
                        if userAuthManager.isUserAuthenticated {
                            withAnimation {
                                shouldShowOverlay = false
                                activeSheet = .search
                            }
                        } else {
                            showAlert()
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                                .font(.title)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading) {
                                Text("문장 기록")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("책을 읽고 기억하고 싶은 문장을 기록")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if userAuthManager.isUserAuthenticated {
                            withAnimation {
                                shouldShowOverlay = false
                                activeSheet = .search
                            }
                        } else {
                            showAlert()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider().padding(.horizontal)
                    
                    Button(action: {
                        if userAuthManager.isUserAuthenticated {
                            withAnimation {
                                shouldShowOverlay = false
                                activeSheet = .thema
                            }
                        } else {
                            showAlert()
                        }
                    }) {
                        HStack {

                            Image(systemName: "folder.badge.plus")
                                .font(.title)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading) {
                                Text("테마 만들기")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("테마를 만들어 나의 기록을 분류")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if userAuthManager.isUserAuthenticated {
                            withAnimation {
                                shouldShowOverlay = false
                                activeSheet = .thema
                            }
                        } else {
                            showAlert()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 40)
                .background(Color(.systemBackground).edgesIgnoringSafeArea(.all)) // Ensuring background compatibility with light/dark mode
                .padding(.bottom, geometry.safeAreaInsets.bottom) // Add padding for the bottom safe area
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .frame(width: geometry.size.width)
                .transition(.move(edge: .bottom))
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
        .edgesIgnoringSafeArea(.all) // We want the semi-transparent background to cover the entire screen
        .animation(.easeInOut, value: shouldShowOverlay)
        .zIndex(1) // Keeps the overlay content above the background
        .opacity(shouldShowOverlay ? 1 : 0)
        .onTapGesture {
            withAnimation {
                shouldShowOverlay = false
            }
        }
    }
}
