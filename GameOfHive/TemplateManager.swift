//
//  TemplatesViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

private let lastSavedTemplateIdentifierKey = "org.gameofhive.lastSavedTemplateIdentifier"

private var lastSavedTemplateIdentifier: String {
    return UserDefaults.standard.object(forKey: lastSavedTemplateIdentifierKey)! as! String
}

class TemplateManager {
    enum TemplateError: Error {
        case imageFailedSaving
    }
    
    static let shared = TemplateManager()
    fileprivate let fileManager = FileManager.default
    
    init() {
        createDirectory(atPath: jsonDirectory as String)
        createDirectory(atPath: imageDirectory as String)
    }
    
    fileprivate func createDirectory(atPath path: String) {
        guard !fileManager.fileExists(atPath: path) else {
            return
        }
        
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
    
    func loadTemplate(_ identifier: String? = nil) throws -> Template {
        let templateIdentifier = identifier ?? lastSavedTemplateIdentifier
        let templateFileName = "\(templateIdentifier).json"
        let templatePath = templateDirectory.appendingPathComponent(templateFileName)
        return try Template.load(templatePath)
    }
    
    func saveTemplate(grid: HexagonGrid, image: UIImage, title: String? = nil) throws {
        let identifier = String(grid.hashValue)
        let date = Date()
        let title = title /*?? date.iso8601*/ ?? identifier
        
        let imageFileName = "\(identifier).png"
        let imagePath = imageDirectory.appendingPathComponent(imageFileName)
        guard let imageData = UIImagePNGRepresentation(image), ((try? imageData.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])) != nil) else {
            throw TemplateError.imageFailedSaving
        }
        
        let gridFileName = "\(identifier).json"
        let gridPath = jsonDirectory.appendingPathComponent(gridFileName)
        try grid.save(gridPath)
        
        let templateFileName = gridFileName
        let templatePath = templateDirectory.appendingPathComponent(templateFileName)
        let template = Template(identifier: identifier, title: title, date: date, gridPath: gridPath, imagePath: imagePath)
        try template.save(templatePath)
        
        UserDefaults.standard.set(identifier, forKey: lastSavedTemplateIdentifierKey)
    }    
    
    func allTemplates() -> [Template] {
        
        guard let filenames = try? FileManager.default.contentsOfDirectory(atPath: templateDirectory as String) else {
            return []
        }
        let paths = filenames.filter { $0.hasSuffix(".json") }.map(templateDirectory.appendingPathComponent)
        return paths.flatMap { path in
            do { return try Template.load(path) }
            catch { return nil }
        }
    }
}
