//
//  ViewController.swift
//  VisionTest
//
//  Created by Aaron on 11/06/2017.
//  Copyright © 2017 Aaron. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var request = [VNRequest]()
    let imagePicker = UIImagePickerController()
    var detectImageView = UIImageView()
    var detectImage: UIImage?
    
    var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detectImageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        detectImageView.contentMode = .scaleAspectFit
        detectImageView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        self.view.addSubview(detectImageView)
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Photo",
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(ViewController.pickImage(sender:))),
                                                              animated: false)
        
        let faceLandmarks = VNDetectFaceLandmarksRequest(completionHandler: self.faceLandmarksHandler)
        request = [faceLandmarks]
    }
    
    func faceLandmarksHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            self.observation(request.results as! [VNFaceObservation])
        }
    }
    
    func observation(_ observation: [VNFaceObservation]) {
        guard let img = detectImage, let _ = observation.first?.landmarks else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Detect failed", message: "Invalid face bounding", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        let imageScale: CGFloat = screenSize.width/img.size.width
        var s = img.size
        s.width *= imageScale
        s.height *= imageScale
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenSize.width, height: img.size.height*imageScale), false, 1)
        let context = UIGraphicsGetCurrentContext()
        
        detectImageView.image = faceBoundingBox(img: img,
                                                imageScale: imageScale,
                                                observation: observation,
                                                graphicsContext: context)
        UIGraphicsEndImageContext()
    }
    
    private func faceBoundingBox(img: UIImage, imageScale: CGFloat, observation: [VNFaceObservation], graphicsContext: CGContext?) -> UIImage? {
        var s = img.size
        s.width *= imageScale
        s.height *= imageScale
        
        graphicsContext?.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: screenSize.width, height: img.size.height*imageScale))
        graphicsContext?.addRect((observation.first?.boundingBox)!.scaled(to: s))
        graphicsContext?.setLineWidth(0.8)
        graphicsContext?.setStrokeColor(UIColor.green.cgColor)
        graphicsContext?.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    @objc func pickImage(sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Did cancel pick image
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.dismiss(animated: true, completion: nil)
        
        self.detectImage = image
        
        let faceLandmarksHandler = VNImageRequestHandler(cgImage: (self.detectImage?.cgImage)!, options: [:])
        do {
            try faceLandmarksHandler.perform(self.request)
        } catch {
            print(error)
        }
    }
}







