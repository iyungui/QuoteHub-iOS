//
//  CustomProgressView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/4/25.
//

import SwiftUI
import Lottie

// MARK: - VIEW

struct CustomProgressView: View {
    let animationName: String
    let message: String?
    let size: CGSize
    let loopMode: LottieLoopMode
    
    init(
        animationName: String,
        message: String? = nil,
        size: CGSize = CGSize(width: 100, height: 100),
        loopMode: LottieLoopMode = .loop
    ) {
        self.animationName = animationName
        self.message = message
        self.size = size
        self.loopMode = loopMode
    }
    
    var body: some View {
        VStack(spacing: 16) {
            LottieView(animation: .named(animationName))
                .playing(loopMode: loopMode)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)

            
            if let message = message {
                Text(message)
                    .font(.appFont(.medium, size: .subheadline))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - VIEW MODIFIER

/// 하나의 뷰모델 사용하는 로딩뷰 모디파이어
struct ProgressOverlay<VM: LoadingViewModelProtocol>: ViewModifier {
    @ObservedObject var viewModel: VM
    let animationName: String
    let opacity: Bool
    
    func body(content: Content) -> some View {
        content
            // 화면 전체로 확장
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ZStack {
                            if opacity {
                                // 화면 전체를 덮는 반투명 배경
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea(.all)
                            }
                            // Progress View
                            CustomProgressView(
                                animationName: animationName,
                                message: viewModel.loadingMessage,
                                size: CGSize(width: 100, height: 100)
                            )
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    }
                }
            )
    }
}

/// 여러 뷰모델을 사용하는 로딩뷰 모디파이어
struct MultipleProgressOverlay: ViewModifier {
    let loadingViewModels: [any LoadingViewModelProtocol]
    let animationName: String
    let opacity: Bool
    
    // 하나라도 로딩 중이면 true
    private var isLoading: Bool {
        loadingViewModels.contains { $0.isLoading }
    }
    
    // 로딩 메시지
    private var loadingMessage: String? {
        "로딩 중..."
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Group {
                    if isLoading {
                        ZStack {
                            if opacity {
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea(.all)
                            }
                            
                            CustomProgressView(
                                animationName: animationName,
                                message: loadingMessage,
                                size: CGSize(width: 100, height: 100)
                            )
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: isLoading)
                    }
                }
            }
    }
}

// MARK: - VIEW EXTENSION

extension View {
    /// 단일 ViewModel 에서의 로딩뷰
    func progressOverlay<VM: LoadingViewModelProtocol>(
        viewModel: VM,
        animationName: String = "progressLottie",
        opacity: Bool
    ) -> some View {
        self.modifier(ProgressOverlay(viewModel: viewModel, animationName: animationName, opacity: opacity))
    }
    
    /// 여러 ViewModel 에서의 로딩뷰
    func progressOverlay(
        viewModels: any LoadingViewModelProtocol...,
        animationName: String = "progressLottie",
        opacity: Bool
    ) -> some View {
        self.modifier(MultipleProgressOverlay(
            loadingViewModels: viewModels,
            animationName: animationName,
            opacity: opacity
        ))
    }
}
