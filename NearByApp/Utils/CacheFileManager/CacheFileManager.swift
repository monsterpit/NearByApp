//
//  CacheFileManager.swift
//  NearByApp
//
//  Created by Vikas Salian on 17/12/23.
//

import Foundation

protocol CacheFileManagerProtocol{
    func cacheFileName(url: URL?) -> String
    func writeToCache(_ data: Data, withName name: String)
    func writeToCache(_ data: Data, withURL url: URL?)
    func writeToCache(_ data: Codable, withURL url: URL?)
    func readFromCache(withName name: String, validFor seconds: TimeInterval) -> Data?
    func readFromCache<T: Codable>(withName name: String, validFor seconds: TimeInterval) -> T?
    func readFromCache(withURL url: URL?, validFor seconds: TimeInterval) -> Data?
    func readFromCache<T: Codable>(withURL url: URL?, validFor seconds: TimeInterval) -> T?
}

final class CacheFileManager: CacheFileManagerProtocol{
    
    func writeToCache(_ data: Data, withName name: String) {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileUrl = cacheDir.appendingPathComponent(name)

        do {
            try data.write(to: fileUrl)
        } catch {
            print("Failed to write data to cache: \(error)")
        }
    }
    
    func writeToCache(_ data: Data, withURL url: URL?){
        let fileName = cacheFileName(url: url)
        writeToCache(data, withName: fileName)
    }
    
    func writeToCache(_ data: Codable, withURL url: URL?){
        do {
            let data  = try JSONEncoder().encode(data)
            let fileName = cacheFileName(url: url)
            writeToCache(data, withName: fileName)
        }catch{
            print("Error occured while saving data \(error)")
        }
    }

    func readFromCache(withName name: String, validFor seconds: TimeInterval = 0) -> Data? {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileUrl = cacheDir.appendingPathComponent(name)

        guard let data = try? Data(contentsOf: fileUrl) else {
            return nil
        }

        let fileCreationTime = try? FileManager.default.attributesOfItem(atPath: fileUrl.path)[.modificationDate] as? Date
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(fileCreationTime ?? currentTime)

        if timeSinceCreation > seconds && Reachability.isConnectedToNetwork {
            // Cache is stale and you are connected to network else return data
            return nil
        }
        print("Fetched From Saved Data")
        return data
    }
    
    func readFromCache<T: Codable>(withName name: String, validFor seconds: TimeInterval) -> T? {
        if let data = readFromCache(withName : name,validFor : seconds){
            do {
                return try JSONDecoder().decode(T.self, from: data)
            }catch{
                print("Failed to decode cached data \(error)")
            }
        }
        return nil
    }
    
    func readFromCache(withURL url: URL?, validFor seconds: TimeInterval) -> Data? {
        let cachedNamed = cacheFileName(url: url)
        return readFromCache(withName: cachedNamed, validFor: seconds)
    }
    
    func readFromCache<T: Codable>(withURL url: URL?, validFor seconds: TimeInterval) -> T? {
        let cachedNamed = cacheFileName(url: url)
        return readFromCache(withName: cachedNamed, validFor: seconds)
    }

    func cacheFileName(url: URL?) -> String {
        var fileName = url?.absoluteString ?? "default"
        if let query = url?.query {
            fileName += "?\(query)"
        }
        let cacheFileName = fileName.replacingOccurrences(of: "[^a-zA-Z0-9]+", with: "_", options: .regularExpression)
        return String(cacheFileName.hash)
    }
}

