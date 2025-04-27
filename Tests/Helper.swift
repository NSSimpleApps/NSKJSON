//
//  Helpers.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 06.05.17.
//
//

import Foundation

class Helper {
    struct DataInfo {
        let fileName: String
        let data: Data
    }
    struct StringInfo {
        let fileName: String
        let string: String
    }
    private init() {}
    
    static func directoryPath(forName name: String) -> String {
        return Bundle(for: self).resourcePath!.appending("/" + name)
    }
    
    static func data(in directory: String, withPrefix prefix: String, encoding: String.Encoding) throws -> [DataInfo] {
        return try self.string(in: directory, withPrefix: prefix).map({ (stringInfo) -> DataInfo in
            let fileName = stringInfo.fileName
            if let data = stringInfo.string.data(using: encoding) {
                return DataInfo(fileName: fileName, data: data)
                
            } else {
                throw NSError(domain: "ERROR", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert file: \(fileName) to encoding: \(encoding)."])
            }
        })
    }
    
    static func string(in directory: String, withPrefix prefix: String) throws -> [StringInfo] {
        let path = self.directoryPath(forName: directory + "/utf8")
        
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        
        return try files.compactMap({ (file) -> String? in
            if file.hasPrefix(prefix) {
                return path + "/" + file
                
            } else {
                return nil
            }
        }).map({ (fileName) -> StringInfo in
            let url = URL(fileURLWithPath: fileName)
            let str = try String(contentsOf: url)
            let fileName = (fileName as NSString).lastPathComponent
            
            return StringInfo(fileName: fileName, string: str)
        })
    }
}
