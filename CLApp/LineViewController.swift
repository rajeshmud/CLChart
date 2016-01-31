//
//  LineViewController.swift
//  TestApp
//
//  Created by Rajesh Mudaliyar on 02/10/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit
import CLCharts

class LineViewController: UIViewController {
    private var chart: Chart? 
    let sideSelectorHeight: CGFloat = 50
    var mbMml:Bool = true
    var fileName:String = "json"
    var breakedLinesArray = NSMutableArray(capacity: 1)

    private let useViewsLayer = true
    var chartBubblePoints: [CLPointBubble] = [CLPointBubble(point: (ChartPoint(x: CLAxisValue(scalar: 0),y: CLAxisValue(scalar: 0))))]

    @IBOutlet weak var line: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        DrawLine("json")
         if let _ = self.chart {
            let sideSelector = DirSelector(frame: CGRectMake(90, 80, 100, self.sideSelectorHeight), controller: self,title1: "D1",title2: "D2")
            let sideSelector1 = DirSelector(frame: CGRectMake(160, 80, self.view.frame.size.width, self.sideSelectorHeight), controller: self,title1: "D3",title2: "D4")
            let sideSelector2 = DirSelector(frame: CGRectMake(225, 80, self.view.frame.size.width, self.sideSelectorHeight), controller: self,title1: "D5",title2: "D6")
            let sideSelector3 = DirSelector(frame: CGRectMake(290, 80, self.view.frame.size.width, self.sideSelectorHeight), controller: self,title1: "D7",title2: "D8")
            sideSelector.fileName1 = "json"
            sideSelector.fileName2 = "xyjson"
            sideSelector1.fileName1 = "json1"
            sideSelector1.fileName2 = "xyjson1"
            sideSelector2.fileName1 = "json96points1"
            sideSelector2.fileName2 = "json96points2"
            sideSelector3.fileName1 = "jsondis"
            sideSelector3.fileName2 = "xyjsondis"
            let pointSelector = PointSelector(frame: CGRectMake(0, 80, 130, self.sideSelectorHeight), controller: self)
            self.view.addSubview(pointSelector)
            self.view.addSubview(sideSelector)
            self.view.addSubview(sideSelector1)
            self.view.addSubview(sideSelector2)
            self.view.addSubview(sideSelector3)

        }
    }
    
    internal class AB {
        var a:Int = 0
        var b:Int = 0
        internal init(a:Int,b:Int) {
            self.a = a
            self.b = b
        }
    }
    
    func DrawLine(jsonFile:String) {
        
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        
        var chartPoints = json(jsonFile)
        
        var factor:CGFloat = 1.0
        var yTitle:String = "Unit1"
        var lineFactor:Float = 1.0
        if !mbMml {
            factor = 18
            yTitle = "Unit2"
            lineFactor = 0.2
        }
        let xValues = 0.stride(through: 24, by: 2).map {CLAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = CLAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 7, maxSegmentCount: Double(350/factor), multiple: Double(50/factor), axisValueGenerator: {CLAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        let xModel = CLAxisModel(axisValues: xValues, axisTitleLabel: CLAxisLabel(text: "24 hours chart", settings: labelSettings))
        let yModel = CLAxisModel(axisValues: yValues, axisTitleLabel: CLAxisLabel(text:yTitle, settings: labelSettings.defaultVertical()))
        let chartFrame = CLDefaults.chartFrame(self.view.bounds)
        let coordsSpace = CLCoordsSpaceLeftBottomSingleAxis(chartSettings: CLDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        let borderP1 = ChartPoint(x: CLAxisValueInt(24, labelSettings: labelSettings), y: CLAxisValueDouble(Double(0/factor)))
        let borderP2 = ChartPoint(x: CLAxisValueInt(24, labelSettings: labelSettings), y: CLAxisValueDouble(Double(350/factor)))
        let borderLine = [borderP1,borderP2]
        var TargetBand:[ChartPoint] = [ChartPoint(x: CLAxisValueDouble(0, labelSettings: labelSettings), y: CLAxisValueDouble(Double(100/factor))),ChartPoint(x: CLAxisValueInt(24, labelSettings: labelSettings), y: CLAxisValueDouble(Double(100/factor)))]
        for var index = Float(103/factor); index < Float(140/factor); index = index + lineFactor{
            TargetBand.append(ChartPoint(x: CLAxisValueDouble(0, labelSettings: labelSettings), y: CLAxisValueDouble(Double(index))))
            TargetBand.append(ChartPoint(x: CLAxisValueInt(24, labelSettings: labelSettings), y: CLAxisValueDouble(Double(index))))
        }
        
        let lineLowTargetModel = CLLineModel(chartPoints:TargetBand, lineColor: UIColor(red:0.5,green:0.5, blue:0.5, alpha:0.5), lineWidth: 4, animDuration: 0, animDelay: 0)
        let lineLowTargetLineLayer = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineLowTargetModel])//, pathGenerator: CubicLinePathGenerator())
        let borderModel = CLLineModel(chartPoints:borderLine, lineColor: UIColor.blackColor(), lineWidth: 0.7, animDuration: 0, animDelay: 0)
        let borderModelLineLayer = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [borderModel])//, pathGenerator: CubicLinePathGenerator())
        chartPoints = breakedLinesArray.objectAtIndex(0) as! [ChartPoint]
        var chartPoints2 = chartPoints
        let lineModel = CLLineModel(chartPoints: chartPoints, lineColor: UIColor.purpleColor(), lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel], pathGenerator: CubicLinePathGenerator())
        var lineModel1 = lineModel
        var chartPointsLineLayer2 = chartPointsLineLayer
        if breakedLinesArray.count > 1 {
            chartPoints2.removeAll()
            chartPoints2 = breakedLinesArray.objectAtIndex(1) as! [ChartPoint]
        lineModel1 = CLLineModel(chartPoints: chartPoints2, lineColor: UIColor.purpleColor(), lineWidth: 2, animDuration: 1, animDelay: 0)
        chartPointsLineLayer2 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel1], pathGenerator: CubicLinePathGenerator())
        }
        
        let bubbleLayer = self.bubblesLayer(xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame, chartPoints: chartBubblePoints)
        let trackerLayerSettings = CLPointsLineTrackerLayerSettings(thumbSize: Env.iPad ? 30 : 15, thumbCornerRadius: Env.iPad ? 8 : 4, thumbBorderWidth: Env.iPad ? 4 : 2, infoViewFont: CLDefaults.fontWithSize(Env.iPad ? 26 : 16), infoViewSize: CGSizeMake(Env.iPad ? 400 : 230, Env.iPad ? 70 : 20), infoViewCornerRadius: Env.iPad ? 30 : 15)
        let chartPointsTrackerLayer = CLPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, lineColor: UIColor.blackColor(), animDuration: 1, animDelay: 2, settings: trackerLayerSettings)
        let settings = CLGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: CLDefaults.guidelinesWidth)
        let guidelinesLayer = CLGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        let chart = Chart(
            frame: chartFrame,
            layers: [
            xAxis,
            yAxis,
            lineLowTargetLineLayer,
            guidelinesLayer,
            borderModelLineLayer,
            chartPointsLineLayer,
            bubbleLayer,
            chartPointsLineLayer2,
            chartPointsTrackerLayer
            
            ]
        )
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    private func bubblesLayer(xAxis xAxis: CLAxisLayer, yAxis: CLAxisLayer, chartInnerFrame: CGRect, chartPoints: [CLPointBubble]) -> CLLayer {
        
        let _: Double = 30, _: Double = 2
        
        if self.useViewsLayer == true {
            
            let (_, _): (Double, Double) = chartPoints.reduce((min: 0, max: 0)) {tuple, chartPoint in
                (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
            }
            return CLPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
                
                let diameter = CGFloat(10)//CGFloat(chartPointModel.chartPoint.diameterScalar * diameterFactor)
                let circleView = CLPointEllipseView(center: chartPointModel.screenLoc, diameter: diameter)
                circleView.fillColor = chartPointModel.chartPoint.bgColor
                circleView.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
                circleView.borderWidth = 1
                circleView.animDelay = Float(chartPointModel.index) * 0.2
                circleView.animDuration = 1.2
                circleView.animDamping = 0.4
                circleView.animInitSpringVelocity = 0.5
                return circleView
            })
            
        } else {
            return CLPointsBubbleLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints)
        }
    }

    func json(fileName:String)->[ChartPoint] {
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        let p1 = ChartPoint(x: CLAxisValueInt(0, labelSettings: labelSettings), y: CLAxisValueInt(0))
        var points:[ChartPoint] = [p1]
        var noOfArray = -1
        var newline = true
        chartBubblePoints.removeAll()
        breakedLinesArray.removeAllObjects()
        var jsonResult:NSArray! = NSArray()
        do{
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
            let jsonData = NSData(contentsOfFile: path!)
            jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData! , options: NSJSONReadingOptions.MutableContainers) as! NSArray
            chartBubblePoints.removeAll()
            for i in 0...jsonResult.count - 1
            {
                var factor:CGFloat = 1.0
                if !mbMml {factor = 18}
                let x = CGFloat(((jsonResult[i].valueForKey("time"))?.floatValue)!)
                let y = CGFloat(((jsonResult[i].valueForKey("gValue"))?.floatValue)!)/factor
                if y == -1/factor {
                    newline = true
                    points.removeAll()
                    
                } else {
                    if newline {
                        points.removeAll()

                        noOfArray++
                        newline = false
                        breakedLinesArray.addObject(points)

                    }
                let point = ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y))
                var arr = breakedLinesArray.objectAtIndex(noOfArray) as! [ChartPoint]
                arr.append(point)
                points.append(point)
                breakedLinesArray.replaceObjectAtIndex(noOfArray, withObject: points)
                if y < 75/factor {
                 chartBubblePoints.append(CLPointBubble(point: point,diameterScalar: 20,bgColor: UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 0.7)))
                } else if y > 200/factor {
                    chartBubblePoints.append(CLPointBubble(point: point,diameterScalar: 20,bgColor: UIColor(red: 0.8, green: 0.5, blue: 0.0, alpha: 0.7)))
                }
                }
            }
        } catch let error as NSError {
            print(error)
        }
        return points
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class DirSelector: UIView {
        
        let dataSet1: UIButton
        let dataSet2: UIButton
        var title1: String = "but1"
        var title2: String = "but2"
        var fileName1: String = "1"
        var fileName2: String = "2"
        weak var controller: LineViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: LineViewController,title1: String,title2: String) {
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
            controller!.DrawLine(controller!.fileName)
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
            let buttonsSpace: CGFloat = Env.iPad ? 20 : 4
            
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
        weak var controller: LineViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: LineViewController) {
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
            controller!.DrawLine(controller!.fileName)
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

