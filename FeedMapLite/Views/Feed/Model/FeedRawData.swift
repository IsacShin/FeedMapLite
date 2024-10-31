//
//  FeedRawData.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/31/24.
//

import Foundation

struct FeedListAPI: Codable {
    struct Request: Codable {
        var memId: String
        var type: String
    }
    
    struct Response: Codable, Hashable {
        var list: [FeedRawData]?

        struct FeedRawData: Codable, Identifiable, Hashable {
            var uId = UUID()
            var id : Int?
            var title: String?
            var addr: String?
            var date: String?
            var comment: String?
            var latitude: String?
            var longitude: String?
            var memid: String?
            var img1: String?
            var img2: String?
            var img3: String?
            
            enum CodingKeys: String, CodingKey {
                case id
                case title
                case addr
                case date
                case comment
                case latitude
                case longitude
                case memid
                case img1
                case img2
                case img3
            }
        }
    }
}
