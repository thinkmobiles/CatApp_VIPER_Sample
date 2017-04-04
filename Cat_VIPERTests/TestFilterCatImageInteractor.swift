//
//  TestFilterCatImageInteractor.swift
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

class TestFilterCatImageInteractor: XCTestCase {
    
    class InteractorOutput: FilterCatImageOutput {
        
        var didFinishFilterImageLambda: ( (_ image: UIImage?) -> Void )?
        func didFinishFilterImage(_ image: UIImage?) {
            if let callback = didFinishFilterImageLambda {
                callback(image)
            }
        }
    }
    
    var filterCatImageInteractor: FilterCatImageInteractor!
    var filterCatImageInteractorOutput: InteractorOutput!
    var testImage: UIImage!
    
    override func setUp() {
        super.setUp()
        
        filterCatImageInteractor = FilterCatImageInteractor()
        filterCatImageInteractorOutput = InteractorOutput()
        filterCatImageInteractor.output = filterCatImageInteractorOutput
        
        testImage = UIImage(contentsOfFile: Bundle.init(for: self.classForCoder).path(forResource: "stubbedCatImage.jpg", ofType: nil)!)!
    }
    
    func test_filter_image_ok() {
        
        let finishFilterExpectation = self.expectation(description: "Finish filter image")
        
        filterCatImageInteractorOutput.didFinishFilterImageLambda = { image in
            let originalImageData = UIImagePNGRepresentation(self.testImage)
            let processedImageData = UIImagePNGRepresentation(image!)
            
            XCTAssertNotEqual(originalImageData, processedImageData)
            finishFilterExpectation.fulfill()
        }
        
        let filter = CIFilter(name: "CIPhotoEffectMono")!
        filter.setDefaults()
        
        filterCatImageInteractor.filterImage(testImage, withFilter: filter)

        self.waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func test_cancell_filtering() {
        
        let callbackNotCalled = self.expectation(description: "Doesn't called")
        
        filterCatImageInteractorOutput.didFinishFilterImageLambda = { image in
            XCTAssert(false, "Shouldn't be called")
        }
        
        let filter = CIFilter(name: "CIPhotoEffectMono")!
        filter.setDefaults()
        
        filterCatImageInteractor.filterImage(testImage, withFilter: filter)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.filterCatImageInteractor.cancell()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            callbackNotCalled.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
        }
    }
    
}
