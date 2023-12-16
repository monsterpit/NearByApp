//
//  Endpoints.swift
//  CurrencyConverter
//
//  Created by Vikas Salian on 14/05/23.
//

import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var queryParameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var body: [String: Any]? { get }
    var urlRequest: URLRequest? {get}
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
}

extension Endpoint {

    var headers: [String: String]? {
          return nil
      }

    var body: [String: Any]? {
        nil
    }

    var cachePolicy: URLRequest.CachePolicy {
         return .useProtocolCachePolicy
     }

     var timeoutInterval: TimeInterval {
         return 30
     }

    var urlRequest: URLRequest? {
        makeRequest()
    }

    private func makeRequest() -> URLRequest? {
        // Construct the URL for the request
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        var queryItems = queryParameters?.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        queryItems?.append(URLQueryItem(name: "client_id", value: "Mzg0OTc0Njl8MTcwMDgxMTg5NC44MDk2NjY5"))
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }

        // Create the request object and set its properties
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body, let bodyData =  try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = bodyData
        }

        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
