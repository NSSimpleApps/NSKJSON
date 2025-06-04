//
//  TestComments.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 09.05.17.
//
//

import XCTest
@testable import NSKJSON

let numbersOfLines = ["comment0.json": 0,
                      "comment1.json": 5,
                      "comment2.json": 0,
                      "comment3.json": 6,
                      "comment4.json": 17,
                      "comment5.json": 0]

class NSKCommentTests: XCTestCase {
    
    func testComments() {
        do {
            let infos = try Helper.data(in: "comments", withPrefix: "c", encoding: .utf8)
            
            for info in infos {
                let fileName = info.fileName
                print("TESTING", fileName)
                let result = try NSKOptionsUTF8.buffer(data: info.data.dropLast(1), offset: 0, isBigEndian: isBigEndian,
                                                            block: { (result) -> (index: NSKOptionsUTF8.Index, numberOfLines: Int) in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5Parser<NSKOptionsUTF8>.skipWhiteSpacesWithLines(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                    
                })
                let lines = result.numberOfLines
                print(fileName, ":", lines)
                XCTAssertEqual(lines, numbersOfLines[fileName]!)
            }
        } catch {
            XCTFail("!!!! FAILED AT \(error)")
        }
    }
}
