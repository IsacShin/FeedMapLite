//
//  GeocodeAPIClient.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/22/24.
//

import Foundation
import ComposableArchitecture

enum GeocodeRequest {
    case normal(GeocodeAPI.Request)
    case reversed(GeocodeAPI.ReversedRequest)
}

struct GeocodeAPIClient {
    var fetchData: (GeocodeRequest) async throws -> Result<GeocodeAPI.Response, APIError>
}

extension GeocodeAPIClient: DependencyKey {
    static let liveValue = GeocodeAPIClient { request in
        guard var components = URLComponents(string: GeocodeAPI.path) else { throw APIError.networkError }
        
        var paramDic: [String: Any]?
        switch request {
        case let .normal(req):
            if let paramDic = req.toDictionary() {
                components.queryItems = paramDic.map {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
            }
            break
        case let .reversed(req):
            if let paramDic = req.toDictionary() {
                components.queryItems = paramDic.map {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
            }
            break
        }
        
        
        guard let url = components.url else {
            throw APIError.networkError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(returning: .failure(.etcError(error: error)))
                    return
                }
                
                guard let data = data else {
                    continuation.resume(returning: .failure(.dataError))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(GeocodeAPI.Response.self, from: data)
                    continuation.resume(returning: .success(response))
                } catch {
                    continuation.resume(returning: .failure(.decodingError))
                }
            }.resume()
        }
    }
}
