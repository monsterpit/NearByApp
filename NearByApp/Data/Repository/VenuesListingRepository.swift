//
//  VenuesListingRepository.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import Foundation

protocol VenuesListingRepositoryProtocol {
    func fetchMoviesListing(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void) async
    func fetchCachedMoviesListing(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void)
}

final class VenuesListingRepositoryRepository: VenuesListingRepositoryProtocol {
    
    private let apiService: VenuesListingApiServiceProtocol
    private let caching: VenuesListingCachingServiceProtocol

    /// Initializes a new instance of the `VenuesListingRepositoryRepository` class with the specified `VenuesListingApiService` instance.
    /// - Parameter apiService: An instance of `VenuesListingApiServiceProtocol`.
    init(apiService: VenuesListingApiServiceProtocol = VenuesListingApiService(),
         caching: VenuesListingCachingServiceProtocol = VenuesListingCaching()) {
        self.apiService = apiService
        self.caching = caching
    }
    
    func fetchMoviesListing(perPage: Int, pageCount: Int, lat: Double, lon: Double, range: String, searchTerm: String, completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void) async {
        await apiService.fetchMoviesListing(perPage: perPage,pageCount: pageCount,lat: lat,lon: lon,range: range,searchTerm: searchTerm) {[weak self] networkResponse in
            guard let self else { completion(.failure(NetworkError.noData)); return }
            switch networkResponse{
            case .success(let venueResponse):
                self.caching.cacheResponse(perPage: perPage, pageCount: pageCount, lat: lat, lon: lon, range: range, searchTerm: searchTerm, data: venueResponse)
                completion(.success(venueResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchCachedMoviesListing(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void){
        caching.fetchMoviesListing(perPage: perPage, pageCount: pageCount, lat: lat, lon: lon, range: range, searchTerm: searchTerm, completion: completion)
    }
    
}
