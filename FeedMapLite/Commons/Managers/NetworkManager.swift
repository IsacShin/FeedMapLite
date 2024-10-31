//
//  NetworkManager.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import Foundation
import SwiftUI
import Combine

/// Networing Shared Manager
final class NetworkManager {
    enum HTTPMethod {
        case get
        case post
    }
    
    static let shared = NetworkManager()
    
    func request<T: Codable>(_ urlStr: String,
                             type: T.Type,
                             method: HTTPMethod = .get,
                             headerField: [String: String]? = nil,
                             param: [String: Any] = [:],
                             addEncoding: Bool = true) -> AnyPublisher<T, URLError> {
        guard var urlComponents = URLComponents(string: urlStr) else {
            print("Error: cannot create URLComponents")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request: URLRequest!
        switch method {
        case .get:
            // parameter 추가
            let queryItems = param.map {
                if addEncoding {
                    URLQueryItem(name: $0.key, value: "\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                } else {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
            }
            
            urlComponents.queryItems = queryItems
            
            guard let requestURL = urlComponents.url else {
                print("Error: cannot create URLComponents")
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            request = URLRequest(url: requestURL)
            request.httpMethod = "GET"
        case .post:
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // parameter 추가
            let requestBody = try! JSONSerialization.data(withJSONObject: param, options: [])
            request.httpBody = requestBody
        }
        
        
        // header 추가
        _ = headerField?.map { (key, value) in
            request.addValue(key, forHTTPHeaderField: value)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: type, decoder: JSONDecoder())
            .mapError { error -> URLError in
                // 에러 타입이 URLError인 경우 그대로 반환
                if let urlError = error as? URLError {
                    return urlError
                }
                // URLError가 아닌 다른 에러 타입을 특정 URLError로 변환
                return URLError(.unknown, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            }
            .eraseToAnyPublisher()
    }
    
}
