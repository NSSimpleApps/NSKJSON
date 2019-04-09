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
    
    func testCorrectPlainFormat_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_plain_parsing", withPrefix: "y_", encoding: encoding)
                
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
    func testCorrectPlainFormat_string() {
        do {
            let infos = try Helper.string(in: "test_plain_parsing", withPrefix: "y_")
            
            for info in infos {
                let fileName = info.fileName
                print("SHOULD HAVE PASS TEST: \(fileName)")
                do {
                    let json = try NSKJSON.jsonObject(fromString: info.string, version: .plain)
                    print(json)
                } catch {
                    XCTFail("!!!! FAILED AT \(fileName), \(error)")
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    /////////////////////////////////////////////////////////////////////////////
    func testIncorrectPlainFormat_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_plain_parsing", withPrefix: "n_", encoding: encoding)
                
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
    func testIncorrectPlainFormat_string() {
        do {
            let infos = try Helper.string(in: "test_plain_parsing", withPrefix: "n_")
            
            for info in infos {
                let fileName = info.fileName
                print("SHOULD HAVE FAILED \(fileName)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(fromString: info.string, version: .plain), "!!!! FAILED AT \(fileName)", { (error) in
                    
                })
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    /////////////////////////////////////////////////////////////////////////////
    func testUndefinedPlainFormat_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_plain_parsing", withPrefix: "i_", encoding: encoding)
                
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
    func testUndefinedPlainFormat_string() {
        do {
            let infos = try Helper.string(in: "test_plain_parsing", withPrefix: "i_")
            
            for info in infos {
                let fileName = info.fileName
                print("UNDEFINED FORMAT TEST: \(fileName)")
                
                do {
                    let json = try NSKJSON.jsonObject(fromString: info.string, version: .plain)
                    print(json)
                    
                } catch {
                    XCTFail("!!!! FAILED AT \(fileName), \(error)")
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
}
