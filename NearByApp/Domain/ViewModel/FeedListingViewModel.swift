//
//  FeedListingViewModel.swift
//  NearBy
//
//  Created by Vikas Salian on 16/12/23.
//
import Combine
import Foundation

protocol FeedListingViewModelProtocol{
    var venues: CurrentValueSubject<[Venue], Never>{ get }
    var searchTerm: String {get set}
    var latitude: Double {get }
    var longitude: Double {get }
    func fetchVenues( range: Int) async
    func setLocation(latitude: Double,longitude: Double)
}

final class FeedListingViewModel: FeedListingViewModelProtocol {
    
    private let venueListingUseCase: VenueListingUseCaseProtocol
    var searchTerm: String = ""
    private(set) var latitude: Double = 0
    private(set) var longitude: Double = 0
    
    private (set) var venues = CurrentValueSubject<[Venue], Never>([Venue]())
    
    init(venueListingUseCase: VenueListingUseCaseProtocol = VenueListingUseCase()) {
        self.venueListingUseCase = venueListingUseCase
    }
    
    func fetchVenues(range: Int) async{
        await venueListingUseCase.fecthListing(lat: latitude,
                                               lon: longitude,
                                               range: range,
                                               searchTerm: searchTerm)
        { venues in
            self.venues.send(venues)
        }
    }
    
    func setLocation(latitude: Double,longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }

 
}
