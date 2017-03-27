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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(for: view, isPortrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
    }
    
    private func adjustButtonLayout(for view: UIView, isPortrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = isPortrait
            } else if subview.tag == 2 {
                subview.isHidden = !isPortrait
            }
            if let button = subview as? UIButton {
                button.setBackgroundColor(UIColor.black, forState: .highlighted)
                button.setTitleColor(UIColor.white, for: .highlighted)
            } else if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait);
            }
        }
    }

}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext();
        color.setFill()
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, for: state);
    }
}

