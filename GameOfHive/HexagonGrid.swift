//
//  HexagonGrid.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
//import Argo

typealias HexagonRow = [Int: Hexagon]

public enum GridType {
  case empty
  case random
}

public struct HexagonGrid: Persistable {
    fileprivate var count = 0
    fileprivate let grid: [Int: HexagonRow]
    
    var rows: Int {
        return grid.count
    }
    
    var columns: Int {
        return grid[0]?.count ?? 0
    }
    
    fileprivate init(grid: [Int: HexagonRow]) {
        self.grid = grid
        self.count = grid.count
    }
    
    public init(rows: Int = 10, columns: Int = 10, initialGridType: GridType) {
        let grid = initialGrid(rows,columns: columns,gridType: initialGridType)
        self.init(grid: grid)
    }
    
    func wrap(_ value: Int, max: Int) -> Int {
        if value < 0 {
            return value + max - 1
        }
        if max <= value {
            return value - max + 1
        }
        return value
    }
    
    public func hexagon(atLocation location: Coordinate) -> Hexagon? {
        let wrappedRow = wrap(location.row, max: rows)
        let wrappedColumn = wrap(location.column, max: columns)
        let wrappedLocation = Coordinate(row: wrappedRow, column: wrappedColumn)
        return grid[wrappedLocation.row]?[wrappedLocation.column]
    }
    
    func activeNeigbors(_ cell: Hexagon) -> Int {
        let ns = neighboringLocations(cell.location).reduce(0) { (value, location: Coordinate) in
            if let hex = hexagon(atLocation: location), hex.active {
                return value+1
            }
            return value
            
        }
        return ns
    }
    
    func update(_ hexagon: Hexagon, forRules rules: Rules) -> Hexagon {
        return rules.update(hexagon, numberOfActiveNeighbors: activeNeigbors(hexagon))
    }
    
    public func setActive(_ active: Bool, atLocation location: Coordinate) -> HexagonGrid
    {
        var newGrid = grid
        var row: HexagonRow! = newGrid[location.row]
        if row == nil {
            return self
        }
        let hex: Hexagon! = row[location.column]
        if hex == nil {
            return self
        }
        row[location.column] = hex.setActive(active)
        newGrid[location.row] = row
        return HexagonGrid(grid: newGrid)
    }
    
    func nextIteration(_ rules: Rules) -> HexagonGrid {
        var nextIteration: [Int:HexagonRow] = [:]
        grid.forEach{ (rowNumber,row) in
            var nextRow: HexagonRow = [:]
            row.forEach { (columnNumber,hex) in
                let nextHex = update(hex, forRules: rules)
                nextRow[columnNumber] = nextHex
            }
            nextIteration[rowNumber] = nextRow
        }
        return HexagonGrid(grid: nextIteration)
        
    }
    
    fileprivate func rowString(index rowIndex: Int) -> String {
        var rowString: String = ""
        for columnIndex in 0..<columns {
            if let hex = self.grid[rowIndex]?[columnIndex] {
                rowString += hex.active ? "1" : "0"
            } else {
                assertionFailure("Error encoding grid")
                rowString += "x"
            }
        }
        return rowString
    }
}

extension HexagonGrid: CustomStringConvertible {
    public var description: String {
        return grid.reduce("") { (prev, el) in
            let (_, row) = el
            return prev + row.reduce("") { (prev, el) in
                let (_, hex) = el
                return prev + hex.description
            }
        }
    }
}

extension HexagonGrid: Sequence {
    public func makeIterator() -> AnyIterator<Hexagon> {
        var rowGenerator = self.grid.makeIterator()
        var columnGenerator = rowGenerator.next()?.1.makeIterator()
        return AnyIterator {
            if let column = columnGenerator?.next()
            {
                return column.1
            }
            columnGenerator = rowGenerator.next()?.1.makeIterator()
            return columnGenerator?.next()?.1
        }
    }
}

extension HexagonGrid: Hashable {
    public var hashValue: Int {
        var hashValue: Int = 0
        for rowIndex in 0..<rows {
            hashValue ^= self.rowString(index: rowIndex).hashValue
        }
        
        return hashValue
    }
}

public func == (lhs: HexagonGrid, rhs: HexagonGrid) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func initialGrid(_ rows: Int, columns: Int, gridType: GridType) -> [Int: HexagonRow] {
    var grid: [Int:HexagonRow] = [:]
    for r in 0..<rows {
        var row: HexagonRow = [:]
        for c in 0..<columns {
            let active = gridType == .empty ? false : arc4random_uniform(10) == 1
            row[c] = Hexagon(row: r, column: c, active: active)
        }
        grid[r] = row
    }
    return grid
}



func gridFromViewDimensions(_ gridSize: CGSize, cellSize: CGSize, gridType: GridType = .empty) -> HexagonGrid {
    let colums = Int(ceil(gridSize.width / cellSize.width)) + 1
    let rows = Int(ceil(gridSize.height / ((3 * cellSize.height) / 4))) + 1
    
    return HexagonGrid(rows: rows, columns: colums, initialGridType: gridType)
}
