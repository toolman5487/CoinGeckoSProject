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
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let crypto = viewModel.cryptoDetail {
                    headerSection(crypto: crypto)
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error)
                }
            }
            .padding()
        }
        .navigationTitle("Crypto")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.fetchCryptoDetail(id: id)
        }
    }
    
    private func headerSection(crypto: CryptoDetailModel) -> some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: crypto.image?.small ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(crypto.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(crypto.symbol.uppercased())
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
}

#Preview {
    CryptoDetailView(id: "bitcoin")
}
