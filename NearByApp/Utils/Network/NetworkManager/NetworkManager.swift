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
    var cacheManager: CacheFileManagerProtocol {get}
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (NetworkResult<T>) -> Void) async
}

final class NetworkManager: NetworkManaging {
    
    static let shared = NetworkManager()
    private let session = URLSession.shared
    private(set) var cacheManager: CacheFileManagerProtocol
    
    private init(cacheManager: CacheFileManagerProtocol = CacheFileManager()){
        self.cacheManager = cacheManager
    }
    
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (NetworkResult<T>) -> Void) async{
        
        guard let urlRequest = endpoint.urlRequest  else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let cacheFileName = cacheManager.cacheFileName(url: urlRequest.url)
        if  !AppManager.shared.isVenuesFetched &&  Reachability.isConnectedToNetwork,
            let data = cacheManager.readFromCache(withName: cacheFileName, validFor: 0)
        {
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
            return
        }
        
        do {
            let (data, response) =  try await URLSession.shared.data(for: urlRequest)
            cacheManager.writeToCache(data, withURL: endpoint.urlRequest?.url)
            
            print("OUTGOING request \(String(describing: response.url))")
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.badHTTPResponse))
                return
            }
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            print("Fetched From API")
            AppManager.shared.isVenuesFetched = true
            completion(.success(decodedData))
            
        }catch{
            completion(.failure(error))
        }
        
    }
    
}
