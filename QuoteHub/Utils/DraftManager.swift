//
//  DraftManager.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftData
import SwiftUI

@Observable
final class DraftManager {
    private let modelContext: ModelContext
    private var autoSaveTimer: Timer?
    private let autoSaveDelay: TimeInterval = 3.0
    
    // 에러 상태
    var lastError: Error?
    var isLoading = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    deinit {
        stopAutoSave()
    }
    
    // MARK: - Public Methods
    
    /// 현재 임시저장이 있는지 확인
    @MainActor
    func hasDraft(for bookId: String) async -> Bool {
        let descriptor = FetchDescriptor<DraftStory>(
            predicate: #Predicate { $0.bookId == bookId }
        )
        
        do {
            let drafts = try modelContext.fetch(descriptor)
            return !drafts.isEmpty
        } catch {
            print("Draft check error: \(error)")
            return false
        }
    }
    
    /// 임시저장 데이터 불러오기 (추가된 메서드)
    @MainActor
    func loadDraft(for bookId: String) async -> DraftStory? {
        let descriptor = FetchDescriptor<DraftStory>(
            predicate: #Predicate { $0.bookId == bookId }
        )
        
        do {
            let drafts = try modelContext.fetch(descriptor)
            return drafts.first
        } catch {
            print("Draft load error: \(error)")
            lastError = error
            return nil
        }
    }
    
    /// 임시저장을 StoryFormViewModel에 적용
    @MainActor
    func applyDraftToViewModel(_ draft: DraftStory, viewModel: StoryFormViewModel) {
        viewModel.keywords = draft.keywords
        viewModel.quotes = draft.quotes.isEmpty ? [Quote(quote: "", page: nil)] : draft.quotes
        viewModel.content = draft.content
        viewModel.isPublic = draft.isPublic
        viewModel.themeIds = draft.themeIds
        
        // 이미지 데이터를 UIImage로 변환
        viewModel.selectedImages = convertDataToImages(draft.imageData)
    }
    
    /// 임시저장 저장/업데이트 (기존 것이 있으면 덮어쓰기)
    func saveDraft(
        bookId: String,
        bookTitle: String,
        bookAuthor: String = "",
        bookImageURL: String = "",
        keywords: [String],
        quotes: [Quote],
        content: String,
        isPublic: Bool,
        themeIds: [String],
        images: [UIImage]
    ) {
        Task { @MainActor in
            await performSave(
                bookId: bookId,
                bookTitle: bookTitle,
                bookAuthor: bookAuthor,
                bookImageURL: bookImageURL,
                keywords: keywords,
                quotes: quotes,
                content: content,
                isPublic: isPublic,
                themeIds: themeIds,
                images: images
            )
        }
    }
    
    /// StoryFormViewModel로부터 임시저장
    @MainActor
    func saveDraftFromViewModel(
        book: Book,
        viewModel: StoryFormViewModel
    ) async {
        await performSave(
            bookId: book.id,
            bookTitle: book.title,
            bookAuthor: book.author.joined(separator: ", "),
            bookImageURL: book.bookImageURL,
            keywords: viewModel.keywords,
            quotes: viewModel.quotes.filter { !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            content: viewModel.content,
            isPublic: viewModel.isPublic,
            themeIds: viewModel.themeIds,
            images: viewModel.selectedImages
        )
    }
    
    /// Book 객체로부터 새 임시저장 생성
    func createDraftFromBook(_ book: Book) -> DraftStory {
        // 기존 임시저장 삭제
        clearDraft(for: book.id)
        
        let draft = DraftStory(from: book)
        modelContext.insert(draft)
        
        do {
            try modelContext.save()
            print("새 임시저장 생성 성공")
        } catch {
            print("새 임시저장 생성 실패: \(error)")
            lastError = error
        }
        
        return draft
    }
    
    /// 특정 책의 임시저장 삭제
    func clearDraft(for bookId: String? = nil) {
        do {
            let descriptor: FetchDescriptor<DraftStory>
            
            if let bookId = bookId {
                descriptor = FetchDescriptor<DraftStory>(
                    predicate: #Predicate { $0.bookId == bookId }
                )
            } else {
                descriptor = FetchDescriptor<DraftStory>()
            }
            
            let drafts = try modelContext.fetch(descriptor)
            
            for draft in drafts {
                modelContext.delete(draft)
            }
            
            try modelContext.save()
            print("임시저장 삭제 성공")
        } catch {
            print("임시저장 삭제 실패: \(error)")
            lastError = error
        }
    }
    
    /// 모든 임시저장 삭제
    func clearAllDrafts() {
        clearDraft()
    }
    
    /// 최종 저장 후 임시저장 삭제
    @MainActor
    func finalizeAndClearDraft(
        for bookId: String,
        onSave: @escaping () async throws -> Void
    ) async throws {
        do {
            try await onSave()
            clearDraft(for: bookId)
            print("최종 저장 완료 및 임시저장 삭제")
        } catch {
            print("최종 저장 실패: \(error)")
            lastError = error
            throw error
        }
    }
    
    // MARK: - Auto Save
    
    /// 자동저장 시작
    func startAutoSave(
        bookId: String,
        bookTitle: String,
        bookAuthor: String = "",
        bookImageURL: String = "",
        keywords: [String],
        quotes: [Quote],
        content: String,
        isPublic: Bool,
        themeIds: [String],
        images: [UIImage]
    ) {
        stopAutoSave()
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveDelay, repeats: false) { [weak self] _ in
            self?.saveDraft(
                bookId: bookId,
                bookTitle: bookTitle,
                bookAuthor: bookAuthor,
                bookImageURL: bookImageURL,
                keywords: keywords,
                quotes: quotes,
                content: content,
                isPublic: isPublic,
                themeIds: themeIds,
                images: images
            )
        }
    }
    
    /// ViewModel을 이용한 자동저장 시작
    func startAutoSaveFromViewModel(
        book: Book,
        viewModel: StoryFormViewModel
    ) {
        stopAutoSave()
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveDelay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.saveDraftFromViewModel(book: book, viewModel: viewModel)
            }
        }
    }
    
    /// 자동저장 중지
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func performSave(
        bookId: String,
        bookTitle: String,
        bookAuthor: String,
        bookImageURL: String,
        keywords: [String],
        quotes: [Quote],
        content: String,
        isPublic: Bool,
        themeIds: [String],
        images: [UIImage]
    ) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 기존 임시저장 삭제 (해당 책의 것만)
            clearDraft(for: bookId)
            
            // 이미지 압축 처리
            let compressedImageData = await compressImages(images)
            
            // 새 임시저장 생성
            let draft = DraftStory(
                bookId: bookId,
                bookTitle: bookTitle,
                bookAuthor: bookAuthor,
                bookImageURL: bookImageURL,
                keywords: keywords,
                quotes: quotes,
                content: content,
                isPublic: isPublic,
                themeIds: themeIds,
                imageData: compressedImageData
            )
            
            modelContext.insert(draft)
            try modelContext.save()
            
            print("임시저장 성공 - 키워드: \(keywords.count), 이미지: \(images.count)")
            
        } catch {
            print("임시저장 실패: \(error)")
            lastError = error
        }
    }
    
    /// 이미지 압축 처리 (메모리 최적화)
    private func compressImages(_ images: [UIImage]) async -> [Data] {
        await withTaskGroup(of: Data?.self) { group in
            for image in images {
                group.addTask {
                    return await self.compressImage(image)
                }
            }
            
            var compressedData: [Data] = []
            for await data in group {
                if let data = data {
                    compressedData.append(data)
                }
            }
            return compressedData
        }
    }
    
    /// 개별 이미지 압축
    private func compressImage(_ image: UIImage) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                // 이미지 리사이징 (최대 1024x1024)
                let maxSize: CGFloat = 1024
                let resizedImage = self.resizeImage(image, to: maxSize)
                
                // JPEG 압축 (품질 0.7)
                let compressedData = resizedImage.jpegData(compressionQuality: 0.7)
                
                DispatchQueue.main.async {
                    continuation.resume(returning: compressedData)
                }
            }
        }
    }
    
    /// 이미지 리사이징
    private func resizeImage(_ image: UIImage, to maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// 압축된 Data를 UIImage 배열로 변환
    func convertDataToImages(_ imageData: [Data]) -> [UIImage] {
        return imageData.compactMap { UIImage(data: $0) }
    }
}
