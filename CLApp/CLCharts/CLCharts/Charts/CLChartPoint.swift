//
//  ChartPoint.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//


import UIKit

public class ChartPoint: Equatable {
    
    public let x: CLAxisValue
    public let y: CLAxisValue
    
    required public init(x: CLAxisValue, y: CLAxisValue) {
        self.x = x
        self.y = y
    }
    
    public var text: String {
        return "\(self.x.text), \(self.y.text)"
    }
}

public func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public class CLPointBubble: ChartPoint {
    public let diameterScalar: Double
    public let bgColor: UIColor
    public let borderColor: UIColor
    
    public init(x: CLAxisValue, y: CLAxisValue, diameterScalar: Double, bgColor: UIColor, borderColor: UIColor = UIColor.blackColor()) {
        self.diameterScalar = diameterScalar
        self.bgColor = bgColor
        self.borderColor = borderColor
        super.init(x: x, y: y)
    }
    
    public init(point:ChartPoint, diameterScalar: Double = 0.0, bgColor: UIColor = UIColor.blackColor(), borderColor: UIColor = UIColor.blackColor()) {
        self.diameterScalar = diameterScalar
        self.bgColor = bgColor
        self.borderColor = borderColor
        super.init(x: point.x, y: point.y)
    }
    required public init(x: CLAxisValue, y: CLAxisValue) {
        fatalError("init(x:y:) has not been implemented")
    }
}

public class CLPointCandleStick: ChartPoint {
    
    public let date: NSDate
    public let open: Double
    public let close: Double
    public let low: Double
    public let high: Double
    
    public init(date: NSDate, formatter: NSDateFormatter, high: Double, low: Double, open: Double, close: Double, labelHidden: Bool = false) {
        
        let x = CLAxisValueDate(date: date, formatter: formatter)
        self.date = date
        x.hidden = labelHidden
        
        let highY = CLAxisValueDouble(high)
        self.high = high
        self.low = low
        self.open = open
        self.close = close
        
        super.init(x: x, y: highY)
    }
    
    required public init(x: CLAxisValue, y: CLAxisValue) {
        fatalError("init(x:y:) has not been implemented")
    }
}
