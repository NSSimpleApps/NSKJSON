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
    
    func testCorrectPlainFormat() {
        
        let files = try! Helper.jsonFiles(in: "test_plain_parsing", withPrefix: "y_")
        
        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent
            
            print("SHOULD HAVE PASS TEST: \(file)")
            
            do {
                
                let val = try NSKJSON.jsonObject(with: data, version: .json5)
                print(val)
                
            } catch {
                
                XCTFail("!!!! FAILED AT \(file), \(error)")
            }
        }
    }
    
    func testCorrectJSON5Format() {
        
        let files = try! Helper.jsonFiles(in: "test_json5_parsing", withPrefix: "y_")
        
        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent
            
            print("SHOULD HAVE PASS TEST: \(file)")
            
            do {
                
                let val = try NSKJSON.jsonObject(with: data, version: .json5)
                print(val)
                
            } catch {
                
                XCTFail("!!!! FAILED AT \(file), \(error)")
            }
        }
    }
    
    func testIncorrectFormat() {
        
        let files = try! Helper.jsonFiles(in: "test_json5_parsing", withPrefix: "n_")

        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent

            print("SHOULD HAVE FAILED \(fileName)")
            
            XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .json5), "!!!! FAILED AT \(file)", { (error) in
                
                print(error)
            })
        }
    }
    
    func testUndefinedJSON5Format() {
        
        let files = try! Helper.jsonFiles(in: "test_json5_parsing", withPrefix: "i_")
        
        for fileName in files {
            
            let url = URL(fileURLWithPath: fileName)
            let data = try! Data(contentsOf: url)
            let file = (fileName as NSString).lastPathComponent

            print("SHOULD HAVE FAILED \(file)")
            
            XCTAssertThrowsError(try NSKJSON.jsonObject(with: data, version: .json5), "!!!! FAILED AT \(file)", { (error) in
                
                print(error)
            })
        }
    }
}
