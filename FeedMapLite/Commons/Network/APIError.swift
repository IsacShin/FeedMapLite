//
//  APIError.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/22/24.
//

import Foundation

enum APIError: Error {
    case dataError
    case decodingError
    case networkError
    case etcError(error: Error)
}
