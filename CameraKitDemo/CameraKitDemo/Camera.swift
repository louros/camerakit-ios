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

class CameraBase: UIViewController, CKFSessionDelegate {

    var recordButton: RecordButton!
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    
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

        control.underlineSelected = true
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

        control.underlineSelected = true
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
    
    var flashMode: CKFPhotoSession.FlashMode = .auto
    var cameraType: CKFSession.CameraPosition = .back
    
    var isTimerControlOn: Bool = false
    var isSpeedControlOn: Bool = false
    
    func didChangeValue(session: CKFSession, value: Any, key: String) {
        
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

