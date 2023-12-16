//
//  VenuesListingRepository.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import Foundation

protocol VenuesListingRepositoryProtocol {
    func fetchMoviesListing(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void) async
}

final class VenuesListingRepositoryRepository: VenuesListingRepositoryProtocol {
    
    private let apiService: VenuesListingApiServiceProtocol

    /// Initializes a new instance of the `VenuesListingRepositoryRepository` class with the specified `VenuesListingApiService` instance.
    /// - Parameter apiService: An instance of `VenuesListingApiServiceProtocol`.
    init(apiService: VenuesListingApiServiceProtocol = VenuesListingApiService()) {
        self.apiService = apiService
    }
    
    func fetchMoviesListing(perPage: Int, pageCount: Int, lat: Double, lon: Double, range: String, searchTerm: String, completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void) async {
        await  apiService.fetchMoviesListing(perPage: perPage,pageCount: pageCount,lat: lat,lon: lon,range: range,searchTerm: searchTerm,completion: completion)
    }

    
}
