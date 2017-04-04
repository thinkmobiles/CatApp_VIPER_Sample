//
//  StoreImageInteractor.swift
//
//  Created by R. Fogash, V. Ahosta
//  Copyright (c) 2017 Thinkmobiles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import Photos

enum SaveImageResult {
    case restricted
    case denied
    case failed
    case success
}

protocol SaveImageInteractorInput: class {
    func saveImage(_ image: UIImage)
}

protocol SaveImageInteractorOutput: class {
    func didSaveImageWithResult(_ result: SaveImageResult)
}

class SaveImageInteractor: SaveImageInteractorInput {
    
    weak var output: SaveImageInteractorOutput?
    
    func saveImage(_ image: UIImage) {
        
        switch PHPhotoLibrary.authorizationStatus() {
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(){ [weak self] _ in
                self?.saveImage(image)
            }
            
        case .restricted:
            self.output?.didSaveImageWithResult(.restricted)
            
        case .denied:
            self.output?.didSaveImageWithResult(.denied)
            
        case .authorized:
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { [weak self] (success, error) in
                guard let strongself = self else { return }
                
                if !success {
                    strongself.output?.didSaveImageWithResult(.failed)
                } else {
                    strongself.output?.didSaveImageWithResult(.success)
                }
            }
        }
    }
}
