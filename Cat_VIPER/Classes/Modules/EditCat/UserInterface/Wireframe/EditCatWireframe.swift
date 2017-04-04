//
//  EditCatWireframe.swift
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

class EditCatWireframe {
    
    public var presenter: EditCatPresenterProtocol!
    
    public func showOnViewController(_ viewController: UIViewController, withImage: UIImage, delegate: EditCatPresenterDelegate?) {
        let editCatView = self.viewController()
        presenter.delegate = delegate
        presenter.image = withImage
        editCatView.presenter = presenter as! EditCatPresenter
        presenter.installView(editCatView)
        viewController.present(editCatView, animated: true, completion: nil)
    }
    
    public func showMessage(_ message: String, onView view: UIViewController) {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
        let alertController = UIAlertController(title: appName, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.presenter.finishEditing()
        }
        alertController.addAction(okAction)
        
        view.present(alertController, animated: true, completion: nil)
    }
    
    private func viewController() -> EditCatViewController {
        let storyboard = UIStoryboard.init(name: Constants.storyboardName, bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.controllerID)
        return controller as! EditCatViewController
    }
}

// MARK: Constants

extension EditCatWireframe {
    enum Constants {
        static let controllerID = "EditCatViewController"
        static let storyboardName = "Main"
    }
}
