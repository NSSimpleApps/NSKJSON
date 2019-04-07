//
//  NSKJSONTests.swift
//  NSKJSONTests
//
//  Created by NSSimpleApps on 19.03.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import XCTest
@testable import NSKJSON

class NSKPlainJSONTests: XCTestCase {
    
    func testCorrectPlainFormat() {
        do {
            for encoding in encodings {
                let infos = try Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "y_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE PASS TEST: \(fileName), \(encoding)")
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .plain)
                        print(json)
                    } catch {
                        XCTFail("!!!! FAILED AT \(fileName), \(error), \(encoding)")
                    }
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    
    func testIncorrectPlainFormat() {
        do {
            for encoding in encodings {
                let infos = try Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "n_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE FAILED \(fileName), \(encoding)")
                    
                    XCTAssertThrowsError(try NSKJSON.jsonObject(with: info.data, version: .plain), "!!!! FAILED AT \(fileName), \(encoding)", { (error) in
                        
                    })
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    
    func testUndefinedPlainFormat() {
        do {
            for encoding in encodings {
                let infos = try Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "i_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("UNDEFINED FORMAT TEST: \(fileName), \(encoding)")
                    
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .plain)
                        print(json)
                        
                    } catch {
                        XCTFail("!!!! FAILED AT \(fileName), \(error), \(encoding))")
                    }
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
}
