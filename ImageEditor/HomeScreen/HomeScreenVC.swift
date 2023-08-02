//
//  ViewController.swift
//  ImageEditor
//
//  Created by HIMANSHU SINGH on 25/07/23.
//

import UIKit
import PhotosUI

class HomeScreenVC: UIViewController {

    @IBOutlet var imagePickerButton: UIButton!
    var viewModel = HomeScreenVM()
    var editorVC : EditorVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions
    @IBAction func didSelectImageButtonClicked(_ sender: Any) {
        var configuration = PHPickerConfiguration(); // Created the instance of PHPickerConfiguration
        configuration.filter = .images // Add the filter in config for picking only image
        configuration.selectionLimit = 1 // Add the selection limit in config for that it choose only 10 images
        let picker = PHPickerViewController(configuration: configuration); // Create the instance of PHPickerController add pass the configuration in the parameter.
        picker.delegate = self // Assign the delegate self
        self.present(picker, animated: true, completion: nil) // it present the VC controller over the present VC.
    }


}

//MARK: - Extensions
extension HomeScreenVC : PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker view controller
        for result in results {

            let itemProvider: NSItemProvider = result.itemProvider

            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        self.viewModel.setImage(image: image)
                    }
                    DispatchQueue.main.async { [self] in
                         let editorVM = viewModel.createEditorVMInstance()
                        if let editorVM = editorVM {
                            editorVC = EditorVC(viewModel: editorVM)
                        }
                        if let editorVC = editorVC{
                            navigationController?.pushViewController(editorVC, animated: true)
                        }
                    }
                }

            }

        }
    }
}


