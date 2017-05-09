//
//  NSKJSONTests.swift
//  NSKJSONTests
//
//  Created by NSSimpleApps on 19.03.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import XCTest
@testable import NSKJSON

class NSKJSONTests: XCTestCase {
    
    func testCorrectPlainFormat() {
        
        let files = try! Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "y_")
        
        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent

            print("SHOULD HAVE PASS TEST: \(file)")
            
            do {
                
                let val = try NSKJSON.jsonObject(with: data, version: .plain)
                print(val)
                
            } catch {
                
                XCTFail("!!!! FAILED AT \(file), \(error)")
            }
        }
    }
    
    func testIncorrectPlainFormat() {
        
        let files = try! Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "n_")
        
        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent

            print("SHOULD HAVE FAILED \(file)")
            
            XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .plain), "!!!! FAILED AT \(file)", { (error) in
                
                print(error)
            })
        }
    }
    
    func testUndefinedPlainFormat() {
        
        let files = try! Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "i_")
        
        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent

            print("SHOULD HAVE PASS TEST: \(file)")
            
            do {
                
                let val = try NSKJSON.jsonObject(with: data, version: .plain)
                print(val)
                
            } catch {
                
                XCTFail("!!!! FAILED AT \(file), \(error)")
            }
        }
    }
}
