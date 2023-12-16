//
//  VenueListingUseCase.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import Foundation

protocol VenueListingUseCaseProtocol{

    func fecthListing(lat: Double, lon: Double, range: Int, searchTerm: String,completion: @escaping ([Venue]) -> Void) async
}

final class VenueListingUseCase: VenueListingUseCaseProtocol{
    
    private let listingRepository: VenuesListingRepositoryProtocol
    
    private var pageCount = 1
    private let perPage = 10
    private var venueLists: [Venue] = []
    private var totalCount: Int?
    private var range: Int = 0
    private var searchTerm: String = ""

    init(listingRepository: VenuesListingRepositoryProtocol = VenuesListingRepositoryRepository()) {
        self.listingRepository = listingRepository
    }
    
    func fecthListing( lat: Double, lon: Double, range: Int, searchTerm: String,completion: @escaping ([Venue]) -> Void) async{
        if self.searchTerm != searchTerm ||  self.range != range{
            pageCount = 1
            venueLists = []
            self.range = range
            self.searchTerm  = searchTerm
        }
        if  totalCount  == nil || totalCount != venueLists.count{
            await listingRepository.fetchMoviesListing(perPage: perPage, pageCount: pageCount, lat: lat, lon: lon, range: "\(range)mi", searchTerm: searchTerm) { result in
                switch result {
                case .success(let venueResponse):
                    self.pageCount += 1
                    self.totalCount = venueResponse.meta.total
                    self.venueLists.append(contentsOf: venueResponse.venues)
                    
                    completion(self.venueLists)
                case .failure(let error):
                    print("Error fetching exchange rates \(error.localizedDescription)")
                }
            }
        }
    }
    
}

