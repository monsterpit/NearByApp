//
//  FeedListingViewModel.swift
//  NearBy
//
//  Created by Vikas Salian on 16/12/23.
//

import Foundation

protocol FeedListingViewModelProtocol{
    func fetchVenues(lat: Double, lon: Double, range: Int) async
    var venues: [Venue] { get }
    var searchTerm: String {get set}
}
 
protocol FeedListingViewModelDelegate{
    func updateVenues()
}

final class FeedListingViewModel: FeedListingViewModelProtocol {
    
    private let venueListingUseCase: VenueListingUseCaseProtocol
    var searchTerm: String = ""
    let delegate: FeedListingViewModelDelegate?
    
    private (set) var venues: [Venue] = []
    init(venueListingUseCase: VenueListingUseCaseProtocol = VenueListingUseCase(),
         delegate: FeedListingViewModelDelegate?) {
        self.venueListingUseCase = venueListingUseCase
        self.delegate = delegate
    }
    
    func fetchVenues(lat: Double, lon: Double, range: Int) async{
        await venueListingUseCase.fecthListing(lat: lat, lon: lon, range: range, searchTerm: searchTerm){ venues in
            self.venues = venues
            self.delegate?.updateVenues()
        }
    }
    
}
