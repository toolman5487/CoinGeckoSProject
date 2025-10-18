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
    @Published var marketChart: CryptoDetailModel.MarketChartData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 15.0
    private var cryptoId: String = ""
    
    func startRealTimeUpdates(id: String) {
        cryptoId = id
        fetchCryptoDetail(id: id)
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.fetchCryptoDetail(id: id)
        }
    }
    
    func stopRealTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopRealTimeUpdates()
    }
    
    func fetchCryptoDetail(id: String) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let detailEndpoint = "coins/\(id)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
        
        APIService.shared.get(endpoint: detailEndpoint, responseModel: CryptoDetailModel.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.cryptoDetail = data
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        
        let chartEndpoint = "coins/\(id)/market_chart?vs_currency=usd&days=7&interval=daily"
        
        APIService.shared.get(endpoint: chartEndpoint, responseModel: CryptoDetailModel.MarketChartData.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.marketChart = data
                case .failure(let error):
                    print("圖表數據載入失敗: \(error.localizedDescription)")
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
