//
//  EncodingTests.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import XCTest
@testable import GameOfHive
//import Argo

class EncodingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEncodingDecodingGrid() throws {
        let gridBefore = HexagonGrid(rows: 10, columns: 5, initialGridType: .random)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let encodedGrid = try encoder.encode(gridBefore)
        let gridAfter = try decoder.decode(HexagonGrid.self, from: encodedGrid)

        XCTAssertEqual(gridBefore.hashValue, gridAfter.hashValue, "hashes should be the same")
        XCTAssertEqual(gridBefore, gridAfter, "grids should compare equal")
    }
}
