//
//  TestComments.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 09.05.17.
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
            let file = (fileName as NSString).lastPathComponent
            print("TESTING: \(file)")
            
            do {
                
                let options = NSKOptions(encoding: .utf8, trailingComma: true, transformer: { $0 })
                
                let (_, _, numberOfLines) = try NSKJSON5Parser(options: options).skipWhiteSpaces(buffer: data, from: 0)
                
                XCTAssertEqual(numberOfLines, numbersOfLines[index])
                
            } catch {
                
                XCTFail("!!!! FAILED AT \(file), \(error)")
            }
        }
    }
}
