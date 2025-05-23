//
//  ContentView.swift
//  Currex
//
//  Created by Tim Tseng on 2025/5/1.
//

import SwiftUI
import OSLog
import SwiftData

struct ContentView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // 幣別與金額顯示區塊
                VStack(alignment: .leading, spacing: 16) {

                    // 左邊：幣別旗幟與代碼
                    HStack(alignment: .center, spacing: 32) {
                        CurrencySelectorView(
                            currencyCode: viewModel.sourceCountry?.currencyCode ?? "",
                            flag: viewModel.sourceCountry?.flag ?? "🏳️",
                            action: { showingSourcePicker = true }
                        )
                        
                        Text(viewModel.formattedResultWithCurrency)
                            .font(.system(size: 32, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // 右邊：金額顯示
                    HStack(alignment: .center, spacing: 32) {
                        CurrencySelectorView(
                            currencyCode: viewModel.targetCountry?.currencyCode ?? "",
                            flag: viewModel.targetCountry?.flag ?? "🏳️",
                            action: { showingTargetPicker = true }
                        )
                                                
                        Text(viewModel.formattedConvertedAmountWithCurrency)
                            .font(.system(size: 32, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal)

                Spacer()
                // 🔽 新增匯率文字區
                if let exchangeText = viewModel.formattedExchangeRate {
                    Text(exchangeText)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                Spacer()

                // 計算機按鍵
                NumberPadView { action in
                    viewModel.handle(action: action)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingSourcePicker) {
                CurrencyPickerView(selectedCountryCode: Binding(
                    get: { viewModel.sourceCountry?.countryCode ?? "" },
                    set: { newCode in
                        if let match = viewModel.countries.first(where: { $0.countryCode == newCode }) {
                            viewModel.sourceCountry = match
                        }
                    }), countries: viewModel.countries)
            }
            .sheet(isPresented: $showingTargetPicker) {
                CurrencyPickerView(selectedCountryCode: Binding(
                    get: { viewModel.targetCountry?.countryCode ?? "" },
                    set: { newCode in
                        if let match = viewModel.countries.first(where: { $0.countryCode == newCode }) {
                            viewModel.targetCountry = match
                        }
                    }), countries: viewModel.countries)
            }
        }
    }
}
