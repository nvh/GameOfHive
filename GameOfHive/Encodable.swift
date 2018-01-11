//
//  Encode.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
//import Argo

//public protocol Encodable {
//    func encode() -> JSON
//}
//
////MARK: LiteralConvertible
//
//extension JSON : ExpressibleByStringLiteral {
//    public typealias UnicodeScalarLiteralType = StringLiteralType
//    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
//    public init(stringLiteral value: StringLiteralType) {
//        self =  .string(value)
//    }
//    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
//        self =  .string(value)
//    }
//    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
//        self = .string(value)
//    }
//}
//
//extension JSON : ExpressibleByIntegerLiteral {
//    public init(integerLiteral value: IntegerLiteralType) {
//        self = .number(NSNumber(value))
//    }
//}
//
//extension JSON : ExpressibleByFloatLiteral {
//    public init(floatLiteral value: FloatLiteralType) {
//        self = .number(NSNumber(value))
//        
//    }
//}
//
//extension JSON : ExpressibleByBooleanLiteral {
//    public init(booleanLiteral value: BooleanLiteralType) {
//        self = .number(value as NSNumber)
//    }
//}
//
//extension JSON : ExpressibleByDictionaryLiteral {
//    public typealias Key = Swift.String
//    public typealias Value = Encodable?
//    public init(dictionaryLiteral elements: (Key, Value)...) {
//        let dictionary = elements.reduce([:], combine: Dictionary<Key,Value>.combine)
//        self = dictionaryEncode(dictionary)
//    }
//}
//
//extension JSON : ExpressibleByArrayLiteral {
//    public typealias Element = Encodable
//    public init(arrayLiteral elements: Element...) {
//        self = elements.encode() ?? .Null
//    }
//}
//
//extension JSON : ExpressibleByNilLiteral {
//    public init(nilLiteral: ()) {
//        self = .null
//    }
//}
//
//
////MARK: Standard Types
//extension JSON: Encodable {
//    public func encode() -> JSON {
//        return self
//    }
//}
//
//extension String: Encodable {
//    public func encode() -> JSON {
//        return .string(self)
//    }
//}
//
//extension Int: Encodable {
//    public func encode() -> JSON {
//        return .number(NSNumber(self))
//    }
//}
//
//extension Double: Encodable {
//    public func encode() -> JSON {
//        return .number(NSNumber(self))
//    }
//}
//
//extension Bool: Encodable {
//    public func encode() -> JSON {
//        return .number(self as NSNumber)
//    }
//}
//
//extension Float: Encodable {
//    public func encode() -> JSON {
//        return .number(NSNumber(self))
//    }
//}
//
//extension Array: Encodable {
//    public func encode() -> JSON {
//        let encodables: [Encodable] = self.map{ ($0 as? Encodable) ?? JSON.null }
//        return .array(encodables.map {$0.encode()})
//    }
//}
//
//extension Dictionary: Encodable {
//    public func encode() -> JSON {
//        guard Key.self == String.self else {
//            return .null
//        }
//        var result: [String:JSON] = [:]
//        for (key,value) in self {
//            result[String(key)] = (value as? Encodable)?.encode() ?? .Null
//        }
//        return .object(result)
//    }
//}
//
//func dictionaryEncode(_ dict: Dictionary<String,Encodable?>?) -> JSON {
//    if dict == nil {
//        return .null
//    }
//    
//    let result: [String : JSON] = dict!.mapValues { value in
//        return value?.encode() ?? .Null
//    }
//    
//    return .object(result)
//}
//
////MARK: Helper function
//extension JSON {
//    public func filterJSONNull() -> JSON {
//        switch self {
//        case let .Object(o):
//            var dict: [Swift.string : JSON] = [:]
//            for (key,value) in o {
//                if value != .Null {
//                    dict[key] = value.filterJSONNull()
//                }
//            }
//            return .Object(dict)
//        case let .Array(a):
//            let filtered = a.filter({ (e:JSON) in e != .Null})
//            let mapped = filtered.map({$0.filterJSONNull()})
//            return .Array(mapped)
//        default:
//            return self
//        }
//    }
//}
