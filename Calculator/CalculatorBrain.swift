//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Martin Mandl on 22.03.17.
//  Copyright © 2017 m2m server software gmbh. All rights reserved.
//

import Foundation

func changeSign(operand: Double) -> Double {
    return -operand
}

func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}

func factorial(_ op1: Double) -> Double {
    if (op1 <= 1.0) {
        return 1.0
    }
    return op1 * factorial(op1 - 1.0)
}

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private let operations: Dictionary<String,Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "±": Operation.unaryOperation({ -$0 }),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "=": Operation.equals,
        
        "x²" : Operation.unaryOperation({ pow($0, 2) }),
        "x³" : Operation.unaryOperation({ pow($0, 3) }),
        "x⁻¹" : Operation.unaryOperation({ 1 / $0 }),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "sinh" : Operation.unaryOperation(sinh),
        "cosh" : Operation.unaryOperation(cosh),
        "tanh" : Operation.unaryOperation(tanh),
        "ln" : Operation.unaryOperation(log),
        "log" : Operation.unaryOperation(log10),
        "eˣ" : Operation.unaryOperation(exp),
        "10ˣ" : Operation.unaryOperation({ pow(10, $0) }),
        "x!" : Operation.unaryOperation(factorial),
        "xʸ" : Operation.binaryOperation(pow),
        ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                if nil != accumulator {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if nil != accumulator {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if nil != pendingBinaryOperation && nil != accumulator {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return nil != pendingBinaryOperation
        }
    }
}
