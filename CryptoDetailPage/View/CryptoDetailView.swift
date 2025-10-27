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
            HStack {
                Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                    ForEach(CryptoDetailViewModel.TimeRange.allCases, id: \.self) { timeRange in
                        Text(timeRange.displayName).tag(timeRange)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: viewModel.selectedTimeRange) { newValue in
                    viewModel.changeTimeRange(newValue)
                }
            }
            .padding(.bottom, 8)
            
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
                    .foregroundStyle(
                        crypto.market_data?.price_change_percentage_24h ?? 0 >= 0 ? .green : .red
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(
                        crypto.market_data?.price_change_percentage_24h ?? 0 >= 0 ? .green : .red
                    )
                    .symbolSize(20)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: viewModel.getXAxisStride())) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: viewModel.getXAxisFormat())
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
                Image(systemName: "chart.xyaxis.line")
                    .foregroundColor(.secondary)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    CryptoDetailView(id: "bitcoin")
}
