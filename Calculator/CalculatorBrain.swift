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
    
    private var stack = [Element]()
    
    private enum Element {
        case operation(String)
        case operand(Double)
        case variable(String)
    }
    
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private let operations: Dictionary<String,Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, { "√(" + $0 + ")" }),
        "cos": Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "±": Operation.unaryOperation({ -$0 }, { "-(" + $0 + ")" }),
        "×": Operation.binaryOperation(*, { $0 + "×" + $1 }),
        "÷": Operation.binaryOperation(/, { $0 + "÷" + $1 }),
        "+": Operation.binaryOperation(+, { $0 + "+" + $1 }),
        "-": Operation.binaryOperation(-, { $0 + "-" + $1 }),
        "=": Operation.equals,
        
        "x²" : Operation.unaryOperation({ pow($0, 2) }, { "(" + $0 + ")²" }),
        "x³" : Operation.unaryOperation({ pow($0, 3) }, { "(" + $0 + ")³" }),
        "x⁻¹" : Operation.unaryOperation({ 1 / $0 }, {  "(" + $0 + ")⁻¹" }),
        "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "tan" : Operation.unaryOperation(tan, { "tan(" + $0 + ")" }),
        "sinh" : Operation.unaryOperation(sinh, { "sinh(" + $0 + ")" }),
        "cosh" : Operation.unaryOperation(cosh, { "cosh(" + $0 + ")" }),
        "tanh" : Operation.unaryOperation(tanh, { "tanh(" + $0 + ")" }),
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")" }),
        "log" : Operation.unaryOperation(log10, { "log(" + $0 + ")" }),
        "eˣ" : Operation.unaryOperation(exp, { "e^(" + $0 + ")" }),
        "10ˣ" : Operation.unaryOperation({ pow(10, $0) }, { "10^(" + $0 + ")" }),
        "x!" : Operation.unaryOperation(factorial, { "(" + $0 + ")!" }),
        "xʸ" : Operation.binaryOperation(pow, { $0 + "^" + $1 }),
        
        "rand" : Operation.nullaryOperation({ Double(arc4random()) / Double(UInt32.max) }, "rand()")
    ]
    
    
    mutating func setOperand(_ operand: Double) {
        stack.append(Element.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        stack.append(Element.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        stack.append(Element.operation(symbol))
    }
    
    var result: Double? {
        return evaluate().result
    }
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    var description: String? {
        return evaluate().description
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {
        var accumulator: (Double, String)?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            let firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        func performPendingBinaryOperation() {
            if nil != pendingBinaryOperation && nil != accumulator {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        var result: Double? {
            if nil != accumulator {
                return accumulator!.0
            }
            return nil
        }
        
        var description: String? {
            if nil != pendingBinaryOperation {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
        
        for element in stack {
            switch element {
            case .operand(let value):
                accumulator = (value, "\(value)")
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                    case .nullaryOperation(let function, let description):
                        accumulator = (function(), description)
                    case .unaryOperation(let function, let description):
                        if nil != accumulator {
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                        }
                    case .binaryOperation(let function, let description):
                        performPendingBinaryOperation()
                        if nil != accumulator {
                            pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            case .variable(let symbol):
                if let value = variables?[symbol] {
                    accumulator = (value, "\(value)")
                } else {
                    accumulator = (0, "0")
                }
            }
        }
        
        return (result, nil != pendingBinaryOperation, description ?? "")
    }
}
