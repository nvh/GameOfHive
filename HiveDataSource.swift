//
//  HiveDataSource.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation

class HiveDataSource {
    let manager: HiveManager

    init(manager: HiveManager) {
        self.manager = manager
    }

    var hives: [Hive] = []
   
    func refresh() {
        self.hives = manager.allHives()
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfHives(inSection section: Int) -> Int {
        return hives.count
    }
    
    func hive(atIndexPath indexPath: IndexPath) -> Hive? {
        guard indexPath.item < numberOfHives(inSection: indexPath.section) else {
            return nil
        }
        return hives[indexPath.item]
    }
    
}
