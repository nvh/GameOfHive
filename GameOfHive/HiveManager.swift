//
//  HiveManager.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

private let savedHivesDirectory: URL = documentsDirectory.appendingPathComponent("saved", isDirectory: true)


private let lastSavedHiveIdentifierKey = "org.gameofhive.lastSavedHiveIdentifier"

private let jsonPath = "json"
private let imagesPath = "images"

private var lastSavedHiveIdentifier: String {
    return UserDefaults.standard.object(forKey: lastSavedHiveIdentifierKey)! as! String
}

class HiveManager {
    enum HiveError: Error {
        case imageFailedSaving
    }
    
    static let sharedSaved = HiveManager(directory: savedHivesDirectory)
    private let fileManager = FileManager.default
    private let directory: URL

    init(directory: URL) {
        self.directory = directory
        let jsonDirectory = directory.appendingPathComponent(jsonPath, isDirectory: true)
        let imageDirectory = directory.appendingPathComponent(imagesPath, isDirectory: true)
        createDirectory(at: jsonDirectory)
        createDirectory(at: imageDirectory)
    }
    
    fileprivate func createDirectory(at url: URL) {
        guard !fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
    
    func loadHive(_ identifier: String? = nil) throws -> Hive {
        let hiveIdentifier = identifier ?? lastSavedHiveIdentifier
        let hiveFileName = "\(hiveIdentifier).json"
        let hiveURL = URL(fileURLWithPath: hiveFileName, relativeTo: directory)
        return try Hive.load(hiveURL)
    }
    
    func save(grid: HexagonGrid, image: UIImage, title: String? = nil) throws {
        let identifier = String(grid.hashValue)
        let date = Date()
        let title = title ?? date.iso8601 ?? identifier
        
        let imagePath = URL(fileURLWithPath: "\(imagesPath)/\(identifier).png", relativeTo: directory)
        guard let imageData = UIImagePNGRepresentation(image), ((try? imageData.write(to: imagePath, options: [.atomic])) != nil) else {
            throw HiveError.imageFailedSaving
        }
        
        let gridFileName = "\(jsonPath)/\(identifier).json"
        let gridURL = URL(fileURLWithPath: gridFileName, relativeTo: directory)
        try grid.save(gridURL)
        
        let hiveFileName = "\(identifier).json"
        let hiveURL = URL(fileURLWithPath: hiveFileName, relativeTo: directory)
        let hive = Hive(identifier: identifier, title: title, date: date, gridURL: gridURL, imageURL: imagePath)
        try hive.save(hiveURL)
        
        UserDefaults.standard.set(identifier, forKey: lastSavedHiveIdentifierKey)
    }    
    
    func allHives() -> [Hive] {
        
        guard let filenames = try? FileManager.default.contentsOfDirectory(atPath: directory.path) else {
            return []
        }
        let paths = filenames.filter { $0.hasSuffix(".json") }.map(directory.appendingPathComponent)
        return paths.flatMap { path in
            do { return try Hive.load(path) }
            catch { return nil }
        }
    }
}
