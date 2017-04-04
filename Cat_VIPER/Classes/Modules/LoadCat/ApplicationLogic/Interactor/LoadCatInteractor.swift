//
//  LoadCatInteractor.swift
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

protocol LoadCatInteractorInput {
    func loadCat()
    func cancelLoad()
}

protocol LoadCatInteractorOutput {
    func didLoadCatURL(_ catURL: NSURL?, success: Bool, cancelled: Bool)
    func didLoadCatImage(_ image: Data?, success: Bool, cancelled: Bool)
}

class LocadCatInteractor: LoadCatInteractorInput {
    
    private var catProvider: CatProvider
    private var cat: Cat?
    private var isLoading: Bool
    
    public  var output: LoadCatInteractorOutput!
    
    init(catProvider: CatProvider) {
        self.catProvider = catProvider
        isLoading = false
    }
    
    public func loadCat() {
        
        guard !isLoading else { return }
        isLoading = true
        
        self.catProvider.createNewCat { [weak self] (cat, success, loadCatError) in
            guard let strongself = self else { return }
            strongself.cat = cat
            
            var loadCatCancelled = false
            if !success {
                loadCatCancelled = CatLoadingError.cancelled == loadCatError
            }
            
            strongself.output.didLoadCatURL(cat?.imageURL, success: success, cancelled: loadCatCancelled)
            
            if success {
                strongself.cat?.loadImage(complation: { [weak self] (image, success, loadImageError) in
                    guard let strongself = self else { return }
                    
                    var loadImageCancelled = false
                    if !success {
                        loadImageCancelled = CatLoadingError.cancelled == loadImageError
                    }
                    strongself.output.didLoadCatImage(image, success: success, cancelled: loadImageCancelled)
                    strongself.isLoading = false
                })
            } else {
                strongself.isLoading = false
            }
        }
    }
    
    public func cancelLoad() {
        catProvider.cancel()
        cat?.cancel()
    }
}
