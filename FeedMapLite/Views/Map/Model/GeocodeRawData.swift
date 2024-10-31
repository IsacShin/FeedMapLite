//
//  GeocodeRawData.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/20/24.
//

import Foundation

struct GeocodeAPI: Codable {
    
    static let path = "https://maps.googleapis.com/maps/api/geocode/json"
    
    struct Request: Codable {
        var address: String
        var key: String
        
        func toDictionary() -> [String: Any]? {
            guard let data = try? JSONEncoder().encode(self) else {
                return nil
            }
            return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
        }
    }
    
    struct ReversedRequest: Codable {
        var latlng: String
        var key: String
        
        func toDictionary() -> [String: Any]? {
            guard let data = try? JSONEncoder().encode(self) else {
                return nil
            }
            return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
        }
    }
    
    struct Response: Codable {
        var results: [AddrRawData]?
        
        struct AddrRawData: Codable {
            var geometry: GeometryRawData?
            var formatted_address: String?
        }

        struct GeometryRawData: Codable {
            var location: LocationRawData?
        }

        struct LocationRawData: Codable {
            let lat: Double?
            let lng: Double?
        }
    }
    
}
