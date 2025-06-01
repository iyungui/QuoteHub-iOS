//
//  SetThemeView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 북스토리 생성 4 (option): 테마 선택/만들기링크 뷰

struct SetThemeView: View {
    
    // MARK: - PROPERTIES
    
    @Binding var selectedThemeIds: [String]
    @StateObject var themesViewModel = ThemesViewModel()
    @Environment(\.dismiss) var dismiss
    
    // 테마 선택 상태를 관리하는 Set
    @State private var selectedSet = Set<String>()
    
    // MARK: - BODY
    
    var body: some View {
        ScrollView {
            VStack {
                linkMakeThemeView
                Divider()
                listThemeView
            }
        }
        .navigationBarTitle("테마 선택하기", displayMode: .inline)
        .navigationBarItems(trailing: Button("완료") {
            selectedThemeIds = Array(selectedSet)
            dismiss()
        })
    }
    
    // 테마 만들기
    var linkMakeThemeView: some View {
        HStack {
            NavigationLink(
                destination: CreateThemeView(mode: .embedded)
                    .environmentObject(themesViewModel)
            ) {
                Text("새 테마 만들기")
                    .font(.callout)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.callout)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top)
    }
    
    // 테마 리스트
    private var listThemeView: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("내 테마 목록")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading)
            
            if themesViewModel.themes.isEmpty {
                emptyThemeListView
            } else {
//                themeGridListView
            }
            
        }
        .padding(10)
    }
    
    private var emptyThemeListView: some View {
        Text("지금 바로 나만의 테마를 만들어보세요!")
            .font(.headline)
            .foregroundColor(.gray)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
//    private var themeGridListView: some View {
//        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 20) {
//            ForEach(themesViewModel.folder, id: \.id) { folder in
//                Button(action: {
//                    if selectedSet.contains(folder.id) {
//                        selectedSet.remove(folder.id)
//                    } else {
//                        selectedSet.insert(folder.id)
//                    }
//                }) {
//                    VStack(alignment: .leading) {
//                        WebImage(url: URL(string: folder.folderImageURL))
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: (UIScreen.main.bounds.width / 2) - 25, height: ((UIScreen.main.bounds.width / 2) - 25) * 5 / 8)
//                            .cornerRadius(10)
//                            .clipped()
//                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedSet.contains(folder.id) ? Color.black : Color.clear, lineWidth: 1))
//                        
//                        Text(folder.name)
//                            .font(.callout)
//                            .fontWeight(.semibold)
//                    }
//                    .overlay(
//                        Image(systemName: selectedSet.contains(folder.id) ? "checkmark.circle.fill" : "circle")
//                            .font(.title2)
//                            .foregroundColor(selectedSet.contains(folder.id) ? Color.black : Color.gray.opacity(0.5))
//                            .padding(4),
//                        alignment: .topTrailing
//                    )
//                }
//            }
//            
//            if !themesViewModel.isLastPage {
//                ProgressView().onAppear {
//                    themesViewModel.loadMoreIfNeeded(currentItem: themesViewModel.themes.last)
//                }
//            }
//        }
//        .padding(.horizontal, 10)
//        .padding(.top)
//    }
}
