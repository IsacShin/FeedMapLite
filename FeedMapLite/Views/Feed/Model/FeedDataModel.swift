//
//  FeedDataModel.swift
//  FeedMapLite
//
//  Created by 신이삭 on 10/30/24.
//

import Foundation
import SwiftData

@Model
final class FeedDataModel {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var addr: String?
    var date: String
    var comment: String?
    var latitude: String?
    var longitude: String?
    var img1: Data?
    var img2: Data?
    var img3: Data?
    
    init(title: String, addr: String? = nil, date: String, comment: String? = nil, latitude: String? = nil, longitude: String? = nil, img1: Data? = nil, img2: Data? = nil, img3: Data? = nil) {
        self.title = title
        self.addr = addr
        self.date = date
        self.comment = comment
        self.latitude = latitude
        self.longitude = longitude
        self.img1 = img1
        self.img2 = img2
        self.img3 = img3
    }
}
