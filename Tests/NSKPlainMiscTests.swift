//
//  NSKMiscTests.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 12.04.17.
//
//

import XCTest
@testable import NSKJSON

class NSKPlainMiscTests: XCTestCase {
    
    func testMisc() {
        let data = "11".data(using: .utf8)!
        
        do {
            let obj = try NSKJSON.jsonObject(with: data, version: .json5)
            print("####", obj)
        } catch {
            print(error)
        }
    }
}
