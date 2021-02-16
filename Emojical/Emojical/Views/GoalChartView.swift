//
//  GoalChartView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/15/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalChartView : UIView {
    
    var data = [GoalChartPoint]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Graph line color
    @IBInspectable
    var lineColor: UIColor = UIColor.black

    /// Graph line width
    @IBInspectable
    var lineWidth: CGFloat = 3.0

    /// Radius for the graph dots
    @IBInspectable
    var dotRadius: CGFloat = 5.0

    /// Count of plot points to display (at max - data array can contain fewer items)
    @IBInspectable
    var count: Int = 20
    
    /// Max value for the data
    @IBInspectable
    var dataMax: Int = 10
    
    /// Draw a threashold at what level
    @IBInspectable
    var dataThreshold: Int = 10

    // MARK: - State
    
    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        // Inset inside to allow for dot circles and lines to not be cut
        let chartRect = rect.insetBy(dx: dotRadius+lineWidth, dy: dotRadius+lineWidth)

        let step = chartRect.width / CGFloat(count-1)
        let scale = chartRect.height / CGFloat(dataMax)
        var start = chartRect.maxX

        // First draw dotted line at the level of threshold
        let thresholdLine = UIBezierPath()
        thresholdLine.lineWidth = 1.0
        thresholdLine.setLineDash([3.0, 1.0], count: 1, phase: 0)
        lineColor.withAlphaComponent(0.5).setStroke()

        let y = chartRect.maxY - (chartRect.height / CGFloat(dataMax) * CGFloat(dataThreshold))
        thresholdLine.move(to: CGPoint(x: 0, y: y))
        thresholdLine.addLine(to: CGPoint(x: bounds.maxX, y: y))
        thresholdLine.stroke()

        // Now build array of points for our graph
        let points: [CGPoint] = data.prefix(count).map({
            let point = CGPoint(x: start, y: chartRect.maxY - scale * CGFloat($0.total))
            start = start - step
            return point
        })
        
        // Second draw the graph line
        let graph = UIBezierPath()
        graph.lineWidth = lineWidth
        graph.lineJoinStyle = .round
        lineColor.setStroke()
        
        points.forEach({
            if graph.isEmpty {
                graph.move(to: $0)
            } else {
                graph.addLine(to: $0)
            }
        })
        graph.stroke()

        // Now draw the dots (fill them up based on whether goal was reached or not)
        for (point, dataPoint) in zip(points, data) {

            /// Circle in the middle of the point with `dotRadius`
            let circle = CGRect(x: point.x, y: point.y, width: 0, height: 0)
                .insetBy(dx: -dotRadius, dy: -dotRadius)
            let path = UIBezierPath(roundedRect: circle, cornerRadius: dotRadius)

            /// Optionally fill circle
            if dataPoint.reached {
                lineColor.setFill()
            } else {
                backgroundColor?.setFill()
            }
            path.fill()

            /// Rectangle Drawing
            lineColor.setStroke()
            path.lineWidth = lineWidth
            path.lineJoinStyle = .round
            path.stroke()
        }
    }
}
