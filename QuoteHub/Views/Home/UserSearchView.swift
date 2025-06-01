//
//  UserSearchView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 홈뷰 -> 유저 검색
struct UserSearchView: View {
    @State private var searchNickname: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var isActioned: Bool = false
    @StateObject var viewModel = UserSearchViewModel()
    
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    enum Field: Hashable {
        case searchNickname
    }
    
    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
            searchField
            Divider()
            resultsListView
            Spacer()
        }
        .padding()
        .navigationBarTitle("사용자 검색", displayMode: .inline)
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
    
    private func searchWithNickname() {
        self.isActioned = true
        viewModel.users.removeAll()
        viewModel.searchUser(nickname: searchNickname)
    }

    private var searchField: some View {
        VStack(spacing: 15) {

            HStack {
                TextField("사용자의 닉네임을 입력하세요", text: $searchNickname)
                    .focused($focusField, equals: .searchNickname)
                    .submitLabel(.done)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        searchWithNickname()
                    }
                
                Button(action: {
                    searchWithNickname()
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .onSubmit {
            switch focusField {
            case .searchNickname:
                searchWithNickname()
            default:
                break
            }
        }
    }
    
    private var resultsListView: some View {
        ScrollView {
            if viewModel.users.isEmpty && isActioned {
                Text("검색결과가 없습니다.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top)
            } else {
                ForEach(viewModel.users, id: \.id) { user in
                    NavigationLink(
                        destination: LibraryView(user: user)
                            .environmentObject(userAuthManager)
                            .environmentObject(userViewModel)
                            .environmentObject(storiesViewModel)
                            .environmentObject(themesViewModel)
                    ) {
                        ProfileRowView(user: user)
                    }
                }
            }
        }
    }
}

struct ProfileRowView: View {
    let user: User
    
    var body: some View {
        HStack {
            
            if let url = URL(string: user.profileImage), !user.profileImage.isEmpty {
                WebImage(url: URL(string: user.profileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 1)
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .padding(.trailing, 5)

            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 5)
            }
            
            VStack(alignment: .leading) {
                Text(user.nickname)
                    .font(.headline)
            }
            
            Spacer()
        }
    }
}


