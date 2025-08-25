//
//  FontSettingsView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/28/25.
//

import SwiftUI

struct FontSettingsView: View {
    @State private var selectedFont: FontType = FontManager.currentFontType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                selectedFontPreview
                    .padding([.horizontal, .top])
                    .padding(.bottom, 5)
                selectFontSection
            }
            .navigationTitle("폰트 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        FontManager.changeFontType(to: selectedFont)
                    } label: {
                        Text("확인")
                            .font(.appHeadline)
                    }
                }
            }
        }
    }
    
    /// 현재 선택된 폰트로 미리보기
    private var selectedFontPreview: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("안녕하세요! 문장모아입니다.")
                .font(.appFont(.bold, size: .title2, font: selectedFont))
                .multilineTextAlignment(.center)
            
            Text("이 텍스트는 현재 선택된 폰트로 표시됩니다.")
                .font(.appFont(.regular, size: .body, font: selectedFont))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondary)
            
            Text("이 텍스트는 현재 선택된 폰트로 표시됩니다.")
                .font(.appFont(.light, size: .caption, font: selectedFont))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.warmBeige.opacity(0.7))
        .cornerRadius(30, corners: [.bottomRight, .topLeft])
    }
    
    /// 폰트 선택 섹션
    private var selectFontSection: some View {
        List {
            Section {
                ForEach(FontType.allCases, id: \.self) { fontType in
                    Toggle(isOn: Binding(
                        get: { selectedFont == fontType }, // 현재 폰트와 같으면 선택됨
                        set: { _ in selectedFont = fontType } // 토글하면 해당 폰트로 변경
                    )) {
                        Text(fontType.displayName)
                            .font(.appFont(.bold, size: .body, font: fontType))
                            .foregroundStyle(Color.primary)
                    }
                    .toggleStyle(CheckboxStyle())
                }
            } header: {
                Text("폰트 선택").font(.appCaption)
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(
                        """
                        모든 폰트는 해당 저작권자의 라이선스를 따릅니다.
                        
                        - 프리텐다드 (길형진 (orioncactus))
                        - 에스코어드림 (S-Core)
                        - 고운바탕 (류양희)
                        - 리디바탕 (리디주식회사)
                        - 조선일보명조체 (조선일보)
                        """
                    )
                        .font(.appFont(.thin, size: .caption2))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.top, 12)
            }
        }
//        .listStyle(.grouped)
        .scrollDisabled(FontType.allCases.count <= 5)   // 폰트가 5개 미만일 때 리스트뷰에서 스크롤 비활성화
    }
}

#Preview {
    NavigationStack {
        FontSettingsView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
