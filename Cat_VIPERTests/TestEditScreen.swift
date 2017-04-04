//
//  TestEditScreen.swift
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

import XCTest
@testable import Cat_VIPER

class TestEditScreen: XCTestCase {
    
    class TestableView: EditCatViewProtocol {
        
        var presenter: EditCatPresenterProtocol!
        var imageList: [UIImage]!
        var image: UIImage?
        var currentMessage: String?
        var isProcessing = false
        
        func setPresenter(_ presenter: Presenter) {
            self.presenter = presenter as! EditCatPresenterProtocol
        }
        
        func getPresenter() -> Presenter {
            return presenter
        }
        
        func imageListUpdateImage(_ image: UIImage, at index: Int) {
            imageList[index] = image
        }
        
        func updateImage(_ image: UIImage) {
            self.image = image
        }
        
        func showMessage(_ message: String) {
            currentMessage = message
        }
        
        func updateProcessingState(_ processingState: Bool) {
            isProcessing = processingState
        }
        
        func resetState() {
            isProcessing = false
            currentMessage = nil
            image = nil
        }
        
    }
    
    class StubPrepareSampleImagesInput: PrepareSampleImagesInput {
        
        var didCallProcessImage: ( (_ image: UIImage, _ filterList: [CIFilter]) -> Void )?
        var didCallCancell: ( () -> Void )?
        
        func processImage(_ image: UIImage, withFilters filters: [CIFilter]) {
            if let callback = didCallProcessImage {
                callback(image, filters)
            }
        }
        
        func cancell() {
            if let callback = didCallCancell {
                callback()
            }
        }
    }
    
    class StubFilterCatImageInput: FilterCatImageInput {
        
        var didCallFilterImage: ( (_ image: UIImage, _ filter: CIFilter) -> Void )?
        var didCallCancell: ( () -> Void )?
        
        func filterImage(_ image: UIImage, withFilter filter: CIFilter) {
            if let callback = didCallFilterImage {
                callback(image, filter)
            }
        }
        
        func cancell() {
            if let callback = didCallCancell {
                callback()
            }
        }
    }
    
    class StubSaveImageInput: SaveImageInteractorInput {
        
        var didCallSaveImage: ( (_ image: UIImage) -> Void )?
        
        func saveImage(_ image: UIImage) {
            if let callback = didCallSaveImage {
                callback(image)
            }
        }
    }
    
    class StubPresenterDelegate: EditCatPresenterDelegate {
        
        var didCallFinished: ( ()->Void )?
        
        func finished() {
            if let callback = didCallFinished {
                callback()
            }
        }
    }
    
    
    var view: TestableView!
    var presenter: EditCatPresenter!
    var filterCatImageInput: StubFilterCatImageInput!
    var prepareSampleImagesInput: StubPrepareSampleImagesInput!
    var saveImageInteractor: StubSaveImageInput!
    var testImage: UIImage!
    var delegate: StubPresenterDelegate!
    
    override func setUp() {
        super.setUp()
        
        view = TestableView()
        presenter = EditCatPresenter()
        presenter.view = view
        view.presenter = presenter
        
        filterCatImageInput = StubFilterCatImageInput()
        prepareSampleImagesInput = StubPrepareSampleImagesInput()
        saveImageInteractor = StubSaveImageInput()
        
        presenter.filterCatImageInteractor = filterCatImageInput
        presenter.prepareSampleImagesInteractor = prepareSampleImagesInput
        presenter.saveImageInteractor = saveImageInteractor
        
        testImage = UIImage(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "stubbedCatImage.jpg", ofType: nil)! )!
        delegate = StubPresenterDelegate()
        
        presenter.image = testImage
        presenter.delegate = delegate
    }
    
    func test_presenter_flow() {
        
        // ------------------------------------------------------------
        //                      Initiate View
        // ------------------------------------------------------------
        
        view.resetState()
        
        //
        // Check PrepareSampleImagesInput state
        //
        let processImageExpectation = self.expectation(description: "Process image")
        prepareSampleImagesInput.didCallProcessImage = { (image, filterList) in
            // Test image list and filter list
            let placeholderImage = UIImage(named: "CatFace")!
            XCTAssertEqual(UIImagePNGRepresentation(placeholderImage), UIImagePNGRepresentation(image))
            XCTAssertEqual(filterList.count, EditCatPresenter.Constants.filterNames.count)
            
            processImageExpectation.fulfill()
        }
        prepareSampleImagesInput.didCallCancell = {
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Cehck FilterCatImageInput state
        //
        filterCatImageInput.didCallCancell = {
            XCTAssert(false)
        }
        filterCatImageInput.didCallFilterImage = { (image, filter) in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check SaveImageInteractorInput state
        //
        saveImageInteractor.didCallSaveImage = { image in
            XCTAssert(false)
        }
        // ======================================
        
        // 
        // Check EditCatPresenterDelegate state
        //
        delegate.didCallFinished = {
            XCTAssert(false)
        }
        // ======================================
        
        presenter.updateView()
        
        self.waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
        
        //
        // Test View state
        //
        XCTAssertEqual(UIImagePNGRepresentation(self.presenter.image), UIImagePNGRepresentation(self.view.image!))
        
        // Test image list
        for image in self.view.imageList {
            let placeholderImage = UIImage(named: "CatFace")!
            XCTAssertEqual(UIImagePNGRepresentation(image), UIImagePNGRepresentation(placeholderImage))
        }
        
        XCTAssertFalse(self.view.isProcessing)
        XCTAssertNil(self.view.currentMessage)
        
        
        // ------------------------------------------------------------
        //                   Select image to process
        // ------------------------------------------------------------
        
        //
        // Check PrepareSampleImagesInput state
        //
        prepareSampleImagesInput.didCallProcessImage = { (image, filterList) in
            XCTAssert(false)
        }
        prepareSampleImagesInput.didCallCancell = {
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Cehck FilterCatImageInput state
        //
        let callFilterImageExpectation = self.expectation(description: "Start filter image")
        filterCatImageInput.didCallCancell = {
            XCTAssert(false)
        }
        filterCatImageInput.didCallFilterImage = { (image, filter) in
            callFilterImageExpectation.fulfill()
        }
        // ======================================
        
        //
        // Check SaveImageInteractorInput state
        //
        saveImageInteractor.didCallSaveImage = { image in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check EditCatPresenterDelegate state
        //
        delegate.didCallFinished = {
            XCTAssert(false)
        }
        // ======================================
        
        presenter.selectedImageAtIndex(0)
        
        self.waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
        
        XCTAssertNotNil(view.image)
        XCTAssertTrue(view.isProcessing)
        XCTAssertNil(view.currentMessage)
        
        // ------------------------------------------------------------
        //                    Finish image process
        // ------------------------------------------------------------
        
        //
        // Check PrepareSampleImagesInput state
        //
        prepareSampleImagesInput.didCallProcessImage = { (image, filterList) in
            XCTAssert(false)
        }
        prepareSampleImagesInput.didCallCancell = {
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Cehck FilterCatImageInput state
        //
        filterCatImageInput.didCallCancell = {
            XCTAssert(false)
        }
        filterCatImageInput.didCallFilterImage = { (image, filter) in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check SaveImageInteractorInput state
        //
        saveImageInteractor.didCallSaveImage = { image in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check EditCatPresenterDelegate state
        //
        delegate.didCallFinished = {
            XCTAssert(false)
        }
        // ======================================
        
        let finishedImage = UIImage()
        presenter.didFinishFilterImage(finishedImage)
        
        XCTAssertFalse(view.isProcessing)
        XCTAssertEqual(UIImagePNGRepresentation(finishedImage), UIImagePNGRepresentation(view.image!))
        XCTAssertNil(view.currentMessage)
        
        
        // ------------------------------------------------------------
        //                         Save image
        // ------------------------------------------------------------
        
        //
        // Check PrepareSampleImagesInput state
        //
        prepareSampleImagesInput.didCallProcessImage = { (image, filterList) in
            XCTAssert(false)
        }
        prepareSampleImagesInput.didCallCancell = {
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Cehck FilterCatImageInput state
        //
        filterCatImageInput.didCallCancell = {
            XCTAssert(false)
        }
        filterCatImageInput.didCallFilterImage = { (image, filter) in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check SaveImageInteractorInput state
        //
        let callSaveImageExpectation = self.expectation(description: "Save image")
        saveImageInteractor.didCallSaveImage = { image in
            XCTAssertEqual(UIImagePNGRepresentation(image), UIImagePNGRepresentation(self.view.image!))
            callSaveImageExpectation.fulfill()
        }
        // ======================================
        
        //
        // Check EditCatPresenterDelegate state
        //
        delegate.didCallFinished = {
            XCTAssert(false)
        }
        // ======================================
        
        presenter.saveImage()
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
        
        // ------------------------------------------------------------
        //                         Test Save Success
        // ------------------------------------------------------------
        
        //
        // Check PrepareSampleImagesInput state
        //
        prepareSampleImagesInput.didCallProcessImage = { (image, filterList) in
            XCTAssert(false)
        }
        prepareSampleImagesInput.didCallCancell = {
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Cehck FilterCatImageInput state
        //
        filterCatImageInput.didCallCancell = {
            XCTAssert(false)
        }
        filterCatImageInput.didCallFilterImage = { (image, filter) in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check SaveImageInteractorInput state
        //
        saveImageInteractor.didCallSaveImage = { image in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check EditCatPresenterDelegate state
        //
        delegate.didCallFinished = {
            XCTAssert(false)
        }
        // ======================================
        
        presenter.didSaveImageWithResult(.success)
        XCTAssertEqual(view.currentMessage!, EditCatPresenter.Constants.saveImageSuccessMessage)
        XCTAssertFalse(view.isProcessing)
        XCTAssertNotNil(view.image)
        
        presenter.didSaveImageWithResult(.failed)
        XCTAssertEqual(view.currentMessage!, EditCatPresenter.Constants.saveImageFailedMessage)
        XCTAssertFalse(view.isProcessing)
        XCTAssertNotNil(view.image)
        
        presenter.didSaveImageWithResult(.denied)
        XCTAssertEqual(view.currentMessage!, EditCatPresenter.Constants.photoLibraryAccessDeniedMessage)
        XCTAssertFalse(view.isProcessing)
        XCTAssertNotNil(view.image)

        presenter.didSaveImageWithResult(.restricted)
        XCTAssertEqual(view.currentMessage!, EditCatPresenter.Constants.photoLibraryAccessRestrictedMessage)
        XCTAssertFalse(view.isProcessing)
        XCTAssertNotNil(view.image)
        
        // ------------------------------------------------------------
        //                         Test Cancel
        // ------------------------------------------------------------
        
        //
        // Check PrepareSampleImagesInput state
        //
        let didCallPrepareSampleImagesCancel = self.expectation(description: "Cancel prepare images")
        prepareSampleImagesInput.didCallProcessImage = { (image, filterList) in
            XCTAssert(false)
        }
        prepareSampleImagesInput.didCallCancell = {
            didCallPrepareSampleImagesCancel.fulfill()
        }
        // ======================================
        
        //
        // Cehck FilterCatImageInput state
        //
        let didCallFilterImageCancel = self.expectation(description: "Cancel filter image")
        filterCatImageInput.didCallCancell = {
            didCallFilterImageCancel.fulfill()
        }
        filterCatImageInput.didCallFilterImage = { (image, filter) in
            XCTAssert(false)
        }
        // ======================================
        
        //
        // Check SaveImageInteractorInput state
        //
        saveImageInteractor.didCallSaveImage = { image in
             XCTAssert(false)
        }
        // ======================================
        
        //
        // Check EditCatPresenterDelegate state
        //
        let didCallDelegateCancelExpectation = self.expectation(description: "Did cancell")
        delegate.didCallFinished = {
            didCallDelegateCancelExpectation.fulfill()
        }
        // ======================================
        
        presenter.finishEditing()
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
    
    

}
