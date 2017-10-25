//
//  NSKJSONError.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 17.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

private let NSDebugDescription = "NSDebugDescription"

internal class NSKJSONError {
    
    private init() {}
    
    internal static func error(description: String) -> NSError {
        return NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
            NSDebugDescription : description])
    }
}
