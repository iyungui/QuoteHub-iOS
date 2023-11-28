////
////  NotificationsView.swift
////  QuoteHub
////
////  Created by 이융의 on 11/5/23.
////
//
//import SwiftUI
//
//// Define an enum for notification types
//enum NotificationType {
//    case follow, comment
//}
//
//// Extend the NotificationItem to handle different types and user information
//struct NotificationItem: Identifiable {
//    let id = UUID()
//    let type: NotificationType
//    let title: String
//    let description: String
//    let timestamp: Date
//    let profileImage: String
//    let nickname: String
//}
//
//struct NotificationsView: View {
//    // Sample notifications with user info
//    @State private var notifications: [NotificationItem] = [
//        NotificationItem(type: .follow, title: "팔로우 요청", description: "융의님이 회원님을 팔로우하기 시작했습니다.", timestamp: Date(), profileImage: "dev_profile", nickname: "융의"),
//        NotificationItem(type: .comment, title: "새 댓글", description: "융의님이 회원님의 북스토리에 댓글을 달았습니다.", timestamp: Date().addingTimeInterval(-86400), profileImage: "dev_profile", nickname: "융의"),
//        NotificationItem(type: .follow, title: "팔로우 요청", description: "융의님이 회원님을 팔로우하기 시작했습니다.", timestamp: Date(), profileImage: "dev_profile", nickname: "융의"),
//        NotificationItem(type: .comment, title: "새 댓글", description: "융의님이 회원님의 북스토리에 댓글을 달았습니다.", timestamp: Date().addingTimeInterval(-86400), profileImage: "dev_profile", nickname: "융의")
//    ]
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(notifications) { notification in
//                    NotificationRow(notification: notification)
//                }
//                .onDelete(perform: delete)
//            }
//            .navigationTitle("Notifications")
//        }
//        .refreshable {
//            // Handle the refresh action here
//        }
//    }
//    private func delete(at offsets: IndexSet) {
//        notifications.remove(atOffsets: offsets)
//    }
//}
//
//// Define a view for a single notification row
//struct NotificationRow: View {
//    var notification: NotificationItem
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            // Profile image
//            Image(notification.profileImage)
//                .resizable()
//                .scaledToFill()
//                .clipped()
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(notification.description)
//                    .font(.subheadline)
//                // Timestamp
//                Text("\(notification.timestamp, style: .time)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//// Preview of the NotificationsView
//struct NotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationsView()
//    }
//}
