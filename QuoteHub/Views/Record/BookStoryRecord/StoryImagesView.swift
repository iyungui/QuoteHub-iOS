//
//  StoryImagesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI

struct StoryImagesView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showingImagePicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            cardHeader(title: "이미지 추가", icon: "photo.fill", subtitle: "최대 10장까지 추가 가능")
            
            VStack(spacing: 16) {
                // 이미지 추가 버튼
                addPhotoButton
                
                // 선택된 이미지들
                if !selectedImages.isEmpty {
                    imageGrid
                }
                
                // 이미지 개수 안내
                imageCountInfo
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var addPhotoButton: some View {
        Button(action: {
            if selectedImages.count < 10 {
                showingImagePicker = true
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.brownLeather)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: selectedImages.count >= 10 ? "checkmark" : "plus")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(selectedImages.count >= 10 ? "이미지 가득함" : "사진 추가")
                        .font(.scoreDream(.medium, size: .subheadline))
                        .foregroundColor(.primaryText)
                    
                    Text("\(selectedImages.count)/10")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.paperBeige.opacity(0.5))
                        )
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.paperBeige.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedImages.count >= 10 ? Color.brownLeather.opacity(0.3) : Color.gray.opacity(0.3),
                                style: StrokeStyle(lineWidth: 2, dash: selectedImages.count >= 10 ? [] : [8])
                            )
                    )
            )
        }
        .buttonStyle(CardButtonStyle())
        .disabled(selectedImages.count >= 10)
        .opacity(selectedImages.count >= 10 ? 0.7 : 1.0)
    }
    
    private var imageGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                imageCell(for: image, at: index)
            }
        }
    }
    
    private func imageCell(for image: UIImage, at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            // 이미지
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            
            // 삭제 버튼
            Button(action: {
                selectedImages.remove(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 24, height: 24)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .offset(x: 8, y: -8)
            .scaleEffect(0.9)
            
            // 이미지 순서 번호
            VStack {
                Spacer()
                HStack {
                    Text("\(index + 1)")
                        .font(.scoreDream(.bold, size: .caption2))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .accessibilityLabel("Photo \(index + 1)")
    }
    
    private var imageCountInfo: some View {
        Text(selectedImages.isEmpty ? "이미지를 추가하여 북스토리를 더욱 풍성하게 만들어보세요." : "이미지를 길게 눌러서 순서를 변경할 수 있습니다.")
            .font(.scoreDream(.light, size: .caption))
            .foregroundColor(.secondaryText.opacity(0.8))
            .padding(.horizontal, 4)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.antiqueGold.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private func cardHeader(title: String, icon: String, subtitle: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundColor(.brownLeather)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                }
            }
            
            Spacer()
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.antiqueGold.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 60)
        }
    }
}
