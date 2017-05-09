//
//  TestComments.swift
//  NSKJSON
//
//  Created by neo on 09.05.17.
//
//

import XCTest
@testable import NSKJSON

class NSKCommentTests: XCTestCase {
    
    func testComments() {
        
        let numbersOfLines = [0, 5, 0, 6, 17, 0]
        
        let files = try! Helper.jsonFiles(in: "comments", withPrefix: "c")
        
        for (index, fileName) in files.enumerated() {
                
            let url = URL(fileURLWithPath: fileName)
            let data = Data((try! Data(contentsOf: url)).dropLast())
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            let file = (fileName as NSString).lastPathComponent
            print("Testing: \(file)")
            
            do {
                
                let (_, _, numberOfLines) = try NSKJSON5Parser(options: NSKOptions(encoding: .utf8)).skipWhiteSpaces(buffer: buffer, from: 0)
                
                XCTAssertEqual(numberOfLines, numbersOfLines[index])
                
            } catch {
                
                XCTFail("!!!! FAILED AT \(file), \(error)")
            }
        }
    }
}
