//
//  MonthBoxView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

// Custom view to draw month statistic box
class MonthBoxView : UIView {
    
    @IBInspectable
    var startOffset: Int = 0

    @IBInspectable
    var data: String = "0|1|0|1|0|1|0|0|1|0|1|0|1|0|0|1|0|1|0|1|0|0|1|0|1|0|1|0|1|1" {
        didSet {
            bits = data.split(separator: "|").map({ String($0) })
        }
    }
    
    @IBInspectable
    var lineWidth: CGFloat = 2.0

    @IBInspectable
    var boxesRatio: CGFloat = 0.7

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
        // dx / dy
        let step = bounds.width / 7.0

        // Size of the square - 7 per row with some gap
        let size = step * boxesRatio
        
        // Initial x point of the first square
        let startY = step / 2.0 - size / 2.0
        let startX = startY + (step * CGFloat(startOffset))
        
        // initial index
        var index = startOffset
        
        // iInitial rect for the first square
        var squareRect = CGRect(x: startX, y: startY, width: size, height: size).insetBy(dx: lineWidth, dy: lineWidth)
        
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
            
            if index < 6 {
                squareRect = squareRect.offsetBy(dx: step, dy: 0)
                index += 1
            } else {
                squareRect = squareRect.offsetBy(dx: -step*6, dy: step)
                index = 0
            }
        }
    }
}
