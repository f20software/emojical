//
//  WeekLineView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class WeekLineView : UIView {
    
    @IBInspectable
    var data: String = "0|1|0|1|0|1|0" {
        didSet {
            bits = data.split(separator: "|").map({ String($0) })
        }
    }
    
    @IBInspectable
    var lineWidth: CGFloat = 2.0

    @IBInspectable
    var cornerRadius: CGFloat = 2.0

    // MARK: - State
    
    // Array of data to display
    private var bits: [String] = []

    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let size = bounds.height
        let step = bounds.width / CGFloat(bits.count)
        let start = step / 2.0 - size / 2.0
        
        // iInitial rect for the first square
        var squareRect = CGRect(x: start, y: 0, width: size, height: size).insetBy(dx: lineWidth, dy: lineWidth)
        
        for bit in bits {
            let path = UIBezierPath(roundedRect: squareRect, cornerRadius: cornerRadius)
            
            /// Optionally fill rect
            if bit == "1" {
                tintColor.setFill()
                path.fill()
            }

            /// Rectangle Drawing
            tintColor.setStroke()
            path.lineWidth = lineWidth
            path.lineJoinStyle = .round
            path.stroke()
            
            squareRect = squareRect.offsetBy(dx: step, dy: 0)
        }
    }
}
