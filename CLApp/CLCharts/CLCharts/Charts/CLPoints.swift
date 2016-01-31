//
//  CLPointsAreaLayer.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit

public class CLPointsAreaLayer<T: ChartPoint>: CLPointsLayer<T> {
    
    private let areaColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    private let addContainerPoints: Bool
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], areaColor: UIColor, animDuration: Float, animDelay: Float, addContainerPoints: Bool) {
        self.areaColor = areaColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    override func display(chart chart: Chart) {
        var points = self.chartPointScreenLocs
        
        let origin = self.innerFrame.origin
        let xLength = self.innerFrame.width
        
        let bottomY = origin.y + self.innerFrame.height
        
        if self.addContainerPoints {
            points.append(CGPointMake(origin.x + xLength, bottomY))
            points.append(CGPointMake(origin.x, bottomY))
        }
        
        let areaView = CLAreasView(points: points, frame: chart.bounds, color: self.areaColor, animDuration: self.animDuration, animDelay: self.animDelay)
        chart.addSubview(areaView)
    }
}

class CLPointsScatterLayer<T: ChartPoint>: CLPointsLayer<T> {
    
    let itemSize: CGSize
    let itemFillColor: UIColor
    
    required init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        self.itemSize = itemSize
        self.itemFillColor = itemFillColor
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override func viewDrawing(context context: CGContextRef, chart: Chart) {
        for chartPointModel in self.chartPointsModels {
            self.drawChartPointModel(context: context, chartPointModel: chartPointModel)
        }
    }
    
    func drawChartPointModel(context context: CGContextRef, chartPointModel: CLPointLayerModel<T>) {
        fatalError("override")
    }
}

public class CLPointsBubbleLayer<T: CLPointBubble>: CLPointsLayer<T> {
    
    private let diameterFactor: Double
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, maxBubbleDiameter: Double = 30, minBubbleDiameter: Double = 2) {
        
        let (minDiameterScalar, maxDiameterScalar): (Double, Double) = chartPoints.reduce((min: 0, max: 0)) {tuple, chartPoint in
            (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
        }
        
        self.diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override public func viewDrawing(context context: CGContextRef, chart: Chart) {
        
        for chartPointModel in self.chartPointsModels {
            
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, chartPointModel.chartPoint.borderColor.CGColor)
            CGContextSetFillColorWithColor(context, chartPointModel.chartPoint.bgColor.CGColor)
            
            let diameter = CGFloat(chartPointModel.chartPoint.diameterScalar * diameterFactor)
            let circleRect = (CGRectMake(chartPointModel.screenLoc.x - diameter / 2, chartPointModel.screenLoc.y - diameter / 2, diameter, diameter))
            
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
        }
    }
}

public class CLPointsCandleStickViewsLayer<T: CLPointCandleStick, U: CLCandleStickView>: CLPointsViewsLayer<CLPointCandleStick, CLCandleStickView> {
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], viewGenerator: CLPointViewGenerator) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }
    
    public func highlightChartpointView(screenLoc screenLoc: CGPoint) {
        let  x = screenLoc.x
        for viewWithChartPoint in self.viewsWithChartPoints {
            let view = viewWithChartPoint.view
            let originX = view.frame.origin.x
            view.highlighted = x > originX && x < originX + view.frame.width
        }
    }
}

public class ChartPointsScatterTrianglesLayer<T: ChartPoint>: CLPointsScatterLayer<T> {
    
    required public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context context: CGContextRef, chartPointModel: CLPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, chartPointModel.screenLoc.x, chartPointModel.screenLoc.y - h / 2)
        CGPathAddLineToPoint(path, nil, chartPointModel.screenLoc.x + w / 2, chartPointModel.screenLoc.y + h / 2)
        CGPathAddLineToPoint(path, nil, chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y + h / 2)
        CGPathCloseSubpath(path)
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
    }
}

public class ChartPointsScatterSquaresLayer<T: ChartPoint>: CLPointsScatterLayer<T> {
    
    required public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context context: CGContextRef, chartPointModel: CLPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextFillRect(context, CGRectMake(chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y - h / 2, w, h))
    }
}

public class ChartPointsScatterCirclesLayer<T: ChartPoint>: CLPointsScatterLayer<T> {
    
    required public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context context: CGContextRef, chartPointModel: CLPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextFillEllipseInRect(context, CGRectMake(chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y - h / 2, w, h))
    }
}

public struct CLPointLayerModel<T: ChartPoint> {
    public let chartPoint: T
    public let index: Int
    public let screenLoc: CGPoint
    
    init(chartPoint: T, index: Int, screenLoc: CGPoint) {
        self.chartPoint = chartPoint
        self.index = index
        self.screenLoc = screenLoc
    }
}

public class CLPointsLayer<T: ChartPoint>: CLCoordsSpaceLayer {
    
    let chartPointsModels: [CLPointLayerModel<T>]
    
    private let displayDelay: Float
    
    public var chartPointScreenLocs: [CGPoint] {
        return self.chartPointsModels.map{$0.screenLoc}
    }
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0) {
        self.chartPointsModels = chartPoints.enumerate().map {index, chartPoint in
            let screenLoc = CGPointMake(xAxis.screenLocForScalar(chartPoint.x.scalar), yAxis.screenLocForScalar(chartPoint.y.scalar))
            return CLPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        }
        
        self.displayDelay = displayDelay
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    
    override public func chartInitialized(chart chart: Chart) {
        if self.displayDelay == 0 {
            self.display(chart: chart)
        } else {
            dispatch_after(CLUtils.toDispatchTime(self.displayDelay), dispatch_get_main_queue()) {() -> Void in
                self.display(chart: chart)
            }
        }
    }
    
    func display(chart chart: Chart) {}
    
    public func chartPointScreenLoc(chartPoint: ChartPoint) -> CGPoint {
        return self.modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
    }
    
    public func modelLocToScreenLoc(x x: Double, y: Double) -> CGPoint {
        return CGPointMake(
            self.xAxis.screenLocForScalar(x),
            self.yAxis.screenLocForScalar(y))
    }
    
    public func chartPointsForScreenLoc(screenLoc: CGPoint) -> [T] {
        return self.chartPointsWith(filter: {$0 == screenLoc})
    }
    
    public func chartPointsForScreenLocX(x: CGFloat) -> [T] {
        return self.chartPointsWith(filter: {$0.x == x})
    }
    
    public func chartPointsForScreenLocY(y: CGFloat) -> [T] {
        return self.chartPointsWith(filter: {$0.y == y})
        
    }
    
    // smallest screen space between chartpoints on x axis
    public lazy var minXScreenSpace: CGFloat = {
        return self.minAxisScreenSpace{$0.x}
    }()
    
    // smallest screen space between chartpoints on y axis
    public lazy var minYScreenSpace: CGFloat = {
        return self.minAxisScreenSpace{$0.y}
    }()
    
    private func minAxisScreenSpace(dimPicker dimPicker: (CGPoint) -> CGFloat) -> CGFloat {
        return self.chartPointsModels.reduce((CGFloat.max, -CGFloat.max)) {tuple, viewWithChartPoint in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(dimPicker(viewWithChartPoint.screenLoc) - previousScreenLoc)), dimPicker(viewWithChartPoint.screenLoc))
            }.0
    }
    
    private func chartPointsWith(filter filter: (CGPoint) -> Bool) -> [T] {
        return self.chartPointsModels.reduce(Array<T>()) {u, chartPointModel in
            let chartPoint = chartPointModel.chartPoint
            if filter(self.chartPointScreenLoc(chartPoint)) {
                return u + [chartPoint]
            } else {
                return u
            }
        }
    }
}

public class ChartPointsScatterCrossesLayer<T: ChartPoint>: CLPointsScatterLayer<T> {
    
    private let strokeWidth: CGFloat
    
    required public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, strokeWidth: CGFloat = 2) {
        self.strokeWidth = strokeWidth
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context context: CGContextRef, chartPointModel: CLPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        func drawLine(p1X: CGFloat, p1Y: CGFloat, p2X: CGFloat, p2Y: CGFloat) {
            CGContextSetStrokeColorWithColor(context, self.itemFillColor.CGColor)
            CGContextSetLineWidth(context, self.strokeWidth)
            CGContextMoveToPoint(context, p1X, p1Y)
            CGContextAddLineToPoint(context, p2X, p2Y)
            CGContextStrokePath(context)
        }
        
        drawLine(chartPointModel.screenLoc.x - w / 2, p1Y: chartPointModel.screenLoc.y - h / 2, p2X: chartPointModel.screenLoc.x + w / 2, p2Y: chartPointModel.screenLoc.y + h / 2)
        drawLine(chartPointModel.screenLoc.x + w / 2, p1Y: chartPointModel.screenLoc.y - h / 2, p2X: chartPointModel.screenLoc.x - w / 2, p2Y: chartPointModel.screenLoc.y + h / 2)
    }
}

private struct ScreenLine {
    let points: [CGPoint]
    let color: UIColor
    let lineWidth: CGFloat
    let animDuration: Float
    let animDelay: Float
    
    init(points: [CGPoint], color: UIColor, lineWidth: CGFloat, animDuration: Float, animDelay: Float) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.animDuration = animDuration
        self.animDelay = animDelay
    }
}

public class CLPointsLineLayer<T: ChartPoint>: CLPointsLayer<T> {
    private let lineModels: [CLLineModel<T>]
    private var lineViews: [CLLinesView] = []
    private let pathGenerator: CLLinesViewPathGenerator
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, lineModels: [CLLineModel<T>], pathGenerator: CLLinesViewPathGenerator = StraightLinePathGenerator(), displayDelay: Float = 0) {
        
        self.lineModels = lineModels
        self.pathGenerator = pathGenerator
        
        let chartPoints: [T] = lineModels.flatMap{$0.chartPoints}
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    private func toScreenLine(lineModel lineModel: CLLineModel<T>, chart: Chart) -> ScreenLine {
        return ScreenLine(
            points: lineModel.chartPoints.map{self.chartPointScreenLoc($0)},
            color: lineModel.lineColor,
            lineWidth: lineModel.lineWidth,
            animDuration: lineModel.animDuration,
            animDelay: lineModel.animDelay
        )
    }
    
    override func display(chart chart: Chart) {
        let screenLines = self.lineModels.map{self.toScreenLine(lineModel: $0, chart: chart)}
        
        for screenLine in screenLines {
            let lineView = CLLinesView(
                path: self.pathGenerator.generatePath(points: screenLine.points, lineWidth: screenLine.lineWidth),
                frame: chart.bounds,
                lineColor: screenLine.color,
                lineWidth: screenLine.lineWidth,
                animDuration: screenLine.animDuration,
                animDelay: screenLine.animDelay)
            
            self.lineViews.append(lineView)
            chart.addSubview(lineView)
        }
    }
    
}

public struct CLPointsLineTrackerLayerSettings {
    let thumbSize: CGFloat
    let thumbCornerRadius: CGFloat
    let thumbBorderWidth: CGFloat
    let thumbBGColor: UIColor
    let thumbBorderColor: UIColor
    let infoViewFont: UIFont
    let infoViewFontColor: UIColor
    let infoViewSize: CGSize
    let infoViewCornerRadius: CGFloat
    
    public init(thumbSize: CGFloat, thumbCornerRadius: CGFloat = 16, thumbBorderWidth: CGFloat = 4, thumbBorderColor: UIColor = UIColor.blackColor(), thumbBGColor: UIColor = UIColor.whiteColor(), infoViewFont: UIFont, infoViewFontColor: UIColor = UIColor.blackColor(), infoViewSize: CGSize, infoViewCornerRadius: CGFloat) {
        self.thumbSize = thumbSize
        self.thumbCornerRadius = thumbCornerRadius
        self.thumbBorderWidth = thumbBorderWidth
        self.thumbBGColor = thumbBGColor
        self.thumbBorderColor = thumbBorderColor
        self.infoViewFont = infoViewFont
        self.infoViewFontColor = infoViewFontColor
        self.infoViewSize = infoViewSize
        self.infoViewCornerRadius = infoViewCornerRadius
    }
}

public class CLPointsLineTrackerLayer<T: ChartPoint>: CLPointsLayer<T> {
    
    private let lineColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    
    private let settings: CLPointsLineTrackerLayerSettings
    
    private lazy var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = UIColor.redColor()
        currentPositionLineOverlay.alpha = 0
        return currentPositionLineOverlay
    }()
    
    private lazy var thumb: UIView = {
        let thumb = UIView()
        thumb.layer.cornerRadius = self.settings.thumbCornerRadius
        thumb.layer.borderWidth = self.settings.thumbBorderWidth
        thumb.layer.backgroundColor = UIColor.clearColor().CGColor
        thumb.layer.borderColor = self.settings.thumbBorderColor.CGColor
        thumb.alpha = 0
        return thumb
    }()
    
    private var currentPositionInfoOverlay: UILabel?
    
    private var view: TrackerView?
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: CLPointsLineTrackerLayerSettings) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    private func linesIntersection(line1P1 line1P1: CGPoint, line1P2: CGPoint, line2P1: CGPoint, line2P2: CGPoint) -> CGPoint? {
        return self.findLineIntersection(p0X: line1P1.x, p0y: line1P1.y, p1x: line1P2.x, p1y: line1P2.y, p2x: line2P1.x, p2y: line2P1.y, p3x: line2P2.x, p3y: line2P2.y)
    }
    
    // src: http://stackoverflow.com/a/14795484/930450 (modified)
    private func findLineIntersection(p0X p0X: CGFloat , p0y: CGFloat, p1x: CGFloat, p1y: CGFloat, p2x: CGFloat, p2y: CGFloat, p3x: CGFloat, p3y: CGFloat) -> CGPoint? {
        
        var s02x: CGFloat, s02y: CGFloat, s10x: CGFloat, s10y: CGFloat, s32x: CGFloat, s32y: CGFloat, sNumer: CGFloat, tNumer: CGFloat, denom: CGFloat, t: CGFloat;
        
        s10x = p1x - p0X
        s10y = p1y - p0y
        s32x = p3x - p2x
        s32y = p3y - p2y
        
        denom = s10x * s32y - s32x * s10y
        if denom == 0 {
            return nil // Collinear
        }
        let denomPositive: Bool = denom > 0
        
        s02x = p0X - p2x
        s02y = p0y - p2y
        sNumer = s10x * s02y - s10y * s02x
        if (sNumer < 0) == denomPositive {
            return nil // No collision
        }
        
        tNumer = s32x * s02y - s32y * s02x
        if (tNumer < 0) == denomPositive {
            return nil // No collision
        }
        if ((sNumer > denom) == denomPositive) || ((tNumer > denom) == denomPositive) {
            return nil // No collision
        }
        
        // Collision detected
        t = tNumer / denom
        let i_x = p0X + (t * s10x)
        let i_y = p0y + (t * s10y)
        return CGPoint(x: i_x, y: i_y)
    }
    
    private func createCurrentPositionInfoOverlay(view view: UIView) -> UILabel {
        let currentPosW: CGFloat = (self.settings.infoViewSize.width - 20)
        let currentPosH: CGFloat = self.settings.infoViewSize.height
        let currentPosX: CGFloat = 10//(view.frame.size.width - currentPosW) / CGFloat(2)
        let currentPosY: CGFloat = 5
        let currentPositionInfoOverlay = UILabel(frame: CGRectMake(currentPosX, currentPosY, currentPosW, currentPosH))
        currentPositionInfoOverlay.textColor = self.settings.infoViewFontColor
        currentPositionInfoOverlay.font = self.settings.infoViewFont
        currentPositionInfoOverlay.layer.cornerRadius = self.settings.infoViewCornerRadius
        //currentPositionInfoOverlay.layer.borderWidth = 1
        currentPositionInfoOverlay.textAlignment = NSTextAlignment.Left
        currentPositionInfoOverlay.layer.backgroundColor = UIColor(white: 1, alpha: 0).CGColor//UIColor.whiteColor().CGColor
        currentPositionInfoOverlay.layer.borderColor = UIColor.grayColor().CGColor
        currentPositionInfoOverlay.alpha = 0
        return currentPositionInfoOverlay
    }
    
    
    private func currentPositionInfoOverlay(view view: UIView) -> UILabel {
        return self.currentPositionInfoOverlay ?? {
            let currentPositionInfoOverlay = self.createCurrentPositionInfoOverlay(view: view)
            self.currentPositionInfoOverlay = currentPositionInfoOverlay
            return currentPositionInfoOverlay
            }()
    }
    
    private func updateTrackerLineOnValidState(updateFunc updateFunc: (view: UIView) -> ()) {
        if !self.chartPointsModels.isEmpty {
            if let view = self.view {
                updateFunc(view: view)
            }
        }
    }
    
    private func updateTrackerLine(touchPoint touchPoint: CGPoint) {
        
        self.updateTrackerLineOnValidState{(view) in
            
            var touchlineP1 = CGPointMake(touchPoint.x, 0)
            var touchlineP2 = CGPointMake(touchPoint.x, view.frame.size.height)
            
            var intersections: [CGPoint] = []
            for i in 0..<(self.chartPointsModels.count - 1) {
                let m1 = self.chartPointsModels[i]
                let m2 = self.chartPointsModels[i + 1]
                //touchlineP1.y = 10
                //touchlineP2.y = touchlineP2.y - 20
                if let intersection = self.linesIntersection(line1P1: touchlineP1, line1P2: touchlineP2, line2P1: m1.screenLoc, line2P2: m2.screenLoc) {
                    intersections.append(intersection)
                }
            }
            
            // Select point with smallest distance to touch point.
            // If there's only one intersection, returns intersection. If there's no intersection returns nil.
            var intersectionMaybe: CGPoint? = {
                var minDistancePoint: (distance: Float, point: CGPoint?) = (MAXFLOAT, nil)
                for intersection in intersections {
                    let distance = hypotf(Float(intersection.x - touchPoint.x), Float(intersection.y - touchPoint.y))
                    if distance < minDistancePoint.0 {
                        minDistancePoint = (distance, intersection)
                    }
                }
                return minDistancePoint.point
            }()
            
            if let intersection = intersectionMaybe {
                
                if self.currentPositionInfoOverlay?.superview == nil {
                    view.addSubview(self.currentPositionLineOverlay)
                    view.addSubview(self.currentPositionInfoOverlay(view: view))
                    view.addSubview(self.thumb)
                }
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.currentPositionLineOverlay.alpha = 1
                    self.currentPositionInfoOverlay(view: view).alpha = 1
                    self.thumb.alpha = 1
                    }, completion: { (Bool) -> Void in
                })
                
                var w: CGFloat = self.settings.thumbSize
                var h: CGFloat = self.settings.thumbSize
                self.currentPositionLineOverlay.frame = CGRectMake(intersection.x, 0, 1, view.frame.size.height)
                self.thumb.frame = CGRectMake(intersection.x - w/2, intersection.y - h/2, w, h)
                
                func createTmpChartPoint(firstModel: CLPointLayerModel<T>, secondModel: CLPointLayerModel<T>) -> ChartPoint {
                    let p1 = firstModel.chartPoint
                    let p2 = secondModel.chartPoint
                    
                    // calculate x scalar
                    let pxXDiff = secondModel.screenLoc.x - firstModel.screenLoc.x
                    let scalarXDiff = p2.x.scalar - p1.x.scalar
                    let factorX = CGFloat(scalarXDiff) / pxXDiff
                    let currentXPx = intersection.x - firstModel.screenLoc.x
                    let currentXScalar = Double(currentXPx * factorX) + p1.x.scalar
                    
                    // calculate y scalar
                    let pxYDiff = (secondModel.screenLoc.y - firstModel.screenLoc.y)//fabs
                    let scalarYDiff = p2.y.scalar - p1.y.scalar;
                    let factorY = CGFloat(scalarYDiff) / pxYDiff
                    let currentYPx = (intersection.y - firstModel.screenLoc.y)//fabs
                    let currentYScalar = p1.y.scalar + Double(currentYPx * factorY)
                    
                    let x = firstModel.chartPoint.x.copy(currentXScalar)
                    let y = secondModel.chartPoint.y.copy(currentYScalar)
                    let chartPoint = T(x: x, y: y)
                    return chartPoint
                }
                
                if self.chartPointsModels.count > 1 {
                    let first = self.chartPointsModels[0]
                    let second = self.chartPointsModels[1]
                    //self.currentPositionInfoOverlay(view: view).text = "Point: \(createTmpChartPoint(first, secondModel: second).text)"
                    let point = createTmpChartPoint(first, secondModel:second )
                    self.currentPositionInfoOverlay(view: view).text = "Point:\(point.y.text) Time: \(point.x.text)"
                }
            }
        }
    }
    
    override func display(chart chart: Chart) {
        let view = TrackerView(frame: chart.bounds, updateFunc: {[weak self] location in
            self?.updateTrackerLine(touchPoint: location)
            })
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
}

private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    
    init(frame: CGRect, updateFunc: (CGPoint) -> ()) {
        self.updateFunc = updateFunc
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
}

// Layer that shows only one view at a time
public class CLPointsSingleViewLayer<T: ChartPoint, U: UIView>: CLPointsViewsLayer<T, U> {
    
    private var addedViews: [UIView] = []
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], viewGenerator: CLPointViewGenerator) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }
    
    override func display(chart chart: Chart) {
        // skip adding views - this layer manages its own list
    }
    
    public func showView(chartPoint chartPoint: T, chart: Chart) {
        
        for view in self.addedViews {
            view.removeFromSuperview()
        }
        
        let screenLoc = self.chartPointScreenLoc(chartPoint)
        let index = self.chartPointsModels.map{$0.chartPoint}.indexOf(chartPoint)!
        let model: CLPointLayerModel = CLPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        if let view = self.viewGenerator(chartPointModel: model, layer: self, chart: chart) {
            self.addedViews.append(view)
            chart.addSubview(view)
        }
    }
}

public class CLPointsTrackerLayer<T: ChartPoint>: CLPointsLayer<T> {
    
    private var view: TrackerView?
    private let locChangedFunc: ((CGPoint) -> ())
    
    private let lineColor: UIColor
    private let lineWidth: CGFloat
    
    private lazy var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = self.lineColor
        return currentPositionLineOverlay
    }()
    
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints: [T], locChangedFunc: (CGPoint) -> (), lineColor: UIColor = UIColor.blackColor(), lineWidth: CGFloat = 1) {
        self.locChangedFunc = locChangedFunc
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    override func display(chart chart: Chart) {
        let view = TrackerView(frame: chart.bounds, updateFunc: {[weak self] location in
            self?.locChangedFunc(location)
            self?.currentPositionLineOverlay.center.x = location.x
            })
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
        
        view.addSubview(self.currentPositionLineOverlay)
        self.currentPositionLineOverlay.frame = CGRectMake(self.innerFrame.origin.x + 200 - self.lineWidth / 2, self.innerFrame.origin.y, self.lineWidth, self.innerFrame.height)
    }
}



public class CLPointsViewsLayer<T: ChartPoint, U: UIView>: CLPointsLayer<T> {
    
    public typealias CLPointViewGenerator = (chartPointModel: CLPointLayerModel<T>, layer: CLPointsViewsLayer<T, U>, chart: Chart) -> U?
    public typealias ViewWithChartPoint = (view: U, chartPointModel: CLPointLayerModel<T>)
    
    private(set) var viewsWithChartPoints: [ViewWithChartPoint] = []
    
    private let delayBetweenItems: Float = 0
    
    let viewGenerator: CLPointViewGenerator
    
    private var conflictSolver: CLViewsConflictSolver<T, U>?
    
    public init(xAxis: CLAxisLayer, yAxis: CLAxisLayer, innerFrame: CGRect, chartPoints:[T], viewGenerator: CLPointViewGenerator, conflictSolver: CLViewsConflictSolver<T, U>? = nil, displayDelay: Float = 0, delayBetweenItems: Float = 0) {
        self.viewGenerator = viewGenerator
        self.conflictSolver = conflictSolver
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override func display(chart chart: Chart) {
        super.display(chart: chart)
        
        self.viewsWithChartPoints = self.generateChartPointViews(chartPointModels: self.chartPointsModels, chart: chart)
        
        if self.delayBetweenItems == 0 {
            for v in self.viewsWithChartPoints {chart.addSubview(v.view)}
            
        } else {
            func next(index: Int, delay: dispatch_time_t) {
                if index < self.viewsWithChartPoints.count {
                    dispatch_after(delay, dispatch_get_main_queue()) {() -> Void in
                        let view = self.viewsWithChartPoints[index].view
                        chart.addSubview(view)
                        next(index + 1, delay: CLUtils.toDispatchTime(self.delayBetweenItems))
                    }
                }
            }
            next(0, delay: 0)
        }
    }
    
    private func generateChartPointViews(chartPointModels chartPointModels: [CLPointLayerModel<T>], chart: Chart) -> [ViewWithChartPoint] {
        let viewsWithChartPoints = self.chartPointsModels.reduce(Array<ViewWithChartPoint>()) {viewsWithChartPoints, model in
            if let view = self.viewGenerator(chartPointModel: model, layer: self, chart: chart) {
                return viewsWithChartPoints + [(view: view, chartPointModel: model)]
            } else {
                return viewsWithChartPoints
            }
        }
        
        self.conflictSolver?.solveConflicts(views: viewsWithChartPoints)
        
        return viewsWithChartPoints
    }
    
    override public func chartPointsForScreenLoc(screenLoc: CGPoint) -> [T] {
        return self.filterChartPoints{self.inXBounds(screenLoc.x, view: $0.view) && self.inYBounds(screenLoc.y, view: $0.view)}
    }
    
    override public func chartPointsForScreenLocX(x: CGFloat) -> [T] {
        return self.filterChartPoints{self.inXBounds(x, view: $0.view)}
    }
    
    override public func chartPointsForScreenLocY(y: CGFloat) -> [T] {
        return self.filterChartPoints{self.inYBounds(y, view: $0.view)}
    }
    
    private func filterChartPoints(filter: (ViewWithChartPoint) -> Bool) -> [T] {
        return self.viewsWithChartPoints.reduce([]) {arr, viewWithChartPoint in
            if filter(viewWithChartPoint) {
                return arr + [viewWithChartPoint.chartPointModel.chartPoint]
            } else {
                return arr
            }
        }
    }
    
    private func inXBounds(x: CGFloat, view: UIView) -> Bool {
        return (x > view.frame.origin.x) && (x < (view.frame.origin.x + view.frame.width))
    }
    
    private func inYBounds(y: CGFloat, view: UIView) -> Bool {
        return (y > view.frame.origin.y) && (y < (view.frame.origin.y + view.frame.height))
    }
}



