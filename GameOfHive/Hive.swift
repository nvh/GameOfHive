//
//  Hive.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit
//import Argo



struct Hive: Persistable {
    let identifier: String
    let title: String
    let date: Date
    let gridURL: URL
    let imageURL: URL
    
    var image: UIImage? {
        return UIImage(contentsOfFile: imageURL.path)
    }
    
    func grid() throws -> HexagonGrid  {
        return try HexagonGrid.load(gridURL)
    }

    init(identifier: String, title: String, date: Date, gridURL: URL, imageURL: URL) {
        self.identifier = identifier
        self.title = title
        self.date = date
        self.gridURL = gridURL
        self.imageURL = imageURL
    }

    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case date
        case gridPath
        case imagePath
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        title = try values.decode(String.self, forKey: .title)
        date = try values.decode(Date.self, forKey: .date)
        let gridPath = try values.decode(String.self, forKey: .gridPath)
        let imagePath = try values.decode(String.self, forKey: .imagePath)
        let url = decoder.userInfo[Hive.urlKey] as! URL
        let directory = url.deletingLastPathComponent()
        gridURL = URL(fileURLWithPath: gridPath, relativeTo: directory)
        imageURL = URL(fileURLWithPath: imagePath, relativeTo: directory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(gridURL.relativePath, forKey: .gridPath)
        try container.encode(imageURL.relativePath, forKey: .imagePath)
    }
}
