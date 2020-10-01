//
//  Camera.swift
//  CameraKitDemo
//
//  Created by uros on 30/09/2020.
//  Copyright © 2020 Wonderkiln. All rights reserved.
//

import UIKit
import CameraKit
import EasyPeasy
import ScrollableSegmentedControl
import Photos

class CameraBase: UIViewController, CKFSessionDelegate {

    var recordButton: RecordButton!
    var progressTimer : Timer!
    var progress : CGFloat = 0.0
    
    lazy var speedSegmentedControl: ScrollableSegmentedControl = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 22
        blurEffectView.clipsToBounds = true

        let control = ScrollableSegmentedControl()
        control.segmentStyle = .textOnly
        control.insertSegment(withTitle: "0.3x", image: nil, at: 0)
        control.insertSegment(withTitle: "0.5x", image: nil, at: 1)
        control.insertSegment(withTitle: "1x", image: nil, at: 2)
        control.insertSegment(withTitle: "2x", image: nil, at: 3)
        control.insertSegment(withTitle: "3x", image: nil, at: 4)

        control.circularShadeSelected = true
        control.tintColor = .white
        control.selectedSegmentContentColor = .white
        control.fixedSegmentWidth = true
        control.selectedSegmentIndex = 2
        
        control.insertSubview(blurEffectView, at: 0)
        blurEffectView.easy.layout(Edges())
        
        return control
    }()
    
    lazy var timerSegmentedControl: ScrollableSegmentedControl = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 22
        blurEffectView.clipsToBounds = true

        let control = ScrollableSegmentedControl()
        control.segmentStyle = .textOnly
        control.insertSegment(withTitle: "5s", image: nil, at: 0)
        control.insertSegment(withTitle: "10s", image: nil, at: 1)
        control.insertSegment(withTitle: "15s", image: nil, at: 2)

        control.circularShadeSelected = true
        control.tintColor = .white
        control.selectedSegmentContentColor = .white
        control.fixedSegmentWidth = true
        control.selectedSegmentIndex = 2
        
        control.insertSubview(blurEffectView, at: 0)
        blurEffectView.easy.layout(Edges())
        
        return control
    }()
    
    var closeButton: CameraOverlayButton!
    var flipButton: CameraOverlayButton!
    var speedButton: CameraOverlayButton!
    var filtersButton: CameraOverlayButton!
    var timerButton: CameraOverlayButton!
    var flashButton: CameraOverlayButton!
    
    var swapModeButton: CameraSwapButton!
    var galleryButton: CameraGalleryButton!
    
    var flashMode: CKFPhotoSession.FlashMode = .auto
    var cameraType: CKFSession.CameraPosition = .back
    
    var isTimerControlOn: Bool = false
    var isSpeedControlOn: Bool = false
    
    func didChangeValue(session: CKFSession, value: Any, key: String) {
        
    }
    
    func fetchLastImageInGallery(completion: @escaping (UIImage?) -> Void) -> Void {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 3

        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

        if fetchResult.count > 0 {
            fetchPhotoAtIndex(0, 1, fetchResult) { (image) in
                completion(image)
            }
        }
    }
    
    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>, completion: @escaping (UIImage?) -> Void) {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                if let image = image {
                    completion(image)
                }
            })
        }
}

class CameraOverlayButton: UIButton {
    var label: UILabel = UILabel()
    var iconView: UIImageView = UIImageView()
    
    var title: String = ""
    var icon: UIImage? = nil {
        didSet {
            iconView.image = icon
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, title: String, icon: UIImage?) {
        self.init(frame: frame)
        self.title = title
        self.icon = icon
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.25
        
        self.addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(didTouchUp), for: .touchUpOutside)
        
        setup()
    }
    
    func setup() {
        iconView.image = icon
        self.addSubview(iconView)
        iconView.easy.layout(CenterX(), CenterY(), Width(24), Height(24))
        
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(label)
        label.easy.layout(Left(), Right(), Top(5).to(iconView), Height(22))
    }
    
    @objc open func didTouchDown(){
        
    }
    
    @objc open func didTouchUp() {
        
    }
}

class CameraSwapButton: CameraOverlayButton {
    override func setup() {
        self.layer.shadowOpacity = 0.0
        
        iconView.backgroundColor = .cardsGray
        iconView.layer.cornerRadius = 12
        iconView.clipsToBounds = true
        iconView.image = icon?.withPadding(14.0)
        self.addSubview(iconView)
        iconView.easy.layout(CenterX(), CenterY(), Width(48), Height(48))
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.25
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(label)
        label.easy.layout(Left(), Right(), Top(5).to(iconView), Height(22))
    }
}

class CameraGalleryButton: CameraOverlayButton {
    override func setup() {
        self.layer.shadowOpacity = 0.0
        
        let bg = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        bg.backgroundColor = .cardsGray
        bg.layer.cornerRadius = 12
        bg.clipsToBounds = true
        self.insertSubview(bg, at: 0)
        bg.easy.layout(CenterX(), CenterY(), Width(48), Height(48))
        
        iconView.contentMode = .scaleAspectFill
        iconView.image = icon
        iconView.layer.cornerRadius = 12
        iconView.clipsToBounds = true
        self.addSubview(iconView)
        iconView.easy.layout(CenterX(), CenterY(), Width(44), Height(44))
    }
}

class CameraActionButton: CameraOverlayButton {
    override func setup() {
        self.layer.shadowOpacity = 0.0
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
        
        iconView.image = icon?.withPadding(14.0)
        self.addSubview(iconView)
        iconView.easy.layout(CenterX(), CenterY(), Width(48), Height(48))
    }
}

class CameraLibraryButton: CameraOverlayButton {
    override func setup() {
        self.layer.shadowOpacity = 0.0
        
        iconView.backgroundColor = .cardsGray
        iconView.layer.cornerRadius = 12
        iconView.clipsToBounds = true
        iconView.image = icon?.withPadding(14.0)
        self.addSubview(iconView)
        iconView.easy.layout(CenterX(), CenterY(), Width(48), Height(48))
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.25
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(label)
        label.easy.layout(Left(), Right(), Top(5).to(iconView), Height(22))
    }
}

@objc open class RecordButton: UIButton {
    let ringCircle = CAShapeLayer()
    var ringPath: UIBezierPath?
    
    var isRecording: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let innerCircle = CALayer()
        innerCircle.frame = CGRect(x: 6, y: 6, width: 68, height: 68)
        innerCircle.backgroundColor = UIColor.pink.cgColor
        innerCircle.cornerRadius = 34
        self.layer.addSublayer(innerCircle)
        
        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi/2)
        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi/2)
        
        ringPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.midX,y: self.frame.midY),
                                radius: self.frame.size.width / 2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        ringCircle.path = ringPath!.cgPath
        ringCircle.backgroundColor = nil
        ringCircle.fillColor = nil
        ringCircle.strokeColor = UIColor.pink.cgColor.copy(alpha: 0.5)
        ringCircle.lineWidth = 4.0
        ringCircle.strokeStart = 0.0
        ringCircle.strokeEnd = 1.0
        self.layer.addSublayer(ringCircle)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        self.ringCircle.lineWidth = 8.0
        self.ringCircle.path = self.ringPath!.cgPath
        
        isRecording = true
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        self.ringCircle.lineWidth = 4.0
        self.ringCircle.path = self.ringPath!.cgPath
        
        isRecording = false
    }
}
