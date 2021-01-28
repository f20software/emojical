//
//  StickerView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/7/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

// Extension to UIImage class to render label as image
extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

// Sublcass of UIView to provide easy functionality to render complete sticker
// with enabled/disabled state, emoji in the middle and shadow if necessary
//
// -- main view - will use background property, and configure border + shadow on a view layer
//  -- label view - will render sticker emoji symbol (only visible if sticker is enabled)
//  -- overlay view - monochromatic version of label view (only visible is sticker is disabled)
class StickerViewO: UIView {

    // Default sticker color
    static private let defaultColor = UIColor.gray
    
    // Text to be used as a sticker
    // We might extend it back to use SS Symbol font for example
    var text: String? {
        didSet {
            labelView?.text = String(text?.first ?? " ")
            updateState()
        }
    }
    
    // Color for the sticker background and border
    var color: UIColor? = StickerViewO.defaultColor {
        didSet {
            if color == nil {
                color = StickerViewO.defaultColor
            }
            updateState()
        }
    }
    
    // Enabled/disabled state for the sticker
    var isEnabled: Bool = true {
        didSet {
            updateState()
        }
    }

    private var labelView: UILabel!
    private var overlayView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func updateOverlayView() {
        labelView.isHidden = false
        // Render label and apply monochromatic effect to it
        let image = UIImage.imageWithLabel(label: labelView)
        let tonalFilter = CIFilter(name: "CIPhotoEffectTonal")
        let imageToBlur = CIImage(cgImage: image.cgImage!)
        tonalFilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
        // Use the result as an overlay image view
        let outputImage: CIImage? = tonalFilter?.outputImage
        overlayView.image = UIImage(ciImage: outputImage ?? CIImage())
    }
    
    // Configure all subviews and colors based on whether sticker is enabled or disabled
    private func updateState() {
        if isEnabled {
            backgroundColor = color!.lighter(by: 50)
            labelView.isHidden = false
            overlayView.removeFromSuperview()
            layer.borderColor = color!.cgColor
            layer.borderWidth = 2.0
            layer.shadowOpacity = 0.5
        }
        else {
            backgroundColor = UIColor.systemBackground
            addSubview(overlayView)
            layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            layer.borderWidth = 1.0
            layer.shadowOpacity = 0
            updateOverlayView()
            labelView.isHidden = true
        }
    }
    
    private func setupView() {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2.0

        labelView = UILabel(frame: bounds)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: 26/*((bounds.width * 0.60)*/)
        labelView.textAlignment = .center
        labelView.backgroundColor = UIColor.clear
        addSubview(labelView)
        
        overlayView = UIImageView(frame: bounds)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.layer.opacity = 0.3
        
        updateState()
        
        // let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        labelView.frame = CGRect(origin: .zero, size: bounds.size)
        overlayView.frame = CGRect(origin: .zero, size: bounds.size)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        isEnabled = !isEnabled
    }
}
