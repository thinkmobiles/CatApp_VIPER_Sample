//
//  EditCatPresenter.swift
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

protocol EditCatPresenterDelegate: class {
    func finished()
}

protocol EditCatPresenterProtocol: Presenter {
    
    func updateView()
    func selectedImageAtIndex(_ index: Int)
    func saveImage()
    func finishEditing()
    
    weak var delegate: EditCatPresenterDelegate? { get set }
    var image: UIImage! { get set }
    
    var prepareSampleImagesInteractor: PrepareSampleImagesInput! { get set }
    var filterCatImageInteractor: FilterCatImageInput! { get set }
    var saveImageInteractor: SaveImageInteractorInput! { get set }
    
    var wireframe: EditCatWireframe! { get set }
}

class EditCatPresenter: EditCatPresenterProtocol {
    
    //
    // EditCatPresenterProtocol variables
    //
    var prepareSampleImagesInteractor: PrepareSampleImagesInput!
    var filterCatImageInteractor: FilterCatImageInput!
    var saveImageInteractor: SaveImageInteractorInput!
    var image: UIImage! {
        didSet{
            processedCatImage = image
        }
    }
    weak var delegate: EditCatPresenterDelegate?
    var wireframe: EditCatWireframe!
    
    //
    // View state
    //
    var isProcessing: Bool
    var processedCatImage: UIImage!
    lazy var imageList: [UIImage] = self.initiateSampleImageList()
    
    //
    // Internal state
    //
    weak var view: EditCatViewProtocol!
    var filterList: [CIFilter]!
    
    required init() {
        isProcessing = false
    }
    
    func installView(_ view: View) {
        self.view = view as! EditCatViewProtocol
    }
    
    func updateView() {
        view.updateProcessingState(isProcessing)
        view.updateImage(processedCatImage)
        view.imageList = imageList
        createFilteredImages()
    }
    
    func selectedImageAtIndex(_ index: Int) {
        isProcessing = true
        view.updateProcessingState(isProcessing)
        filterCatImageInteractor.filterImage(image, withFilter: filterList[index])
    }
    
    func saveImage() {
        self.saveImageInteractor.saveImage(self.processedCatImage)
    }
 
    func finishEditing() {
        filterCatImageInteractor.cancell()
        prepareSampleImagesInteractor.cancell()
        delegate?.finished()
    }
    
    func createFilteredImages() {
        filterList = Constants.filterNames.map { filterName -> CIFilter in
            let filter = CIFilter(name: filterName)!
            filter.setDefaults()
            return filter
        }
        prepareSampleImagesInteractor.processImage(imageList.first!, withFilters: filterList)
    }
    
    func initiateSampleImageList() -> [UIImage] {
        let imageListItem = UIImage(named: Constants.placeholderImageName)!
        let imageListCount = Constants.filterNames.count
        return Array(repeating: imageListItem, count: imageListCount)
    }
}

extension EditCatPresenter: PrepareSampleImagesOutput {
    
    func didProcessImage(_ image: UIImage, atIndex index: Int) {
        imageList[index] = image
        view.imageListUpdateImage(image, at: index)
    }
}

extension EditCatPresenter: FilterCatImageOutput {
    
    func didFinishFilterImage(_ image: UIImage?) {
        isProcessing = false
        processedCatImage = image ?? self.image
        view.updateProcessingState(isProcessing)
        view.updateImage(processedCatImage)
    }
}

extension EditCatPresenter: SaveImageInteractorOutput {
    
    func didSaveImageWithResult(_ result: SaveImageResult) {
        switch result {
        case .success:
            self.wireframe.showMessage(Constants.saveImageSuccessMessage, onView: view as! UIViewController)
        case .failed:
            self.wireframe.showMessage(Constants.saveImageFailedMessage, onView: view as! UIViewController)
        case .restricted:
            self.wireframe.showMessage(Constants.photoLibraryAccessRestrictedMessage, onView: view as! UIViewController)
        case .denied:
            self.wireframe.showMessage(Constants.photoLibraryAccessDeniedMessage, onView: view as! UIViewController)
        }
    }
}


extension EditCatPresenter {
    enum Constants {
        static let filterNames = ["CIPhotoEffectMono", "CISepiaTone", "CIColorInvert", "CIPhotoEffectChrome",
                                  "CIPhotoEffectTransfer", "CIPhotoEffectProcess", "CIPhotoEffectNoir",
                                  "CIPhotoEffectInstant", "CIPhotoEffectFade"]
        static let placeholderImageName = "CatFace"
        static let photoLibraryAccessRestrictedMessage = "Access to photos library restricted"
        static let photoLibraryAccessDeniedMessage = "Access to photos denied"
        static let saveImageFailedMessage = "Failed to save image"
        static let saveImageSuccessMessage = "Saving image complete"
    }
}
