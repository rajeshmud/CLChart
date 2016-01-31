
import UIKit
import CLCharts

class Env {
    
    static var iPad: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
}

struct CLDefaults {
    
    static var chartSettings: CLSettings {
        if Env.iPad {
            return self.iPadCLSettings
        } else {
            return self.iPhoneCLSettings
        }
    }

    private static var iPadCLSettings: CLSettings {
        let chartSettings = CLSettings()
        chartSettings.leading = 20
        chartSettings.top = 20
        chartSettings.trailing = 20
        chartSettings.bottom = 20
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        return chartSettings
    }
    
    private static var iPhoneCLSettings: CLSettings {
        let chartSettings = CLSettings()
        chartSettings.leading = 10
        chartSettings.top = 50
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        return chartSettings
    }
    
    static func chartFrame(containerBounds: CGRect) -> CGRect {
        return CGRectMake(0, 110, containerBounds.size.width, containerBounds.size.height - 150)
    }
    
    static var labelSettings: CLLabelSettings {
        return CLLabelSettings(font: CLDefaults.labelFont)
    }
    
    static var labelFont: UIFont {
        return CLDefaults.fontWithSize(Env.iPad ? 14 : 11)
    }
    
    static var labelFontSmall: UIFont {
        return CLDefaults.fontWithSize(Env.iPad ? 12 : 10)
    }
    
    static func fontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size) ?? UIFont.systemFontOfSize(size)
    }
    
    static var guidelinesWidth: CGFloat {
        return Env.iPad ? 0.5 : 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return Env.iPad ? 10 : 5
    }
}
