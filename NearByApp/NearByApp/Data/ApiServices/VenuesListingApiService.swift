//
//  VenuesListingApiService.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import Foundation

protocol VenuesListingApiServiceProtocol {
    func fetchMoviesListing(perPage: Int,pageCount: Int,lat: Double,lon: Double,range: String,searchTerm: String,completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void) async
}

final class VenuesListingApiService: VenuesListingApiServiceProtocol {

    /// The object that handles the network requests and responses.
    private let networkManager: NetworkManaging
    
    
    /// Initializes a new instance of the `VenuesListingApiService` class.
    /// - Parameter networkManager: networkManager: The object that handles the network requests and responses. By default, this is set to a new instance of the `NetworkManager` class.
    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchMoviesListing(perPage: Int,pageCount: Int, lat: Double, lon: Double, range: String, searchTerm: String, completion: @escaping (NetworkResult<VenuesListingResponse>) -> Void) async {
        let queryParams: [String : Any] = ["per_page": perPage,
                           "page": pageCount,
                           "lat": lat,
                           "lon": lon,
                           "range": range,
                           "q":searchTerm
        ]
        await networkManager.request(VenueListingEndPoint(queryParameters: queryParams), completion: completion)
        
    }
    
}
