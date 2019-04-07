//
//  Helpers.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 06.05.17.
//
//

import Foundation

class Helper {
    struct Info {
        let fileName: String
        let data: Data
    }
    private init() {}
    
    static func directoryPath(forName name: String) -> String {
        return Bundle(for: self).resourcePath!.appending("/" + name)
    }

    static func jsonFiles(in directory: String, withPrefix prefix: String, encoding: String.Encoding) throws -> [Info] {
        let path = self.directoryPath(forName: directory + "/utf8")
        
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        
        return try files.compactMap({ (file) -> String? in
            if file.hasPrefix(prefix) {
                return path + "/" + file
                
            } else {
                return nil
            }
        }).map({ (fileName) -> Info in
            let url = URL(fileURLWithPath: fileName)
            let str = try String(contentsOf: url)
            let fileName = (fileName as NSString).lastPathComponent
            
            if let data = str.data(using: encoding) {
                return Info(fileName: fileName, data: data)
                
            } else {
                throw NSError(domain: "ERROR", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert file: \(fileName) to encoding: \(encoding)."])
            }
        })
    }
}
