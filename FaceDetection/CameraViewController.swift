//
//  CameraViewController.swift
//  FaceDetection
//
//  Created by Goodnews on 2018. 4. 30..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import CoreImage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	@IBOutlet var imageView: UIImageView!
	let imagePicker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePicker.delegate = self
		
		guard let image = UIImage(named: "sample04") else { return }
		//		let imageView = UIImageView(image: image)
		imageView.image = image
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		detect()
		
	}
	
	@IBAction func takePhoto(sender: AnyObject) {
		
		if !UIImagePickerController.isSourceTypeAvailable(.camera) {
			return
		}
		
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .camera
		imagePicker.cameraDevice = .front
		
		present(imagePicker, animated: true, completion: nil)
	}
	
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageView.contentMode = .scaleAspectFit
			imageView.image = pickedImage
		}
		
		dismiss(animated: true, completion: nil)
		self.detect()
	}
	
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func detect() {
		let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
		//		let personciImage = CIImage(CGImage: imageView.image!.CGImage!)
		guard let personciImage = CIImage(image: imageView.image!) else { return }
		let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
		let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
		//		let faces = faceDetector?.features(in: personciImage!, options: imageOptions as? [String : AnyObject])
		let faces = faceDetector?.features(in: personciImage)
		
		// For converting the Core Image Coordinates to UIView Coordinates
		let ciImageSize = personciImage.extent.size
		var transform = CGAffineTransform(scaleX: 1, y: -1)
		transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
		
		
		if let _ = faces?.first as? CIFaceFeature {
			for face in faces as! [CIFaceFeature] {
				print("found bounds are \(face.bounds)")
				
				
				// Apply the transform to convert the coordinates
				var faceViewBounds = face.bounds.applying(transform)
				
				// Calculate the actual position and size of the rectangle in the image view
				let viewSize = imageView.bounds.size
				let scale = min(viewSize.width / ciImageSize.width,
								viewSize.height / ciImageSize.height)
				let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
				let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
				
				faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
				faceViewBounds.origin.x += offsetX
				faceViewBounds.origin.y += offsetY
				
				let faceBox = UIView(frame: faceViewBounds)
				
				faceBox.layer.borderWidth = 3
				faceBox.layer.borderColor = UIColor.red.cgColor
				
				imageView.addSubview(faceBox)
				
				
				
				
				//			let alert = UIAlertController(title: "Say Cheese!", message: "We detected a face!", preferredStyle: UIAlertControllerStyle.alert)
				//			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				//			self.present(alert, animated: true, completion: nil)
				
				if face.hasSmile {
					print("face is smiling");
				}
				
				if face.hasLeftEyePosition {
					var position = face.leftEyePosition
					print("Left eye bounds are \(face.leftEyePosition)")
					
					position = position.applying(transform)
					position = position.applying(CGAffineTransform(scaleX: scale, y: scale))
					position.x += offsetX
					position.y += offsetY
					
					let faceBox = UIView(frame: CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20))
					
					faceBox.layer.borderWidth = 3
					faceBox.layer.borderColor = UIColor.red.cgColor
					if face.leftEyeClosed {
						faceBox.layer.borderColor = UIColor.blue.cgColor
					}
					
					
					imageView.addSubview(faceBox)
				}
				
				if face.hasRightEyePosition {
					print(self.view.frame)
					var position = face.rightEyePosition
					
					print("Right eye bounds are \(position)")

					position = position.applying(transform)
					position = position.applying(CGAffineTransform(scaleX: scale, y: scale))
					position.x += offsetX
					position.y += offsetY
					
					let faceBox = UIView(frame: CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20))
					
					faceBox.layer.borderWidth = 3
					faceBox.layer.borderColor = UIColor.red.cgColor
					if face.rightEyeClosed {
						faceBox.layer.borderColor = UIColor.blue.cgColor
					}
					imageView.addSubview(faceBox)
				}
			}
		} else {
			let alert = UIAlertController(title: "No Face!", message: "No face was detected", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
}
