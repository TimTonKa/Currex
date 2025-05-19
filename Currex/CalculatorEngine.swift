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
        case .backspace:
            backspace()
        case .swapCurrency:
            // 不處理，由 ViewModel 處理
            break
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

    private func backspace() {
        guard !currentInput.isEmpty else { return }
        currentInput.removeLast()
        result = currentInput.isEmpty ? "0" : currentInput
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
            expression.removeLast()
        }
        
        guard !expression.isEmpty else { return }

        let mathExpression = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")

        let exp = NSExpression(format: mathExpression)
        if let value = exp.expressionValue(with: nil, context: nil) as? NSNumber {
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = false
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 10 //設定小數點後最多顯示幾位數（會四捨五入）
            formatter.maximumIntegerDigits = 20  //= 5 ,formatter.string(from: 1234567) // 顯示 "34567"

            if let formatted = formatter.string(from: value) {
                result = formatted }
            else {
                //在某些情況下把 999999999 自動四捨五入成 1e+09，然後再轉成 1000000000，這是一種數值格式化的預設行為
                result = "\(value.doubleValue)" // fallback
            }
        } else {
            result = "錯誤"
        }

        // Reset for next round
        currentInput = result
        expression = ""
    }
}
