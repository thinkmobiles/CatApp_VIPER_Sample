//
//  CatViewController.swift
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

protocol LoadCatViewProtocol: View {
    
    func updateLoadingState(_ loadingState: Bool)
    func updateTitle(_ title: String?)
    func updateImage(_ image: UIImage?)
    func finishEditing()
}

class LoadCatViewController: UIViewController, LoadCatViewProtocol {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var loadButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var imageTitleLabel: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var presenter: LoadCatPresenterProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.updateUI()
    }
    
    @IBAction func actLoad(_ sender: UIButton) {
        presenter.load()
    }
    
    @IBAction func actCancel(_ sender: UIButton) {
        presenter.cancel()
    }
    
    @IBAction func actEdit(_ sender: UIButton) {
        loadButton.isEnabled = false
        presenter.edit()
    }
    
    func setPresenter(_ presenter: Presenter) {
        self.presenter = presenter as! LoadCatPresenterProtocol
    }
    
    func getPresenter() -> Presenter {
        return presenter
    }
    
    func updateLoadingState(_ loadingState: Bool) {
        self.loadButton.isEnabled = !loadingState
        self.cancelButton.isEnabled = loadingState
        
        if loadingState && loadingIndicator.isHidden {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else if !loadingState && !loadingIndicator.isHidden {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    func updateTitle(_ title: String?) {
        self.imageTitleLabel.text = title
    }
    
    func updateImage(_ image: UIImage?) {
        self.imageView.image = image
        self.editButton.isEnabled = (image != nil)
    }
    
    func finishEditing() {
        loadButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
}
