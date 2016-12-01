/*
    UIFont + Utility
 */

import Foundation
import UIKit

enum SystemFontWeight : String {
    
    case UltraLight = "HelveticaNeue-UltraLight"
    case Thin = "HelveticaNeue-Thin"
    case Light = "HelveticaNeue-Light"
    case Regular = "HelveticaNeue"
    case Medium = "HelveticaNeue-Medium"
    case Semibold = "Helvetica-Bold"
    case Bold = "HelveticaNeue-Bold"
    case Heavy = "HelveticaNeue-CondensedBold"
    case Black = "HelveticaNeue-CondensedBlack"
    
    var weightValue:CGFloat? {
        if #available(iOS 8.2, *) {
            switch self {
            case .UltraLight:
                return UIFontWeightUltraLight
            case .Thin:
                return UIFontWeightThin
            case .Light:
                return UIFontWeightLight
            case .Regular:
                return UIFontWeightRegular
            case .Medium:
                return UIFontWeightMedium
            case .Semibold:
                return UIFontWeightSemibold
            case .Bold:
                return UIFontWeightBold
            case .Heavy:
                return UIFontWeightHeavy
            case .Black:
                return UIFontWeightBlack
            }
        } else {
            return nil
        }
    }
}

enum ItalicSystemFontWeight: String {
    case Thin = "HelveticaNeue-ThinItalic"
    case UltraLight = "HelveticaNeue-UltraLightItalic"
    case Light = "HelveticaNeue-LightItalic"
    case Regular = "HelveticaNeue-Italic"
    case Medium = "HelveticaNeue-MediumItalic"
    case Bold = "HelveticaNeue-BoldItalic"
    case CondensedBold = "HelveticaNeue-CondensedBold"
    
    var weightValue:CGFloat? {
        if #available(iOS 8.2, *) {
            switch self {
            case .UltraLight:
                return UIFontWeightUltraLight
            case .Thin:
                return UIFontWeightThin
            case .Light:
                return UIFontWeightLight
            case .Regular:
                return UIFontWeightRegular
            case .Medium:
                return UIFontWeightMedium
            case .Bold:
                return UIFontWeightBold
            case .CondensedBold:
                return UIFontWeightBold
            }
        } else {
            return nil
        }
    }
}

extension UIFont {
    
    static func systemFontOfSize(_ fontSize:CGFloat, weight: SystemFontWeight) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: fontSize, weight: weight.weightValue!)
        } else {
            return UIFont(name: weight.rawValue, size: fontSize)!
        }
    }
    
    static func italicSystemFontOfSize(_ fontSize: CGFloat, weight: ItalicSystemFontWeight) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.italicSystemFont(ofSize: fontSize)
        } else {
            return UIFont(name: weight.rawValue, size: fontSize)!
        }
    }
}
