//
//  Foundation.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation

let documentsDirectory: NSString = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}()

let templateDirectory: NSString = documentsDirectory.appendingPathComponent("template") as NSString
let jsonDirectory: NSString = templateDirectory.appendingPathComponent("json") as NSString
let imageDirectory: NSString = templateDirectory.appendingPathComponent("images") as NSString
