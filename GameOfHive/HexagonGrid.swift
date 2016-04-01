//
//  HexagonGrid.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import Foundation

typealias HexagonRow = [Int: Hexagon]

public enum GridType {
  case Empty
  case Random
}

public struct HexagonGrid {
    private var count = 0
    private let grid: [Int: HexagonRow]
    private let rules: Rules
    
    private init(grid: [Int: HexagonRow], rules: Rules) {
        self.grid = grid
        self.count = grid.count
        self.rules = rules
    }
    
    public init(rows: Int = 10, columns: Int = 10, initialGridType: GridType) {
        let grid = initialGrid(rows,columns: columns,gridType: initialGridType)
        self.init(grid: grid, rules: Rules.randomRules())
        print(rules)
    }
    
    public func hexagon(atLocation location: Coordinate) -> Hexagon? {
        return grid[location.row]?[location.column]
    }
    
    func activeNeigbors(cell: Hexagon) -> Int {
        let ns = neighboringLocations(cell.location).reduce(0) { (value, location: Coordinate) in
            if let hex = hexagon(atLocation: location) where hex.active {
                return value+1
            }
            return value
            
        }
        return ns
    }
    
    public func nextIteration(cell: Hexagon) -> Hexagon {
        return rules.perform(cell, numberOfActiveNeighbors: activeNeigbors(cell))
    }
    
    public func setActive(active: Bool, atLocation location: Coordinate) -> HexagonGrid
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
        return HexagonGrid(grid: newGrid, rules: rules)
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

extension HexagonGrid: SequenceType {
    public func generate() -> AnyGenerator<Hexagon> {
        var rowGenerator = self.grid.generate()
        var columnGenerator = rowGenerator.next()?.1.generate()
        return AnyGenerator {
            if let column = columnGenerator?.next()
            {
                return column.1
            }
            columnGenerator = rowGenerator.next()?.1.generate()
            return columnGenerator?.next()?.1
        }
    }
}

func initialGrid(rows: Int, columns: Int, gridType: GridType) -> [Int: HexagonRow] {
    var grid: [Int:HexagonRow] = [:]
    for r in 0..<rows {
        var row: HexagonRow = [:]
        for c in 0..<columns {
            let active = gridType == .Empty ? false : arc4random_uniform(10) == 1
            row[c] = Hexagon(row: r, column: c, active: active)
        }
        grid[r] = row
    }
    return grid
}


public func nextGrid(grid: HexagonGrid) -> HexagonGrid {
    var nextIteration: [Int:HexagonRow] = [:]
    for (rowNumber,row) in grid.grid {
        var nextRow: HexagonRow = [:]
        for (columnNumber,hex) in row {
            let nextHex = grid.nextIteration(hex)
            nextRow[columnNumber] = nextHex
        }
        nextIteration[rowNumber] = nextRow
    }
    return HexagonGrid(grid: nextIteration, rules: grid.rules)
}

func emptyGrid(rows: Int, columns: Int) -> HexagonGrid {
  return HexagonGrid(rows: rows, columns: columns, initialGridType: .Empty)
}