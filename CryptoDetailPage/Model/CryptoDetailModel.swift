//
//  CryptoDetailModel.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/17.
//

import Foundation

struct CryptoDetailModel: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: ImageInfo?
    let market_data: MarketData?
    let description: Description?
    let links: Links?
    let genesis_date: String?
    let categories: [String]?
    let sparkline_in_7d: SparklineData?
    
    struct ImageInfo: Codable {
        let thumb: String?
        let small: String?
        let large: String?
    }
    
    struct MarketData: Codable {
        let current_price: [String: Double]?
        let price_change_percentage_24h: Double?
        let high_24h: [String: Double]?
        let low_24h: [String: Double]?
        let market_cap: [String: Double]?
        let total_volume: [String: Double]?
        let circulating_supply: Double?
        let total_supply: Double?
        let max_supply: Double?
    }
    
    struct Description: Codable {
        let en: String?
        let zh_tw: String?
    }
    
    struct Links: Codable {
        let homepage: [String]?
        let blockchain_site: [String]?
        let subreddit_url: String?
        let twitter_screen_name: String?
    }
    
    struct SparklineData: Codable {
        let price: [Double]?
    }
    
    struct MarketChartData: Codable {
        let prices: [[Double]]?
        let market_caps: [[Double]]?
        let total_volumes: [[Double]]?
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}
