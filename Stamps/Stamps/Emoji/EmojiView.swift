//
//  EmojiView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/7/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

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
class EmojiView: UIView {

    var text: String? {
        didSet {
            labelView?.text = String(text?.first ?? " ")
            updateEnableState()
        }
    }

    var labelView: UILabel!
    var overlay: UIImageView!
    var color: UIColor? = UIColor.gray {
        didSet {
            if color == nil {
                color = UIColor.gray
            }
            updateEnableState()
        }
    }
    var isEnabled: Bool = true {
        didSet {
            updateEnableState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func updateOverlay() {
        labelView.isHidden = false
        let image = UIImage.imageWithLabel(label: labelView)
        let tonalFilter = CIFilter(name: "CIPhotoEffectTonal")
        let imageToBlur = CIImage(cgImage: image.cgImage!)
        tonalFilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
        let outputImage: CIImage? = tonalFilter?.outputImage
        overlay.image = UIImage(ciImage: outputImage ?? CIImage())
    }
    
    func updateEnableState() {
        if isEnabled {
            backgroundColor = color!.lighter(by: 50)
            labelView.isHidden = false
            overlay.removeFromSuperview()
            layer.borderColor = color!.cgColor
            layer.borderWidth = 2.0
            layer.shadowOpacity = 0.5
        }
        else {
            backgroundColor = UIColor.systemBackground
            addSubview(overlay)
            layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            layer.borderWidth = 1.0
            layer.shadowOpacity = 0
            updateOverlay()
            labelView.isHidden = true
        }
    }
    
    func setupView() {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2.0

        labelView = UILabel(frame: bounds)
        labelView.font = UIFont.systemFont(ofSize: (bounds.width * 0.65))
        labelView.textAlignment = .center
        labelView.backgroundColor = UIColor.clear
        addSubview(labelView)
        
        overlay = UIImageView(frame: bounds)
        overlay.layer.opacity = 0.3
        
        updateEnableState()
        
        // let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // addGestureRecognizer(tap)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        isEnabled = !isEnabled
    }
}
