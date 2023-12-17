//
//  CachingService.swift
//  NearByApp
//
//  Created by Vikas Salian on 17/12/23.
//

import Foundation
 
protocol  VenuesListingCachingServiceProtocol{
    func fetchMoviesListing<T: Codable>(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<T>) -> Void)
    func cacheResponse<T: Codable>(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,data: T)
}

class VenuesListingCaching: VenuesListingCachingServiceProtocol{
    
    private let cacheManager: CacheFileManagerProtocol
    
    init(cacheManager: CacheFileManagerProtocol = CacheFileManager()) {
        self.cacheManager = cacheManager
    }
    
    func fetchMoviesListing<T: Codable>(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<T>) -> Void){
        let queryParams: [String : Any] = ["per_page": perPage,
                           "page": pageCount,
                           "lat": lat,
                           "lon": lon,
                           "range": range,
                           "q":searchTerm
        ]
        let endpoint = VenueListingEndPoint(queryParameters: queryParams)
        
        if let cachedData:T  = cacheManager.readFromCache(withURL: endpoint.urlRequest?.url, validFor: 0){
            completion(.success(cachedData))
        }else{
            completion(.failure(NetworkError.decodingError))
        }
    }
    
    func cacheResponse<T: Codable>(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,data: T){
        let queryParams: [String : Any] = ["per_page": perPage,
                           "page": pageCount,
                           "lat": lat,
                           "lon": lon,
                           "range": range,
                           "q":searchTerm
        ]
        let endpoint = VenueListingEndPoint(queryParameters: queryParams)
       
        cacheManager.writeToCache(data, withURL: endpoint.urlRequest?.url)
    }
}
