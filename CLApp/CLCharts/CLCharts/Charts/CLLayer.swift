//
//  CLLayer.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//


import UIKit

// Convenience class to make protocol's methods optional
public class CLLayerBase: CLLayer {
    
    public func chartInitialized(chart chart: Chart) {}
    
    public func viewDrawing(context context: CGContextRef, chart: Chart) {}
}


public protocol CLLayer {
    
    // Execute actions after chart initialisation, e.g. add subviews
     func chartInitialized(chart chart: Chart)
    
    // Use this to draw directly in chart's context.
    // Don't do anything processor intensive here - this is executed as part of draw(rect) thus has to be quick.
    // Note that everything drawn here will appear behind subviews added by any layer (regardless of position in layers array)
    // Everything done here can also be done adding a subview in chartInialized and drawing on that. The reason this method exists is only performance - as long as we know the layers will appear always behind (e.g. axis lines, guidelines) there's no reason to create new views.
    func viewDrawing(context context: CGContextRef, chart: Chart)
}

public class CLCoordsSpaceLayer: CLLayerBase {
    
    let xAxis: CLAxisLayer
    let yAxis: CLAxisLayer
    
    // frame where the layer displays chartpoints
    // note that this is not necessarily derived from axis, as axis can be in different positions (x-left/right, y-top/bottom) and be separated from content frame by a specified offset (multiaxis)
    public let innerFrame: CGRect
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.innerFrame = innerFrame
    }
}

public class CLShowCoordsLinesLayer<T: ChartPoint>: CLPointsLayer<T> {
    
    private var view: UIView?
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    public func showChartPointLines(chartPoint: T, chart: Chart) {
        
        if let view = self.view {
            
            for v in view.subviews {
                v.removeFromSuperview()
            }
            
            let screenLoc = self.chartPointScreenLoc(chartPoint)
            
            let hLine = UIView(frame: CGRectMake(screenLoc.x, screenLoc.y, 0, 1))
            let vLine = UIView(frame: CGRectMake(screenLoc.x, screenLoc.y, 0, 1))
            
            for lineView in [hLine, vLine] {
                lineView.backgroundColor = UIColor.blackColor()
                view.addSubview(lineView)
            }
            
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                hLine.frame = CGRectMake(self.innerFrame.origin.x, screenLoc.y, screenLoc.x - self.innerFrame.origin.x, 1)
                vLine.frame = CGRectMake(screenLoc.x, screenLoc.y, 1, self.innerFrame.origin.y + self.innerFrame.height - screenLoc.y)
                }, completion: nil)
        }
    }
    
    
    override func display(chart chart: Chart) {
        let view = UIView(frame: chart.bounds)
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
}

public typealias CLStackedBarItemModel = (quantity: Double, bgColor: UIColor)

public class ChartStackedBarModel: CLBarModel {
    
    let items: [CLStackedBarItemModel]
    
    public init(constant: CLAxisValue, start: CLAxisValue, items: [CLStackedBarItemModel]) {
        self.items = items
        
        let axisValue2Scalar = items.reduce(start.scalar) {sum, item in
            sum + item.quantity
        }
        let axisValue2 = start.copy(axisValue2Scalar)
        
        super.init(constant: constant, axisValue1: start, axisValue2: axisValue2)
    }
    
    lazy var totalQuantity: Double = {
        return self.items.reduce(0) {total, item in
            total + item.quantity
        }
    }()
}


class CLStackedBarsViewGenerator<T: ChartStackedBarModel>: CLBarsViewGenerator<T> {
    
    private typealias FrameBuilder = (barModel: ChartStackedBarModel, item: CLStackedBarItemModel, currentTotalQuantity: Double) -> (frame: CLPointViewBarStackedFrame, length: CGFloat)
    
    override init(horizontal: Bool, xAxis: CLAxisLayer, yAxis: CLAxisLayer, chartInnerFrame: CGRect, barWidth barWidthMaybe: CGFloat?, barSpacing barSpacingMaybe: CGFloat?) {
        super.init(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: chartInnerFrame, barWidth: barWidthMaybe, barSpacing: barSpacingMaybe)
    }
    
    override func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor? = nil, animDuration: Float) -> CLPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let frameBuilder: FrameBuilder = {
            switch self.direction {
            case .LeftToRight:
                return {barModel, item, currentTotalQuantity in
                    let p0 = self.xAxis.screenLocForScalar(currentTotalQuantity)
                    let p1 = self.xAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
                    let length = p1 - p0
                    let barLeftScreenLoc = self.xAxis.screenLocForScalar(length > 0 ? barModel.axisValue1.scalar : barModel.axisValue2.scalar)
                    
                    return (frame: CLPointViewBarStackedFrame(rect:
                        CGRectMake(
                            p0 - barLeftScreenLoc,
                            0,
                            length,
                            self.barWidth), color: item.bgColor), length: length)
                }
            case .BottomToTop:
                return {barModel, item, currentTotalQuantity in
                    let p0 = self.yAxis.screenLocForScalar(currentTotalQuantity)
                    let p1 = self.yAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
                    let length = p1 - p0
                    let barTopScreenLoc = self.yAxis.screenLocForScalar(length > 0 ? barModel.axisValue1.scalar : barModel.axisValue2.scalar)
                    
                    return (frame: CLPointViewBarStackedFrame(rect:
                        CGRectMake(
                            0,
                            p0 - barTopScreenLoc,
                            self.barWidth,
                            length), color: item.bgColor), length: length)
                }
            }
        }()
        
        
        let stackFrames = barModel.items.reduce((currentTotalQuantity: barModel.axisValue1.scalar, currentTotalLength: CGFloat(0), frames: Array<CLPointViewBarStackedFrame>())) {tuple, item in
            let frameWithLength = frameBuilder(barModel: barModel, item: item, currentTotalQuantity: tuple.currentTotalQuantity)
            return (currentTotalQuantity: tuple.currentTotalQuantity + item.quantity, currentTotalLength: tuple.currentTotalLength + frameWithLength.length, frames: tuple.frames + [frameWithLength.frame])
        }
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        
        return CLPointViewBarStacked(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, stackFrames: stackFrames.frames, animDuration: animDuration)
    }
    
}

public class CLStackedBarsLayer: CLCoordsSpaceLayer {
    
    private let barModels: [ChartStackedBarModel]
    private let horizontal: Bool
    
    private let barWidth: CGFloat?
    private let barSpacing: CGFloat?
    
    private let animDuration: Float
    
    public convenience init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: barWidth, barSpacing: nil, animDuration: animDuration)
    }
    
    public convenience init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barSpacing: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, animDuration: animDuration)
    }
    
    private init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat? = nil, barSpacing: CGFloat?, animDuration: Float) {
        self.barModels = barModels
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.animDuration = animDuration
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    public override func chartInitialized(chart chart: Chart) {
        
        let barsGenerator = CLStackedBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: self.barWidth, barSpacing: self.barSpacing)
        
        for barModel in self.barModels {
            chart.addSubview(barsGenerator.generateView(barModel, animDuration: self.animDuration))
        }
    }
}

public class CLBarModel {
    public let constant: CLAxisValue
    public let axisValue1: CLAxisValue
    public let axisValue2: CLAxisValue
    public let bgColor: UIColor?
    
    /**
     - parameter constant:Value of coordinate which doesn't change between start and end of the bar - if the bar is horizontal, this is y, if it's vertical it's x.
     - parameter axisValue1:Start, variable coordinate.
     - parameter axisValue2:End, variable coordinate.
     - parameter bgColor:Background color of bar.
     */
    public init(constant: CLAxisValue, axisValue1: CLAxisValue, axisValue2: CLAxisValue, bgColor: UIColor? = nil) {
        self.constant = constant
        self.axisValue1 = axisValue1
        self.axisValue2 = axisValue2
        self.bgColor = bgColor
    }
}

enum CLBarDirection {
    case LeftToRight, BottomToTop
}

class CLBarsViewGenerator<T: CLBarModel> {
    let xAxis: CLAxisLayer
    let yAxis: CLAxisLayer
    let chartInnerFrame: CGRect
    let direction: CLBarDirection
    let barWidth: CGFloat
    
    init(horizontal: Bool, xAxis: CLAxisLayer, yAxis: CLAxisLayer, chartInnerFrame: CGRect, barWidth barWidthMaybe: CGFloat?, barSpacing barSpacingMaybe: CGFloat?) {
        
        let direction: CLBarDirection = {
            switch (horizontal: horizontal, yLow: yAxis.low, xLow: xAxis.low) {
            case (horizontal: true, yLow: true, _): return .LeftToRight
            case (horizontal: false, _, xLow: true): return .BottomToTop
            default: fatalError("Direction not supported - stacked bars must be from left to right or bottom to top")
            }
        }()
        
        let barWidth = barWidthMaybe ?? {
            let axis: CLAxisLayer = {
                switch direction {
                case .LeftToRight: return yAxis
                case .BottomToTop: return xAxis
                }
            }()
            let spacing: CGFloat = barSpacingMaybe ?? 0
            return axis.minAxisScreenSpace - spacing
            }()
        
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.chartInnerFrame = chartInnerFrame
        self.direction = direction
        self.barWidth = barWidth
    }
    
    func viewPoints(barModel: T, constantScreenLoc: CGFloat) -> (p1: CGPoint, p2: CGPoint) {
        switch self.direction {
        case .LeftToRight:
            return (
                CGPointMake(self.xAxis.screenLocForScalar(barModel.axisValue1.scalar), constantScreenLoc),
                CGPointMake(self.xAxis.screenLocForScalar(barModel.axisValue2.scalar), constantScreenLoc))
        case .BottomToTop:
            return (
                CGPointMake(constantScreenLoc, self.yAxis.screenLocForScalar(barModel.axisValue1.scalar)),
                CGPointMake(constantScreenLoc, self.yAxis.screenLocForScalar(barModel.axisValue2.scalar)))
        }
    }
    
    func constantScreenLoc(barModel: T) -> CGFloat {
        return (self.direction == .LeftToRight ? self.yAxis : self.xAxis).screenLocForScalar(barModel.constant.scalar)
    }
    
    // constantScreenLoc: (screen) coordinate that is equal in p1 and p2 - for vertical bar this is the x coordinate, for horizontal bar this is the y coordinate
    func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor?, animDuration: Float) -> CLPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        return CLPointViewBar(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, bgColor: bgColor, animDuration: animDuration)
    }
}



public class CLBarsLayer: CLCoordsSpaceLayer {
    
    private let bars: [CLBarModel]
    
    private let barWidth: CGFloat?
    private let barSpacing: CGFloat?
    
    private let horizontal: Bool
    
    private let animDuration: Float
    
    public convenience init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, bars: [CLBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: barWidth, barSpacing: nil, animDuration: animDuration)
    }
    
    public convenience init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, bars: [CLBarModel], horizontal: Bool = false, barSpacing: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, animDuration: animDuration)
    }
    
    private init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, bars: [CLBarModel], horizontal: Bool = false, barWidth: CGFloat? = nil, barSpacing: CGFloat?, animDuration: Float) {
        self.bars = bars
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.animDuration = animDuration
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    public override func chartInitialized(chart chart: Chart) {
        
        
        let barsGenerator = CLBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: self.barWidth, barSpacing: self.barSpacing)
        
        for barModel in self.bars {
            chart.addSubview(barsGenerator.generateView(barModel, bgColor: barModel.bgColor, animDuration: self.animDuration))
        }
    }
}

public struct CLDividersLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    let start: CGFloat // points from start to axis, axis is 0
    let end: CGFloat // points from axis to end, axis is 0
    let onlyVisibleValues: Bool
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3, start: CGFloat = 5, end: CGFloat = 5, onlyVisibleValues: Bool = false) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
        self.start = start
        self.end = end
        self.onlyVisibleValues = onlyVisibleValues
    }
}

public enum CLDividersLayerAxis {
    case X, Y, XAndY
}

public class CLDividersLayer: CLCoordsSpaceLayer {
    
    private let settings: CLDividersLayerSettings
    
    private let xScreenLocs: [CGFloat]
    private let yScreenLocs: [CGFloat]
    
    let axis: CLDividersLayerAxis
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, axis: CLDividersLayerAxis = .XAndY, settings: CLDividersLayerSettings) {
        self.axis = axis
        self.settings = settings
        
        func screenLocs(axisLayer: CLAxisLayer) -> [CGFloat] {
            let values = settings.onlyVisibleValues ? axisLayer.axisValues.filter{!$0.hidden} : axisLayer.axisValues
            return values.map{axisLayer.screenLocForScalar($0.scalar)}
        }
        
        self.xScreenLocs = screenLocs(xAxis)
        self.yScreenLocs = screenLocs(yAxis)
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawLine(context context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint) {
        CLDrawLine(context: context, p1: p1, p2: p2, width: width, color: color)
    }
    
    override public func viewDrawing(context context: CGContextRef, chart: Chart) {
        let xScreenLocs = self.xScreenLocs
        let yScreenLocs = self.yScreenLocs
        
        if self.axis == .X || self.axis == .XAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = self.xAxis.lineP1.y + (self.xAxis.low ? -self.settings.end : self.settings.end)
                let x2 = xScreenLoc
                let y2 = self.xAxis.lineP1.y + (self.xAxis.low ? self.settings.start : -self.settings.end)
                self.drawLine(context: context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
        
        if self.axis == .Y || self.axis == .XAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = self.yAxis.lineP1.x + (self.yAxis.low ? -self.settings.start : self.settings.start)
                let y1 = yScreenLoc
                let x2 = self.yAxis.lineP1.x + (self.yAxis.low ? self.settings.end : self.settings.end)
                let y2 = yScreenLoc
                self.drawLine(context: context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
    }
}

public class CLGuideLinesLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
    }
}

public class CLGuideLinesDottedLayerSettings: CLGuideLinesLayerSettings {
    let dotWidth: CGFloat
    let dotSpacing: CGFloat
    
    public init(linesColor: UIColor, linesWidth: CGFloat, dotWidth: CGFloat = 2, dotSpacing: CGFloat = 2) {
        self.dotWidth = dotWidth
        self.dotSpacing = dotSpacing
        super.init(linesColor: linesColor, linesWidth: linesWidth)
    }
}

public enum CLGuideLinesLayerAxis {
    case X, Y, XAndY
}

public class CLGuideLinesLayerAbstract<T: CLGuideLinesLayerSettings>: CLCoordsSpaceLayer {
    
    private let settings: T
    private let onlyVisibleX: Bool
    private let onlyVisibleY: Bool
    private let axis: CLGuideLinesLayerAxis
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, axis: CLGuideLinesLayerAxis = .XAndY, settings: T, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        self.settings = settings
        self.onlyVisibleX = onlyVisibleX
        self.onlyVisibleY = onlyVisibleY
        self.axis = axis
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override public func viewDrawing(context context: CGContextRef, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        let xScreenLocs = onlyVisibleX ? self.xAxis.visibleAxisValuesScreenLocs : self.xAxis.axisValuesScreenLocs
        let yScreenLocs = onlyVisibleY ? self.yAxis.visibleAxisValuesScreenLocs : self.yAxis.axisValuesScreenLocs
        
        if self.axis == .X || self.axis == .XAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = originScreenLoc.y
                let x2 = x1
                let y2 = originScreenLoc.y + self.innerFrame.height
                self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
        
        if self.axis == .Y || self.axis == .XAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = originScreenLoc.x
                let y1 = yScreenLoc
                let x2 = originScreenLoc.x + self.innerFrame.width
                let y2 = y1
                self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
    }
}

public typealias CLGuideLinesLayer = CLGuideLinesLayer_<Any>
public class CLGuideLinesLayer_<N>: CLGuideLinesLayerAbstract<CLGuideLinesLayerSettings> {
    
    override public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, axis: CLGuideLinesLayerAxis = .XAndY, settings: CLGuideLinesLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: axis, settings: settings, onlyVisibleX: onlyVisibleX, onlyVisibleY: onlyVisibleY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        CLDrawLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor)
    }
}

public typealias CLGuideLinesDottedLayer = CLGuideLinesDottedLayer_<Any>
public class CLGuideLinesDottedLayer_<N>: CLGuideLinesLayerAbstract<CLGuideLinesDottedLayerSettings> {
    
    override public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, axis: CLGuideLinesLayerAxis = .XAndY, settings: CLGuideLinesDottedLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: axis, settings: settings, onlyVisibleX: onlyVisibleX, onlyVisibleY: onlyVisibleY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        CLDrawDottedLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor, dotWidth: self.settings.dotWidth, dotSpacing: self.settings.dotSpacing)
    }
}


public class CLGuideLinesForValuesLayerAbstract<T: CLGuideLinesLayerSettings>: CLCoordsSpaceLayer {
    
    private let settings: T
    private let axisValuesX: [CLAxisValue]
    private let axisValuesY: [CLAxisValue]
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, settings: T, axisValuesX: [CLAxisValue], axisValuesY: [CLAxisValue]) {
        self.settings = settings
        self.axisValuesX = axisValuesX
        self.axisValuesY = axisValuesY
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawGuideline(context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint, dotWidth: CGFloat, dotSpacing: CGFloat) {
        CLDrawDottedLine(context: context, p1: p1, p2: p2, width: width, color: color, dotWidth: dotWidth, dotSpacing: dotSpacing)
    }
    
    private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override public func viewDrawing(context context: CGContextRef, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        
        for axisValue in self.axisValuesX {
            let screenLoc = self.xAxis.screenLocForScalar(axisValue.scalar)
            let x1 = screenLoc
            let y1 = originScreenLoc.y
            let x2 = x1
            let y2 = originScreenLoc.y + self.innerFrame.height
            self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            
        }
        
        for axisValue in self.axisValuesY {
            let screenLoc = self.yAxis.screenLocForScalar(axisValue.scalar)
            let x1 = originScreenLoc.x
            let y1 = screenLoc
            let x2 = originScreenLoc.x + self.innerFrame.width
            let y2 = y1
            self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            
        }
    }
}


public typealias CLGuideLinesForValuesLayer = CLGuideLinesForValuesLayer_<Any>
public class CLGuideLinesForValuesLayer_<N>: CLGuideLinesForValuesLayerAbstract<CLGuideLinesLayerSettings> {
    
    public override init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, settings: CLGuideLinesLayerSettings, axisValuesX: [CLAxisValue], axisValuesY: [CLAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        CLDrawLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor)
    }
}

public typealias CLGuideLinesForValuesDottedLayer = CLGuideLinesForValuesDottedLayer_<Any>
public class CLGuideLinesForValuesDottedLayer_<N>: CLGuideLinesForValuesLayerAbstract<CLGuideLinesDottedLayerSettings> {
    
    public override init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, settings: CLGuideLinesDottedLayerSettings, axisValuesX: [CLAxisValue], axisValuesY: [CLAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        CLDrawDottedLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor, dotWidth: self.settings.dotWidth, dotSpacing: self.settings.dotSpacing)
    }
}

public class CLCandleStickLayer<T: CLPointCandleStick>: CLPointsLayer<T> {
    
    private var screenItems: [CandleStickScreenItem] = []
    
    private let itemWidth: CGFloat
    private let strokeWidth: CGFloat
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], itemWidth: CGFloat = 10, strokeWidth: CGFloat = 1) {
        self.itemWidth = itemWidth
        self.strokeWidth = strokeWidth
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
        
        self.screenItems = self.chartPointsModels.map {model in
            
            let chartPoint = model.chartPoint
            
            let x = model.screenLoc.x
            
            let highScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.high)).y
            let lowScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.low)).y
            let openScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.open)).y
            let closeScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.close)).y
            
            let (rectTop, rectBottom, fillColor) = closeScreenY < openScreenY ? (closeScreenY, openScreenY, UIColor.whiteColor()) : (openScreenY, closeScreenY, UIColor.blackColor())
            return CandleStickScreenItem(x: x, lineTop: highScreenY, lineBottom: lowScreenY, rectTop: rectTop, rectBottom: rectBottom, width: self.itemWidth, fillColor: fillColor)
        }
    }
    
    override public func viewDrawing(context context: CGContextRef, chart: Chart) {
        
        for screenItem in self.screenItems {
            
            CGContextSetLineWidth(context, self.strokeWidth)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextMoveToPoint(context, screenItem.x, screenItem.lineTop)
            CGContextAddLineToPoint(context, screenItem.x, screenItem.lineBottom)
            CGContextStrokePath(context)
            
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0)
            CGContextSetFillColorWithColor(context, screenItem.fillColor.CGColor)
            CGContextFillRect(context, screenItem.rect)
            CGContextStrokeRect(context, screenItem.rect)
        }
    }
}


private struct CandleStickScreenItem {
    let x: CGFloat
    let lineTop: CGFloat
    let lineBottom: CGFloat
    let fillColor: UIColor
    let rect: CGRect
    
    init(x: CGFloat, lineTop: CGFloat, lineBottom: CGFloat, rectTop: CGFloat, rectBottom: CGFloat, width: CGFloat, fillColor: UIColor) {
        self.x = x
        self.lineTop = lineTop
        self.lineBottom = lineBottom
        self.rect = CGRectMake(x - (width / 2), rectTop, width, rectBottom - rectTop)
        self.fillColor = fillColor
    }
    
}

public final class CLPointsBarGroup<T: CLBarModel> {
    let constant: CLAxisValue
    let bars: [T]
    
    public init(constant: CLAxisValue, bars: [T]) {
        self.constant = constant
        self.bars = bars
    }
}


public class CLGroupedBarsLayer<T: CLBarModel>: CLCoordsSpaceLayer {
    
    private let groups: [CLPointsBarGroup<T>]
    
    private let barSpacing: CGFloat?
    private let groupSpacing: CGFloat?
    
    private let horizontal: Bool
    
    private let animDuration: Float
    
    init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, groups: [CLPointsBarGroup<T>], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?, animDuration: Float) {
        self.groups = groups
        self.horizontal = horizontal
        self.barSpacing = barSpacing
        self.groupSpacing = groupSpacing
        self.animDuration = animDuration
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    func barsGenerator(barWidth barWidth: CGFloat) -> CLBarsViewGenerator<T> {
        fatalError("override")
    }
    
    override public func chartInitialized(chart chart: Chart) {
        
        let axis = self.horizontal ? self.yAxis : self.xAxis
        let groupAvailableLength = (axis.length  - (self.groupSpacing ?? 0) * CGFloat(self.groups.count)) / CGFloat(groups.count + 1)
        let maxBarCountInGroup = self.groups.reduce(CGFloat(0)) {maxCount, group in
            max(maxCount, CGFloat(group.bars.count))
        }
        
        let barWidth = ((groupAvailableLength - ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))) / CGFloat(maxBarCountInGroup))
        
        let barsGenerator = self.barsGenerator(barWidth: barWidth)
        
        let calculateConstantScreenLoc: (axis: CLAxisLayer, index: Int, group: CLPointsBarGroup<T>) -> CGFloat = {axis, index, group in
            let totalWidth = CGFloat(group.bars.count) * barWidth + ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))
            let groupCenter = axis.screenLocForScalar(group.constant.scalar)
            let origin = groupCenter - totalWidth / 2
            return origin + CGFloat(index) * (barWidth + (self.barSpacing ?? 0)) + barWidth / 2
        }
        
        for group in self.groups {
            
            for (index, bar) in group.bars.enumerate() {
                
                let constantScreenLoc: CGFloat = {
                    if barsGenerator.direction == .LeftToRight {
                        return calculateConstantScreenLoc(axis: self.yAxis, index: index, group: group)
                    } else {
                        return calculateConstantScreenLoc(axis: self.xAxis, index: index, group: group)
                    }
                }()
                chart.addSubview(barsGenerator.generateView(bar, constantScreenLoc: constantScreenLoc, bgColor: bar.bgColor, animDuration: self.animDuration))
            }
        }
    }
}



public typealias CLGroupedPlainBarsLayer = CLGroupedPlainBarsLayer_<Any>
public class CLGroupedPlainBarsLayer_<N>: CLGroupedBarsLayer<CLBarModel> {
    
    public override init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, groups: [CLPointsBarGroup<CLBarModel>], horizontal: Bool, barSpacing: CGFloat?, groupSpacing: CGFloat?, animDuration: Float) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, groups: groups, horizontal: horizontal, barSpacing: barSpacing, groupSpacing: groupSpacing, animDuration: animDuration)
    }
    
    override func barsGenerator(barWidth barWidth: CGFloat) -> CLBarsViewGenerator<CLBarModel> {
        return CLBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: barWidth, barSpacing: self.barSpacing)
    }
}

public typealias CLGroupedStackedBarsLayer = CLGroupedStackedBarsLayer_<Any>
public class CLGroupedStackedBarsLayer_<N>: CLGroupedBarsLayer<ChartStackedBarModel> {
    
    public override init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, groups: [CLPointsBarGroup<ChartStackedBarModel>], horizontal: Bool, barSpacing: CGFloat?, groupSpacing: CGFloat?, animDuration: Float) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, groups: groups, horizontal: horizontal, barSpacing: barSpacing, groupSpacing: groupSpacing, animDuration: animDuration)
    }
    
    override func barsGenerator(barWidth barWidth: CGFloat) -> CLBarsViewGenerator<ChartStackedBarModel> {
        return CLStackedBarsViewGenerator(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame, barWidth: barWidth, barSpacing: barSpacing)
    }
}

