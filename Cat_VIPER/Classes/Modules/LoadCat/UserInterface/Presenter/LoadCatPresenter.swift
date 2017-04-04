//
//  CatViewPresenter.swift
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

protocol LoadCatPresenterProtocol: Presenter {
    
    func load()
    func cancel()
    func updateUI()
    func edit()
    
    var loadCatInteractor: LocadCatInteractor! { get set }
}

class LoadCatPresenter: LoadCatPresenterProtocol, LoadCatInteractorOutput, EditCatPresenterDelegate {
    
    // 
    // Internal state
    //
    weak var view: LoadCatViewProtocol!
    var loadCatInteractor: LocadCatInteractor!
    var wireframe: LoadCatViewWireframe!
    
    //
    // View state
    //
    var isLoading: Bool
    var image: UIImage?
    var imageTitle: String?
    
    init() {
        isLoading = false
        image = nil
        imageTitle = nil
    }
    
    func installView(_ view: View) {
        self.view = view as! LoadCatViewProtocol
    }
    
    public func load() {
        
        guard !isLoading else { return }
        
        isLoading = true
        image = nil
        imageTitle = nil
        
        updateUI()
        loadCatInteractor.loadCat()
    }
    
    public func cancel() {
        loadCatInteractor.cancelLoad()
    }
    
    public func updateUI() {
        view.updateLoadingState(isLoading)
        view.updateTitle(imageTitle)
        view.updateImage(image)
    }
    
    func edit() {
        wireframe.presentEditScene(withImage: image!, delegate: self)
    }
    
    //MARK: LoadCatInteractorOutput
    
    func didLoadCatURL(_ catURL: NSURL?, success: Bool, cancelled: Bool) {
        
        imageTitle = catURL?.absoluteString
        isLoading = success
        
        if !success {
            if cancelled {
                imageTitle = Constants.cancelledString
            } else {
                imageTitle = Constants.errorSrting
            }
        }
        
        updateUI()
    }
    
    func didLoadCatImage(_ image: Data?, success: Bool, cancelled: Bool) {
        
        isLoading = false
        if success {
            if let imageData = image {
                self.image = UIImage(data: imageData)
            }
        } else {
            if cancelled {
                imageTitle = Constants.cancelledString
            } else {
                imageTitle = Constants.errorSrting
            }
        }
        updateUI()
    }
    
    // MARK: EditCatPresenterDelegate
    
    func finished() {
        view.finishEditing()
    }
}

// MARK: Constants

extension LoadCatPresenter {
    enum Constants {
        static let cancelledString = "Cancelled"
        static let errorSrting = "Error"
    }
}
