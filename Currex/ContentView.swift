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
                
                // 幣別選擇區塊
                HStack {
                    VStack(alignment: .leading) {
                        Text("來源幣別")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button(action: {
                            showingSourcePicker = true
                        }) {
                            Text(viewModel.sourceCurrencyCode.uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                    
                    VStack {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("目標幣別")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button(action: {
                            showingTargetPicker = true
                        }) {
                            Text(viewModel.targetCurrencyCode.uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                }
                .sheet(isPresented: $showingSourcePicker) {
                    CurrencyPickerView(selectedCode: $viewModel.sourceCurrencyCode, countries: viewModel.countries)
                }
                .sheet(isPresented: $showingTargetPicker) {
                    CurrencyPickerView(selectedCode: $viewModel.targetCurrencyCode, countries: viewModel.countries)
                }

                // 運算式與結果顯示
                VStack(alignment: .trailing, spacing: 8) {
                    Text(viewModel.engine.expression)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)

                    Text(viewModel.engine.result)
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                }
                .padding(.top)

                // 換算顯示
                if let converted = viewModel.convertedAmount {
                    Text("換算結果：\(viewModel.targetCurrencyCode.uppercased()) \(String(format: "%.2f", converted))")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top)
                        .foregroundColor(.green)
                }

                // 計算機按鍵
                Spacer()
                NumberPadView { action in
                    viewModel.handle(action: action)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}
