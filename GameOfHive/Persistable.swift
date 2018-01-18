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

protocol Saveable: Encodable {
    func save(_ url: URL) throws
}

extension Saveable {
    func save(_ url: URL) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        try data.write(to: url, options: .atomic)
    }
}

protocol Loadable: Decodable {
    static func load(_ url: URL) throws -> Self
}

extension Loadable {
    static var urlKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "Loadable.URL")!
    }
    static func load(_ url: URL) throws -> Self {
        guard let data = try? Data(contentsOf: url) else {
            throw LoadError.fileDoesNotExist
        }

        let decoder = JSONDecoder()
        decoder.userInfo[urlKey] = url
        do {
            let value = try decoder.decode(self.self, from: data)
            return value
        } catch let error {
            throw LoadError.decodeFailed(error: error)
        }
    }
}
