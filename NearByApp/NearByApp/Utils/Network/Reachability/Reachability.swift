//
//  Reachability.swift
//  CurrencyConverter
//
//  Created by Vikas Salian on 13/05/23.
//

import Network

class Reachability {

    static let monitor = NWPathMonitor()
    static let queue = DispatchQueue(label: "Monitor")
    static var isConnectedToNetwork = false

    static func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            isConnectedToNetwork = path.status == .satisfied
        }
    }
    static func stopMonitoring() {
        monitor.cancel()
    }

}
