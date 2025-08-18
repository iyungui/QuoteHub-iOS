//
//  UniversalImagePicker.swift
//  QuoteHub
//
//  Created by iyungui on 8/18/25.
//

import SwiftUI
import PhotosUI
import Photos
import AVFoundation

// MARK: - Configuration

struct ImagePickerConfig {
    let sourceType: SourceType
    let selectionMode: SelectionMode
    let resultHandler: ResultHandler
    
    enum SourceType {
        case camera
        case gallery
    }
    
    enum SelectionMode {
        case single
        case multiple(limit: Int)
    }
    
    enum ResultHandler {
        case binding(Binding<[UIImage]>)           // 기존 방식: 배열에 추가
        case singleBinding(Binding<UIImage?>)      // 단일 이미지 바인딩
        case callback((UIImage) -> Void)           // OCR용: 즉시 콜백
        case multiCallback(([UIImage]) -> Void)    // 다중 이미지 콜백
    }
}

// MARK: - Universal ImagePicker

struct UniversalImagePicker: UIViewControllerRepresentable {
    let config: ImagePickerConfig
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Convenience Initializers
    
    /// 기존 ImagePicker 대체 (카메라/갤러리 → 배열에 추가)
    static func legacy(
        selectedImages: Binding<[UIImage]>,
        sourceType: UIImagePickerController.SourceType
    ) -> UniversalImagePicker {
        return UniversalImagePicker(config: ImagePickerConfig(
            sourceType: sourceType == .camera ? .camera : .gallery,
            selectionMode: .single,
            resultHandler: .binding(selectedImages)
        ))
    }
    
    /// 기존 MultipleImagePicker 대체
    static func multiple(
        selectedImages: Binding<[UIImage]>,
        limit: Int
    ) -> UniversalImagePicker {
        return UniversalImagePicker(config: ImagePickerConfig(
            sourceType: .gallery,
            selectionMode: .multiple(limit: limit),
            resultHandler: .binding(selectedImages)
        ))
    }
    
    /// 기존 SingleImagePicker 대체
    static func single(
        selectedImage: Binding<UIImage?>
    ) -> UniversalImagePicker {
        return UniversalImagePicker(config: ImagePickerConfig(
            sourceType: .gallery,
            selectionMode: .single,
            resultHandler: .singleBinding(selectedImage)
        ))
    }
    
    /// OCR용 카메라
    static func ocrCamera(
        onImageSelected: @escaping (UIImage) -> Void
    ) -> UniversalImagePicker {
        return UniversalImagePicker(config: ImagePickerConfig(
            sourceType: .camera,
            selectionMode: .single,
            resultHandler: .callback(onImageSelected)
        ))
    }
    
    /// OCR용 갤러리
    static func ocrGallery(
        onImageSelected: @escaping (UIImage) -> Void
    ) -> UniversalImagePicker {
        return UniversalImagePicker(config: ImagePickerConfig(
            sourceType: .gallery,
            selectionMode: .single,
            resultHandler: .callback(onImageSelected)
        ))
    }
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch config.sourceType {
        case .camera:
            return makeCameraPicker(context: context)
        case .gallery:
            return makeGalleryPicker(context: context)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Private Helpers
    
    private func makeCameraPicker(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        return picker
    }
    
    private func makeGalleryPicker(context: Context) -> UIViewController {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .limited, .authorized:
            return createGalleryPicker(context: context)
        default:
            return UIViewController() // 권한 없음
        }
    }
    
    private func createGalleryPicker(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        
        switch self.config.selectionMode {
        case .single:
            config.selectionLimit = 1
        case .multiple(let limit):
            config.selectionLimit = limit
        }
        
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: UniversalImagePicker
        
        init(_ parent: UniversalImagePicker) {
            self.parent = parent
        }
        
        // MARK: - UIImagePickerControllerDelegate (카메라)
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                handleSingleImage(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // MARK: - PHPickerViewControllerDelegate (갤러리)
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            // 단일 이미지 처리
            if results.count == 1 {
                let provider = results[0].itemProvider
                guard provider.canLoadObject(ofClass: UIImage.self) else {
                    parent.presentationMode.wrappedValue.dismiss()
                    return
                }
                
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self.handleSingleImage(uiImage)
                        }
                    }
                }
            } else {
                // 다중 이미지 처리
                handleMultipleImages(results)
            }
        }
        
        // MARK: - Result Handling
        
        private func handleSingleImage(_ image: UIImage) {
            switch parent.config.resultHandler {
            case .binding(let binding):
                binding.wrappedValue.append(image)
                
            case .singleBinding(let binding):
                binding.wrappedValue = image
                
            case .callback(let callback):
                callback(image)
                
            case .multiCallback(let callback):
                callback([image])
            }
        }
        
        private func handleMultipleImages(_ results: [PHPickerResult]) {
            var loadedImages: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    defer { group.leave() }
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            loadedImages.append(uiImage)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                switch self.parent.config.resultHandler {
                case .binding(let binding):
                    binding.wrappedValue.append(contentsOf: loadedImages)
                    
                case .multiCallback(let callback):
                    callback(loadedImages)
                    
                case .singleBinding(let binding):
                    binding.wrappedValue = loadedImages.first
                    
                case .callback(let callback):
                    if let firstImage = loadedImages.first {
                        callback(firstImage)
                    }
                }
            }
        }
    }
}

// MARK: - View Extensions for Easy Usage

extension View {
    func singleImagePicker(
        isPresented: Binding<Bool>,
        selectedImage: Binding<UIImage?>,
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            UniversalImagePicker.single(selectedImage: selectedImage)
        }
    }
    
    /// 기존 ImagePicker 호환 (카메라/갤러리)
    func legacyImagePicker(
        isPresented: Binding<Bool>,
        selectedImages: Binding<[UIImage]>,
        sourceType: UIImagePickerController.SourceType
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            UniversalImagePicker.legacy(
                selectedImages: selectedImages,
                sourceType: sourceType
            )
        }
    }
    
    /// 기존 MultipleImagePicker 호환
    func multipleImagePicker(
        isPresented: Binding<Bool>,
        selectedImages: Binding<[UIImage]>,
        selectionLimit: Int
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            UniversalImagePicker.multiple(
                selectedImages: selectedImages,
                limit: selectionLimit
            )
        }
    }
    
    /// OCR용 카메라
    func ocrCameraPicker(
        isPresented: Binding<Bool>,
        onImageSelected: @escaping (UIImage) -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            UniversalImagePicker.ocrCamera(onImageSelected: onImageSelected)
        }
    }
    
    /// OCR용 갤러리
    func ocrGalleryPicker(
        isPresented: Binding<Bool>,
        onImageSelected: @escaping (UIImage) -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            UniversalImagePicker.ocrGallery(onImageSelected: onImageSelected)
        }
    }
}
