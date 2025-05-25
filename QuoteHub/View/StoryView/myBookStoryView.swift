//
//  BookStoryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/12.
//

import SwiftUI
import SDWebImageSwiftUI

struct myBookStoryView: View {
    let storyId: String
    
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @StateObject private var commentViewModel: CommentViewModel
    
    init(storyId: String) {
        self.storyId = storyId
        self._commentViewModel = StateObject(wrappedValue: CommentViewModel(bookStoryId: storyId))
    }
    
    @State private var isEditing = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showActionSheet = false
    
    @State private var isMarked = false
    
    @State private var isExpanded: Bool = false
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        if let story = myStoriesViewModel.bookStories.first(where: { $0.id == storyId }) {
            ScrollView {
                NavigationLink(destination: UpdateStoryView(storyId: story.id).environmentObject(myStoriesViewModel).environmentObject(userViewModel), isActive: $isEditing) {
                    EmptyView()
                }
                VStack {
                    // PAGE 1
                    Divider()
                    // keywordView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(story.keywords ?? [], id: \.self) { keyword in
                                Text("#\(keyword)")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.leading, 20)
                    }
                    .padding(.top, 10)
                    
                    //quoteView
                    VStack(alignment: .center, spacing: 10) {
                        HStack {
                            Text("“")
                                .font(.largeTitle)
                                .fontWeight(.black)
                            Spacer()
                        }
                        
                        Text(story.quote ?? "")
                            .frame(minHeight: 100)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            Text("”")
                                .font(.largeTitle)
                                .fontWeight(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    
                    //storyImagesView
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        
                        TabView {
                            ForEach(story.storyImageURLs ?? [], id: \.self) { index in
                                WebImage(url: URL(string: index))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: width)
                                    .clipped()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(width: width, height: width)
                    }
                    .frame(height: UIScreen.main.bounds.width)
                    
                    // profileView
                    HStack {
                        if let url = URL(string: userViewModel.user?.profileImage ?? ""), !(userViewModel.user?.profileImage ?? "").isEmpty {
                            WebImage(url: url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Text(userViewModel.user?.nickname ?? "닉네임 없음")
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Text(userViewModel.user?.statusMessage ?? "")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .padding(.all, 10)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // storyContentView
                    VStack(alignment: .leading) {
                        Text(story.content ?? "Content")
                            .font(.body)
                            .frame(minHeight: 50)
                            .padding()
                    }
                    .padding(.horizontal)
                    
                    // PAGE 2
                    
                        Button(action: {
                            self.showAlert = true
                        }) {
                            // infoBookView
                            HStack {
                                WebImage(url: URL(string: story.bookId.bookImageURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 100)
                                    .cornerRadius(4)
                                    .shadow(radius: 3)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(story.bookId.title)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    
                                    Text(story.bookId.author.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(story.bookId.publisher)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 10)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)

                            }
                            .padding(.all, 10)
                            .padding(.horizontal)
                        }
                        .buttonStyle(MyActionButtonStyle())
                    
                    Spacer().frame(minHeight: 50)
                    HStack {
                        Spacer()
                        
                        Text(story.isPublic ? "공개" : "비공개")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Image(systemName: story.isPublic ? "lock.open.fill" : "lock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing)

                        Text("작성일: \(story.updatedAtDate)")
                            .padding(.trailing)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Divider()
                    
                    VStack {
                        // Wrapping HStack in Button
                        Button(action: {
                            isExpanded.toggle()
                        }) {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.accentColor)
                                    .padding()
                                Text("\(commentViewModel.totalCommentCount)")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }   //: VSTACK
            }   // SCROLL
            .alert(isPresented: $showAlert) {
                 Alert(
                     title: Text("외부 사이트로 이동"),
                     message: Text("이 책에 대한 추가 정보를 외부 사이트에서 제공합니다. 외부 링크를 통해 해당 정보를 보시겠습니까?"),
                     primaryButton: .default(Text("확인")) {
                         if let url = URL(string: story.bookId.bookLink) {
                             UIApplication.shared.open(url)
                         }
                     },
                     secondaryButton: .cancel()
                 )
             }
            .navigationBarItems(trailing:
                                    Button(action: {
                showActionSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            })
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("선택"), buttons: [
                    .default(Text("수정하기"), action: {
                        isEditing = true
                    }),
                    .destructive(Text("삭제하기"), action: {
                        myStoriesViewModel.deleteBookStory(storyID: story.id) { isSuccess in
                            if isSuccess {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }),
                    .cancel() // 취소 버튼
                ])
            }
            .sheet(isPresented: $isExpanded) {
                CommentView(viewModel: commentViewModel)
            }
            .refreshable {
                commentViewModel.refreshComments()
            }
            .onTapGesture {
                hideKeyboard()
            }
        } else {
            Text("해당 북스토리를 찾을 수 없습니다.")
        }
    }
}
