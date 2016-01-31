//
//  CLAxisLabel.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit

public class CLAxisLabel {
    
    public let text: String
    let settings: CLLabelSettings

    var hidden: Bool = false
   
    lazy var textSize: CGSize = {
        let size = CLUtils.textSize(self.text, font: self.settings.font)
        if self.settings.rotation == 0 {
            return size
        } else {
            return CLUtils.boundingRectAfterRotatingRect(CGRectMake(0, 0, size.width, size.height), radians: self.settings.rotation * CGFloat(M_PI) / 180.0).size
        }
    }()
    
    public init(text: String, settings: CLLabelSettings) {
        self.text = text
        self.settings = settings
    }
}

public protocol CLAxisLayer: CLLayer {
    
    var p1: CGPoint {get}
    var p2: CGPoint {get}
    var axisValues: [CLAxisValue] {get}
    var rect: CGRect {get}
    var axisValuesScreenLocs: [CGFloat] {get}
    var visibleAxisValuesScreenLocs: [CGFloat] {get}
    var minAxisScreenSpace: CGFloat {get}
    var length: CGFloat {get}
    var modelLength: CGFloat {get}
    var low: Bool {get}
    var lineP1: CGPoint {get}
    var lineP2: CGPoint {get}
    
    func screenLocForScalar(scalar: Double) -> CGFloat
}

public class CLAxisSettings {
    var screenLeading: CGFloat = 0
    var screenTrailing: CGFloat = 0
    var screenTop: CGFloat = 0
    var screenBottom: CGFloat = 0
    var labelsSpacing: CGFloat = 5
    var labelsToAxisSpacingX: CGFloat = 5
    var labelsToAxisSpacingY: CGFloat = 5
    var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    var lineColor:UIColor = UIColor.blackColor()
    var axisStrokeWidth: CGFloat = 2.0
    var isAxisLineVisible: Bool = true
    
    convenience init(_ chartSettings: CLSettings) {
        self.init()
        self.labelsSpacing = chartSettings.labelsSpacing
        self.labelsToAxisSpacingX = chartSettings.labelsToAxisSpacingX
        self.labelsToAxisSpacingY = chartSettings.labelsToAxisSpacingY
        self.axisTitleLabelsToLabelsSpacing = chartSettings.axisTitleLabelsToLabelsSpacing
        self.screenLeading = chartSettings.leading
        self.screenTop = chartSettings.top
        self.screenTrailing = chartSettings.trailing
        self.screenBottom = chartSettings.bottom
        self.axisStrokeWidth = chartSettings.axisStrokeWidth
    }
}

class CLAxisLayerDefault: CLAxisLayer {
    
    let p1: CGPoint
    let p2: CGPoint
    let axisValues: [CLAxisValue]
    let axisTitleLabels: [CLAxisLabel]
    let settings: CLAxisSettings
    // exposed for subclasses
    var lineDrawer: CLLineDrawer?
    var labelDrawers: [CLLabelDrawer] = []
    var axisTitleLabelDrawers: [CLLabelDrawer] = []
    var rect: CGRect {
        return CGRectMake(self.p1.x, self.p1.y, self.width, self.height)
    }
    
    var axisValuesScreenLocs: [CGFloat] {
        return self.axisValues.map{self.screenLocForScalar($0.scalar)}
    }
    
    var visibleAxisValuesScreenLocs: [CGFloat] {
        return self.axisValues.reduce(Array<CGFloat>()) {u, axisValue in
            return axisValue.hidden ? u : u + [self.screenLocForScalar(axisValue.scalar)]
        }
    }
    
    // smallest screen space between axis values
    var minAxisScreenSpace: CGFloat {
        return self.axisValuesScreenLocs.reduce((CGFloat.max, -CGFloat.max)) {tuple, screenLoc in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(screenLoc - previousScreenLoc)), screenLoc)
            }.0
    }
    
    var length: CGFloat {
        fatalError("override")
    }
    
    var modelLength: CGFloat {
        if let first = self.axisValues.first, let last = self.axisValues.last {
            return CGFloat(last.scalar - first.scalar)
        } else {
            return 0
        }
    }
    
    lazy var axisTitleLabelsHeight: CGFloat = {
        return self.axisTitleLabels.reduce(0) {sum, label in
            sum + self.labelMaybeSize(label).height
        }
    }()
    
    lazy var axisTitleLabelsWidth: CGFloat = {
        return self.axisTitleLabels.reduce(0) {sum, label in
            sum + self.labelMaybeSize(label).width
        }
    }()
    
    var width: CGFloat {
        fatalError("override")
    }
    
    var lineP1: CGPoint {
        fatalError("override")
    }
    
    var lineP2: CGPoint {
        fatalError("override")
    }
    
    var height: CGFloat {
        fatalError("override")
    }
    
    var low: Bool {
        fatalError("override")
    }
    
    // p1: screen location corresponding to smallest axis value
    // p2: screen location corresponding to biggest axis value
    required init(p1: CGPoint, p2: CGPoint, axisValues: [CLAxisValue], axisTitleLabels: [CLAxisLabel], settings: CLAxisSettings)  {
        self.p1 = p1
        self.p2 = p2
        self.axisValues = axisValues.sort {(ca1, ca2) -> Bool in // ensure sorted
            ca1.scalar < ca2.scalar
        }
        self.axisTitleLabels = axisTitleLabels
        self.settings = settings
    }
    
    func chartInitialized(chart chart: Chart) {
        self.initDrawers()
    }
    
    func viewDrawing(context context: CGContextRef, chart: Chart) {
        if self.settings.isAxisLineVisible {
            if let lineDrawer = self.lineDrawer {
                CGContextSetLineWidth(context, CGFloat(self.settings.axisStrokeWidth))
                lineDrawer.triggerDraw(context: context, chart: chart)
            }
        }
        
        for labelDrawer in self.labelDrawers {
            labelDrawer.triggerDraw(context: context, chart: chart)
        }
        for axisTitleLabelDrawer in self.axisTitleLabelDrawers {
            axisTitleLabelDrawer.triggerDraw(context: context, chart: chart)
        }
    }
    
    
    func initDrawers() {
        fatalError("override")
    }
    
    func createLineDrawer(offset offset: CGFloat) -> CLLineDrawer {
        fatalError("override")
    }
    
    func createAxisTitleLabelsDrawers(offset offset: CGFloat) -> [CLLabelDrawer] {
        fatalError("override")
    }
    
    func createLabelDrawers(offset offset: CGFloat) -> [CLLabelDrawer] {
        fatalError("override")
    }
    
    func labelMaybeSize(labelMaybe: CLAxisLabel?) -> CGSize {
        return labelMaybe?.textSize ?? CGSizeZero
    }
    
    final func screenLocForScalar(scalar: Double) -> CGFloat {
        if let firstScalar = self.axisValues.first?.scalar {
            return self.screenLocForScalar(scalar, firstAxisScalar: firstScalar)
        } else {
            print("Warning: requesting empty axis for screen location")
            return 0
        }
    }
    
    func innerScreenLocForScalar(scalar: Double, firstAxisScalar: Double) -> CGFloat {
        return self.length * CGFloat(scalar - firstAxisScalar) / self.modelLength
    }
    
    func screenLocForScalar(scalar: Double, firstAxisScalar: Double) -> CGFloat {
        fatalError("must override")
    }
}

public class CLAxisModel {
    let axisValues: [CLAxisValue]
    let lineColor: UIColor
    let axisTitleLabels: [CLAxisLabel]
    
    public convenience init(axisValues: [CLAxisValue], lineColor: UIColor = UIColor.blackColor(), axisTitleLabel: CLAxisLabel) {
        self.init(axisValues: axisValues, lineColor: lineColor, axisTitleLabels: [axisTitleLabel])
    }
    
    public init(axisValues: [CLAxisValue], lineColor: UIColor = UIColor.blackColor(), axisTitleLabels: [CLAxisLabel] = []) {
        self.axisValues = axisValues
        self.lineColor = lineColor
        self.axisTitleLabels = axisTitleLabels
    }
}

public typealias CLAxisValueGenerator = Double -> CLAxisValue

// Dynamic axis values generation
public struct CLAxisValuesGenerator {
    
    public static func generateXAxisValuesWithChartPoints(chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: CLAxisValueGenerator, addPaddingSegmentIfEdge: Bool) -> [CLAxisValue] {
        return self.generateAxisValuesWithChartPoints(chartPoints, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge, axisPicker: {$0.x})
    }
    
    public static func generateYAxisValuesWithChartPoints(chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: CLAxisValueGenerator, addPaddingSegmentIfEdge: Bool) -> [CLAxisValue] {
        return self.generateAxisValuesWithChartPoints(chartPoints, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge, axisPicker: {$0.y})
    }
    
    private static func generateAxisValuesWithChartPoints(chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: CLAxisValueGenerator, addPaddingSegmentIfEdge: Bool, axisPicker: (ChartPoint) -> CLAxisValue) -> [CLAxisValue] {
        
        let sortedChartPoints = chartPoints.sort {(obj1, obj2) in
            return axisPicker(obj1).scalar < axisPicker(obj2).scalar
        }
        
        if let first = sortedChartPoints.first, last = sortedChartPoints.last {
            return self.generateAxisValuesWithChartPoints(axisPicker(first).scalar, last: axisPicker(last).scalar, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge)
            
        } else {
            print("Trying to generate Y axis without datapoints, returning empty array")
            return []
        }
    }
    
    private static func generateAxisValuesWithChartPoints(first: Double, last: Double, minSegmentCount: Double, maxSegmentCount: Double, multiple: Double, axisValueGenerator:CLAxisValueGenerator, addPaddingSegmentIfEdge: Bool) -> [CLAxisValue] {
        
        if last < first {
            fatalError("Invalid range generating axis values")
        } else if last == first {
            return []
        }
        
        var firstValue = 0.0//first - (first % multiple)
        var lastValue = last + (abs(multiple - last) % multiple)
        var segmentSize = multiple
        
        if firstValue == first && addPaddingSegmentIfEdge {
            firstValue = firstValue - segmentSize
        }
        if lastValue == last && addPaddingSegmentIfEdge {
            lastValue = lastValue + segmentSize
        }
        
        let distance = lastValue - firstValue
        var currentMultiple = multiple
        var segmentCount = distance / currentMultiple
        while segmentCount > maxSegmentCount {
            currentMultiple *= 2
            segmentCount = distance / currentMultiple
        }
        segmentCount = ceil(segmentCount)
        while segmentCount < minSegmentCount {
            segmentCount++
        }
        segmentSize = currentMultiple
        
        let offset = firstValue
        return (0...Int(segmentCount)).map {segment in
            let scalar = offset + (Double(segment) * segmentSize)
            return axisValueGenerator(scalar)
        }
    }
}

class CLAxisXHighLayerDefault: CLAxisXLayerDefault {
    
    override var low: Bool {return false}
    
    override var lineP1: CGPoint {
        return CGPointMake(self.p1.x, self.p1.y + self.lineOffset)
    }
    
    override var lineP2: CGPoint {
        return CGPointMake(self.p2.x, self.p2.y + self.lineOffset)
    }
    
    private lazy var labelsOffset: CGFloat = {
        return self.axisTitleLabelsHeight + self.settings.axisTitleLabelsToLabelsSpacing
    }()
    
    private lazy var lineOffset: CGFloat = {
        return self.labelsOffset + (self.settings.axisStrokeWidth / 2) + self.settings.labelsToAxisSpacingX + self.labelsTotalHeight
    }()
    
    override func viewDrawing(context context: CGContextRef, chart: Chart) {
        super.viewDrawing(context: context, chart: chart)
    }
    
    override func initDrawers() {
        self.axisTitleLabelDrawers = self.createAxisTitleLabelsDrawers(offset: 0)
        self.labelDrawers = self.createLabelDrawers(offset: self.labelsOffset)
        self.lineDrawer = self.createLineDrawer(offset: self.lineOffset)
    }
}

class CLAxisXLayerDefault: CLAxisLayerDefault {
    
    override var width: CGFloat {
        return self.p2.x - self.p1.x
    }
    
    lazy var labelsTotalHeight: CGFloat = {
        return self.rowHeights.reduce(0) {sum, height in
            sum + height + self.settings.labelsSpacing
        }
    }()
    
    lazy var rowHeights: [CGFloat] = {
        return self.calculateRowHeights()
    }()
    
    override var height: CGFloat {
        return self.labelsTotalHeight + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingX + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsHeight
    }
    
    override var length: CGFloat {
        return p2.x - p1.x
    }
    
    override func viewDrawing(context context: CGContextRef, chart: Chart) {
        super.viewDrawing(context: context, chart: chart)
    }
    
    override func createLineDrawer(offset offset: CGFloat) -> CLLineDrawer {
        let p1 = CGPointMake(self.p1.x, self.p1.y + offset)
        let p2 = CGPointMake(self.p2.x, self.p2.y + offset)
        return CLLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor)
    }
    
    override func createAxisTitleLabelsDrawers(offset offset: CGFloat) -> [CLLabelDrawer] {
        return self.createAxisTitleLabelsDrawers(self.axisTitleLabels, spacingLabelAxisX: self.settings.labelsToAxisSpacingX, spacingLabelBetweenAxis: self.settings.labelsSpacing, offset: offset)
    }
    
    
    private func createAxisTitleLabelsDrawers(labels: [CLAxisLabel], spacingLabelAxisX: CGFloat, spacingLabelBetweenAxis: CGFloat, offset: CGFloat) -> [CLLabelDrawer] {
        
        let rowHeights = self.rowHeightsForRows(rows: labels.map{[$0]})
        
        return labels.enumerate().map{(index, label) in
            
            let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
            
            let labelWidth = CLUtils.textSize(label.text, font: label.settings.font).width
            let x = (self.p2.x - self.p1.x) / 2 + self.p1.x - labelWidth / 2
            let y = self.p1.y + offset + rowY
            
            let drawer = CLLabelDrawer(text: label.text, screenLoc: CGPointMake(x, y), settings: label.settings)
            drawer.hidden = label.hidden
            return drawer
        }
    }
    
    
    override func screenLocForScalar(scalar: Double, firstAxisScalar: Double) -> CGFloat {
        return self.p1.x + self.innerScreenLocForScalar(scalar, firstAxisScalar: firstAxisScalar)
    }
    
    // calculate row heights (max text height) for each row
    private func calculateRowHeights() -> [CGFloat] {
        
        // organize labels in rows
        let maxRowCount = self.axisValues.reduce(-1) {maxCount, axisValue in
            max(maxCount, axisValue.labels.count)
        }
        let rows:[[CLAxisLabel?]] = (0..<maxRowCount).map {row in
            self.axisValues.map {axisValue in
                let labels = axisValue.labels
                return row < labels.count ? labels[row] : nil
            }
        }
        
        return self.rowHeightsForRows(rows: rows)
    }
    
    override func createLabelDrawers(offset offset: CGFloat) -> [CLLabelDrawer] {
        
        let spacingLabelBetweenAxis = self.settings.labelsSpacing
        
        let rowHeights = self.rowHeights
        
        // generate all the label drawers, in a flat list
        return self.axisValues.flatMap {axisValue in
            return Array(axisValue.labels.enumerate()).map {index, label in
                let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
                
                let x = self.screenLocForScalar(axisValue.scalar)
                let y = self.p1.y + offset + rowY
                
                let labelSize = CLUtils.textSize(label.text, font: label.settings.font)
                let labelX = x - (labelSize.width / 2)
                
                let labelDrawer = CLLabelDrawer(text: label.text, screenLoc: CGPointMake(labelX, y), settings: label.settings)
                labelDrawer.hidden = label.hidden
                return labelDrawer
            }
        }
    }
    
    // Get the y offset of row relative to the y position of the first row
    private func calculateRowY(rowHeights rowHeights: [CGFloat], rowIndex: Int, spacing: CGFloat) -> CGFloat {
        return Array(0..<rowIndex).reduce(0) {y, index in
            y + rowHeights[index] + spacing
        }
    }
    
    
    // Get max text height for each row of axis values
    private func rowHeightsForRows(rows rows: [[CLAxisLabel?]]) -> [CGFloat] {
        return rows.map {row in
            row.reduce(-1) {maxHeight, labelMaybe in
                return max(maxHeight, self.labelMaybeSize(labelMaybe).height)
            }
        }
    }
}

class CLAxisXLowLayerDefault: CLAxisXLayerDefault {
    
    override var low: Bool {return true}
    
    override var lineP1: CGPoint {
        return self.p1
    }
    
    override var lineP2: CGPoint {
        return self.p2
    }
    
    override func viewDrawing(context context: CGContextRef, chart: Chart) {
        super.viewDrawing(context: context, chart: chart)
    }
    
    override func initDrawers() {
        self.lineDrawer = self.createLineDrawer(offset: 0)
        let labelsOffset = (self.settings.axisStrokeWidth / 2) + self.settings.labelsToAxisSpacingX
        let labelDrawers = self.createLabelDrawers(offset: labelsOffset)
        let definitionLabelsOffset = labelsOffset + self.labelsTotalHeight + self.settings.axisTitleLabelsToLabelsSpacing
        self.axisTitleLabelDrawers = self.createAxisTitleLabelsDrawers(offset: definitionLabelsOffset)
        self.labelDrawers = labelDrawers
    }
}

class CLAxisYHighLayerDefault: CLAxisYLayerDefault {
    
    override var low: Bool {return false}
    
    override var lineP1: CGPoint {
        return self.p1
    }
    
    override var lineP2: CGPoint {
        return self.p2
    }
    
    override func initDrawers() {
        
        self.lineDrawer = self.createLineDrawer(offset: 0)
        
        let labelsOffset = self.settings.labelsToAxisSpacingY + self.settings.axisStrokeWidth
        self.labelDrawers = self.createLabelDrawers(offset: labelsOffset)
        let axisTitleLabelsOffset = labelsOffset + self.labelsMaxWidth + self.settings.axisTitleLabelsToLabelsSpacing
        self.axisTitleLabelDrawers = self.createAxisTitleLabelsDrawers(offset: axisTitleLabelsOffset)
    }
    
    override func createLineDrawer(offset offset: CGFloat) -> CLLineDrawer {
        let halfStrokeWidth = self.settings.axisStrokeWidth / 2 // we want that the stroke begins at the beginning of the frame, not in the middle of it
        let x = self.p1.x + offset + halfStrokeWidth
        let p1 = CGPointMake(x, self.p1.y)
        let p2 = CGPointMake(x, self.p2.y)
        return CLLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor)
    }
    
    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat) -> CGFloat {
        return self.p1.x + offset
    }
}

class CLAxisYLayerDefault: CLAxisLayerDefault {
    
    override var height: CGFloat {
        return self.p2.y - self.p1.y
    }
    
    var labelsMaxWidth: CGFloat {
        if self.labelDrawers.isEmpty {
            return self.maxLabelWidth(self.axisValues)
        } else {
            return self.labelDrawers.reduce(0) {maxWidth, labelDrawer in
                max(maxWidth, labelDrawer.size.width)
            }
        }
    }
    
    override var width: CGFloat {
        return self.labelsMaxWidth + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingY + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsWidth
    }
    
    override var length: CGFloat {
        return p1.y - p2.y
    }
    
    override func createAxisTitleLabelsDrawers(offset offset: CGFloat) -> [CLLabelDrawer] {
        
        if let firstTitleLabel = self.axisTitleLabels.first {
            
            if self.axisTitleLabels.count > 1 {
                print("WARNING: No support for multiple definition labels on vertical axis. Using only first one.")
            }
            let axisLabel = firstTitleLabel
            let labelSize = CLUtils.textSize(axisLabel.text, font: axisLabel.settings.font)
            let settings = axisLabel.settings
            let newSettings = CLLabelSettings(font: settings.font, fontColor: settings.fontColor, rotation: settings.rotation, rotationKeep: settings.rotationKeep)
            let axisLabelDrawer = CLLabelDrawer(text: axisLabel.text, screenLoc: CGPointMake(
                self.p1.x + offset,
                self.p2.y + ((self.p1.y - self.p2.y) / 2) - (labelSize.height / 2)), settings: newSettings)
            
            return [axisLabelDrawer]
            
        } else { // definitionLabels is empty
            return []
        }
    }
    
    
    override func screenLocForScalar(scalar: Double, firstAxisScalar: Double) -> CGFloat {
        return self.p1.y - self.innerScreenLocForScalar(scalar, firstAxisScalar: firstAxisScalar)
    }
    
    
    override func createLabelDrawers(offset offset: CGFloat) -> [CLLabelDrawer] {
        
        return self.axisValues.reduce([]) {arr, axisValue in
            let scalar = axisValue.scalar
            let y = self.screenLocForScalar(scalar)
            if let axisLabel = axisValue.labels.first { // for now y axis supports only one label x value
                let labelSize = CLUtils.textSize(axisLabel.text, font: axisLabel.settings.font)
                let labelY = y - (labelSize.height / 2)
                let labelX = self.labelsX(offset: offset, labelWidth: labelSize.width)
                let labelDrawer = CLLabelDrawer(text: axisLabel.text, screenLoc: CGPointMake(labelX, labelY), settings: axisLabel.settings)
                labelDrawer.hidden = axisValue.hidden
                return arr + [labelDrawer]
                
            } else {
                return arr
            }
            
        }
    }
    
    func labelsX(offset offset: CGFloat, labelWidth: CGFloat) -> CGFloat {
        fatalError("override")
    }
    
    private func maxLabelWidth(axisLabels: [CLAxisLabel]) -> CGFloat {
        return axisLabels.reduce(CGFloat(0)) {maxWidth, label in
            return max(maxWidth, CLUtils.textSize(label.text, font: label.settings.font).width)
        }
    }
    
    private func maxLabelWidth(axisValues: [CLAxisValue]) -> CGFloat {
        return axisValues.reduce(CGFloat(0)) {maxWidth, axisValue in
            return max(maxWidth, self.maxLabelWidth(axisValue.labels))
        }
    }
}

class CLAxisYLowLayerDefault: CLAxisYLayerDefault {
    
    override var low: Bool {return true}
    
    override var lineP1: CGPoint {
        return CGPointMake(self.p1.x + self.lineOffset, self.p1.y)
    }
    
    override var lineP2: CGPoint {
        return CGPointMake(self.p2.x + self.lineOffset, self.p2.y)
    }
    
    private lazy var labelsOffset: CGFloat = {
        return self.axisTitleLabelsWidth + self.settings.axisTitleLabelsToLabelsSpacing
    }()
    
    private lazy var lineOffset: CGFloat = {
        return self.labelsOffset + self.labelsMaxWidth + self.settings.labelsToAxisSpacingY + self.settings.axisStrokeWidth
    }()
    
    override func initDrawers() {
        self.axisTitleLabelDrawers = self.createAxisTitleLabelsDrawers(offset: 0)
        self.labelDrawers = self.createLabelDrawers(offset: self.labelsOffset)
        self.lineDrawer = self.createLineDrawer(offset: self.lineOffset)
    }
    
    override func createLineDrawer(offset offset: CGFloat) -> CLLineDrawer {
        let halfStrokeWidth = self.settings.axisStrokeWidth / 2 // we want that the stroke ends at the end of the frame, not be in the middle of it
        let p1 = CGPointMake(self.p1.x + offset - halfStrokeWidth, self.p1.y)
        let p2 = CGPointMake(self.p2.x + offset - halfStrokeWidth, self.p2.y)
        return CLLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor)
    }
    
    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat) -> CGFloat {
        let labelsXRight = self.p1.x + offset + self.labelsMaxWidth
        return labelsXRight - labelWidth
    }
}


