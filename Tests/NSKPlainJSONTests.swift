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
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_plain_parsing/\(encoding)", withPrefix: "y_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                if file != "y_structure_lonely_int.json" {
                    
                    continue
                }
                
                print("SHOULD HAVE PASS TEST: \(file), \(encoding)")
                
                do {
                    
                    let json = try NSKJSON.jsonObject(with: data, version: .plain)
                    print(json)
                    
                } catch {
                    
                    XCTFail("!!!! FAILED AT \(file), \(error), \(encoding)")
                }
            }
        }
    }
    
    func testIncorrectPlainFormat() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_plain_parsing/\(encoding)", withPrefix: "n_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE FAILED \(file), \(encoding)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .plain), "!!!! FAILED AT \(file), \(encoding)", { (error) in
                    
                    print(error)
                })
            }
        }
    }
    
    func testUndefinedPlainFormat() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_plain_parsing/\(encoding)", withPrefix: "i_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE PASS TEST: \(file), \(encoding)")
                
                do {
                    
                    let json = try NSKJSON.jsonObject(with: data, version: .plain)
                    print(json)
                    
                } catch {
                    
                    XCTFail("!!!! FAILED AT \(file), \(error), \(encoding)")
                }
            }
        }
    }
}
