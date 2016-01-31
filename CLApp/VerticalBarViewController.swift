//
//  VerticalBarViewController.swift
//  TestApp
//
//  Created by Rajesh Mudaliyar on 02/10/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit
import CLCharts

class VerticalBarViewController: UIViewController {
    private var chart: Chart? // arc
    var mbMml:Bool = true
    var fileName:String = "json"
    let sideSelectorHeight: CGFloat = 50
    func barPoint(fileName:String) ->[ChartPoint]{
        let points = json(fileName)
        let lessthen2 = CLAxisValue(scalar: 0)
        var index2 = 0
        let lessthen4 = CLAxisValue(scalar: 0)
        var index4 = 0
        let lessthen6 = CLAxisValue(scalar: 0)
        var index6 = 0
        let lessthen8 = CLAxisValue(scalar: 0)
        var index8 = 0
        let lessthen10 = CLAxisValue(scalar: 0)
        var index10 = 0
        let lessthen12 = CLAxisValue(scalar: 0)
        var index12 = 0
        let lessthen14 = CLAxisValue(scalar: 0)
        var index14 = 0
        let lessthen16 = CLAxisValue(scalar: 0)
        var index16 = 0
        let lessthen18 = CLAxisValue(scalar: 0)
        var index18 = 0
        let lessthen20 = CLAxisValue(scalar: 0)
        var index20 = 0
        let lessthen22 = CLAxisValue(scalar: 0)
        var index22 = 0
        let lessthen24 = CLAxisValue(scalar: 0)
        var index24 = 0
        for point in points {
            if point.x <=  CLAxisValue(scalar: 2){
                lessthen2 += point.y
                index2++
            }
            if point.x >  CLAxisValue(scalar: 2) && point.x <=  CLAxisValue(scalar: 4){
                lessthen4 += point.y
                index4++
            }
            if point.x >  CLAxisValue(scalar: 4) && point.x <=  CLAxisValue(scalar: 6){
                lessthen6 += point.y
                index6++
            }
            if point.x >  CLAxisValue(scalar: 6) && point.x <=  CLAxisValue(scalar: 8){
                lessthen8 += point.y
                index8++
            }
            if point.x >  CLAxisValue(scalar: 8) && point.x <=  CLAxisValue(scalar: 10){
                lessthen10 += point.y
                index10++
            }
            if point.x >  CLAxisValue(scalar: 10) && point.x <=  CLAxisValue(scalar: 12){
                lessthen12 += point.y
                index12++
            }
            if point.x >  CLAxisValue(scalar: 12) && point.x <=  CLAxisValue(scalar: 14){
                lessthen14 += point.y
                index14++
            }
            if point.x >  CLAxisValue(scalar: 14) && point.x <=  CLAxisValue(scalar: 16){
                lessthen16 += point.y
                index16++
            }
            if point.x >  CLAxisValue(scalar: 16) && point.x <=  CLAxisValue(scalar: 18){
                lessthen18 += point.y
                index18++
            }
            if point.x >  CLAxisValue(scalar: 18) && point.x <=  CLAxisValue(scalar: 20){
                lessthen20 += point.y
                index20++
            }
            if point.x >  CLAxisValue(scalar: 20) && point.x <=  CLAxisValue(scalar: 22){
                lessthen22 += point.y
                index22++
            }
            if point.x >  CLAxisValue(scalar: 22) && point.x <=  CLAxisValue(scalar: 24){
                lessthen24 += point.y
                index24++
            }

        }

        lessthen2.divideBy(index2)
        lessthen4.divideBy(index4)
        lessthen6.divideBy(index6)
        lessthen8.divideBy(index8)
        lessthen10.divideBy(index10)
        lessthen12.divideBy(index12)
        lessthen14.divideBy(index14)
        lessthen16.divideBy(index16)
        lessthen18.divideBy(index18)
        lessthen20.divideBy(index20)
        lessthen22.divideBy(index22)
        lessthen24.divideBy(index24)
        
        let p1 = ChartPoint(x: CLAxisValueInt(0), y: CLAxisValueInt(0))
        var retPoints:[ChartPoint] = [p1]
        retPoints.append(ChartPoint(x: CLAxisValueFloat(2), y: lessthen2))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(4), y: lessthen4))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(6), y: lessthen6))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(8), y: lessthen8))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(10), y: lessthen10))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(12), y: lessthen12))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(14), y: lessthen14))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(16), y: lessthen16))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(18), y: lessthen18))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(20), y: lessthen20))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(22), y: lessthen22))
        retPoints.append(ChartPoint(x: CLAxisValueFloat(24), y: lessthen24))
        retPoints.removeFirst()
        return retPoints
    }
    
    private func barsChart(fileName:String) -> Chart {
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        var factor:CGFloat = 1.0
        var yTitle:String = "Unit1"
        if !mbMml {
            factor = 18
            yTitle = "Unit2"
        }
        
        func reverseTuples(tuples: [(Int, Int)]) -> [(Int, Int)] {
            return tuples.map{($0.1, $0.0)}
        }
        
        let chartPoints = barPoint(fileName)
        let xValues = 0.stride(through: 24, by: 2).map {CLAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = CLAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 7, maxSegmentCount: Double(350/factor), multiple: Double(50/factor), axisValueGenerator: {CLAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        let xModel = CLAxisModel(axisValues: xValues, axisTitleLabel: CLAxisLabel(text: "24 hours chart", settings: labelSettings))
        let yModel = CLAxisModel(axisValues: yValues, axisTitleLabel: CLAxisLabel(text: yTitle, settings: labelSettings.defaultVertical()))
        let barViewGenerator = {(chartPointModel: CLPointLayerModel, layer: CLPointsViewsLayer, chart: Chart) -> UIView? in
            let bottomLeft = CGPointMake(layer.innerFrame.origin.x, layer.innerFrame.origin.y + layer.innerFrame.height)
            let barWidth: CGFloat = Env.iPad ? 30 : 15
            let (p1, p2): (CGPoint, CGPoint) = {
                return (CGPointMake(chartPointModel.screenLoc.x, bottomLeft.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
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
            label.text = "\(formatter.stringFromNumber(chartPointModel.chartPoint.y.scalar)!)"
            label.font = CLDefaults.fontWithSize(Env.iPad ? 14 : 9)
            label.sizeToFit()
            label.center = CGPointMake(chartPointModel.screenLoc.x, pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0
            
            label.movedToSuperViewHandler = {[weak label] in
                UIView.animateWithDuration(0.0, animations: {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y + yOffset
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
    
    
    private func showChart(fileName:String) {
        self.chart?.clearView()
        let chart = self.barsChart(fileName)
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        self.showChart("json")
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
    
    
    class DirSelector: UIView {
        
        let dataSet1: UIButton
        let dataSet2: UIButton
        var title1: String = "but1"
        var title2: String = "but2"
        var fileName1: String = "1"
        var fileName2: String = "2"
        weak var controller: VerticalBarViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: VerticalBarViewController,title1: String,title2: String) {
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
            controller!.showChart(controller!.fileName)
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
        weak var controller: VerticalBarViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: VerticalBarViewController) {
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
            if (sender == self.mmo) {
                controller!.mbMml = false
                self.mmo.setTitle("Unit2", forState: .Normal)
                self.mml.setTitle("Unit1", forState: .Normal)
            }else {
                controller!.mbMml = true
                self.mml.setTitle("Unit1", forState: .Normal)
                self.mmo.setTitle("Unit2", forState: .Normal)
            }
            controller!.showChart(controller!.fileName)
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

