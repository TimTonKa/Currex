//
//  AppEntry.swift
//  Currex
//
//  Created by Tim Tseng on 2025/5/23.
//

import SwiftUI
import SwiftData

struct AppEntry: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let viewModel = CurrencyViewModel(modelContext: modelContext)
        ContentView(viewModel: viewModel)
    }
}
