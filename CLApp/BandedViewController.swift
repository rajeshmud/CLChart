//
//  BandedViewController.swift
//  TestApp
//
//  Created by Rajesh Mudaliyar on 02/10/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit
import CLCharts

class BandedViewController: UIViewController {
    private var chart: Chart? // arc
    let sideSelectorHeight: CGFloat = 50
    var mbMml:Bool = true
    var fileName:String = "json"
    var bandedLinesArray = NSMutableArray(capacity: 1)

    @IBOutlet weak var line: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
         DrawLine("json")
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
  
    
    func DrawLine(jsonFile:String) {
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        var chartPoints = json(jsonFile)
        let bandedPoints = json(jsonFile)
        var factor:CGFloat = 1.0
        var yTitle:String = "Unit1"
        var lineFactor:Float = 1.0
        if !mbMml {
            factor = 18
            yTitle = "Unit2"
            lineFactor = 0.2
        }
        var readFormatter = NSDateFormatter()
        readFormatter.dateFormat = "dd.MM.yyyy"
        var displayFormatter = NSDateFormatter()
        displayFormatter.dateFormat = "MMM dd"
        
        let date = {(str: String) -> NSDate in
            return readFormatter.dateFromString(str)!
        }
        let calendar = NSCalendar.currentCalendar()
        let dateWithComponents = {(day: Int, month: Int, year: Int) -> NSDate in
            let components = NSDateComponents()
            components.day = day
            components.month = month
            components.year = year
            return calendar.dateFromComponents(components)!
        }
        
        func generateDateAxisValues(month: Int, year: Int) -> [CLAxisValueDate] {
            let date = dateWithComponents(1, month, year)
            let calendar = NSCalendar.currentCalendar()
            let monthDays = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
            return Array(monthDays.toRange()!).map {day in
                let date = dateWithComponents(day, month, year)
                let axisValue = CLAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
                axisValue.hidden = !(day % 5 == 0)
                return axisValue
            }
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
        var TargetBand:[ChartPoint] = [ChartPoint(x: CLAxisValueDouble(0, labelSettings: labelSettings), y: CLAxisValueDouble(Double(100/factor))),ChartPoint(x: CLAxisValueInt(24, labelSettings: labelSettings), y: CLAxisValueDouble(Double(100/factor)))]
        for var index = Float(103/factor); index < Float(140/factor); index = index + lineFactor{
            TargetBand.append(ChartPoint(x: CLAxisValueDouble(0, labelSettings: labelSettings), y: CLAxisValueDouble(Double(index))))
            TargetBand.append(ChartPoint(x: CLAxisValueInt(24, labelSettings: labelSettings), y: CLAxisValueDouble(Double(index))))
        }
        
        let borderLine = [borderP1,borderP2]
        let lineLowTargetModel = CLLineModel(chartPoints:TargetBand, lineColor: UIColor(red:0.5,green:0.5, blue:0.5, alpha:0.5), lineWidth: 4, animDuration: 0, animDelay: 0)
        let lineLowTargetLineLayer = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineLowTargetModel], pathGenerator: CubicLinePathGenerator())
        let borderModel = CLLineModel(chartPoints:borderLine, lineColor: UIColor.blackColor(), lineWidth: 0.7, animDuration: 0, animDelay: 0)
        let borderModelLineLayer = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [borderModel], pathGenerator: CubicLinePathGenerator())
        chartPoints = bandedLinesArray.objectAtIndex(0) as! [ChartPoint]
        let chartPoints1 = bandedLinesArray.objectAtIndex(1) as! [ChartPoint]
        let chartPoints2 = bandedLinesArray.objectAtIndex(2) as! [ChartPoint]
        let chartPoints3 = bandedLinesArray.objectAtIndex(3) as! [ChartPoint]
        let chartPoints4 = bandedLinesArray.objectAtIndex(4) as! [ChartPoint]
        let chartPoints5 = bandedLinesArray.objectAtIndex(5) as! [ChartPoint]
        let chartPoints6 = bandedLinesArray.objectAtIndex(6) as! [ChartPoint]
        let bandColor =  UIColor(red: 0.5, green: 0.7, blue: 0.5, alpha: 0.7)
        let lineModel1 = CLLineModel(chartPoints: chartPoints1, lineColor: bandColor, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer1 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel1], pathGenerator: CubicLinePathGenerator())
        let lineModel2 = CLLineModel(chartPoints: chartPoints2, lineColor: bandColor, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer2 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel2], pathGenerator: CubicLinePathGenerator())
        let lineModel3 = CLLineModel(chartPoints: chartPoints3, lineColor: bandColor, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer3 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel3], pathGenerator: CubicLinePathGenerator())
        let lineModel4 = CLLineModel(chartPoints: chartPoints4, lineColor: bandColor, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer4 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel4], pathGenerator: CubicLinePathGenerator())
        let lineModel5 = CLLineModel(chartPoints: chartPoints5, lineColor: bandColor, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer5 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel5], pathGenerator: CubicLinePathGenerator())
        let lineModel6 = CLLineModel(chartPoints: chartPoints6, lineColor: bandColor, lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer6 = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel6], pathGenerator: CubicLinePathGenerator())
        let lineModel = CLLineModel(chartPoints: chartPoints, lineColor: UIColor.purpleColor(), lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = CLPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel], pathGenerator: CubicLinePathGenerator())
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
                //bandedPointsLineLayer,
                chartPointsLineLayer1,
                chartPointsLineLayer2,
                chartPointsLineLayer3,
                chartPointsLineLayer4,
                chartPointsLineLayer5,
                chartPointsLineLayer6,
                chartPointsLineLayer
            ]
        )
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    
    func json(fileName:String)->[ChartPoint] {
        let labelSettings = CLLabelSettings(font: CLDefaults.labelFont)
        let p1 = ChartPoint(x: CLAxisValueInt(0, labelSettings: labelSettings), y: CLAxisValueInt(0))
        var points:[ChartPoint] = [p1]
        var points1:[ChartPoint] = [p1]
        var points2:[ChartPoint] = [p1]
        var points3:[ChartPoint] = [p1]
        var points4:[ChartPoint] = [p1]
        var points5:[ChartPoint] = [p1]
        var points6:[ChartPoint] = [p1]
        bandedLinesArray.removeAllObjects()
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
                points1.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y+(4/factor))))
                points2.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y+(8/factor))))
                points3.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y+(12/factor))))
                points4.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y-(4/factor))))
                points5.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y-(8/factor))))
                points6.append(ChartPoint(x: CLAxisValueFloat(x, labelSettings: labelSettings), y: CLAxisValueFloat(y-(12/factor))))
            }
            points.removeFirst()
            points1.removeFirst()
            points2.removeFirst()
            points3.removeFirst()
            points4.removeFirst()
            points5.removeFirst()
            points6.removeFirst()
            bandedLinesArray.addObject(points)
            bandedLinesArray.addObject(points1)
            bandedLinesArray.addObject(points2)
            bandedLinesArray.addObject(points3)
            bandedLinesArray.addObject(points4)
            bandedLinesArray.addObject(points5)
            bandedLinesArray.addObject(points6)
        } catch let error as NSError {
            print(error)
        }
        points.removeFirst()
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
        weak var controller: BandedViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: BandedViewController,title1: String,title2: String) {
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
        weak var controller: BandedViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: BandedViewController) {
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


private class InfoView: UIView {
    let statusView: UIView
    let dateLabel: UILabel
    let lowTextLabel: UILabel
    let highTextLabel: UILabel
    let openTextLabel: UILabel
    let closeTextLabel: UILabel
    let lowLabel: UILabel
    let highLabel: UILabel
    let openLabel: UILabel
    let closeLabel: UILabel
    
    override init(frame: CGRect) {
        let itemHeight: CGFloat = 40
        let y = (frame.height - itemHeight) / CGFloat(2)
        self.statusView = UIView(frame: CGRectMake(0, y, itemHeight, itemHeight))
        self.statusView.layer.borderColor = UIColor.blackColor().CGColor
        self.statusView.layer.borderWidth = 1
        self.statusView.layer.cornerRadius = Env.iPad ? 13 : 8
        let font = CLDefaults.labelFont
        self.dateLabel = UILabel()
        self.dateLabel.font = font
        self.lowTextLabel = UILabel()
        self.lowTextLabel.text = "Low:"
        self.lowTextLabel.font = font
        self.lowLabel = UILabel()
        self.lowLabel.font = font
        self.highTextLabel = UILabel()
        self.highTextLabel.text = "High:"
        self.highTextLabel.font = font
        self.highLabel = UILabel()
        self.highLabel.font = font
        self.openTextLabel = UILabel()
        self.openTextLabel.text = "Open:"
        self.openTextLabel.font = font
        self.openLabel = UILabel()
        self.openLabel.font = font
        self.closeTextLabel = UILabel()
        self.closeTextLabel.text = "Close:"
        self.closeTextLabel.font = font
        self.closeLabel = UILabel()
        self.closeLabel.font = font
        super.init(frame: frame)
        self.addSubview(self.statusView)
        self.addSubview(self.dateLabel)
        self.addSubview(self.lowTextLabel)
        self.addSubview(self.lowLabel)
        self.addSubview(self.highTextLabel)
        self.addSubview(self.highLabel)
        self.addSubview(self.openTextLabel)
        self.addSubview(self.openLabel)
        self.addSubview(self.closeTextLabel)
        self.addSubview(self.closeLabel)
    }
    
    private override func didMoveToSuperview() {
        let views = [self.statusView, self.dateLabel, self.highTextLabel, self.highLabel, self.lowTextLabel, self.lowLabel, self.openTextLabel, self.openLabel, self.closeTextLabel, self.closeLabel]
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
        let circleDiameter: CGFloat = Env.iPad ? 26 : 15
        let labelsSpace: CGFloat = Env.iPad ? 10 : 5
        let hConstraintStr = namedViews[1..<namedViews.count].reduce("H:|[v0(\(circleDiameter))]") {str, tuple in
            "\(str)-(\(labelsSpace))-[\(tuple.0)]"
        }
        let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraintsWithVisualFormat("V:|-(18)-[\($0.0)(\(circleDiameter))]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
            + vConstraits)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showChartPoint(chartPoint: CLPointCandleStick) {
        let color = chartPoint.open > chartPoint.close ? UIColor.blackColor() : UIColor.whiteColor()
        self.statusView.backgroundColor = color
        self.dateLabel.text = chartPoint.x.labels.first?.text ?? ""
        self.lowLabel.text = "\(chartPoint.low)"
        self.highLabel.text = "\(chartPoint.high)"
        self.openLabel.text = "\(chartPoint.open)"
        self.closeLabel.text = "\(chartPoint.close)"
    }
    
    func clear() {
        self.statusView.backgroundColor = UIColor.clearColor()
    }
}


private class InfoWithIntroView: UIView {
    var introView: UIView!
    var infoView: InfoView!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private override func didMoveToSuperview() {
        let label = UILabel(frame: CGRectMake(0, self.bounds.origin.y+10, self.bounds.width, self.bounds.height))
        label.text = "Drag the line to see chartpoint data"
        label.font = CLDefaults.labelFont
        label.backgroundColor = UIColor.whiteColor()
        self.introView = label
        self.infoView = InfoView(frame: self.bounds)
        self.addSubview(self.infoView)
        self.addSubview(self.introView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateIntroAlpha(alpha: CGFloat) {
        UIView.animateWithDuration(0.1, animations: {
            self.introView.alpha = alpha
        })
    }
    
    func showChartPoint(chartPoint: CLPointCandleStick) {
        self.animateIntroAlpha(0)
        self.infoView.showChartPoint(chartPoint)
    }
    
    func clear() {
        self.animateIntroAlpha(1)
        self.infoView.clear()
    }
    class DirSelector: UIView {
        
        let dataSet1: UIButton
        let dataSet2: UIButton
        weak var controller: BandedViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: BandedViewController) {
            self.controller = controller
            self.dataSet1 = UIButton()
            self.dataSet1.setTitle("->DataSet1", forState: .Normal)
            self.dataSet2 = UIButton()
            self.dataSet2.setTitle("DataSet2", forState: .Normal)
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
             if (sender == self.dataSet1) {
                dataSet1.setTitle("->DataSet1", forState: .Normal)
                dataSet2.setTitle("DataSet2", forState: .Normal)
                controller!.fileName = "json"
            }else {
                dataSet1.setTitle("DataSet1", forState: .Normal)
                dataSet2.setTitle("->DataSet2", forState: .Normal)
                controller!.fileName = "xyjson"
            }
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
    
    
    class Point1Selector: UIView {
        
        let mmo: UIButton
        let mml: UIButton
        weak var controller: BandedViewController?
        private let buttonDirs: [UIButton : Bool]
        init(frame: CGRect, controller: BandedViewController) {
            self.controller = controller
            self.mmo = UIButton()
            self.mmo.setTitle("Unit2", forState: .Normal)
            self.mml = UIButton()
            self.mml.setTitle("->Unit1", forState: .Normal)
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
                self.mmo.setTitle("->Unit2", forState: .Normal)
                self.mml.setTitle("Unit1", forState: .Normal)
            }else {
                controller!.mbMml = true
                self.mml.setTitle("Unit1", forState: .Normal)
                self.mmo.setTitle("->Unit2", forState: .Normal)
            }
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
