//
//  Camera.swift
//  CameraKitDemo
//
//  Created by uros on 30/09/2020.
//  Copyright © 2020 Wonderkiln. All rights reserved.
//

import UIKit
import EasyPeasy

class CameraOverlayButton: UIButton {
    var label: UILabel = UILabel()
    var iconView: UIImageView = UIImageView()
    
    var title: String = ""
    var icon: String = "" {
        didSet {
            iconView.image = UIImage(named: icon)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, title: String, icon: String) {
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
        iconView.image = UIImage(named: icon)
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
        iconView.image = UIImage(named: icon)?.withPadding(14.0)
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
        iconView.image = UIImage(named: icon)?.withPadding(14.0)
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

