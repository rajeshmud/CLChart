//
//  HorizontalBarViewController.swift
//  TestApp
//
//  Created by Rajesh Mudaliyar on 02/10/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit
import CLCharts

class HorizontalBarViewController: UIViewController {
    private var chart: Chart?
    var mbMml:Bool = true
    var fileName:String = "json"
    var factor:CGFloat = 1.0
    let sideSelectorHeight: CGFloat = 50
    var xlabel = 0
    var xInterval = 0
    
    func barPoint(fileName:String) ->[ChartPoint]{
        let points = json(fileName)
        let noofPoints = points.count
        if noofPoints < 25 {
            xlabel = 24
            xInterval = 2
        }else if noofPoints > 25 && noofPoints < 50{
            xlabel = 50
            xInterval = 4
        }else {
            xlabel = 96
            xInterval = 8
        }
        var index50 = 0
        var index100 = 0
        var index150 = 0
        var index200 = 0
        var index250 = 0
        var index300 = 0
        var index350 = 0
        var index400 = 0
        for point in points {
            if point.y <=  CLAxisValue(scalar: 75/Double(factor)){
                index50++
            }
            if point.y >  CLAxisValue(scalar: 75/Double(factor)) && point.y <=  CLAxisValue(scalar: 125/Double(factor)){
                index100++
            }
            if point.y >  CLAxisValue(scalar: 125/Double(factor)) && point.y <=  CLAxisValue(scalar: 175/Double(factor)){
                index150++
            }
            if point.y >  CLAxisValue(scalar: 175/Double(factor)) && point.y <=  CLAxisValue(scalar: 225/Double(factor)){
                index200++
            }
            if point.y >  CLAxisValue(scalar: 225/Double(factor)) && point.y <=  CLAxisValue(scalar: 275/Double(factor)){
                index250++
            }
            if point.x >  CLAxisValue(scalar: 275/Double(factor)) && point.y <=  CLAxisValue(scalar: 325/Double(factor)){
                index300++
            }
            if point.y >  CLAxisValue(scalar: 325/Double(factor)) && point.y <=  CLAxisValue(scalar: 375/Double(factor)){
                index350++
            }
            if point.y >  CLAxisValue(scalar: 374/Double(factor)) {
                index400++
            }
        }
        let p1 = ChartPoint(x: CLAxisValueInt(index50), y:CLAxisValue(scalar: 50/Double(factor)))
        var retPoints:[ChartPoint] = [p1]
        retPoints.append(ChartPoint(x: CLAxisValueInt(index100) , y: CLAxisValue(scalar: 100/Double(factor))))
        retPoints.append(ChartPoint(x: CLAxisValueInt(index150), y: CLAxisValue(scalar:150/Double(factor))))
        retPoints.append(ChartPoint(x: CLAxisValueInt(index200), y: CLAxisValue(scalar:200/Double(factor))))
        retPoints.append(ChartPoint(x: CLAxisValueInt(index250), y: CLAxisValue(scalar:250/Double(factor))))
        retPoints.append(ChartPoint(x: CLAxisValueInt(index300), y: CLAxisValue(scalar:300/Double(factor))))
        retPoints.append(ChartPoint(x: CLAxisValueInt(index350), y: CLAxisValue(scalar:350/Double(factor))))
        retPoints.append(ChartPoint(x: CLAxisValueInt(index400), y: CLAxisValue(scalar:400/Double(factor))))
        retPoints.removeFirst()
        return retPoints
    }

    private func barsChart() -> Chart {
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        var yTitle:String = "Unit1"
        if !mbMml {
            factor = 18
            yTitle = "Unit2"
        } else {
            factor = 1.0
            yTitle = "Unit1"
        }
        
        func reverseTuples(tuples: [(Int, Int)]) -> [(Int, Int)] {
            return tuples.map{($0.1, $0.0)}
        }
        let chartPoints:[ChartPoint] = barPoint(fileName)
        let xValues = 0.stride(through: xlabel, by: xInterval).map {CLAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = CLAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 6, maxSegmentCount: Double(350/factor), multiple: Double(50/factor), axisValueGenerator: {CLAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        let xModel = CLAxisModel(axisValues: xValues, axisTitleLabel: CLAxisLabel(text: "24 hours chart", settings: labelSettings))
        let yModel = CLAxisModel(axisValues: yValues, axisTitleLabel: CLAxisLabel(text: yTitle, settings: labelSettings.defaultVertical()))
        let barViewGenerator = {(chartPointModel: CLPointLayerModel, layer: CLPointsViewsLayer, chart: Chart) -> UIView? in
            let bottomLeft = CGPointMake(layer.innerFrame.origin.x, layer.innerFrame.origin.y + layer.innerFrame.height)
            let barWidth: CGFloat = Env.iPad ? 30 : 15
            
            let (p1, p2): (CGPoint, CGPoint) = {
                return (CGPointMake(bottomLeft.x, chartPointModel.screenLoc.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                }()
            return CLPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: UIColor.blueColor().colorWithAlphaComponent(0.6))
        }
        
        let frame = CLDefaults.chartFrame(self.view.bounds)
        let chartFrame = self.chart?.frame ?? CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - sideSelectorHeight)
        let coordsSpace = CLCoordsSpaceLeftBottomSingleAxis(chartSettings: CLDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let labelsLayer = CLPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let label = HandlingLabel()
            let posOffset: CGFloat = 10
            
            let pos = chartPointModel.chartPoint.y.scalar > 0
            
            let yOffset = pos ? -posOffset : posOffset
            if chartPointModel.chartPoint.x.scalar != 0
            {
                label.text = "\(formatter.stringFromNumber(chartPointModel.chartPoint.x.scalar)!)"
            }
            label.font = CLDefaults.fontWithSize(Env.iPad ? 14 : 9)
            label.sizeToFit()
            label.center = CGPointMake(chartPointModel.screenLoc.x + 10, pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0
            
            label.movedToSuperViewHandler = {[weak label] in
                UIView.animateWithDuration(0.0, animations: {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y + yOffset + 10
                })
            }
            return label
            
            }, displayDelay: 0.5)
        let chartPointsLayer = CLPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
        let settings = CLGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: CLDefaults.guidelinesWidth)
        let guidelinesLayer = CLGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        return Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLayer,
                labelsLayer
            ]
        )
    }
    
    private func showChart() {
        self.chart?.clearView()
        
        let chart = self.barsChart()
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        self.showChart()
        if let _ = self.chart {
            let sideSelector = DirSelector(frame: CGRectMake(90, 80, self.view.frame.size.width, self.sideSelectorHeight), controller: self,title1: "DS1",title2: "DS2")
            let sideSelector1 = DirSelector(frame: CGRectMake(180, 80, self.view.frame.size.width, self.sideSelectorHeight), controller: self,title1: "DS3",title2: "DS4")
            let sideSelector2 = DirSelector(frame: CGRectMake(260, 80, self.view.frame.size.width, self.sideSelectorHeight), controller: self,title1: "DS5",title2: "DS6")
            sideSelector.fileName1 = "json"
            sideSelector.fileName2 = "xyjson"
            sideSelector1.fileName1 = "json1"
            sideSelector1.fileName2 = "xyjson1"
            sideSelector2.fileName1 = "json96points1"
            sideSelector2.fileName2 = "json96points2"
            let pointSelector = PointSelector(frame: CGRectMake(0, 80, 130, self.sideSelectorHeight), controller: self)
            self.view.addSubview(pointSelector)
            self.view.addSubview(sideSelector)
            self.view.addSubview(sideSelector1)
            self.view.addSubview(sideSelector2)
        }

    }
    func json(fileName:String)->[ChartPoint] {
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        let p1 = ChartPoint(x: CLAxisValueInt(0, labelSettings: labelSettings), y: CLAxisValueInt(0))
        var points:[ChartPoint] = [p1]
        
        
        var jsonResult:NSArray! = NSArray()
        do{
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
            let jsonData = NSData(contentsOfFile: path!)
            jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData! , options: NSJSONReadingOptions.MutableContainers) as! NSArray
            for i in 0...jsonResult.count - 1
            {
                var factor:CGFloat = 1.0
                if !mbMml {factor = 18}
                let x = CGFloat(((jsonResult[i].valueForKey("time"))?.floatValue)!)
                let y = CGFloat(((jsonResult[i].valueForKey("gValue"))?.floatValue)!)/factor
                points.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y)))
            }
            
        } catch let error as NSError {
            print(error)
        }
        points.removeFirst()
        return points
    }
    
    
    class DirSelector: UIView {
        let dataSet1: UIButton
        let dataSet2: UIButton
        var title1: String = "but1"
        var title2: String = "but2"
        var fileName1: String = "1"
        var fileName2: String = "2"
        weak var controller: HorizontalBarViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: HorizontalBarViewController,title1: String,title2: String) {
            self.controller = controller
            self.dataSet1 = UIButton()
            self.dataSet1.setTitle(title1, forState: .Normal)
            self.dataSet2 = UIButton()
            self.dataSet2.setTitle(title2, forState: .Normal)
            self.buttonDirs = [self.dataSet1 : true, self.dataSet2 : false]
            super.init(frame: frame)
            self.addSubview(self.dataSet1)
            self.addSubview(self.dataSet2)
            for button in [self.dataSet1, self.dataSet2] {
                button.titleLabel?.font = CLDefaults.fontWithSize(14)
                button.setTitleColor(UIColor.blueColor(), forState: .Normal)
                button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            }
        }
        
        func buttonTapped(sender: UIButton) {
            controller?.chart!.clearView()
            if (sender == self.dataSet1) {
                controller!.fileName = fileName1
            }else {
                controller!.fileName = fileName2
            }
            controller!.showChart()
        }
        override func didMoveToSuperview() {
            let views = [self.dataSet1, self.dataSet2]
            for v in views {
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            let namedViews = views.enumerate().map{index, view in
                ("v\(index)", view)
            }
            let viewsDict = namedViews.reduce(Dictionary<String, UIView>()) {(var u, tuple) in
                u[tuple.0] = tuple.1
                return u
            }
            let buttonsSpace: CGFloat = Env.iPad ? 20 : 10
            let hConstraintStr = namedViews.reduce("H:|") {str, tuple in
                "\(str)-(\(buttonsSpace))-[\(tuple.0)]"
            }
            let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraintsWithVisualFormat("V:|[\($0.0)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
                + vConstraits)
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class PointSelector: UIView {
        let mmo: UIButton
        let mml: UIButton
        weak var controller: HorizontalBarViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: HorizontalBarViewController) {
            self.controller = controller
            self.mmo = UIButton()
            self.mmo.setTitle("Unit2", forState: .Normal)
            self.mml = UIButton()
            self.mml.setTitle("Unit1", forState: .Normal)
            self.buttonDirs = [self.mmo : true, self.mml : false]
            super.init(frame: frame)
            self.addSubview(self.mmo)
            self.addSubview(self.mml)
            for button in [self.mmo, self.mml] {
                button.titleLabel?.font = CLDefaults.fontWithSize(14)
                button.setTitleColor(UIColor.blueColor(), forState: .Normal)
                button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            }
        }
        
        func buttonTapped(sender: UIButton) {
            controller?.chart!.clearView()
            if (sender == self.mmo) {
                controller!.mbMml = false
                self.mmo.setTitle("Unit2", forState: .Normal)
                self.mml.setTitle("Unit1", forState: .Normal)
            }else {
                controller!.mbMml = true
                self.mml.setTitle("Unit1", forState: .Normal)
                self.mmo.setTitle("Unit2", forState: .Normal)
            }
            controller!.showChart()
        }
        
        override func didMoveToSuperview() {
            let views = [self.mmo, self.mml]
            for v in views {
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            
            let namedViews = views.enumerate().map{index, view in
                ("v\(index)", view)
            }
            
            let viewsDict = namedViews.reduce(Dictionary<String, UIView>()) {(var u, tuple) in
                u[tuple.0] = tuple.1
                return u
            }
            
            let buttonsSpace: CGFloat = Env.iPad ? 20 : 10
            
            let hConstraintStr = namedViews.reduce("H:|") {str, tuple in
                "\(str)-(\(buttonsSpace))-[\(tuple.0)]"
            }
            
            let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraintsWithVisualFormat("V:|[\($0.0)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
                + vConstraits)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
