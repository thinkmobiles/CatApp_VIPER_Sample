//
//  Dependicies.swift
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

class Dependencies {
    
    private let catProvider = CatProvider()
    private var catViewWireframe: LoadCatViewWireframe!
    
    public func initiateDependencies() {
        
        let presenter = LoadCatPresenter()
        let interactor = LocadCatInteractor(catProvider: catProvider)
        
        interactor.output = presenter
        presenter.loadCatInteractor = interactor
        
        catViewWireframe = LoadCatViewWireframe()
        catViewWireframe.presenter = presenter
        presenter.wireframe = catViewWireframe
        
        // EditCat
        let editCatWireframe = EditCatWireframe()
        let editCatPresenter = EditCatPresenter()
        
        let prepareSampleImagesInteractor = PrepareSampleImagesInteractor()
        prepareSampleImagesInteractor.output = editCatPresenter
        let filterCatImageInterator = FilterCatImageInteractor()
        filterCatImageInterator.output = editCatPresenter
        let saveImageInteractor = SaveImageInteractor()
        saveImageInteractor.output = editCatPresenter
        
        editCatPresenter.prepareSampleImagesInteractor = prepareSampleImagesInteractor
        editCatPresenter.filterCatImageInteractor = filterCatImageInterator
        editCatPresenter.saveImageInteractor = saveImageInteractor
        editCatWireframe.presenter = editCatPresenter
        editCatPresenter.wireframe = editCatWireframe
        
        catViewWireframe.editWireframe = editCatWireframe
    }
    
    public func showInitialControllerOnWindow(_ window: UIWindow) {
        catViewWireframe.installViewOnWindow(window)
    }
}
