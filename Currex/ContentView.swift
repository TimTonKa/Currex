//
//  ContentView.swift
//  Currex
//
//  Created by 曾凱煌 on 2025/5/1.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // 幣別與金額顯示區塊
                HStack(alignment: .center, spacing: 16) {

                    // 左邊：幣別旗幟與代碼
                    VStack(spacing: 32) {
                        CurrencySelectorView(
                            currencyCode: viewModel.sourceCurrencyCode,
                            flag: viewModel.sourceCountry?.flag ?? "🏳️",
                            action: { showingSourcePicker = true }
                        )

                        CurrencySelectorView(
                            currencyCode: viewModel.targetCurrencyCode,
                            flag: viewModel.targetCountry?.flag ?? "🏳️",
                            action: { showingTargetPicker = true }
                        )
                    }

                    // 右邊：金額顯示
                    VStack(alignment: .trailing, spacing: 32) {
                        Text(viewModel.engine.result)
                            .font(.system(size: 32, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .border(.white, width: 1.0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        

                        let converted = viewModel.convertedAmount ?? 0
                        Text(String(format: "%.2f", converted))
                            .font(.system(size: 32, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .border(.white, width: 1.0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // 計算機按鍵
                NumberPadView { action in
                    viewModel.handle(action: action)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingSourcePicker) {
                CurrencyPickerView(selectedCode: $viewModel.sourceCurrencyCode, countries: viewModel.countries)
            }
            .sheet(isPresented: $showingTargetPicker) {
                CurrencyPickerView(selectedCode: $viewModel.targetCurrencyCode, countries: viewModel.countries)
            }
        }
    }
}
