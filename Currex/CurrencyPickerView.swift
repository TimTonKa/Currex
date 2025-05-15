//
//  CurrencyPickerView.swift
//  CurrenxApp
//
//  Created by Tim Zheng on 2025/4/18.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCode: String
    @State private var searchText: String = ""

    let countries: [CountryCurrency]
    
    var filteredCountries: [CountryCurrency] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter {
                let localizedName = NSLocalizedString($0.countryName, comment: "")
                return localizedName.localizedCaseInsensitiveContains(searchText) ||
                $0.countryName.localizedCaseInsensitiveContains(searchText) ||
                $0.currencyCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // 搜尋框
                HStack {
                    TextField("搜尋國家或幣別", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // 清除按鈕
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                }

                // 列表
                List(filteredCountries) { country in
                    Button(action: {
                        selectedCode = country.currencyCode
                        dismiss()
                    }) {
                        HStack {
                            Text(LocalizedStringKey(country.countryName))
                            Spacer()
                            Text(country.currencyCode.uppercased())
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("選擇幣別")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
