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
    @Published var selectedTimeRange: TimeRange = .week
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 15.0
    private var cryptoId: String = ""
    private var isRequestInProgress = false
    private var lastRequestTime: Date = Date.distantPast
    private let minimumRequestInterval: TimeInterval = 5.0
    
    private func getUpdateInterval(for timeRange: TimeRange) -> TimeInterval {
        switch timeRange {
        case .day:
            return 300.0
        case .week:
            return 3600.0
        case .month, .quarter, .year:
            return 86400.0
        }
    }
    
    enum TimeRange: String, CaseIterable {
        case day = "1"
        case week = "7"
        case month = "30"
        case quarter = "90"
        case year = "365"
        
        var displayName: String {
            switch self {
            case .day: return "1D"
            case .week: return "7D"
            case .month: return "30D"
            case .quarter: return "90D"
            case .year: return "1Y"
            }
        }
    }

    func getXAxisStride() -> Calendar.Component {
        switch selectedTimeRange {
        case .day:
            return .hour
        case .week:
            return .day
        case .month:
            return .day
        case .quarter:
            return .weekOfYear
        case .year:
            return .month
        }
    }

    func getXAxisFormat() -> Date.FormatStyle {
        switch selectedTimeRange {
        case .day:
            return .dateTime.hour()
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day().month(.abbreviated)
        case .quarter:
            return .dateTime.month(.abbreviated)
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }
    
    func startRealTimeUpdates(id: String) {
        cryptoId = id
        fetchCryptoDetail(id: id, timeRange: selectedTimeRange)
        let interval = getUpdateInterval(for: selectedTimeRange)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchCryptoDetail(id: id, timeRange: self.selectedTimeRange)
        }
    }
    
    func stopRealTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopRealTimeUpdates()
    }
    
    func fetchCryptoDetail(id: String, timeRange: TimeRange = .week) {
        guard !isLoading && !isRequestInProgress else { return }
        let timeSinceLastRequest = Date().timeIntervalSince(lastRequestTime)
        guard timeSinceLastRequest >= minimumRequestInterval else {
            return
        }
        
        isLoading = true
        isRequestInProgress = true
        lastRequestTime = Date()
        errorMessage = nil
        
        let detailEndpoint = "coins/\(id)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
        
        APIService.shared.get(endpoint: detailEndpoint, responseModel: CryptoDetailModel.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Crypto detail received successfully: \(data.name)")
                    self?.cryptoDetail = data
                case .failure(let error):
                    print("CryptoDetail Loading Failure: \(error)")
                    print("Endpoint: \(detailEndpoint)")
                    if let apiError = error as? APIError, apiError == .rateLimitExceeded {
                        self?.errorMessage = "Rate limit exceeded. Please wait a few minutes before trying again."
                    } else {
                        self?.errorMessage = "Failed to load crypto details: \(error.localizedDescription)"
                    }
                }
            }
        }
        
        let chartEndpoint = "coins/\(id)/market_chart?vs_currency=usd&days=\(timeRange.rawValue)"
        
        APIService.shared.get(endpoint: chartEndpoint, responseModel: CryptoDetailModel.MarketChartData.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isRequestInProgress = false
                switch result {
                case .success(let data):
                    print("Chart data received successfully: \(data)")
                    if let prices = data.prices, !prices.isEmpty {
                        let firstDate = Date(timeIntervalSince1970: prices.first![0] / 1000)
                        let lastDate = Date(timeIntervalSince1970: prices.last![0] / 1000)
                        print("Data time range: \(firstDate) to \(lastDate)")
                        print("Data points count: \(prices.count)")
                    }
                    self?.marketChart = data
                case .failure(let error):
                    print("Chart Loading Failure: \(error)")
                    print("Endpoint: \(chartEndpoint)")
                    if let apiError = error as? APIError, apiError == .rateLimitExceeded {
                        self?.errorMessage = "Rate limit exceeded. Please wait a few minutes before trying again."
                    } else {
                        self?.errorMessage = "Failed to load chart data: \(error.localizedDescription)"
                    }
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
    
    func changeTimeRange(_ timeRange: TimeRange) {
        selectedTimeRange = timeRange
        stopRealTimeUpdates()
        fetchCryptoDetail(id: cryptoId, timeRange: timeRange)
        let interval = getUpdateInterval(for: timeRange)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchCryptoDetail(id: self.cryptoId, timeRange: self.selectedTimeRange)
        }
    }
}
