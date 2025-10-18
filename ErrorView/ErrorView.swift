//
//  ErrorView.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/17.
//

import SwiftUI

struct ErrorView: View {
    let error: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Loading Failed")
                .font(.headline)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ErrorView(error: "Network connection failed")
}
