//
//  CryptoDetailViewModel.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/17.
//

import Foundation
import Combine

class CryptoDetailViewModel: ObservableObject {
    @Published var cryptoDetail: CryptoDetailModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchCryptoDetail(id: String) {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "coins/\(id)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
        
        APIService.shared.get(endpoint: endpoint, responseModel: CryptoDetailModel.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.cryptoDetail = data
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var priceUSDText: String {
        guard let price = cryptoDetail?.market_data?.current_price?["usd"] else { return "-" }
        return String(format: "$%.2f", price)
    }
    
    var change24hText: String {
        guard let change = cryptoDetail?.market_data?.price_change_percentage_24h else { return "-" }
        return String(format: "%.2f%%", change)
    }
    
    var marketCapText: String {
        guard let marketCap = cryptoDetail?.market_data?.market_cap?["usd"] else { return "-" }
        return String(format: "$%.0f", marketCap)
    }
}
