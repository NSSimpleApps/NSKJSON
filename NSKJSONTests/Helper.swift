//
//  Helpers.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 06.05.17.
//
//

import Foundation

class Helper {
    
    static func directoryPath(forName name: String) -> String {
        
        //return Bundle(for: type(of: self)).resourcePath!.appending("/" + name)
        return Bundle(for: self).resourcePath!.appending("/" + name)
    }

    static func jsonFiles(in directory: String, withPrefix prefix: String) throws -> [String] {
        
        let path = self.directoryPath(forName: directory)
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        
        return files.flatMap { (file) -> String? in
            
            if file.hasSuffix("json") && file.hasPrefix(prefix) {
                
                return path + "/" + file
                
            } else {
                
                return nil
            }
        }
    }
}
