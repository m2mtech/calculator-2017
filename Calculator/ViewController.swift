//
//  ViewController.swift
//  Calculator
//
//  Created by Martin Mandl on 21.03.17.
//  Copyright © 2017 m2m server software gmbh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        //print("\(digit) was touched")
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if "." != digit || !textCurrentlyInDisplay.contains(".") {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = "." == digit ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            displayValue = result
        }
    }
    
}

