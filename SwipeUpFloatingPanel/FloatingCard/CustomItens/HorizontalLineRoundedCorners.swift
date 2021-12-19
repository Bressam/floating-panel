//
//  HorizontalLineRoundedCorners.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 18/12/21.
//

import UIKit

@IBDesignable class HorizontalLineRoundedCorners: UIView {
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Important so setup uses values sets on interface builder XIB
    // otherwise will use the default value for each variable
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        if defaultAppearance {
            self.backgroundColor = .darkGray
            self.layer.cornerRadius = self.layer.bounds.height/2
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = shadowOpacity
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    // MARK: - Properties
    var color: UIColor = .darkGray {
        didSet {
            self.backgroundColor = color
        }
    }
    
    @IBInspectable var defaultAppearance: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    var shadowColor: UIColor = .black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
