//
//  VenuesListingResponse.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import Foundation

struct VenuesListingResponse: Codable{
    let venues: [Venue]
    let meta: Meta
}

struct Venue: Codable{
    let name: String
    let slug: String
    let city: String
    let address: String
    let url: String
    
    var venueAddress: String{
        name + city  + address
    }
}

struct Meta: Codable{
    let total: Int
}
