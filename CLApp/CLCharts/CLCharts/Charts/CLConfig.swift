//
//  CLConfig.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit

public class CLConfig {
    public let chartSettings: CLSettings
    public let guidelinesConfig: GuidelinesConfig? // nil means no guidelines
    
    public init(chartSettings: CLSettings, guidelinesConfig: GuidelinesConfig?) {
        self.chartSettings = chartSettings
        self.guidelinesConfig = guidelinesConfig
    }
}


public class CLConfigXY: CLConfig {
    public let xAxisConfig: CLAxisConfig
    public let yAxisConfig: CLAxisConfig
    public let xAxisLabelSettings: CLLabelSettings
    public let yAxisLabelSettings: CLLabelSettings

    public init(chartSettings: CLSettings = CLSettings(), xAxisConfig: CLAxisConfig, yAxisConfig: CLAxisConfig, xAxisLabelSettings: CLLabelSettings = CLLabelSettings(), yAxisLabelSettings: CLLabelSettings = CLLabelSettings(), guidelinesConfig: GuidelinesConfig? = GuidelinesConfig()) {
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.xAxisLabelSettings = xAxisLabelSettings
        self.yAxisLabelSettings = yAxisLabelSettings
        
        super.init(chartSettings: chartSettings, guidelinesConfig: guidelinesConfig)
    }
}

public struct CLAxisConfig {
    public let from: Double
    public let to: Double
    public let by: Double
    
    public init(from: Double, to: Double, by: Double) {
        self.from = from
        self.to = to
        self.by = by
    }
}

public struct GuidelinesConfig {
    public let dotted: Bool
    public let lineWidth: CGFloat
    public let lineColor: UIColor
    
    public init(dotted: Bool = true, lineWidth: CGFloat = 0.1, lineColor: UIColor = UIColor.blackColor()) {
        self.dotted = dotted
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
}

// Helper to generate default guidelines layer for GuidelinesConfig
public struct GuidelinesDefaultLayerGenerator {

    public static func generateOpt(xAxis xAxis: CLAxisLayer, yAxis: CLAxisLayer, chartInnerFrame: CGRect, guidelinesConfig: GuidelinesConfig?) -> CLLayer? {
        if let guidelinesConfig = guidelinesConfig {
            return self.generate(xAxis: xAxis, yAxis: yAxis, chartInnerFrame: chartInnerFrame, guidelinesConfig: guidelinesConfig)
        } else {
            return nil
        }
    }
    
    public static func generate(xAxis xAxis: CLAxisLayer, yAxis: CLAxisLayer, chartInnerFrame: CGRect, guidelinesConfig: GuidelinesConfig) -> CLLayer {
        if guidelinesConfig.dotted {
            let settings = CLGuideLinesDottedLayerSettings(linesColor: guidelinesConfig.lineColor, linesWidth: guidelinesConfig.lineWidth)
            return CLGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, settings: settings)
            
        } else {
            let settings = CLGuideLinesDottedLayerSettings(linesColor: guidelinesConfig.lineColor, linesWidth: guidelinesConfig.lineWidth)
            return CLGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, settings: settings)
        }
    }
}