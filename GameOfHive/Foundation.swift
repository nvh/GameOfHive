//
//  Foundation.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation

let documentsDirectory: URL = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return URL(fileURLWithPath: documentsDirectory, isDirectory: true)
}()
