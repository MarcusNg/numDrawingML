//
//  CanvasVC.swift
//  Drawing
//
//  Created by Marcus Ng on 12/4/17.
//  Copyright © 2017 Marcus Ng. All rights reserved.
//

import UIKit
import Vision

class CanvasVC: UIViewController {

    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var digitLbl: UILabel!
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupVision()
    }
    
    @IBAction func clearBtnPressed(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
    @IBAction func recognizeBtnPressed(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }

    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else { fatalError("Can not load Vision ML Model") }
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        self.requests = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else { print("No results"); return }
        
        let classifications = observations
            .flatMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.8})
            .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.digitLbl.text = classifications.first
        }
    }
    
}
