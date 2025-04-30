//
//  CalculatorEngine.swift
//  Currex
//
//  Created by Tim Zheng on 2025/4/30.
//

import Foundation
import Combine

class CalculatorEngine: ObservableObject {
    @Published var expression: String = ""   // 顯示的完整算式
    @Published var result: String = "0"      // 計算結果

    private var currentInput: String = ""    // 當前輸入的數字
    private var lastOperator: String?        // 最後輸入的運算子

    private let operators: [Character] = ["+", "-", "×", "÷"]

    func input(_ action: CalculatorButtonAction) {
        switch action {
        case .clear:
            clear()
        case .equal:
            evaluate()
        case .input(let val):
            if val == "." {
                handleDecimal()
            } else {
                handleNumber(val)
            }
        case .operation(let op):
            handleOperator(op)
        case .plusMinus:
            togglePlusMinus()
        case .percent:
            applyPercent()
        }
    }

    private func clear() {
        expression = ""
        result = "0"
        currentInput = ""
        lastOperator = nil
    }

    private func handleNumber(_ number: String) {
        if currentInput == "0" && number != "." {
            currentInput = number
        } else {
            currentInput += number
        }
        result = currentInput
    }

    private func handleDecimal() {
        guard !currentInput.contains(".") else { return }
        if currentInput.isEmpty {
            currentInput = "0."
        } else {
            currentInput += "."
        }
        result = currentInput
    }

    private func togglePlusMinus() {
        guard !currentInput.isEmpty else { return }
        if currentInput.hasPrefix("-") {
            currentInput.removeFirst()
        } else {
            currentInput = "-" + currentInput
        }
        result = currentInput
    }

    private func applyPercent() {
        guard let value = Double(currentInput) else { return }
        currentInput = String(value / 100)
        result = currentInput
    }

    private func handleOperator(_ op: String) {
        guard !currentInput.isEmpty else { return }
        expression += currentInput + op
        currentInput = ""
        lastOperator = op
    }

    private func evaluate() {
        expression += currentInput
        
        if let lastChar = expression.last, operators.contains(lastChar) || lastChar == "." {
//            expression.removeLast()
        }

        let mathExpression = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")

        let exp = NSExpression(format: mathExpression)
        if let value = exp.expressionValue(with: nil, context: nil) as? NSNumber {
            result = String(format: "%g", value.doubleValue)
        } else {
            result = "錯誤"
        }

        // Reset for next round
        currentInput = result
        expression = ""
    }
}
