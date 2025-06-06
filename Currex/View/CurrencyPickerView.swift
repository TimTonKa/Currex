//
//  CurrencyPickerView.swift
//  CurrenxApp
//
//  Created by Tim Tseng on 2025/4/18.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountryCode: String
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
                    TextField(L10n.search, text: $searchText)
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
                        selectedCountryCode = country.countryCode
                        dismiss()
                    }) {
                        HStack {
                            Text(country.flag)
                                .font(.system(size: 24))// ← 加上國旗 emoji
                            Text(LocalizedStringKey(country.countryName))
                            Spacer()
                            Text(country.currencyCode.uppercased())
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle(L10n.selectCurrency)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
