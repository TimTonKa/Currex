//
//  NumberPadView.swift
//  Currex
//
//  Created by Tim Zheng on 2025/4/30.
//


import SwiftUI

/// 表示使用者點擊的按鈕類型
enum CalculatorButtonAction: Hashable {
    case input(String)    // 數字與小數點
    case operation(String) // + - × ÷
    case equal
    case clear
    case backspace
    case swapCurrency
}

struct NumberPadView: View {
    let onTap: (CalculatorButtonAction) -> Void

    let buttons: [[CalculatorButtonAction]] = [
        [.clear, .swapCurrency, .backspace, .operation("÷")],
        [.input("7"), .input("8"), .input("9"), .operation("×")],
        [.input("4"), .input("5"), .input("6"), .operation("-")],
        [.input("1"), .input("2"), .input("3"), .operation("+")],
        [.input("0"), .input("."), .equal]
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(buttons.indices, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(buttons[row], id: \.self) { button in
                        Button(action: {
                            onTap(button)
                        }) {
                            Text(buttonLabel(for: button))
                                .font(.title)
                                .frame(width: self.buttonWidth(button), height: self.buttonHeight())
                                .background(buttonColor(for: button))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func buttonLabel(for action: CalculatorButtonAction) -> String {
        switch action {
        case .input(let value): return value
        case .operation(let op): return op
        case .equal: return "="
        case .clear: return "AC"
        case .backspace: return "⌫"
        case .swapCurrency: return "⇄"
        }
    }

    private func buttonColor(for action: CalculatorButtonAction) -> Color {
        switch action {
        case .input:
            return Color(.darkGray)
        case .operation, .equal:
            return Color.orange
        case .clear, .backspace, .swapCurrency:
            return Color(.lightGray)
        }
    }

    private func buttonWidth(_ action: CalculatorButtonAction) -> CGFloat {
        if case .input("0") = action {
            return (UIScreen.main.bounds.width - 5 * 12) / 4 * 2 + 12
        } else {
            return (UIScreen.main.bounds.width - 5 * 12) / 4
        }
    }

    private func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}
