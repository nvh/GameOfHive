//
//  NSDate.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
//import Argo

//extension Date : Decodable {
//    public static func decode(_ json: JSON) -> Decoded<NSDate> {
//        switch(json) {
//        case .Number(let number):
//            let date = Date(timeIntervalSince1970: number.doubleValue)
//            return pure(date)
//        case .String(let string):
//            if let date = ISO8601.parse(string) {
//                return pure(date)
//            } else {
//                return .Failure(.TypeMismatch(expected: "ISO8601 formatted String", actual: string))
//            }
//        default:
//            return .failure(.typeMismatch(expected: "String or Number", actual: json.description))
//        }
//    }
//}
//
//extension Date : Encodable {
//    public func encode() -> JSON {
//        if let string = ISO8601.format(self) {
//            return .string(string)
//        } else {
//            return .null
//        }
//    }
//}
//
//extension Date {
//    var iso8601 : String? {
//        return ISO8601.format(self)
//    }
//    init?(iso8601: String) {
//        if let date = ISO8601.parse(iso8601) {
//            (self as NSDate).init(timeIntervalSinceNow: date.timeIntervalSinceNow)
//            return
//        }
//        (self as NSDate).init()
//        return nil
//    }
//}
