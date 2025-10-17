//
//  CryptoDetailView.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/17.
//

import SwiftUI

struct CryptoDetailView: View {
    
    let id: String
    @StateObject private var viewModel = CryptoDetailViewModel()
    
    var body: some View {
        ScrollView {
    
        }
    }
}

#Preview {
    CryptoDetailView(id: "bitcoin")
}
