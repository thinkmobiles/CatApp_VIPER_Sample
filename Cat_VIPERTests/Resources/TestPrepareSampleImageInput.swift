//
//  TestPrepareSampleImageInput.swift
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

class TestPrepareSampleImageInput: XCTestCase {
    
    class PrepareSampleImageOutputStub: PrepareSampleImagesOutput {
        
        private var imageList: [UIImage]
        private var expectation: XCTestExpectation
        private var setOfProcessedImageIndexes: Set<Int>
        
        init(imageList: [UIImage], allProcessedExpectation expectation: XCTestExpectation) {
            self.imageList = imageList
            self.expectation = expectation
            setOfProcessedImageIndexes = Set<Int>()
        }
        
        func didProcessImage(_ image: UIImage, atIndex index: Int) {
            
            XCTAssertFalse(setOfProcessedImageIndexes.contains(index), "image at index \(index) already processed")
            setOfProcessedImageIndexes.insert(index)
            
            imageList[index] = image
            
            for i in 0..<imageList.count {
                guard i == index else { continue }
                
                let imageFromListData = UIImagePNGRepresentation(imageList[i])
                let processedImageData = UIImagePNGRepresentation(image)
                
                XCTAssertEqual(imageFromListData, processedImageData)
            }
            
            if setOfProcessedImageIndexes.count == imageList.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { 
                    self.expectation.fulfill()
                })
            }
        }
    }

    
    var testImage: UIImage!
    var imageList: [UIImage]!
    var filters: [CIFilter]!
    var prepeareSampleImagesInteractor: PrepareSampleImagesInteractor!
    var prepeareSampleImagesOutStub: PrepareSampleImageOutputStub!
    
    override func setUp() {
        super.setUp()
        
        testImage = UIImage(contentsOfFile: Bundle.init(for: self.classForCoder).path(forResource: "stubbedCatImage.jpg", ofType: nil)!)!
        filters = EditCatPresenter.Constants.filterNames.map({ name -> CIFilter in
            let filter = CIFilter(name: name)
            filter?.setDefaults()
            return filter!
        })
        imageList = Array(repeating: testImage, count: filters.count)
        
        prepeareSampleImagesInteractor = PrepareSampleImagesInteractor()
    }
    
    func test_prepeare_images() {
        let finishAllExpectation = self.expectation(description: "All finished")
        
        prepeareSampleImagesOutStub = PrepareSampleImageOutputStub(imageList: imageList, allProcessedExpectation: finishAllExpectation)
        prepeareSampleImagesInteractor.output = prepeareSampleImagesOutStub
        
        prepeareSampleImagesInteractor.processImage(testImage, withFilters: filters)
        
        self.waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error)
        }
    }
    
}
