//
//  CLAxisValuesString.swift
//  CLCharts
//
//  Created by Rajesh Mudaliyar on 11/09/15.
//  Copyright © 2015 Rajesh Mudaliyar. All rights reserved.
//

import UIKit

public class CLAxisValue: Equatable {
    
    public var scalar: Double
    
    public var text: String {
        fatalError("Override")
    }
    
    /**
     Labels that will be displayed on the chart. How this is done depends on the implementation of CLAxisLayer.
     In the most common case this will be an array with only one element.
     */
    public var labels: [CLAxisLabel] {
        fatalError("Override")
    }
    
    public var hidden: Bool = false {
        didSet {
            for label in self.labels {
                label.hidden = self.hidden
            }
        }
    }
    
    public init(scalar: Double) {
        self.scalar = scalar
    }
    
    public var copy: CLAxisValue {
        return self.copy(self.scalar)
    }
    
    public func copy(scalar: Double) -> CLAxisValue {
        return CLAxisValue(scalar: self.scalar)
    }
    
    public func divideBy(dev:Int) {
        scalar = scalar/Double(dev)
    }
}

public func ==(lhs: CLAxisValue, rhs: CLAxisValue) -> Bool {
    return lhs.scalar == rhs.scalar
}
public func +=(lhs: CLAxisValue, rhs: CLAxisValue) -> CLAxisValue {
    lhs.scalar += rhs.scalar
    return lhs
}
public func <=(lhs: CLAxisValue, rhs: CLAxisValue) -> Bool {
    return lhs.scalar <= rhs.scalar
}

public func >(lhs: CLAxisValue, rhs: CLAxisValue) -> Bool {
    return lhs.scalar > rhs.scalar
}

public class CLAxisValueDate: CLAxisValue {
    
    private let formatter: NSDateFormatter
    private let labelSettings: CLLabelSettings
    
    public var date: NSDate {
        return CLAxisValueDate.dateFromScalar(self.scalar)
    }
    
    public init(date: NSDate, formatter: NSDateFormatter, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: CLAxisValueDate.scalarFromDate(date))
    }
    
    override public var labels: [CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.formatter.stringFromDate(self.date), settings: self.labelSettings)
        axisLabel.hidden = self.hidden
        return [axisLabel]
    }
    
    public class func dateFromScalar(scalar: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(scalar))
    }
    
    public class func scalarFromDate(date: NSDate) -> Double {
        return Double(date.timeIntervalSince1970)
    }
}

public class CLAxisValueDouble: CLAxisValue {
    
    public let formatter: NSNumberFormatter
    let labelSettings: CLLabelSettings
    
    override public var text: String {
        return self.formatter.stringFromNumber(self.scalar)!
    }
    
    public convenience init(_ int: Int, formatter: NSNumberFormatter = CLAxisValueDouble.defaultFormatter, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.init(Double(int), formatter: formatter, labelSettings: labelSettings)
    }
    
    public init(_ double: Double, formatter: NSNumberFormatter = CLAxisValueDouble.defaultFormatter, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: double)
    }
    
    override public var labels: [CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    
    override public func copy(scalar: Double) -> CLAxisValueDouble {
        return CLAxisValueDouble(scalar, formatter: self.formatter, labelSettings: self.labelSettings)
    }
    
    static var defaultFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

public class CLAxisValueDoubleScreenLoc: CLAxisValueDouble {
    
    private let actualDouble: Double
    
    var screenLocDouble: Double {
        return self.scalar
    }
    
    override public var text: String {
        return self.formatter.stringFromNumber(self.actualDouble)!
    }
    
    // screenLocFloat: model value which will be used to calculate screen position
    // actualFloat: scalar which this axis value really represents
    public init(screenLocDouble: Double, actualDouble: Double, formatter: NSNumberFormatter = CLAxisValueFloat.defaultFormatter, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.actualDouble = actualDouble
        super.init(screenLocDouble, formatter: formatter, labelSettings: labelSettings)
    }
    
    override public var labels: [CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
}

public class CLAxisValueFloat: CLAxisValue {
    
    public let formatter: NSNumberFormatter
    let labelSettings: CLLabelSettings
    
    public var float: CGFloat {
        return CGFloat(self.scalar)
    }
    
    override public var text: String {
        return self.formatter.stringFromNumber(self.float)!
    }
    
    public init(_ float: CGFloat, formatter: NSNumberFormatter = CLAxisValueFloat.defaultFormatter, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: Double(float))
    }
    
    override public var labels: [CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    
    override public func copy(scalar: Double) -> CLAxisValueFloat {
        return CLAxisValueFloat(CGFloat(scalar), formatter: self.formatter, labelSettings: self.labelSettings)
    }
    
    static var defaultFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

@available(*, deprecated=0.2.5, message="use CLAxisValueDoubleScreenLoc instead")
public class CLAxisValueFloatScreenLoc: CLAxisValueFloat {
    
    private let actualFloat: CGFloat
    
    var screenLocFloat: CGFloat {
        return CGFloat(self.scalar)
    }
    
    override public var text: String {
        return self.formatter.stringFromNumber(self.actualFloat)!
    }
    
    // screenLocFloat: model value which will be used to calculate screen position
    // actualFloat: scalar which this axis value really represents
    public init(screenLocFloat: CGFloat, actualFloat: CGFloat, formatter: NSNumberFormatter = CLAxisValueFloat.defaultFormatter, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.actualFloat = actualFloat
        super.init(screenLocFloat, formatter: formatter, labelSettings: labelSettings)
    }
    
    override public var labels: [CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
}

public class CLAxisValueInt: CLAxisValue {
    
    public let int: Int
    private let labelSettings: CLLabelSettings
    
    override public var text: String {
        return "\(self.int)"
    }
    
    public init(_ int: Int, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.int = int
        self.labelSettings = labelSettings
        super.init(scalar: Double(int))
    }
    
    override public var labels:[CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    override public func copy(scalar: Double) -> CLAxisValueInt {
        return CLAxisValueInt(self.int, labelSettings: self.labelSettings)
    }
}

public class CLAxisValueString: CLAxisValue {
   
    let string: String
    private let labelSettings: CLLabelSettings
    
    public init(_ string: String = "", order: Int, labelSettings: CLLabelSettings = CLLabelSettings()) {
        self.string = string
        self.labelSettings = labelSettings
        super.init(scalar: Double(order))
    }
    
    override public var labels: [CLAxisLabel] {
        let axisLabel = CLAxisLabel(text: self.string, settings: self.labelSettings)
        return [axisLabel]
    }
}
