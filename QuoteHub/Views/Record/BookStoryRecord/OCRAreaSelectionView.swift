//
//  OCRAreaSelectionView.swift
//  QuoteHub
//
//  Created by iyungui on 8/19/25.
//

import SwiftUI

struct OCRAreaSelectionView: View {
    let image: UIImage
    let onAreaSelected: (UIImage) -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var paintedPaths: [PaintedPath] = []
    @State private var currentPath = Path()
    @State private var imageSize = CGSize.zero
    @State private var imageOffset = CGPoint.zero
    @State private var isPainting = false
    
    private let brushSize: CGFloat = 30
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 안내 텍스트
                instructionHeader
                
                // 이미지 색칠 영역
                imagePaintingArea
                
                // 하단 버튼들
                bottomButtons
            }
            .navigationTitle("텍스트 영역 색칠")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        handleCancel()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("지우기") {
                        clearPaintedArea()
                    }
                    .foregroundColor(.orange)
                    .disabled(paintedPaths.isEmpty)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var instructionHeader: some View {
        VStack(spacing: 8) {
            Text("손가락으로 텍스트가 있는 영역을 칠해주세요")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("칠한 영역의 텍스트만 인식됩니다. 여러 영역을 칠할 수 있어요.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var imagePaintingArea: some View {
        GeometryReader { geometry in
            ZStack {
                // 원본 이미지
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(Color.black)
                    .onAppear {
                        calculateImageSize(in: geometry)
                        print("📱 onAppear 호출됨")
                    }
                
                // 칠한 영역 표시 - 직접 Path로 그리기
                ForEach(paintedPaths.indices, id: \.self) { index in
                    paintedPaths[index].path
                        .stroke(
                            Color.blue.opacity(0.6),
                            style: StrokeStyle(
                                lineWidth: brushSize,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                }
                
                // 현재 그리고 있는 경로
                currentPath
                    .stroke(
                        Color.blue.opacity(0.8),
                        style: StrokeStyle(
                            lineWidth: brushSize,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                
                // 터치 테스트용 - 빨간 점 표시
                if isPainting, let lastPoint = getLastPoint() {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .position(lastPoint)
                }
            }
            .clipped()
            .onAppear {
                calculateImageSize(in: geometry)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handlePaintingChanged(value, in: geometry)
                    }
                    .onEnded { value in
                        handlePaintingEnded(value)
                    }
            )
        }
    }
    
    // 터치 테스트용 - 마지막 포인트 가져오기
    private func getLastPoint() -> CGPoint? {
        guard !currentPath.isEmpty else { return nil }
        // 임시로 현재 터치 위치 반환 (실제 구현은 복잡함)
        return CGPoint(x: 100, y: 100) // 테스트용 고정 위치
    }
    
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            if !paintedPaths.isEmpty {
                VStack(spacing: 4) {
                    Text("✅ 영역을 칠했습니다")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Text("더 칠하거나 '텍스트 인식'을 눌러주세요")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            } else {
                Text("텍스트가 있는 영역을 색칠해주세요")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            
            Divider()
            
            HStack(spacing: 16) {
                // 지우기 버튼
                Button {
                    clearPaintedArea()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "eraser")
                            .font(.callout)
                        Text("지우기")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1)
                    )
                }
                .disabled(paintedPaths.isEmpty)
                
                // OCR 시작 버튼
                Button {
                    startOCRForPaintedArea()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.callout)
                        Text("텍스트 인식")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(paintedPaths.isEmpty ? Color.gray : Color.blue)
                    )
                }
                .disabled(paintedPaths.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Painting Logic
    
    private func calculateImageSize(in geometry: GeometryProxy) {
        let containerSize = geometry.size
        let imageAspectRatio = image.size.width / image.size.height
        let containerAspectRatio = containerSize.width / containerSize.height
        
        print("📱 컨테이너 크기: \(containerSize)")
        print("🖼️ 이미지 원본 크기: \(image.size)")
        print("📊 이미지 비율: \(imageAspectRatio), 컨테이너 비율: \(containerAspectRatio)")
        
        if imageAspectRatio > containerAspectRatio {
            // 이미지가 더 넓음 - 너비에 맞춤
            imageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspectRatio
            )
        } else {
            // 이미지가 더 높음 - 높이에 맞춤
            imageSize = CGSize(
                width: containerSize.height * imageAspectRatio,
                height: containerSize.height
            )
        }
        
        // 이미지 오프셋 계산 (중앙 정렬)
        imageOffset = CGPoint(
            x: (containerSize.width - imageSize.width) / 2,
            y: (containerSize.height - imageSize.height) / 2
        )
        
        print("📐 계산된 이미지 크기: \(imageSize)")
        print("📍 계산된 이미지 오프셋: \(imageOffset)")
    }
    
    private func handlePaintingChanged(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        let location = value.location
        
        print("🎨 터치 감지됨! 위치: \(location)")
        
        // 이미지 크기가 계산되지 않았다면 다시 계산
        if imageSize == .zero {
            calculateImageSize(in: geometry)
        }
        
        if !isPainting {
            // 새로운 경로 시작
            currentPath = Path()
            currentPath.move(to: location)
            isPainting = true
            print("🎯 새 경로 시작: \(location)")
        } else {
            // 경로에 점 추가
            currentPath.addLine(to: location)
            print("➕ 경로에 점 추가: \(location)")
        }
        
        print("🖼️ isPainting: \(isPainting)")
    }
    
    private func handlePaintingEnded(_ value: DragGesture.Value) {
        if isPainting {
            // 현재 경로를 완성된 경로 목록에 추가
            let paintedPath = PaintedPath(path: currentPath)
            paintedPaths.append(paintedPath)
            
            print("✅ 경로 완성! 총 경로 수: \(paintedPaths.count)")
            print("📏 경로 바운딩 박스: \(currentPath.boundingRect)")
            
            // 상태 초기화
            currentPath = Path()
            isPainting = false
        }
    }
    
    private func clearPaintedArea() {
        paintedPaths.removeAll()
        currentPath = Path()
        isPainting = false
        print("🧹 모든 경로 지움")
    }
    
    // MARK: - OCR Processing
    
    private func startOCRForPaintedArea() {
        guard !paintedPaths.isEmpty else {
            print("❌ 칠한 경로가 없어서 OCR 불가")
            return
        }
        
        print("🎯 영역 선택 완료 - 크롭 시작")
        print("📊 총 칠한 경로 수: \(paintedPaths.count)")
        
        // 칠한 영역의 바운딩 박스 계산
        guard let boundingRect = calculateBoundingRect() else {
            print("❌ 바운딩 박스 계산 실패")
            return
        }
        
        print("✅ 바운딩 박스 계산 성공: \(boundingRect)")
        
        // 바운딩 박스 영역으로 이미지 크롭
        guard let croppedImage = cropImageToBoundingRect(boundingRect) else {
            print("❌ 이미지 크롭 실패")
            return
        }
        
        print("✅ 칠한 영역 크롭 성공: \(croppedImage.size)")
        print("🚀 크롭된 이미지를 OCR 처리를 위해 전달...")
        
        // 크롭된 이미지를 StoryFormViewModel로 전달 (OCR 처리는 거기서)
        onAreaSelected(croppedImage)
        dismiss()
    }
    
    private func calculateBoundingRect() -> CGRect? {
        guard !paintedPaths.isEmpty else {
            print("❌ 칠한 경로가 없음")
            return nil
        }
        
        // 모든 경로의 바운딩 박스를 합치기
        var combinedBounds: CGRect?
        
        for paintedPath in paintedPaths {
            let pathBounds = paintedPath.path.boundingRect
            print("📦 개별 경로 바운딩 박스: \(pathBounds)")
            
            if combinedBounds == nil {
                combinedBounds = pathBounds
            } else {
                combinedBounds = combinedBounds!.union(pathBounds)
            }
        }
        
        guard let bounds = combinedBounds else {
            print("❌ 바운딩 박스 계산 실패")
            return nil
        }
        
        print("📦 전체 바운딩 박스: \(bounds)")
        print("🖼️ 현재 이미지 오프셋: \(imageOffset)")
        print("📐 현재 이미지 크기: \(imageSize)")
        
        // 바운딩 박스가 유효한지 확인
        if bounds.width <= 0 || bounds.height <= 0 {
            print("❌ 유효하지 않은 바운딩 박스 크기")
            return nil
        }
        
        // 패딩 추가 (브러시 크기의 절반)
        let padding = brushSize / 2
        let paddedBounds = CGRect(
            x: bounds.origin.x - padding,
            y: bounds.origin.y - padding,
            width: bounds.width + padding * 2,
            height: bounds.height + padding * 2
        )
        
        print("📦 패딩 추가된 바운딩 박스: \(paddedBounds)")
        return paddedBounds
    }
    
    private func cropImageToBoundingRect(_ rect: CGRect) -> UIImage? {
        print("📍 화면 좌표 바운딩 박스: \(rect)")
        
        // 화면 좌표를 이미지 좌표로 변환
        // 1. 화면에서 이미지가 차지하는 실제 영역의 크기와 위치를 고려
        // 2. 원본 이미지 크기로 스케일링
        
        // 화면에서 이미지 영역의 시작점 (중앙 정렬로 인한 오프셋)
        let displayImageRect = CGRect(
            x: imageOffset.x,
            y: imageOffset.y,
            width: imageSize.width,
            height: imageSize.height
        )
        
        print("📦 화면상 이미지 영역: \(displayImageRect)")
        
        // 바운딩 박스와 이미지 영역의 교집합 구하기
        let clippedRect = rect.intersection(displayImageRect)
        
        guard !clippedRect.isEmpty else {
            print("❌ 바운딩 박스가 이미지 영역과 겹치지 않음")
            return nil
        }
        
        print("✂️ 클리핑된 바운딩 박스: \(clippedRect)")
        
        // 이미지 영역 내에서의 상대 좌표로 변환
        let relativeRect = CGRect(
            x: clippedRect.origin.x - imageOffset.x,
            y: clippedRect.origin.y - imageOffset.y,
            width: clippedRect.width,
            height: clippedRect.height
        )
        
        print("📐 상대 좌표: \(relativeRect)")
        
        // 원본 이미지 크기로 스케일링
        let scaleX = image.size.width / imageSize.width
        let scaleY = image.size.height / imageSize.height
        
        let scaledRect = CGRect(
            x: relativeRect.origin.x * scaleX,
            y: relativeRect.origin.y * scaleY,
            width: relativeRect.width * scaleX,
            height: relativeRect.height * scaleY
        )
        
        print("🔍 스케일된 크롭 영역: \(scaledRect)")
        print("📏 원본 이미지 크기: \(image.size)")
        print("📊 스케일 비율: x=\(scaleX), y=\(scaleY)")
        
        // 유효성 검사
        guard scaledRect.width > 0 && scaledRect.height > 0,
              scaledRect.origin.x >= 0 && scaledRect.origin.y >= 0,
              scaledRect.maxX <= image.size.width && scaledRect.maxY <= image.size.height,
              let cgImage = image.cgImage else {
            print("❌ 크롭 실패: 잘못된 좌표")
            print("  - 너비: \(scaledRect.width), 높이: \(scaledRect.height)")
            print("  - 시작점: (\(scaledRect.origin.x), \(scaledRect.origin.y))")
            print("  - 끝점: (\(scaledRect.maxX), \(scaledRect.maxY))")
            print("  - 이미지 크기: \(image.size)")
            return nil
        }
        
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            print("❌ CGImage 크롭 실패")
            return nil
        }
        
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
        
        print("✅ 크롭 성공: \(croppedImage.size)")
        return croppedImage
    }
    
    // MARK: - Actions
    
    private func handleCancel() {
        onCancel()
        dismiss()
    }
}

// MARK: - Supporting Types

struct PaintedPath {
    let path: Path
    let id = UUID()
}

#Preview {
    OCRAreaSelectionView(
        image: UIImage(systemName: "photo")!,
        onAreaSelected: { image in
            print("선택된 영역 이미지: \(image.size)")
        },
        onCancel: {
            print("취소됨")
        }
    )
}
