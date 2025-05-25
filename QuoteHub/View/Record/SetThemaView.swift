//
//  SetThemaView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct SetThemaView: View {
    @Binding var selectedFolderIds: [String]
    @StateObject var myFolderViewModel = MyFolderViewModel()
    @Environment(\.presentationMode) var presentationMode

    // 폴더 선택 상태를 관리하는 Set
    @State private var selectedSet = Set<String>()

    var body: some View {
        ScrollView {
            VStack {
                linkMakeThemaView
                Divider()
                listThemaView
            }
        }
        .navigationBarTitle("테마 선택하기", displayMode: .inline)
        .navigationBarItems(trailing: Button("완료") {
            selectedFolderIds = Array(selectedSet)
            self.presentationMode.wrappedValue.dismiss()
        })
    }
    
    private var listThemaView: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("내 테마 목록")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading)
            
            if myFolderViewModel.folder.isEmpty {
                Spacer()
                Text("지금 바로 나만의 테마를 만들어보세요!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            } else {
                let spacing: CGFloat = 20
                let horizontalPadding: CGFloat = 10
                let columns: Int = 2
                let totalSpacing: CGFloat = spacing * CGFloat(columns - 1)
                let screenWidth: CGFloat = UIScreen.main.bounds.width
                let contentWidth: CGFloat = screenWidth - (horizontalPadding * 2) - totalSpacing

                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: columns), spacing: spacing) {
                    ForEach(myFolderViewModel.folder, id: \.id) { folder in
                        Button(action: {
                            // Toggle selection state
                            if selectedSet.contains(folder.id) {
                                selectedSet.remove(folder.id)
                            } else {
                                selectedSet.insert(folder.id)
                            }
                            print("Selected Folders: \(selectedSet)")

                        }) {
                            VStack(alignment: .leading) {
                                WebImage(url: URL(string: folder.folderImageURL))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: contentWidth / CGFloat(columns) - 10, height: (contentWidth / CGFloat(columns)) * 5 / 8)
                                    .cornerRadius(10)
                                    .clipped()
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedSet.contains(folder.id) ? Color.black : Color.clear, lineWidth: 1))
                                
                                Text(folder.name)
                                    .font(.callout)
                                    .fontWeight(.semibold)

                            }
                            .overlay(
                                Image(systemName: selectedSet.contains(folder.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(selectedSet.contains(folder.id) ? Color.black : Color.gray.opacity(0.5))
                                    .padding(4),
                                alignment: .topTrailing
                            )
                        }
                    }
                    if !myFolderViewModel.isLastPage {
                        ProgressView().onAppear {
                            myFolderViewModel.loadMoreIfNeeded(currentItem: myFolderViewModel.folder.last)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top)
            }
            
        }
        .padding(10)
    }
    
    var linkMakeThemaView: some View {
        HStack {
            NavigationLink(destination: SetAndMakeThemaView(myFolderViewModel: myFolderViewModel)) {
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
}
