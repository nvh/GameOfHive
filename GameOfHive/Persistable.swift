//
//  Persistable.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
//import Argo

enum LoadError: Error {
    case fileDoesNotExist
    case decodeFailed(error: Error)
}

protocol Persistable: Saveable , Loadable { }

protocol Saveable {
    func save(_ path: String) throws
}

extension Saveable /*where Self:Encodable*/ {
    func save(_ path: String) throws {
//        try self.encode().toJSONString.writeToFile(path, atomically: true, encoding: String.Encoding.utf8)
    }
}

protocol Loadable {
    static func load(_ path: String) throws -> Self
}

extension Loadable /*where Self:Decodable*/ {
    static func load(_ path: String) throws -> Self {
        throw LoadError.fileDoesNotExist
//        guard let data = NSData(contentsOfFile: path) else {
//            throw LoadError.fileDoesNotExist
//        }

//        let object = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
//        let json = JSON.parse(object)
//        let decoded: Decoded<Self.DecodedType> = self.decode(json)
//
//        switch decoded {
//        case .Success(let value):
//            return value
//        case .Failure(let error):
//            throw LoadError.DecodeFailed(error: error)
//
//        }
    }
}
