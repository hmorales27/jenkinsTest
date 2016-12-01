//
//  DeviceType.swift
//  JAT
//
//  Created by Sharkey, Justin (ELS-CON) on 7/11/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

extension UIUserInterfaceIdiom {
    
    func stringValue() -> String {
        switch self {
        case .pad:
            return "ipad"
        case .phone:
            return "iphone"
        case .tv:
            return "tv"
        case .unspecified:
            return "unspecified"
        case .carPlay:
            return "carplay"
        }
    }
}
