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

    override func didChangeValue(session: CKFSession, value: Any, key: String) {
        if key == "zoom" {
            self.zoomLabel.text = String(format: "%.1fx", value as! Double)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VideoSettingsViewController {
            vc.previewView = self.previewView
        } else if let nvc = segue.destination as? UINavigationController, let vc = nvc.children.first as? VideoPreviewViewController {
            vc.url = sender as? URL
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
        
        
        let swapModeButton = CameraSwapButton(frame: CGRect(x: 0, y: 80, width: 80, height: 80), title: "Swap to", icon: UIImage(named: "Camera/camera"))
        swapModeButton.addTarget(self, action: #selector(handlePhoto(_:)), for: .touchUpInside)
        self.view.addSubview(swapModeButton)
        swapModeButton.easy.layout(Left(25).to(recordButton), CenterY().to(recordButton), Width(80), Height(80))
        
        let galleryButton = CameraSwapButton(frame: CGRect(x: 0, y: 80, width: 80, height: 80), title: "Gallery", icon: nil)
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
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
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
