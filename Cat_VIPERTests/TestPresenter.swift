//
//  TestPresenter.swift
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

class StubUI: LoadCatViewProtocol {
    
    var isLoadingState: Bool
    var imageTitle: String?
    var image: UIImage?
    var isFinishedEditing: Bool
    var presenter: LoadCatPresenterProtocol!
    
    init() {
        isLoadingState = false
        isFinishedEditing = false
        imageTitle = nil
        image = nil
    }
    
    public func reset() {
        isLoadingState = false
        isFinishedEditing = false
        imageTitle = nil
        image = nil
    }
    
    //MARK: CatViewProtocol
    
    func setPresenter(_ presenter: Presenter) {
        self.presenter = presenter as! LoadCatPresenterProtocol
    }
    
    func getPresenter() -> Presenter {
        return presenter
    }
    
    func updateLoadingState(_ loading: Bool) {
        isLoadingState = loading
    }
    
    func updateTitle(_ title: String?) {
        self.imageTitle = title
    }
    
    func updateImage(_ image: UIImage?) {
        self.image = image
    }
    
    func finishEditing() {
        self.isFinishedEditing = true
    }
}

typealias UpdateUICallback = () -> Void

class TestablePresenter: LoadCatPresenter {
    
    var updateUICallback: UpdateUICallback!
    
    override func updateUI() {
        super.updateUI()
        updateUICallback()
    }
}

class TestPresenter: XCTestCase {
    
    var presenter: TestablePresenter!
    var view: StubUI!
    var interactor: LocadCatInteractor!
    var catProvider: CatProvider!
    
    override func setUp() {
        super.setUp()
        
        catProvider = CatProvider()
        interactor = LocadCatInteractor(catProvider: catProvider)
        
        presenter = TestablePresenter()
        presenter.loadCatInteractor = interactor
        interactor.output = presenter
        
        view = StubUI()
        view.presenter = presenter
        presenter.view = view
    }
}

extension TestPresenter {
    
    func test_load_ok() {
        view.reset()
        
        let loadJsonOkStub = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let loadImageOkStub = self.prepeareStubForSuccessImageLoadRequest()
        
        let startLoadingStateIdentifier = "Start loading"
        let updatedImageTitleStateIdentifier = "Updated image title"
        let finishedLoadingStateIdentifier = "Finished loading"
        
        var expectations = [
            self.expectation(description: startLoadingStateIdentifier),
            self.expectation(description: updatedImageTitleStateIdentifier),
            self.expectation(description: finishedLoadingStateIdentifier)
        ]
        
        presenter.updateUICallback = {
            let expectation = expectations.removeFirst()
            
            if expectation.description == startLoadingStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == updatedImageTitleStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, ImageFileExtensions.stubImageUrl)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == finishedLoadingStateIdentifier {
                let expectedImagePath = Bundle(for: self.classForCoder).path(forResource: ImageFileExtensions.stubbedCatImageName, ofType: nil)
                XCTAssertNotNil(expectedImagePath)
                let expectedImage = UIImage(named: expectedImagePath!)
                
                XCTAssertFalse(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, ImageFileExtensions.stubImageUrl)
                
                let png1 = UIImagePNGRepresentation(self.view.image!)
                let png2 = UIImagePNGRepresentation(expectedImage!)
                
                XCTAssertEqual(png1, png2)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(loadJsonOkStub)
            self.removeStub(loadImageOkStub)
        }
    }
    
    func test_cancelled_cat_load() {
        view.reset()
        
        let loadJsonOkStub = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let loadImageOkStub = self.prepeareStubForSuccessImageLoadRequest()
        
        let startLoadingStateIdentifier = "Start loading"
        let cancelledStateIdentifier = "cancelled loading"
        
        var expectations = [
            self.expectation(description: startLoadingStateIdentifier),
            self.expectation(description: cancelledStateIdentifier)
        ]
        
        presenter.updateUICallback = {
            let expectation = expectations.removeFirst()
            
            if expectation.description == startLoadingStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.presenter.cancel()
                })
            }
            else if expectation.description == cancelledStateIdentifier {
                XCTAssertFalse(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, LoadCatPresenter.Constants.cancelledString)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(loadJsonOkStub)
            self.removeStub(loadImageOkStub)
        }
    }
    
    func test_cancelled_image_load() {
        view.reset()
        
        let loadJsonOkStub = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let loadImageOkStub = self.prepeareStubForSuccessImageLoadRequest()
        
        let startLoadingStateIdentifier = "Start loading"
        let didLoadImageUrlStateIdentifier = "Did loaded image URL"
        let cancelledStateIdentifier = "cancelled loading"
        
        var expectations = [
            self.expectation(description: startLoadingStateIdentifier),
            self.expectation(description: didLoadImageUrlStateIdentifier),
            self.expectation(description: cancelledStateIdentifier)
        ]
        
        presenter.updateUICallback = {
            let expectation = expectations.removeFirst()
            
            if expectation.description == startLoadingStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == didLoadImageUrlStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, ImageFileExtensions.stubImageUrl)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.presenter.cancel()
                })
            }
            else if expectation.description == cancelledStateIdentifier {
                XCTAssertFalse(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, LoadCatPresenter.Constants.cancelledString)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(loadJsonOkStub)
            self.removeStub(loadImageOkStub)
        }
    }
    
    func test_load_cat_network_error() {
        view.reset()
        
        let loadCatNetworkErrorStub = self.prepeareStubNetworkErrorFor(catProvider: catProvider)
        
        let didStartLoadStateIdentifier = "Did start load"
        let didFinishWithErrorStateIdentifier = "Did finish with error"
        
        var expectations = [
            self.expectation(description: didStartLoadStateIdentifier),
            self.expectation(description: didFinishWithErrorStateIdentifier)
        ]
        
        presenter.updateUICallback = {
            let expectation = expectations.removeFirst()
            
            if expectation.description == didStartLoadStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == didFinishWithErrorStateIdentifier {
                XCTAssertFalse(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, LoadCatPresenter.Constants.errorSrting)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(loadCatNetworkErrorStub)
        }
    }
    
    func test_load_image_server_error() {
        view.reset()
        
        let loadJsonOkStub = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let loadImageServerErrorStub = self.prepeareStubServerErrorForImageRequest()
        
        let didStartLoadStateIdentifier = "Did start load"
        let didSetImageURLStateIdentifier = "Did set image URL"
        let didLoadWithErrorStateIdentifier = "Did load with error"
        
        var expectations = [
            self.expectation(description: didStartLoadStateIdentifier),
            self.expectation(description: didSetImageURLStateIdentifier),
            self.expectation(description: didLoadWithErrorStateIdentifier)
        ]
        
        presenter.updateUICallback = {
            let expectation = expectations.removeFirst()
            
            if expectation.description == didStartLoadStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == didSetImageURLStateIdentifier {
                XCTAssertTrue(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, ImageFileExtensions.stubImageUrl)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == didLoadWithErrorStateIdentifier {
                XCTAssertFalse(self.view.isLoadingState)
                XCTAssertEqual(self.view.imageTitle, LoadCatPresenter.Constants.errorSrting)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(loadJsonOkStub)
            self.removeStub(loadImageServerErrorStub)
        }
    }
    
}
