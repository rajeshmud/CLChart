//
//  CLUtils.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit


public class CLCoordsSpace {
    
    public typealias CLAxisLayerModel = (p1: CGPoint, p2: CGPoint, axisValues: [CLAxisValue], axisTitleLabels: [CLAxisLabel], settings: CLAxisSettings)
    public typealias CLAxisLayerGenerator = (CLAxisLayerModel) -> CLAxisLayer
    
    private let chartSettings: CLSettings
    private let chartSize: CGSize
    
    public private(set) var chartInnerFrame: CGRect = CGRectZero
    
    private let yLowModels: [CLAxisModel]
    private let yHighModels: [CLAxisModel]
    private let xLowModels: [CLAxisModel]
    private let xHighModels: [CLAxisModel]
    
    private let yLowGenerator: CLAxisLayerGenerator
    private let yHighGenerator: CLAxisLayerGenerator
    private let xLowGenerator: CLAxisLayerGenerator
    private let xHighGenerator: CLAxisLayerGenerator
    
    public private(set) var yLowAxes: [CLAxisLayer] = []
    public private(set) var yHighAxes: [CLAxisLayer] = []
    public private(set) var xLowAxes: [CLAxisLayer] = []
    public private(set) var xHighAxes: [CLAxisLayer] = []
    
    public convenience init(chartSettings: CLSettings, chartSize: CGSize, yLowModels: [CLAxisModel] = [], yHighModels: [CLAxisModel] = [], xLowModels: [CLAxisModel] = [], xHighModels: [CLAxisModel] = []) {
        
        let yLowGenerator: CLAxisLayerGenerator = {model in
            CLAxisYLowLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        let yHighGenerator: CLAxisLayerGenerator = {model in
            CLAxisYHighLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        let xLowGenerator: CLAxisLayerGenerator = {model in
            CLAxisXLowLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        let xHighGenerator: CLAxisLayerGenerator = {model in
            CLAxisXHighLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        
        self.init(chartSettings: chartSettings, chartSize: chartSize, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels, yLowGenerator: yLowGenerator, yHighGenerator: yHighGenerator, xLowGenerator: xLowGenerator, xHighGenerator: xHighGenerator)
    }
    
    public init(chartSettings: CLSettings, chartSize: CGSize, yLowModels: [CLAxisModel], yHighModels: [CLAxisModel], xLowModels: [CLAxisModel], xHighModels: [CLAxisModel], yLowGenerator: CLAxisLayerGenerator, yHighGenerator: CLAxisLayerGenerator, xLowGenerator: CLAxisLayerGenerator, xHighGenerator: CLAxisLayerGenerator) {
        self.chartSettings = chartSettings
        self.chartSize = chartSize
        
        self.yLowModels = yLowModels
        self.yHighModels = yHighModels
        self.xLowModels = xLowModels
        self.xHighModels = xHighModels
        
        self.yLowGenerator = yLowGenerator
        self.yHighGenerator = yHighGenerator
        self.xLowGenerator = xLowGenerator
        self.xHighGenerator = xHighGenerator
        
        self.chartInnerFrame = self.calculateChartInnerFrame()
        
        self.yLowAxes = self.generateYLowAxes()
        self.yHighAxes = self.generateYHighAxes()
        self.xLowAxes = self.generateXLowAxes()
        self.xHighAxes = self.generateXHighAxes()
    }
    
    private func generateYLowAxes() -> [CLAxisLayer] {
        return generateYAxisShared(axisModels: self.yLowModels, offset: chartSettings.leading, generator: self.yLowGenerator)
    }
    
    private func generateYHighAxes() -> [CLAxisLayer] {
        let chartFrame = self.chartInnerFrame
        return generateYAxisShared(axisModels: self.yHighModels, offset: chartFrame.origin.x + chartFrame.width, generator: self.yHighGenerator)
    }
    
    private func generateXLowAxes() -> [CLAxisLayer] {
        let chartFrame = self.chartInnerFrame
        let y = chartFrame.origin.y + chartFrame.height
        return self.generateXAxesShared(axisModels: self.xLowModels, offset: y, generator: self.xLowGenerator)
    }
    
    private func generateXHighAxes() -> [CLAxisLayer] {
        return self.generateXAxesShared(axisModels: self.xHighModels, offset: chartSettings.top, generator: self.xHighGenerator)
    }
    
    private func generateXAxesShared(axisModels axisModels: [CLAxisModel], offset: CGFloat, generator: CLAxisLayerGenerator) -> [CLAxisLayer] {
        let chartFrame = self.chartInnerFrame
        let chartSettings = self.chartSettings
        let x = chartFrame.origin.x
        let length = chartFrame.width
        
        return generateAxisShared(axisModels: axisModels, offset: offset, pointsCreator: { varDim in
            (p1: CGPointMake(x, varDim), p2: CGPointMake(x + length, varDim))
            }, dimIncr: { layer in
                layer.rect.height + chartSettings.spacingBetweenAxesX
            }, generator: generator)
    }
    
    
    private func generateYAxisShared(axisModels axisModels: [CLAxisModel], offset: CGFloat, generator: CLAxisLayerGenerator) -> [CLAxisLayer] {
        let chartFrame = self.chartInnerFrame
        let chartSettings = self.chartSettings
        let y = chartFrame.origin.y
        let length = chartFrame.height
        
        return generateAxisShared(axisModels: axisModels, offset: offset, pointsCreator: { varDim in
            (p1: CGPointMake(varDim, y + length), p2: CGPointMake(varDim, y))
            }, dimIncr: { layer in
                layer.rect.width + chartSettings.spacingBetweenAxesY
            }, generator: generator)
    }
    
    private func generateAxisShared(axisModels axisModels: [CLAxisModel], offset: CGFloat, pointsCreator: (varDim: CGFloat) -> (p1: CGPoint, p2: CGPoint), dimIncr: (CLAxisLayer) -> CGFloat, generator: CLAxisLayerGenerator) -> [CLAxisLayer] {
        
        let chartSettings = self.chartSettings
        
        return axisModels.reduce((axes: Array<CLAxisLayer>(), x: offset)) {tuple, chartAxisModel in
            let layers = tuple.axes
            let x: CGFloat = tuple.x
            let axisSettings = CLAxisSettings(chartSettings)
            axisSettings.lineColor = chartAxisModel.lineColor
            let points = pointsCreator(varDim: x)
            let layer = generator(p1: points.p1, p2: points.p2, axisValues: chartAxisModel.axisValues, axisTitleLabels: chartAxisModel.axisTitleLabels, settings: axisSettings)
            return (
                axes: layers + [layer],
                x: x + dimIncr(layer)
            )
            }.0
    }
    
    private func calculateChartInnerFrame() -> CGRect {
        
        let totalDim = {(axisLayers: [CLAxisLayer], dimPicker: (CLAxisLayer) -> CGFloat, spacingBetweenAxes: CGFloat) -> CGFloat in
            return axisLayers.reduce((CGFloat(0), CGFloat(0))) {tuple, chartAxisLayer in
                let totalDim = tuple.0 + tuple.1
                return (totalDim + dimPicker(chartAxisLayer), spacingBetweenAxes)
                }.0
        }
        
        func totalWidth(axisLayers: [CLAxisLayer]) -> CGFloat {
            return totalDim(axisLayers, {$0.rect.width}, self.chartSettings.spacingBetweenAxesY)
        }
        
        func totalHeight(axisLayers: [CLAxisLayer]) -> CGFloat {
            return totalDim(axisLayers, {$0.rect.height}, self.chartSettings.spacingBetweenAxesX)
        }
        
        let yLowWidth = totalWidth(self.generateYLowAxes())
        let yHighWidth = totalWidth(self.generateYHighAxes())
        let xLowHeight = totalHeight(self.generateXLowAxes())
        let xHighHeight = totalHeight(self.generateXHighAxes())
        
        let leftWidth = yLowWidth + self.chartSettings.leading
        let topHeigth = xHighHeight + self.chartSettings.top
        let rightWidth = yHighWidth + self.chartSettings.trailing
        let bottomHeight = xLowHeight + self.chartSettings.bottom
        
        return CGRectMake(
            leftWidth,
            topHeigth,
            self.chartSize.width - leftWidth - rightWidth,
            self.chartSize.height - topHeigth - bottomHeight
        )
    }
}

public class CLCoordsSpaceLeftBottomSingleAxis {
    
    public let yAxis: CLAxisLayer
    public let xAxis: CLAxisLayer
    public let chartInnerFrame: CGRect
    
    public init(chartSettings: CLSettings, chartFrame: CGRect, xModel: CLAxisModel, yModel: CLAxisModel) {
        let coordsSpaceInitializer = CLCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xLowModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxis = coordsSpaceInitializer.yLowAxes[0]
        self.xAxis = coordsSpaceInitializer.xLowAxes[0]
    }
}

public class CLCoordsSpaceLeftTopSingleAxis {
    
    public let yAxis: CLAxisLayer
    public let xAxis: CLAxisLayer
    public let chartInnerFrame: CGRect
    
    public init(chartSettings: CLSettings, chartFrame: CGRect, xModel: CLAxisModel, yModel: CLAxisModel) {
        let coordsSpaceInitializer = CLCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xHighModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxis = coordsSpaceInitializer.yLowAxes[0]
        self.xAxis = coordsSpaceInitializer.xHighAxes[0]
    }
}

public class CLCoordsSpaceRightBottomSingleAxis {
    
    public let yAxis: CLAxisLayer
    public let xAxis: CLAxisLayer
    public let chartInnerFrame: CGRect
    
    public init(chartSettings: CLSettings, chartFrame: CGRect, xModel: CLAxisModel, yModel: CLAxisModel) {
        let coordsSpaceInitializer = CLCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yHighModels: [yModel], xLowModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxis = coordsSpaceInitializer.yHighAxes[0]
        self.xAxis = coordsSpaceInitializer.xLowAxes[0]
    }
}

public class CLUtils {

    public class func textSize(text: String, font: UIFont) -> CGSize {
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font]).size()
    }
    
    public class func rotatedTextBounds(text: String, font: UIFont, angle: CGFloat) -> CGRect {
        let labelSize = CLUtils.textSize(text, font: font)
        let radians = angle * CGFloat(M_PI) / CGFloat(180)
        return boundingRectAfterRotatingRect(CGRectMake(0, 0, labelSize.width, labelSize.height), radians: radians)
    }
    
    // src: http://stackoverflow.com/a/9168238/930450
    public class func boundingRectAfterRotatingRect(rect: CGRect, radians: CGFloat) -> CGRect {
        let xfrm = CGAffineTransformMakeRotation(radians)
        return CGRectApplyAffineTransform(rect, xfrm)
    }
    
    public class func toDispatchTime(secs: Float) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(Double(secs) * Double(NSEC_PER_SEC)))
    }
}

public struct CLLineModel<T: ChartPoint> {
    
    let chartPoints: [T]
    let lineColor: UIColor
    let lineWidth: CGFloat
    let animDuration: Float
    let animDelay: Float
    
    public init(chartPoints: [T], lineColor: UIColor, lineWidth: CGFloat = 1, animDuration: Float, animDelay: Float) {
        self.chartPoints = chartPoints
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.animDuration = animDuration
        self.animDelay = animDelay
    }
    
    var chartPointsCount: Int {
        return self.chartPoints.count
    }
    
}

public class CLViewsConflictSolver<T: ChartPoint, U: UIView> {
    
    // Reposition views in case of overlapping
    func solveConflicts(views views: [CLPointsViewsLayer<T, U>.ViewWithChartPoint]) {}
}
