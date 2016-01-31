//
//  CLAreaView.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit

public protocol CLLinesViewPathGenerator {
    func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath
}

public class CLLinesView: UIView {
    
    private let lineColor: UIColor
    private let lineWidth: CGFloat
    private let animDuration: Float
    private let animDelay: Float
    
    init(path: UIBezierPath, frame: CGRect, lineColor: UIColor, lineWidth: CGFloat, animDuration: Float, animDelay: Float) {
        
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.show(path: path)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLineMask(frame frame: CGRect) -> CALayer {
        let lineMaskLayer = CAShapeLayer()
        var maskRect = frame
        maskRect.origin.y = 0
        maskRect.size.height = frame.size.height
        let path = CGPathCreateWithRect(maskRect, nil)
        
        lineMaskLayer.path = path
        
        return lineMaskLayer
    }
    
    private func generateLayer(path path: UIBezierPath) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        lineLayer.lineJoin = kCALineJoinBevel
        lineLayer.fillColor   = UIColor.clearColor().CGColor
        lineLayer.lineWidth   = self.lineWidth
        
        lineLayer.path = path.CGPath;
        lineLayer.strokeColor = self.lineColor.CGColor;
        
        if self.animDuration > 0 {
            lineLayer.strokeEnd   = 0.0
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = CFTimeInterval(self.animDuration)
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = NSNumber(float: 0)
            pathAnimation.toValue = NSNumber(float: 1)
            pathAnimation.autoreverses = false
            pathAnimation.removedOnCompletion = false
            pathAnimation.fillMode = kCAFillModeForwards
            
            pathAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.animDelay)
            lineLayer.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
            
        } else {
            lineLayer.strokeEnd = 1
        }
        
        return lineLayer
    }
    
    private func show(path path: UIBezierPath) {
        let lineMask = self.createLineMask(frame: frame)
        self.layer.mask = lineMask
        self.layer.addSublayer(self.generateLayer(path: path))
    }
}


public class CLAreasView: UIView {

    private let animDuration: Float
    private let color: UIColor
    private let animDelay: Float
    
    public init(points: [CGPoint], frame: CGRect, color: UIColor, animDuration: Float, animDelay: Float) {
        self.color = color
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()
        self.show(path: self.generateAreaPath(points: points))
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func generateAreaPath(points points: [CGPoint]) -> UIBezierPath {
        
        let progressline = UIBezierPath()
        progressline.lineWidth = 1.0
        progressline.lineCapStyle = .Round
        progressline.lineJoinStyle = .Round
        
        if let p = points.first {
            progressline.moveToPoint(p)
        }
        
        for i in 1..<points.count {
            let p = points[i]
            progressline.addLineToPoint(p)
        }
        
        progressline.closePath()
        
        return progressline
    }
    
    private func show(path path: UIBezierPath) {
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor   = self.color.CGColor
        areaLayer.lineWidth   = 2.0
        areaLayer.strokeEnd   = 0.0
        self.layer.addSublayer(areaLayer)
        
        areaLayer.path = path.CGPath
        areaLayer.strokeColor = self.color.CGColor
        
        if self.animDuration > 0 {
            let maskLayer = CAGradientLayer()
            maskLayer.anchorPoint = CGPointZero
            
            let colors = [
                UIColor(white: 0, alpha: 0).CGColor,
                UIColor(white: 0, alpha: 1).CGColor]
            maskLayer.colors = colors
            maskLayer.bounds = CGRectMake(0, 0, 0, self.layer.bounds.size.height)
            maskLayer.startPoint = CGPointMake(1, 0)
            maskLayer.endPoint = CGPointMake(0, 0)
            self.layer.mask = maskLayer
        
            let revealAnimation = CABasicAnimation(keyPath: "bounds")
            revealAnimation.fromValue = NSValue(CGRect: CGRectMake(0, 0, 0, self.layer.bounds.size.height))
            
            let target = CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width + 2000, self.layer.bounds.size.height);
            
            revealAnimation.toValue = NSValue(CGRect: target)
            revealAnimation.duration = CFTimeInterval(self.animDuration)
            
            revealAnimation.removedOnCompletion = false
            revealAnimation.fillMode = kCAFillModeForwards
            
            revealAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.animDelay)
            self.layer.mask?.addAnimation(revealAnimation, forKey: "revealAnimation")
        }
    }
}

public class CLCandleStickView: UIView {
    
    private let innerRect: CGRect
    
    private let fillColor: UIColor
    private let strokeColor: UIColor
    
    private var currentFillColor: UIColor
    private var currentStrokeColor: UIColor
    
    private let highlightColor = UIColor.redColor()
    
    private let strokeWidth: CGFloat
    
    var highlighted: Bool = false {
        didSet {
            if self.highlighted {
                self.currentFillColor = self.highlightColor
                self.currentStrokeColor = self.highlightColor
            } else {
                self.currentFillColor = self.fillColor
                self.currentStrokeColor = self.strokeColor
            }
            self.setNeedsDisplay()
        }
    }
    
    public init(lineX: CGFloat, width: CGFloat, top: CGFloat, bottom: CGFloat, innerRectTop: CGFloat, innerRectBottom: CGFloat, fillColor: UIColor, strokeColor: UIColor = UIColor.blackColor(), strokeWidth: CGFloat = 1) {
        
        let frameX = lineX - width / CGFloat(2)
        let frame = CGRectMake(frameX, top, width, bottom - top)
        let t = innerRectTop - top
        let hsw = strokeWidth / 2
        self.innerRect = CGRectMake(hsw, t + hsw, width - strokeWidth, innerRectBottom - top - t - strokeWidth)
        
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        
        self.currentFillColor = fillColor
        self.currentStrokeColor = strokeColor
        self.strokeWidth = strokeWidth
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let wHalf = self.frame.width / 2
        
        CGContextSetLineWidth(context, self.strokeWidth)
        CGContextSetStrokeColorWithColor(context, self.currentStrokeColor.CGColor)
        CGContextMoveToPoint(context, wHalf, 0)
        CGContextAddLineToPoint(context, wHalf, self.frame.height)
        
        CGContextStrokePath(context)
        
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0)
        CGContextSetFillColorWithColor(context, self.currentFillColor.CGColor)
        CGContextFillRect(context, self.innerRect)
        CGContextStrokeRect(context, self.innerRect)
    }
    
    
}

// Convenience view to handle events without subclassing
public class HandlingView: UIView {
    
    public var movedToSuperViewHandler: (() -> ())?
    public var touchHandler: (() -> ())?
    
    override public func didMoveToSuperview() {
        self.movedToSuperViewHandler?()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchHandler?()
    }
}

// Convenience view to handle events without subclassing
public class HandlingLabel: UILabel {
    
    public var movedToSuperViewHandler: (() -> ())?
    public var touchHandler: (() -> ())?
    
    override public func didMoveToSuperview() {
        self.movedToSuperViewHandler?()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchHandler?()
    }
}

public class InfoBubble: UIView {
    
    private let arrowWidth: CGFloat
    private let arrowHeight: CGFloat
    private let bgColor: UIColor
    private let arrowX: CGFloat
    
    public init(frame: CGRect, arrowWidth: CGFloat, arrowHeight: CGFloat, bgColor: UIColor = UIColor.whiteColor(), arrowX: CGFloat) {
        self.arrowWidth = arrowWidth
        self.arrowHeight = arrowHeight
        self.bgColor = bgColor
        
        let arrowHalf = arrowWidth / 2
        self.arrowX = max(arrowHalf, min(frame.size.width - arrowHalf, arrowX))
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, self.bgColor.CGColor)
        CGContextSetStrokeColorWithColor(context, self.bgColor.CGColor)
        let rrect = CGRectInset(rect, 0, 20)
        
        let minx = CGRectGetMinX(rrect), maxx = CGRectGetMaxX(rrect)
        let miny = CGRectGetMinY(rrect), maxy = CGRectGetMaxY(rrect)
        
        let outlinePath = CGPathCreateMutable()
        
        CGPathMoveToPoint(outlinePath, nil, minx, miny)
        CGPathAddLineToPoint(outlinePath, nil, maxx, miny)
        CGPathAddLineToPoint(outlinePath, nil, maxx, maxy)
        CGPathAddLineToPoint(outlinePath, nil, self.arrowX + self.arrowWidth / 2, maxy)
        CGPathAddLineToPoint(outlinePath, nil, self.arrowX, maxy + self.arrowHeight)
        CGPathAddLineToPoint(outlinePath, nil, self.arrowX - self.arrowWidth / 2, maxy)
        
        CGPathAddLineToPoint(outlinePath, nil, minx, maxy)
        
        CGPathCloseSubpath(outlinePath)
        
        CGContextAddPath(context, outlinePath)
        CGContextFillPath(context)
    }
}

class StraightLinePathGenerator: CLLinesViewPathGenerator {
    func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        
        let progressline = UIBezierPath()
        
        if points.count >= 2 {
            
            progressline.lineWidth = lineWidth
            progressline.lineCapStyle = .Round
            progressline.lineJoinStyle = .Round
            
            for i in 0..<(points.count - 1) {
                let p1 = points[i]
                let p2 = points[i + 1]
                
                progressline.moveToPoint(p1)
                progressline.addLineToPoint(p2)
            }
            
            progressline.closePath()
        }
        
        return progressline
    }
}


public class CubicLinePathGenerator: CLLinesViewPathGenerator {
    
    public init() {}
    
    // src: http://stackoverflow.com/a/29876400/930450
    public func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        var cp1: CGPoint
        var cp2: CGPoint
        
        let path = UIBezierPath()
        var p0: CGPoint
        var p1: CGPoint
        var p2: CGPoint
        var p3: CGPoint
        var tensionBezier1: CGFloat = 0.3
        var tensionBezier2: CGFloat = 0.3
        
        var previousPoint1: CGPoint = CGPointZero
        //        var previousPoint2: CGPoint
        
        path.moveToPoint(points.first!)
        
        for i in 0..<(points.count - 1) {
            p1 = points[i]
            p2 = points[i + 1]
            
            let maxTension: CGFloat = 1 / 3
            tensionBezier1 = maxTension
            tensionBezier2 = maxTension
            
            if i > 0 {  // Exception for first line because there is no previous point
                p0 = previousPoint1
                
                if p2.y - p1.y == p2.y - p0.y {
                    tensionBezier1 = 0
                }
                
            } else {
                tensionBezier1 = 0
                p0 = p1
            }
            
            if i < points.count - 2 { // Exception for last line because there is no next point
                p3 = points[i + 2]
                if p3.y - p2.y == p2.y - p1.y {
                    tensionBezier2 = 0
                }
            } else {
                p3 = p2
                tensionBezier2 = 0
            }
            
            // The tension should never exceed 0.3
            if tensionBezier1 > maxTension {
                tensionBezier1 = maxTension
            }
            if tensionBezier1 > maxTension {
                tensionBezier2 = maxTension
            }
            
            // First control point
            cp1 = CGPointMake(p1.x + (p2.x - p1.x)/3,
                p1.y - (p1.y - p2.y)/3 - (p0.y - p1.y)*tensionBezier1)
            
            // Second control point
            cp2 = CGPointMake(p1.x + 2*(p2.x - p1.x)/3,
                (p1.y - 2*(p1.y - p2.y)/3) + (p2.y - p3.y)*tensionBezier2)
            
            
            path.addCurveToPoint(p2, controlPoint1: cp1, controlPoint2: cp2)
            
            previousPoint1 = p1;
            //            previousPoint2 = p2;
        }
        
        return path
    }
}

