//
//  ISO8601.swift
//  ios-nrc-nl
//
//  Created by Niels van Hoorn on 12/03/15.
//  Copyright (c) 2015 NRC Media. All rights reserved.
//

import Foundation

///Class to convert NSDate instances to and from a ISO8601 formatted string
public struct ISO8601 {
    ///A singleton NSDateformatter initialized with the ISO8601 `dateFormat`
    static var dateFormatter : DateFormatter {
        struct Singleton {
            static let instance : DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXX"
                return dateFormatter
            }()
        }
        return Singleton.instance
    }
    
    /**
     Parses a ISO8601 formatted `String` into an optional `NSDate`
     
     - parameter string: A ISO8601 formatted `String`
     - returns: The date associated with the provided string, or nil if the string doesn't conform to the correct format.
     */
    public static func parse(_ string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    /**
     Formats a ISO8601 formatted `String` into an optional `NSDate`
     
     - parameter date: An NSDate object to format
     - returns: The represented date as an ISO8601 formatted `String`
     */
    public static func format(_ date: Date) -> String? {
        return dateFormatter.string(from: date)
    }
}
