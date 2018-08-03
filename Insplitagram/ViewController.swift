//
//  ViewController.swift
//  Insplitagram
//
//  Created by Sanggyu Nam on 2018. 8. 2..
//  Copyright © 2018년 Sanggyu Nam. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class ViewController: UIViewController {
    let trimQueue = DispatchQueue(label: "trimQueue")
    var completed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if completed {
            let alertController = UIAlertController.init(title: "Insplitagram", message: "Trimmed the video up to one minute successfully.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        // Do any additional setup after loading the view, typically from a nib.
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let alertController = UIAlertController.init(title: nil, message: "Cannot open Photo Library.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        if UIImagePickerController.availableMediaTypes(for: .photoLibrary)?.contains(kUTTypeMovie as String) == false {
            let alertController = UIAlertController.init(title: nil, message: "Cannot open videos from Photo Library.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        present(imagePickerController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let inUrl = info[UIImagePickerControllerMediaURL] as! URL? else {
            return
        }
        
        trimQueue.async {
            let outUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            
            defer {
                DispatchQueue.global(qos: .utility).async {
                    try? FileManager.default.removeItem(at: outUrl)
                }
            }
            
            guard trimOneMinute(inUrl: inUrl, outUrl: outUrl) else {
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outUrl)
            }
            
            DispatchQueue.main.async {
                self.completed = true
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
}

