//
//  CryptoDetailView.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/17.
//

import SwiftUI
import Charts

struct CryptoDetailView: View {
    let id: String
    @StateObject private var viewModel = CryptoDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let crypto = viewModel.cryptoDetail {
                    headerSection(crypto: crypto)
                    priceSection(crypto: crypto)
                    priceChartSection(crypto: crypto)
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.startRealTimeUpdates(id: id)
        }
        .onDisappear {
            viewModel.stopRealTimeUpdates()
        }
    }
    
    private func headerSection(crypto: CryptoDetailModel) -> some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: crypto.image?.small ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
            }
            .frame(width: 32, height: 32)
            Text(crypto.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(crypto.symbol.uppercased())
                .font(.title)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private func priceSection(crypto: CryptoDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.priceUSDText)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: crypto.market_data?.price_change_percentage_24h ?? 0 >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .foregroundColor(crypto.market_data?.price_change_percentage_24h ?? 0 >= 0 ? .green : .red)
                    .font(.caption)
                
                Text(viewModel.change24hText)
                    .foregroundColor(crypto.market_data?.price_change_percentage_24h ?? 0 >= 0 ? .green : .red)
                Text("24h")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
    
    private func priceChartSection(crypto: CryptoDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let marketChart = viewModel.marketChart,
               let prices = marketChart.prices,
               !prices.isEmpty {
                
                let chartData = prices.map { priceArray in
                    ChartDataPoint(
                        date: Date(timeIntervalSince1970: priceArray[0] / 1000),
                        price: priceArray[1]
                    )
                }
                
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(20)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let price = value.as(Double.self) {
                                Text("$\(Int(price/1000))K")
                            }
                        }
                    }
                }
            } else {
                Text("Loading Chart")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    CryptoDetailView(id: "bitcoin")
}
