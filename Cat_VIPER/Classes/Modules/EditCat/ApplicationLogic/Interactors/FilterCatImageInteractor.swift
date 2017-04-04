//
//  FilterCatImageInteractor.swift
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

protocol FilterCatImageInput {
    func filterImage(_ image: UIImage, withFilter filter: CIFilter)
    func cancell()
}

protocol FilterCatImageOutput {
    func didFinishFilterImage(_ image: UIImage?)
}

class FilterCatImageInteractor: FilterCatImageInput  {
    public var output: FilterCatImageOutput!
    private var operationQueue: OperationQueue
    
    init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func filterImage(_ image: UIImage, withFilter filter: CIFilter) {
        operationQueue.cancelAllOperations()
        
        let operation = FilterOperation(filter: filter, image: image)

        operation.completionBlock = { [weak self, weak weakoperation = operation] in
            guard let strongself = self, let operation = weakoperation else { return }
            DispatchQueue.main.async {
                if !operation.isCancelled {
                    strongself.output.didFinishFilterImage(operation.outputImage)
                }
            }
        }
        operationQueue.addOperation(operation)
    }
    
    func cancell() {
        operationQueue.cancelAllOperations()
    }
}
