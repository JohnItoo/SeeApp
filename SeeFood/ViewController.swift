//
//  ViewController.swift
//  SeeFood
//
//  Created by MAC on 9/26/18.
//  Copyright © 2018 John Ohue. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: false, completion: nil)
    }
    
    @IBAction func photoAlbum(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image :CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Core Ml model failed.")
        }
        let vnCoreRequest = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Could not get request results from VNCore")
            }
            if let firstResult = results.first {
                 self.navigationItem.title = firstResult.identifier.description
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([vnCoreRequest])
        } catch {
            print("An error occured")
        }
    }
    
    func checkThatPhotoIsHotDog(item : String) -> Bool {
        return item.contains("Hot Dog")
    }
    
}

