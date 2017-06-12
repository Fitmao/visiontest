//
//  ViewController.swift
//  VisionTest
//
//  Created by Aaron on 11/06/2017.
//  Copyright © 2017 Aaron. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var request = [VNRequest]()
    let imagePicker = UIImagePickerController()
    var detectImageView = UIImageView()
    var detectImage: UIImage?
    var rectImageView = UIImageView()
    var rectImage: UIImage?
    
    var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let captureSession = AVCaptureSession()
//        let out = AVCaptureVideoDataOutput()
//        out.setSampleBufferDelegate(self, queue: DispatchQueue(label: "out"))
//        captureSession.addOutput(out)
//
//        captureSession.startRunning()
        
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        label.textColor = UIColor.white
        label.text = "| 100, 100"
        self.view.addSubview(label)
        
        rectImageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        rectImageView.contentMode = .scaleAspectFit
        detectImageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        detectImageView.contentMode = .scaleAspectFit
        detectImageView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        self.view.addSubview(detectImageView)
        self.view.addSubview(rectImageView)
        
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
            self.observationInfo(request.results as! [VNFaceObservation])
        }
    }
    
    func observationInfo(_ observation: [VNFaceObservation]) {
        guard let img = detectImage, let landmarks = observation.first?.landmarks else {
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
//        rectImageView.frame = (observation.first?.boundingBox)!.scaled(to: s)
//        rectImageView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenSize.width, height: img.size.height*imageScale), false, 1)
        let context = UIGraphicsGetCurrentContext()
        
//        detectImageView.image = faceBoundingBox(img: img,
//                                                imageScale: imageScale,
//                                                observation: observation,
//                                                graphicsContext: context)
        
        context?.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: screenSize.width, height: img.size.height*imageScale))
        context?.addRect((observation.first?.boundingBox)!.scaled(to: s))
        
        context?.setLineWidth(0.8)
        context?.setStrokeColor(UIColor.green.cgColor)
        context?.strokePath()
        
        detectImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let marks = LandMarks2DArray(landmarks: landmarks)
        let marksX = marks.scaleX(markType: .faceCoutour, scaled: 1)
        let marksY = marks.scaleY(markType: .faceCoutour, scaled: 1)
        
        let boundingBox = observation.first?.boundingBox.scaled(to: s)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenSize.width, height: img.size.height*imageScale), false, 1)
        let context2 = UIGraphicsGetCurrentContext()
        
        context2?.draw((detectImage?.cgImage!)!, in: CGRect(x: 0, y: 0, width: screenSize.width, height: img.size.height*imageScale))
        context2?.move(to: CGPoint(x: CGFloat(marksX[0])*(boundingBox?.size.width)!+(boundingBox?.size.width)!,
                                   y: CGFloat(marksY[0])*(boundingBox?.size.height)!+(boundingBox?.size.height)!))
        
        for i in 1..<marksX.count {
            context2?.addLine(to: CGPoint(x: CGFloat(marksX[i])*(boundingBox?.size.width)!+(boundingBox?.size.width)!,
                                          y: CGFloat(marksY[i])*(boundingBox?.size.height)!+(boundingBox?.size.height)!))
        }
        
        context2?.setLineWidth(0.8)
        context2?.setStrokeColor(UIColor.green.cgColor)
        context2?.strokePath()
        
        rectImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func faceBoundingBox(img: UIImage, imageScale: CGFloat, observation: [VNFaceObservation], graphicsContext: CGContext?) -> UIImage? {
        var s = img.size
        s.width *= imageScale
        s.height *= imageScale
        
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenSize.width, height: img.size.height*imageScale), false, 1)
        graphicsContext?.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: screenSize.width, height: img.size.height*imageScale))
        graphicsContext?.addRect((observation.first?.boundingBox)!.scaled(to: s))
        graphicsContext?.setLineWidth(0.8)
        graphicsContext?.setStrokeColor(UIColor.green.cgColor)
        graphicsContext?.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    private func faceLandmarks() {
        
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
    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Running...")
//    }
}







