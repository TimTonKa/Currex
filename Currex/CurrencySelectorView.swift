//
//  CurrencySelectorView.swift
//  Currex
//
//  Created by Tim Zheng on 2025/5/16.
//

import SwiftUICore
import SwiftUI

struct CurrencySelectorView: View {
    let currencyCode: String
    let flag: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(flag)
                    .font(.system(size: 32))
                Text(currencyCode.uppercased())
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(6)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
        }
    }
}
