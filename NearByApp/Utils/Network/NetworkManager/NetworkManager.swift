//
//  NetworkManager.swift
//  CurrencyConverter
//
//  Created by Vikas Salian on 14/05/23.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badHTTPResponse
    case decodingError
    case noData
}

enum NetworkResult<T> {
    case success(T)
    case failure(Error)
}

protocol NetworkManaging {
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (NetworkResult<T>) -> Void) async
}

final class NetworkManager: NetworkManaging {
    
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    private init(){}
    
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (NetworkResult<T>) -> Void) async{
        
        guard let urlRequest = endpoint.urlRequest  else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        do {
            let (data, response) =  try await URLSession.shared.data(for: urlRequest)
            
            print("OUTGOING request \(String(describing: response.url))")
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.badHTTPResponse))
                return
            }
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            print("Fetched From API")
            completion(.success(decodedData))
            
        }catch{
            completion(.failure(error))
        }
        
    }
    
}
