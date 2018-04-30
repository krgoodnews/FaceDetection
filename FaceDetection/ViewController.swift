//
//  ViewController.swift
//  FaceDetection
//
//  Created by Goodnews on 2018. 4. 30..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import Vision


class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let image = UIImage(named: "sample00") else { return }
		let imageView = UIImageView(image: image)
		
		let scaledHeight = view.frame.width / image.size.width * image.size.height
		
		imageView.contentMode = .scaleAspectFit
		
		imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)

		imageView.center = self.view.center
		view.addSubview(imageView)

		let request = VNDetectFaceRectanglesRequest { (req, err) in
			if let err = err {
				print("Failed to detect faces:", err)
				return
			}
			
//			print(req)
			
			req.results?.forEach({ (res) in
//				print(res)
				DispatchQueue.main.async {
					guard let faceObservation = res as? VNFaceObservation else { return }
					
					let x = self.view.frame.width * faceObservation.boundingBox.origin.x
					let height = scaledHeight * faceObservation.boundingBox.height
					let y = scaledHeight * (1 - faceObservation.boundingBox.origin.y) - height
					let width = self.view.frame.width * faceObservation.boundingBox.width
					
					
					let lineView = UIView()
					lineView.layer.cornerRadius = 5
					lineView.layer.borderWidth = 4
					lineView.layer.borderColor = UIColor.red.withAlphaComponent(0.5).cgColor
					lineView.frame = CGRect(x: x, y: y, width: width, height: height)
//					self.view.addSubview(lineView)
					imageView.addSubview(lineView)
					
					print(faceObservation.boundingBox)
				}
			})
		}
		
		guard let cgImage = image.cgImage else { return }
		
		DispatchQueue.global(qos: .background).async {
			let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
			
			do {
				try handler.perform([request])
			} catch let requestErr {
				print("Failed to perform request:", requestErr)
			}
		}
	}
}

