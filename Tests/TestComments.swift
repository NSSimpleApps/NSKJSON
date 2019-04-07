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
        let numbersOfLines = ["comment0.json": 0,
                              "comment1.json": 5,
                              "comment2.json": 0,
                              "comment3.json": 6,
                              "comment4.json": 17,
                              "comment5.json": 0]
        
        do {
            let infos = try Helper.jsonFiles(in: "comments", withPrefix: "c", encoding: .utf8)
            
            for info in infos {
                let fileName = info.fileName
                print("TESTING", fileName)
                let result = try NSKJSON.OptionsUTF8.buffer(data: info.data.dropLast(1), offset: 0, isBigEndian: isBigEndian,
                                           block: { (result) -> (index: NSKJSON.OptionsUTF8.Index, numberOfLines: Int) in
                                            switch result {
                                            case .success(let buffer):
                                                return try NSKJSON5Parser<NSKJSON.OptionsUTF8>.skipWhiteSpacesWithLines(buffer: buffer, from: 0)
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
        
        
//        for (index, fileName) in files.enumerated() {
//
//            let url = URL(fileURLWithPath: fileName)
//            let data = Data((try! Data(contentsOf: url)).dropLast())
//            let file = (fileName as NSString).lastPathComponent
//            print("TESTING: \(file)")
//
//            do {
//
//                let options = NSKOptions(encoding: .utf8, trailingComma: true, transformer: { $0 })
//
//                let (_, _, numberOfLines) = try NSKJSON5Parser(options: options).skipWhiteSpaces(buffer: data, from: 0)
//
//                XCTAssertEqual(numberOfLines, numbersOfLines[index])
//
//            } catch {
//
//                XCTFail("!!!! FAILED AT \(file), \(error)")
//            }
//        }
    }
}
