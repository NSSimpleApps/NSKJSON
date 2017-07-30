//
//  NSKJSON5Tests.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 01.05.17.
//
//


import XCTest
@testable import NSKJSON

class NSKJSON5Tests: XCTestCase {
    
    func testCorrectJSON5Test() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "json5-tests/\(encoding)", withPrefix: "y_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE PASS TEST: \(file), \(encoding)")
                
                do {
                    
                    let json = try NSKJSON.jsonObject(with: data, version: .json5)
                    print(json)
                    
                } catch {
                    
                    XCTFail("!!!! FAILED AT \(file), \(encoding), \(error)")
                }
            }
        }
    }
    
    func testIncorrectJSON5Test() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "json5-tests/\(encoding)", withPrefix: "n_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE FAILED \(file), \(encoding)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .json5), "!!!! FAILED AT \(file), \(encoding)", { (error) in
                    
                    print(error)
                })
            }
        }
    }
    
    func testCorrectPlainFormat() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_plain_parsing/\(encoding)", withPrefix: "y_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE PASS TEST: \(file), \(encoding)")
                
                do {
                    
                    let json = try NSKJSON.jsonObject(with: data, version: .json5)
                    print(json)
                    
                } catch {
                    
                    XCTFail("!!!! FAILED AT \(file), \(error), \(encoding)")
                }
            }
        }
    }
    
    func testCorrectJSON5Format() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_json5_parsing/\(encoding)", withPrefix: "y_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE PASS TEST: \(file), \(encoding)")
                
                do {
                    
                    let json = try NSKJSON.jsonObject(with: data, version: .json5)
                    print(json)
                    
                } catch {
                    
                    XCTFail("!!!! FAILED AT \(file), \(error), \(encoding)")
                }
            }
        }
    }
    
    func testIncorrectFormat() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_json5_parsing/\(encoding)", withPrefix: "n_")
            
            for fileName in files{
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE FAILED: \(file), \(encoding)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .json5), "!!!! FAILED AT \(file), \(encoding)", { (error) in
                    
                    print(error)
                })
            }
        }
    }
    
    func testUndefinedJSON5Format() {
        
        for encoding in encodings {
            
            let files = try! Helper.jsonFiles(in: "test_json5_parsing/\(encoding)", withPrefix: "i_")
            
            for fileName in files {
                
                let url = URL(fileURLWithPath: fileName)
                let data = try! Data(contentsOf: url)
                let file = (fileName as NSString).lastPathComponent
                
                print("SHOULD HAVE FAILED \(file)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .json5), "!!!! FAILED AT \(file), \(encoding)", { (error) in
                    
                    print(error)
                })
            }
        }
    }
}
