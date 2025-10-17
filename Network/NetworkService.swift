//
//  NetworkService.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/14.
//

import Foundation

class APIService {
    // MARK: - Singleton
    static let shared = APIService()
    private let session: URLSession
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    // MARK: - Initialization
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - GET
    func get<T: Codable>(endpoint: String, responseModel: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = endpoint.hasPrefix("http") ? endpoint : "\(baseURL)/\(endpoint)"
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, responseModel: responseModel, completion: completion)
        }.resume()
    }
    
    // MARK: - POST
    func post<T: Codable>(endpoint: String, payload: [String: Any]? = nil, responseModel: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = endpoint.hasPrefix("http") ? endpoint : "\(baseURL)/\(endpoint)"
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let payload = payload {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        session.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, responseModel: responseModel, completion: completion)
        }.resume()
    }
    
    // MARK: - PUT
    func put<T: Codable>(endpoint: String, payload: [String: Any]? = nil, responseModel: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = endpoint.hasPrefix("http") ? endpoint : "\(baseURL)/\(endpoint)"
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let payload = payload {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        session.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, responseModel: responseModel, completion: completion)
        }.resume()
    }
    
    // MARK: - DELETE
    func delete<T: Codable>(endpoint: String, responseModel: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = endpoint.hasPrefix("http") ? endpoint : "\(baseURL)/\(endpoint)"
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        session.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, responseModel: responseModel, completion: completion)
        }.resume()
    }
    
    // MARK: - Response Handling
    private func handleResponse<T: Codable>(data: Data?, response: URLResponse?, error: Error?, responseModel: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(APIError.invalidResponse))
            return
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        default:
            completion(.failure(APIError.invalidResponse))
            return
        }
        
        guard let data = data else {
            completion(.failure(APIError.noData))
            return
        }
        
        do {
            let decodedData = try JSONDecoder().decode(responseModel, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Error Types
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case noData
}
