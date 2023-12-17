//
//  VenueListingEndPoint.swift
//  SugarBoxAssetment
//
//  Created by Vikas Salian on 16/12/23.

import Foundation

struct VenueListingEndPoint: Endpoint {

    var httpMethod: HTTPMethod { .get }
    var queryParameters: [String: Any]?
    var baseURL: URL = URL(string: EndPointConstants.baseURL)!
    let path: String = "2/venues"

    init(queryParameters: [String: Any]?) {
        self.queryParameters = queryParameters
    }

}
