//
//  OCRImagePicker.swift
//  QuoteHub
//
//  Created by iyungui on 2025/08/18.
//

import SwiftUI
import PhotosUI
import Photos
import AVFoundation

// MARK: - OCR용 카메라 ImagePicker

struct OCRCameraPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: OCRCameraPicker

        init(_ parent: OCRCameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - OCR용 갤러리 ImagePicker

struct OCRGalleryPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .limited, .authorized:
            return createPickerViewController(context: context)
        default:
            // 권한이 없는 경우 빈 뷰컨트롤러 반환
            return UIViewController()
        }
    }

    private func createPickerViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: OCRGalleryPicker

        init(_ parent: OCRGalleryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                self.parent.presentationMode.wrappedValue.dismiss()
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.onImageSelected(uiImage)
                    }
                }
            }
        }
    }
}
