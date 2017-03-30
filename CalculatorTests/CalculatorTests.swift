//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Martin Mandl on 30.03.17.
//  Copyright © 2017 m2m server software gmbh. All rights reserved.
//

import XCTest

class CalculatorTests: XCTestCase {
    
    func testDescription() {
        var brain = CalculatorBrain()
        
        // a. touching 7 + would show “7 + ...” (with 7 still in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        XCTAssertEqual(brain.description!, "7.0+")
        
        // b. 7 + 9 would show “7 + ...” (9 in the display)
        //brain.setOperand(9) // entered but not pushed to model
        XCTAssertEqual(brain.description!, "7.0+")
        
        // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
        brain.setOperand(9)
        brain.performOperation("=")
        XCTAssertEqual(brain.description!, "7.0+9.0")
        
        // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
        brain.performOperation("√")
        XCTAssertEqual(brain.description!, "√(7.0+9.0)")
        
        // e. 7 + 9 = √ + 2 = would show “√(7 + 9) + 2 =” (6 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("√")
        brain.performOperation("+")
        brain.setOperand(2)
        brain.performOperation("=")
        XCTAssertEqual(brain.description!, "√(7.0+9.0)+2.0")
        
        // f. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("√")
        XCTAssertEqual(brain.description!, "7.0+√(9.0)")
        
        // g. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
        brain.performOperation("=")
        XCTAssertEqual(brain.description!, "7.0+√(9.0)")
        
        // h. 7 + 9 = + 6 = + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7.0+9.0+6.0+3.0")
        
        // i. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("√")
        brain.setOperand(6)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "6.0+3.0")
        
        // j. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("=")
        //brain.setOperand(73) // entered but not pushed to model
        XCTAssertEqual(brain.description, "5.0+6.0")
        
        // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
        brain.setOperand(4)
        brain.performOperation("×")
        brain.performOperation("π")
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "4.0×π")
    }
    
}
