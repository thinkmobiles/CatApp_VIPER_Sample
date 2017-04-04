//
//  PrepareSampleImagesInteractor.swift
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

protocol PrepareSampleImagesInput {
    func processImage(_ image: UIImage, withFilters filters: [CIFilter])
    func cancell()
}

protocol PrepareSampleImagesOutput {
    func didProcessImage(_ image: UIImage, atIndex index: Int)
}

class PrepareSampleImagesInteractor: PrepareSampleImagesInput {
    private var operationQueue: OperationQueue
    private var image: UIImage!
    public var output: PrepareSampleImagesOutput!
    
    init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = Constants.maxNumberOfConcurentOperations
    }
    
    func processImage(_ image: UIImage, withFilters filters: [CIFilter]) {
        self.image = image
        
        for (index, filter) in filters.enumerated() {

            let operation = FilterOperation(filter: filter, image: image)
            
            operation.completionBlock = { [weak self, weak weakoperation = operation] in
                guard let strongself = self, let operation = weakoperation else { return }
                let image = operation.outputImage
                
                DispatchQueue.main.async {
                    if let image = image {
                        strongself.output.didProcessImage(image, atIndex: index)
                    }
                }
            }
            operationQueue.addOperation(operation)
        }
    }
    
    func cancell() {
        operationQueue.cancelAllOperations()
    }
}

extension PrepareSampleImagesInteractor {
    enum Constants {
        static let maxNumberOfConcurentOperations = 5
    }
}
