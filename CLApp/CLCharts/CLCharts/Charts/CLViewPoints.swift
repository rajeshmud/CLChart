//
//  CLPointEllipseView.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit

public class CLPointEllipseView: UIView {
    
    public var fillColor: UIColor = UIColor.grayColor()
    public var borderColor: UIColor? = nil
    public var borderWidth: CGFloat? = nil
    public var animDelay: Float = 0
    public var animDuration: Float = 0
    public var animateSize: Bool = true
    public var animateAlpha: Bool = true
    public var animDamping: CGFloat = 1
    public var animInitSpringVelocity: CGFloat = 1
    
    public var touchHandler: (() -> ())?

    convenience public init(center: CGPoint, diameter: CGFloat) {
        self.init(center: center, width: diameter, height: diameter)
    }
    
    public init(center: CGPoint, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRectMake(center.x - width / 2, center.y - height / 2, width, height))
        self.backgroundColor = UIColor.clearColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override public func didMoveToSuperview() {
        if self.animDuration != 0 {
            if self.animateSize {
                self.transform = CGAffineTransformMakeScale(0.1, 0.1)
            }
            if self.animateAlpha {
                self.alpha = 0
            }
            
            UIView.animateWithDuration(NSTimeInterval(self.animDuration), delay: NSTimeInterval(self.animDelay), usingSpringWithDamping: self.animDamping, initialSpringVelocity: self.animInitSpringVelocity, options: UIViewAnimationOptions(), animations: { () -> Void in
                if self.animateSize {
                    self.transform = CGAffineTransformMakeScale(1, 1)
                }
                if self.animateAlpha {
                    self.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        let borderOffset = self.borderWidth ?? 0
        let circleRect = (CGRectMake(borderOffset, borderOffset, self.frame.size.width - (borderOffset * 2), self.frame.size.height - (borderOffset * 2)))
        
        if let borderWidth = self.borderWidth, borderColor = self.borderColor {
            CGContextSetLineWidth(context, borderWidth)
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextStrokeEllipseInRect(context, circleRect)
        }
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor)
        CGContextFillEllipseInRect(context, circleRect)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchHandler?()
    }
}

public class CLPointTargetingView: UIView {
    
    private let animDuration: Float
    private let animDelay: Float
    
    private let lineHorizontal: UIView
    private let lineVertical: UIView
    
    private let lineWidth = 1
    
    private let lineHorizontalTargetFrame: CGRect
    private let lineVerticalTargetFrame: CGRect
    
    public init(chartPoint: ChartPoint, screenLoc: CGPoint, animDuration: Float, animDelay: Float, frame: CGRect, layer: CLCoordsSpaceLayer) {
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        let chartInnerFrame = layer.innerFrame
        
        let axisOriginX = chartInnerFrame.origin.x
        let axisOriginY = chartInnerFrame.origin.y
        let axisLengthX = chartInnerFrame.width
        let axisLengthY = chartInnerFrame.height
        
        self.lineHorizontal = UIView(frame: CGRectMake(axisOriginX, axisOriginY, axisLengthX, CGFloat(lineWidth)))
        self.lineVertical = UIView(frame: CGRectMake(axisOriginX, axisOriginY, CGFloat(lineWidth), axisLengthY))
        
        self.lineHorizontal.backgroundColor = UIColor.blackColor()
        self.lineVertical.backgroundColor = UIColor.redColor()
        
        let lineWidthHalf = self.lineWidth / 2
        var targetFrameH = lineHorizontal.frame
        targetFrameH.origin.y = screenLoc.y - CGFloat(lineWidthHalf)
        self.lineHorizontalTargetFrame = targetFrameH
        var targetFrameV = lineVertical.frame
        targetFrameV.origin.x = screenLoc.x - CGFloat(lineWidthHalf)
        self.lineVerticalTargetFrame = targetFrameV
        
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        addSubview(self.lineHorizontal)
        addSubview(self.lineVertical)
        
        UIView.animateWithDuration(NSTimeInterval(self.animDuration), delay: NSTimeInterval(self.animDelay), options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            self.lineHorizontal.frame = self.lineHorizontalTargetFrame
            self.lineVertical.frame = self.lineVerticalTargetFrame
            
            }) { (Bool) -> Void in
        }
    }
}

public class CLPointTextCircleView: UILabel {
    
    private let targetCenter: CGPoint
    public var viewTapped: ((CLPointTextCircleView) -> ())?
    
    public var selected: Bool = false {
        didSet {
            if self.selected {
                self.textColor = UIColor.whiteColor()
                self.layer.borderColor = UIColor.whiteColor().CGColor
                self.layer.backgroundColor = UIColor.blackColor().CGColor
                
            } else {
                self.textColor = UIColor.blackColor()
                self.layer.borderColor = UIColor.blackColor().CGColor
                self.layer.backgroundColor = UIColor.whiteColor().CGColor
            }
        }
    }
    
    public init(chartPoint: ChartPoint, center: CGPoint, diameter: CGFloat, cornerRadius: CGFloat, borderWidth: CGFloat, font: UIFont) {
        
        self.targetCenter = center
        
        super.init(frame: CGRectMake(0, center.y - diameter / 2, diameter, diameter))
        
        self.textColor = UIColor.blackColor()
        self.text = chartPoint.text
        self.font = font
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.textAlignment = NSTextAlignment.Center
        self.layer.borderColor = UIColor.grayColor().CGColor
        
        let c = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
        self.layer.backgroundColor = c.CGColor
        
        self.userInteractionEnabled = true
    }
    
    override public func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            let w: CGFloat = self.frame.size.width
            let h: CGFloat = self.frame.size.height
            let frame = CGRectMake(self.targetCenter.x - (w/2), self.targetCenter.y - (h/2), w, h)
            self.frame = frame
            
            }, completion: {finished in})
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        viewTapped?(self)
    }
}

public class CLPointViewBar: UIView {
    
    private let targetFrame: CGRect
    private let animDuration: Float
    
    public init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor? = nil, animDuration: Float = 0.5) {
        let (targetFrame, firstFrame): (CGRect, CGRect) = {
            if p1.y - p2.y == 0 { // horizontal
                let targetFrame = CGRectMake(p1.x, p1.y - width / 2, p2.x - p1.x, width)
                let initFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y, 0, targetFrame.size.height)
                return (targetFrame, initFrame)
                
            } else { // vertical
                let targetFrame = CGRectMake(p1.x - width / 2, p1.y, width, p2.y - p1.y)
                let initFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y, targetFrame.size.width, 0)
                
                return (targetFrame, initFrame)
            }
        }()
        
        self.targetFrame =  targetFrame
        self.animDuration = animDuration
        
        super.init(frame: firstFrame)
        
        self.backgroundColor = bgColor
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        UIView.animateWithDuration(CFTimeInterval(self.animDuration), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
            self.frame = self.targetFrame
            }, completion: nil)
    }
}

public class CLPointViewBarGreyOut: CLPointViewBar {
    
    private let greyOut: Bool
    private let greyOutDelay: Float
    private let greyOutAnimDuration: Float
    
    init(chartPoint: ChartPoint, p1: CGPoint, p2: CGPoint, width: CGFloat, color: UIColor, animDuration: Float = 0.5, greyOut: Bool = false, greyOutDelay: Float = 1, greyOutAnimDuration: Float = 0.5) {
        
        self.greyOut = greyOut
        self.greyOutDelay = greyOutDelay
        self.greyOutAnimDuration = greyOutAnimDuration
        
        super.init(p1: p1, p2: p2, width: width, bgColor: color, animDuration: animDuration)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        
        if self.greyOut {
            UIView.animateWithDuration(CFTimeInterval(self.greyOutAnimDuration), delay: CFTimeInterval(self.greyOutDelay), options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                self.backgroundColor = UIColor.grayColor()
                }, completion: nil)
        }
    }
}

public typealias CLPointViewBarStackedFrame = (rect: CGRect, color: UIColor)

public class CLPointViewBarStacked: CLPointViewBar {
    
    private let stackFrames: [CLPointViewBarStackedFrame]
    
    init(p1: CGPoint, p2: CGPoint, width: CGFloat, stackFrames: [CLPointViewBarStackedFrame], animDuration: Float = 0.5) {
        self.stackFrames = stackFrames
        super.init(p1: p1, p2: p2, width: width, bgColor: UIColor.clearColor(), animDuration: animDuration)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        for stackFrame in self.stackFrames {
            CGContextSetFillColorWithColor(context, stackFrame.color.CGColor)
            CGContextFillRect(context, stackFrame.rect)
        }
    }
}