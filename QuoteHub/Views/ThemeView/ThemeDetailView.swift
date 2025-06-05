//
//  ThemeDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 테마 상세 뷰 (isMy 가 true인 경우, 수정하기 버튼 활성화
struct ThemeDetailView: View {
    
    // MARK: - PROPERTIES
    
    let theme: Theme
    let isMy: Bool

    private var loadType: LoadType {
        return isMy ? .my : .public
    }
    
    init(theme: Theme, isMy: Bool) {
        self.theme = theme
        self.isMy = isMy
        _storiesViewModel = StateObject(wrappedValue: BookStoriesViewModel(themeId: theme.id))
    }
    
    @State private var selectedTheme: Int = 0
    @State private var showActionSheet: Bool = false
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var storiesViewModel: BookStoriesViewModel

    @State private var isEditing = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode

    // MARK: - BODY
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            NavigationLink(
                // TODO: - update theme view 추가하기
//                destination: UpdateThemaView(folderId: theme.id)
//                    .environmentObject(themesViewModel)
//                , isActive: $isEditing
                
                destination: EmptyView()
            ) {
                EmptyView()
            }
            VStack(spacing: 0) {
                ThemeImageView(theme: theme, selectedTheme: $selectedTheme)
                    .environmentObject(themesViewModel)
                
                tabIndicator(height: 3, selectedView: selectedTheme)
                
                Group {
                    if selectedTheme == 0 {
                        ThemeGalleryGridView(isMy: isMy, loadType: loadType)
                            .environmentObject(userViewModel)
                            .environmentObject(storiesViewModel)

                    } else {
                        ThemeGalleryListView(isMy: isMy, loadType: loadType)
                            .environmentObject(userViewModel)
                            .environmentObject(storiesViewModel)
                    }
                }
            }
        }
        .refreshable {
            // TODO: - Handle refresh action
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        })
        .navigationBarTitle("나의 테마별 모아보기", displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 25, height: 25)
        }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("선택"), buttons: [
                    .default(Text("수정하기"), action: {
                        isEditing = true
                    }),
                    .destructive(Text("삭제하기"), action: {
                        themesViewModel.deleteFolder(folderId: theme.id) { isSuccess in
                            if isSuccess {
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                alertMessage = "테마 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                                showAlert = true
                            }
                        }
                    }),
                    .cancel() // 취소 버튼
                ])
            }
        )
    }
    
}

// MARK: - THEME IMAGE VIEW

struct ThemeImageView: View {
    let theme: Theme
    @Binding var selectedTheme: Int
    @EnvironmentObject private var themesViewModel: ThemesViewModel


    var body: some View {
        ZStack {
            
            if let url = URL(string: theme.themeImageURL), !theme.themeImageURL.isEmpty {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            } else {
                Color.gray
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            }

            GeometryReader { geometry in
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text(theme.name)
                            .font(.title)
                            .foregroundColor(.white)
                        Text(theme.description)
                            .font(.body)
                            .foregroundColor(.white)
                        Text("작성일: \(theme.updatedAt.prefix(10))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding([.top, .leading], 20)
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Text(theme.isPublic ? "공개" : "비공개")
                        .font(.caption)
                        .foregroundColor(.white)
                    Image(systemName: theme.isPublic ? "lock.open.fill" : "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            self.selectedTheme = 0
                        }
                    }) {
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(selectedTheme == 0 ? Color.appAccent : .gray)
                            .scaleEffect(selectedTheme == 0 ? 1.2 : 1.0)
                    }

                    Button(action: {
                        withAnimation {
                            self.selectedTheme = 1
                        }
                    }) {
                        Image(systemName: "list.dash")
                            .foregroundColor(selectedTheme == 1 ? Color.appAccent : .gray)
                            .scaleEffect(selectedTheme == 1 ? 1.2 : 1.0)
                    }
                }
                .padding([.horizontal, .bottom], 20)
            }
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        .clipped()
    }
}


