//
//  VideoViewController.swift
//  CameraKitDemo
//
//  Created by Adrian Mateoaea on 17/01/2019.
//  Copyright © 2019 Wonderkiln. All rights reserved.
//

import UIKit
import CameraKit
import AVKit
import EasyPeasy
import ScrollableSegmentedControl

class VideoPreviewViewController: UIViewController {
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = self.url {
            let player = AVPlayerViewController()
            player.player = AVPlayer(url: url)
            player.view.frame = self.view.bounds
            
            self.view.addSubview(player.view)
            self.addChild(player)
            
            player.player?.play()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSave(_ sender: Any) {
        if let url = self.url {
            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(handleDidCompleteSavingToLibrary(path:error:contextInfo:)), nil)
        }
    }
    
    @objc func handleDidCompleteSavingToLibrary(path: String?, error: Error?, contextInfo: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

class VideoSettingsViewController: UITableViewController {
    
    var previewView: CKFPreviewView!
    
    @IBOutlet weak var cameraSegmentControl: UISegmentedControl!
    @IBOutlet weak var flashSegmentControl: UISegmentedControl!
    @IBOutlet weak var gridSegmentControl: UISegmentedControl!
    
    @IBAction func handleCamera(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFVideoSession {
            session.cameraPosition = sender.selectedSegmentIndex == 0 ? .back : .front
        }
    }
    
    @IBAction func handleFlash(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFVideoSession {
            let values: [CKFVideoSession.FlashMode] = [.auto, .on, .off]
            session.flashMode = values[sender.selectedSegmentIndex]
        }
    }
    
    @IBAction func handleGrid(_ sender: UISegmentedControl) {
        self.previewView.showGrid = sender.selectedSegmentIndex == 1
    }
    
    @IBAction func handleMode(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFVideoSession {
            let modes = [(1920, 1080, 30), (1920, 1080, 60), (3840, 2160, 30)]
            let mode = modes[sender.selectedSegmentIndex]
            session.setWidth(mode.0, height: mode.1, frameRate: mode.2)
        }
    }
}

class VideoViewController: CameraBase {
    @IBOutlet weak var zoomLabel: UILabel!
    
    var deleteClipButton: CameraActionButton!
    var nextButton: CameraActionButton!
    
    let maxVideoLength: Int = 5
    let maxVideoSegments: Int = 5
    var segmentWidth: CGFloat = 0.0
    
    var videoProgressContainer: UIView!
    var videoProgressSegments: [UIView] = []

    override func didChangeValue(session: CKFSession, value: Any, key: String) {
        if key == "zoom" {
            self.zoomLabel.text = String(format: "%.1fx", value as! Double)
        }
    }
    
    @IBOutlet weak var previewView: CKFPreviewView! {
        didSet {
            let session = CKFVideoSession()
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
        closeButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "", icon: UIImage(named: "Navigation/close"))
        closeButton.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.easy.layout(Top(60), Left(10), Width(64), Height(64))
        
        flipButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Flip", icon: UIImage(named: "Camera/flip"))
        flipButton.addTarget(self, action: #selector(flipCameraAction(_:)), for: .touchUpInside)
        self.view.addSubview(flipButton)
        flipButton.easy.layout(Top(60), Right(10), Width(64), Height(64))
        
        speedButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Speed", icon: UIImage(named: "Camera/speed"))
        speedButton.addTarget(self, action: #selector(speedSelectionAction(_:)), for: .touchUpInside)
        self.view.addSubview(speedButton)
        speedButton.easy.layout(Top(20).to(flipButton), Right(10), Width(64), Height(64))
        
        filtersButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Filters", icon: UIImage(named: "Camera/filter"))
        self.view.addSubview(filtersButton)
        filtersButton.easy.layout(Top(20).to(speedButton), Right(10), Width(64), Height(64))
        
        timerButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Timer", icon: UIImage(named: "Camera/timer"))
        timerButton.addTarget(self, action: #selector(timerSelectionAction(_:)), for: .touchUpInside)
        self.view.addSubview(timerButton)
        timerButton.easy.layout(Top(20).to(filtersButton), Right(10), Width(64), Height(64))
        
        flashButton = CameraOverlayButton(frame: CGRect(x: 0, y: 80, width: 64, height: 64), title: "Flash", icon: UIImage(named: "Camera/flash-on"))
        flashButton.addTarget(self, action: #selector(toggleFlashAction(_:)), for: .touchUpInside)
        self.view.addSubview(flashButton)
        flashButton.easy.layout(Top(20).to(timerButton), Right(10), Width(64), Height(64))
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        recordButton.addTarget(self, action: #selector(record), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stop), for: UIControl.Event.touchUpInside)
        recordButton.center.x = self.view.center.x
        self.view.addSubview(recordButton)
        recordButton.easy.layout(CenterX(), Bottom(90), Width(80), Height(80))
        
        swapModeButton = CameraSwapButton(frame: CGRect(x: 0, y: 80, width: 80, height: 80), title: "Swap to", icon: UIImage(named: "Camera/camera"))
        swapModeButton.addTarget(self, action: #selector(handlePhoto(_:)), for: .touchUpInside)
        self.view.addSubview(swapModeButton)
        swapModeButton.easy.layout(Left(25).to(recordButton), CenterY().to(recordButton), Width(80), Height(80))
        
        galleryButton = CameraGalleryButton(frame: CGRect(x: 0, y: 80, width: 80, height: 80), title: "Gallery", icon: nil)
        self.view.addSubview(galleryButton)
        galleryButton.easy.layout(Right(25).to(recordButton), CenterY().to(recordButton), Width(80), Height(80))
        
        fetchLastImageInGallery { (image) in
            self.galleryButton.icon = image
        }
        
        videoProgressContainer = UIView(frame: CGRect(x: 25, y: 50, width: self.view.frame.width - 50, height: 8))
        videoProgressContainer.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        videoProgressContainer.layer.cornerRadius = 4
        videoProgressContainer.clipsToBounds = true
        self.view.addSubview(videoProgressContainer)
        videoProgressContainer.easy.layout(Left(25), Right(25), Top(50), Height(8))
        
        segmentWidth = videoProgressContainer.frame.width / CGFloat(maxVideoSegments)
        
        deleteClipButton = CameraActionButton(frame: CGRect(x: 0, y: 80, width: 48, height: 48), title: "", icon: UIImage(named: "Action/delete"))
        deleteClipButton.addTarget(self, action: #selector(deleteClipAction(_:)), for: .touchUpInside)
        deleteClipButton.backgroundColor = .gray2
        self.view.addSubview(deleteClipButton)
        deleteClipButton.easy.layout(Right(50).to(recordButton), CenterY().to(recordButton), Width(48), Height(48))
        deleteClipButton.isHidden = true
        
        nextButton = CameraActionButton(frame: CGRect(x: 0, y: 80, width: 48, height: 48), title: "", icon: UIImage(named: "Navigation/arrow-long-right"))
        nextButton.backgroundColor = .electricBlue
        self.view.addSubview(nextButton)
        nextButton.easy.layout(Left(50).to(recordButton), CenterY().to(recordButton), Width(48), Height(48))
        nextButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.previewView.session?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView.session?.stop()
    }
    
    @IBAction
    func handleCapture(_ sender: UIButton) {
        if let session = self.previewView.session as? CKFVideoSession {
            if session.isRecording {
                sender.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                session.stopRecording()
            } else {
                sender.backgroundColor = UIColor.red
                session.record({ (url) in
                    self.performSegue(withIdentifier: "Preview", sender: url)
                }) { (_) in
                    //
                }
            }
        }
    }
    
    @objc
    func closeAction(_ sender: UIButton) {
        if videoProgressSegments.count > 0 {
            let alert = UIAlertController(title: "Discard current recording progress?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                for segment in self.videoProgressSegments {
                    segment.removeFromSuperview()
                }
                
                self.videoProgressSegments = []
            
                self.galleryButton.isHidden = false
                self.swapModeButton.isHidden = false
                
                self.deleteClipButton.isHidden = true
                self.nextButton.isHidden = true
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            // dismiss
        }
    }
    
    @objc
    func deleteClipAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Discard last clip?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            
            let activeSegment = self.videoProgressSegments[self.videoProgressSegments.count - 1]
            activeSegment.removeFromSuperview()
            
            self.videoProgressSegments.remove(at: self.videoProgressSegments.count - 1)
            
            if self.videoProgressSegments.count == 0 {
                self.galleryButton.isHidden = false
                self.swapModeButton.isHidden = false
                
                self.deleteClipButton.isHidden = true
                self.nextButton.isHidden = true
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func handlePhoto(_ sender: Any) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Photo")
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = vc
        }, completion: nil)
    }
    
    @objc
    func toggleFlashAction(_ sender: UIButton) {
        switch flashMode {
        case .on:
            flashMode = .off
            flashButton.icon = UIImage(named: "Camera/flash-off")
        case .off:
            flashMode = .auto
            flashButton.icon = UIImage(named: "Camera/flash-auto")
        case .auto:
            flashMode = .on
            flashButton.icon = UIImage(named: "Camera/flash-on")
        }
        
        if let session = self.previewView.session as? CKFPhotoSession {
            session.flashMode = flashMode
        }
    }
    
    @objc
    func timerSelectionAction(_ sender: UIButton) {
        if !isTimerControlOn {
            self.view.addSubview(timerSegmentedControl)
            timerSegmentedControl.clipsToBounds = true
            timerSegmentedControl.easy.layout(CenterX(), Bottom(20).to(recordButton), Width(180), Height(44))
        }else {
            timerSegmentedControl.removeFromSuperview()
        }
        isTimerControlOn = !isTimerControlOn
        
        isSpeedControlOn = false
        speedSegmentedControl.removeFromSuperview()
    }
    
    @objc
    func speedSelectionAction(_ sender: UIButton) {
        if !isSpeedControlOn {
            self.view.addSubview(speedSegmentedControl)
            speedSegmentedControl.clipsToBounds = true
            speedSegmentedControl.easy.layout(CenterX(), Bottom(20).to(recordButton), Width(280), Height(44))
        }else {
            speedSegmentedControl.removeFromSuperview()
        }
        isSpeedControlOn = !isSpeedControlOn
        
        isTimerControlOn = false
        timerSegmentedControl.removeFromSuperview()
    }
    
    @objc
    func flipCameraAction(_ sender: UIButton) {
        switch cameraType {
        case .back:
            cameraType = .front
            
        case .front:
            cameraType = .back
        }
        
        if let session = self.previewView.session as? CKFPhotoSession {
            session.cameraPosition = cameraType
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func record() {
        progress = 0.0
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        galleryButton.isHidden = true
        swapModeButton.isHidden = true
        
        deleteClipButton.isHidden = false
        nextButton.isHidden = false
        
        let xPos = segmentWidth * CGFloat(videoProgressSegments.count)
        
        let segment = UIView(frame: CGRect(x: 0 + xPos, y: 0, width: 0, height: 8))
        segment.backgroundColor = .pink
        videoProgressContainer.addSubview(segment)
        
        if videoProgressSegments.count != 0 {
            let separator = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 8))
            separator.backgroundColor = .white
            segment.addSubview(separator)
        }
        
        videoProgressSegments.append(segment)
    }
    
    @objc func updateProgress() {
        progress = progress + (CGFloat(segmentWidth) * (CGFloat(maxVideoLength) / 1000.0))
        print(progress)
        let activeSegment = videoProgressSegments[videoProgressSegments.count - 1]
        activeSegment.frame.size = CGSize(width: progress, height: 8)
        
        if progress >= segmentWidth {
            progressTimer.invalidate()
            
            if recordButton.isRecording && videoProgressSegments.count < maxVideoSegments {
                record()
            }
        }
    }
    
    @objc func stop() {
        self.progressTimer.invalidate()
    }
}
