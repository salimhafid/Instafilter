//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Salim Hafid on 7/31/20.
//

import Foundation
import UIKit

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: (() -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?()
        }
        else {
            successHandler?()
        }
    }
}
