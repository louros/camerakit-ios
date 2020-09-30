//
//  PhotoViewController.swift
//  CameraKitDemo
//
//  Created by Adrian Mateoaea on 08/01/2019.
//  Copyright © 2019 Wonderkiln. All rights reserved.
//

import UIKit
import CameraKit
import AVFoundation
import EasyPeasy

class PhotoPreviewViewController: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.image
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSave(_ sender: Any) {
        if let image = self.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(handleDidCompleteSavingToLibrary(image:error:contextInfo:)), nil)
        }
    }
        
    @objc func handleDidCompleteSavingToLibrary(image: UIImage?, error: Error?, contextInfo: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

class PhotoSettingsViewController: UITableViewController {
    
    var squareLayoutConstraint: NSLayoutConstraint!
    var wideLayoutConstraint: NSLayoutConstraint!
    var previewView: CKFPreviewView!
    
    @IBOutlet weak var cameraSegmentControl: UISegmentedControl!
    @IBOutlet weak var flashSegmentControl: UISegmentedControl!
    @IBOutlet weak var faceSegmentControl: UISegmentedControl!
    @IBOutlet weak var gridSegmentControl: UISegmentedControl!
    @IBOutlet weak var modeSegmentControl: UISegmentedControl!
    
    @IBAction func handleCamera(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFPhotoSession {
            session.cameraPosition = sender.selectedSegmentIndex == 0 ? .back : .front
        }
    }
    
    @IBAction func handleFlash(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFPhotoSession {
            let values: [CKFPhotoSession.FlashMode] = [.auto, .on, .off]
            session.flashMode = values[sender.selectedSegmentIndex]
        }
    }
    
    @IBAction func handleFace(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFPhotoSession {
            session.cameraDetection = sender.selectedSegmentIndex == 0 ? .none : .faces
        }
    }
    
    @IBAction func handleGrid(_ sender: UISegmentedControl) {
        self.previewView.showGrid = sender.selectedSegmentIndex == 1
    }
    
    @IBAction func handleMode(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFPhotoSession {
            if sender.selectedSegmentIndex == 0 {
                session.resolution = CGSize(width: 3024, height: 4032)
                self.squareLayoutConstraint.priority = .defaultLow
                self.wideLayoutConstraint.priority = .defaultHigh
            } else {
                session.resolution = CGSize(width: 3024, height: 3024)
                self.squareLayoutConstraint.priority = .defaultHigh
                self.wideLayoutConstraint.priority = .defaultLow
            }
        }
    }
}

class PhotoViewController: UIViewController, CKFSessionDelegate {
    
    @IBOutlet weak var squareLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var wideLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    
    var recordButton: RecordButton!
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    
    func didChangeValue(session: CKFSession, value: Any, key: String) {
        if key == "zoom" {
            self.zoomLabel.text = String(format: "%.1fx", value as! Double)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoSettingsViewController {
            vc.previewView = self.previewView
            vc.squareLayoutConstraint = self.squareLayoutConstraint
            vc.wideLayoutConstraint = self.wideLayoutConstraint
        } else if let nvc = segue.destination as? UINavigationController, let vc = nvc.children.first as? PhotoPreviewViewController {
            vc.image = sender as? UIImage
        }
    }
    
    @IBOutlet weak var previewView: CKFPreviewView! {
        didSet {
            let session = CKFPhotoSession()
            session.resolution = CGSize(width: 3024, height: 4032)
            session.delegate = self
            
            self.previewView.autorotate = true
            self.previewView.session = session
            self.previewView.previewLayer?.videoGravity = .resizeAspectFill
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        let closeButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "", icon: "Navigation/close")
        self.view.addSubview(closeButton)
        closeButton.easy.layout(Top(60), Left(10), Width(64), Height(64))
        
        let flipButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Flip", icon: "Camera/flip")
        self.view.addSubview(flipButton)
        flipButton.easy.layout(Top(60), Right(10), Width(64), Height(64))
        
        let filtersButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Filters", icon: "Camera/filter")
        self.view.addSubview(filtersButton)
        filtersButton.easy.layout(Top(20).to(flipButton), Right(10), Width(64), Height(64))
        
        let timerButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Timer", icon: "Camera/timer")
        self.view.addSubview(timerButton)
        timerButton.easy.layout(Top(20).to(filtersButton), Right(10), Width(64), Height(64))
        
        let flashButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Flash", icon: "Camera/flash-on")
        self.view.addSubview(flashButton)
        flashButton.easy.layout(Top(20).to(timerButton), Right(10), Width(64), Height(64))
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        recordButton.pictureMode = true
        recordButton.buttonColor = .pink
        recordButton.progressColor = .red
        recordButton.closeWhenFinished = false
        recordButton.addTarget(self, action: #selector(record), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stop), for: UIControl.Event.touchUpInside)
        recordButton.center.x = self.view.center.x
        self.view.addSubview(recordButton)
        recordButton.easy.layout(CenterX(), Bottom(90), Width(80), Height(80))
        
        
        let swapModeButton = CameraSwapButton(frame: CGRect(x: 0, y: 80, width: 80, height: 80), title: "Swap to", icon: "Camera/video")
        swapModeButton.addTarget(self, action: #selector(handleVideo(_:)), for: .touchUpInside)
        self.view.addSubview(swapModeButton)
        swapModeButton.easy.layout(Left(25).to(recordButton), CenterY().to(recordButton), Width(80), Height(80))
        
        let galleryButton = CameraSwapButton(frame: CGRect(x: 0, y: 80, width: 80, height: 80), title: "Gallery", icon: "")
        self.view.addSubview(galleryButton)
        galleryButton.easy.layout(Right(25).to(recordButton), CenterY().to(recordButton), Width(80), Height(80))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.previewView.session?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView.session?.stop()
    }
    
    @objc
    func handleVideo(_ sender: Any) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Video")
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = vc
        }, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func record() {
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        if let session = self.previewView.session as? CKFPhotoSession {
          session.capture(AVCapturePhotoSettings(), { (image, data, settings) in
            //print("image \(image)")
            //self.performSegue(withIdentifier: "Preview", sender: image)
          }) { (_) in
            //
          }
        }
    }
    
    @objc func updateProgress() {
        let maxDuration = CGFloat(5) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
        }
    }
    
    @objc func stop() {
        self.progressTimer.invalidate()
    }
}
