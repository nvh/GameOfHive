//
//  Template.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit
//import Argo



struct Template: Persistable {
    let identifier: String
    let title: String
    let date: Date
    let gridPath: String
    let imagePath: String
    
    var image: UIImage? {
        return UIImage(contentsOfFile: imagePath)
    }
    
    func grid() throws -> HexagonGrid  {
        return try HexagonGrid.load(gridPath)
    }
}

//extension Template: Decodable {
//    static var curriedInit: (String) -> (String) -> (Date) -> (String) -> (String) -> Template = { identifier in
//        return { title in
//            return { date in
//                return { gridPath in
//                    return { imagePath in
//                        return Template(
//                            identifier: identifier,
//                            title: title,
//                            date: date,
//                            gridPath: gridPath,
//                            imagePath: imagePath)
//                    }
//                }
//            }
//        }
//    }
//    
//    static func decode(_ json: JSON) -> Decoded<Template> {
//        return curriedInit  <^> json <| "identifier"
//            <*> json <| "title"
//            <*> json <| "date"
//            <*> (json <| "gridPath").map(documentsDirectory.stringByAppendingPathComponent)
//            <*> (json <| "imagePath").map(documentsDirectory.stringByAppendingPathComponent)
//    }
//}
//
//extension Template: Encodable {
//    func encode() -> JSON {
//        let relativeGridPath = gridPath.replacingOccurrences(of: documentsDirectory as String, with: "")
//        let relativeImagePath = imagePath.replacingOccurrences(of: documentsDirectory as String, with: "")        
//        return ["identifier":identifier, "title":title, "date":date, "gridPath":relativeGridPath, "imagePath":relativeImagePath]
//    }
//}
