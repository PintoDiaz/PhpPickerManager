//
//  PhpPickerManager.swift
//
//  Created by Pinto Diaz, Roger on 2/11/21.
//  Copyright © 2021 Sage One. All rights reserved.
//

import Foundation
import PhotosUI

@available(iOS 14, *)
@objc final class PhpPickerManager: NSObject, PHPickerViewControllerDelegate {

    // MARK: - Properties

    private let viewController: UIViewController!
    private let onCompletion: RVNImagePickerControllerCallback!

    // MARK: - Initializer

    @objc init(viewController: UIViewController, onCompletion: @escaping RVNImagePickerControllerCallback) {
        self.viewController = viewController
        self.onCompletion = onCompletion
    }

    #if DEBUG
    deinit {
        print("♻️ \(Self.self) deallocated")
    }
    #endif

    // MARK: - Public methods

    @objc func showPhpPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = self
        viewController.present(photoPickerViewController, animated: true)
    }

    // MARK: - PHPickerViewControllerDelegate

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            results.forEach { self.handleItem($0.itemProvider) }
        }
    }

    private func handleItem(_ item: NSItemProvider) {
        item.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, _) in
            guard item.canLoadObject(ofClass: UIImage.self), let url = url else {
                print("PhpPickerManager: Can't load image or url is nil")
                return
            }

            item.loadObject(ofClass: UIImage.self) { (image, _) in
                guard let image = image as? UIImage else {
                    print("PhpPickerManager: Failed to cast image as UIImage")
                    return
                }

                self.onCompletion(image, url)
            }
        }
    }
}
