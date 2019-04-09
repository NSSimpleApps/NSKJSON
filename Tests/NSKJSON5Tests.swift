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
    
    func testCorrectPlainFormat_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_plain_parsing", withPrefix: "y_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE PASS TEST: \(fileName), \(encoding)")
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .json5)
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
                    let json = try NSKJSON.jsonObject(fromString: info.string, version: .json5)
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
                    
                    XCTAssertThrowsError(try NSKJSON.jsonObject(with: info.data, version: .json5), "!!!! FAILED AT \(fileName), \(encoding)", { (error) in
                        
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
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(fromString: info.string, version: .json5), "!!!! FAILED AT \(fileName)", { (error) in
                    
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
                        let json = try NSKJSON.jsonObject(with: info.data, version: .json5)
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
                    let json = try NSKJSON.jsonObject(fromString: info.string, version: .json5)
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
    func testCorrectJSON5Format1_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "json5-tests", withPrefix: "y_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE PASS TEST: \(fileName), \(encoding)")
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .json5)
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
    func testCorrectJSON5Format1_string() {
        do {
            let infos = try Helper.string(in: "json5-tests", withPrefix: "y_")
            
            for info in infos {
                let fileName = info.fileName
                print("SHOULD HAVE PASS TEST: \(fileName)")
                do {
                    let json = try NSKJSON.jsonObject(fromString: info.string, version: .json5)
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
    func testIncorrectJSON5Format1_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "json5-tests", withPrefix: "n_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE FAILED \(fileName), \(encoding)")
                    
                    XCTAssertThrowsError(try NSKJSON.jsonObject(with: info.data, version: .json5), "!!!! FAILED AT \(fileName), \(encoding)", { (error) in
                        
                    })
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    func testIncorrectJSON5Format1_string() {
        do {
            let infos = try Helper.string(in: "json5-tests", withPrefix: "n_")
            
            for info in infos {
                let fileName = info.fileName
                print("SHOULD HAVE FAILED \(fileName)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(fromString: info.string, version: .json5), "!!!! FAILED AT \(fileName)", { (error) in
                    
                })
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    /////////////////////////////////////////////////////////////////////////////
    func testCorrectJSON5Format2_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_json5_parsing", withPrefix: "y_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE PASS TEST: \(fileName), \(encoding)")
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .json5)
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
    func testCorrectJSON5Format2_string() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_json5_parsing", withPrefix: "y_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE PASS TEST: \(fileName), \(encoding)")
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .json5)
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
    /////////////////////////////////////////////////////////////////////////////
    func testIncorrectJSON5Format2_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_json5_parsing", withPrefix: "n_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("SHOULD HAVE FAILED \(fileName), \(encoding)")
                    
                    XCTAssertThrowsError(try NSKJSON.jsonObject(with: info.data, version: .json5), "!!!! FAILED AT \(fileName), \(encoding)", { (error) in
                        
                    })
                }
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    func testIncorrectJSON5Format2_string() {
        do {
            let infos = try Helper.string(in: "test_json5_parsing", withPrefix: "n_")
            
            for info in infos {
                let fileName = info.fileName
                print("SHOULD HAVE FAILED \(fileName)")
                
                XCTAssertThrowsError(try NSKJSON.jsonObject(fromString: info.string, version: .json5), "!!!! FAILED AT \(fileName)", { (error) in
                    
                })
            }
        } catch {
            print("FILE ERROR: \(error.localizedDescription)")
        }
    }
    /////////////////////////////////////////////////////////////////////////////
    func testUndefinedJSON5Format2_data() {
        do {
            for encoding in encodings {
                let infos = try Helper.data(in: "test_json5_parsing", withPrefix: "i_", encoding: encoding)
                
                for info in infos {
                    let fileName = info.fileName
                    print("UNDEFINED FORMAT TEST: \(fileName), \(encoding)")
                    
                    do {
                        let json = try NSKJSON.jsonObject(with: info.data, version: .json5)
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
    func testUndefinedJSON5Format2_string() {
        do {
            let infos = try Helper.string(in: "test_json5_parsing", withPrefix: "i_")
            
            for info in infos {
                let fileName = info.fileName
                print("UNDEFINED FORMAT TEST: \(fileName)")
                
                do {
                    let json = try NSKJSON.jsonObject(fromString: info.string, version: .json5)
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
