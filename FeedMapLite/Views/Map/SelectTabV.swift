//
//  SelectTabV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 11/5/24.
//

import SwiftUI
import Kingfisher
import CoreLocation
import ComposableArchitecture
import UIKit

struct SelectTabV: View {
    
    @Binding var selectFeedData: FeedDataModel?
    @Binding var isActive: Bool
    
    var body: some View {
        
        if let selectFeedData = self.selectFeedData {
            GeometryReader { g in
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        Spacer().frame(height: 8)
                        Text(selectFeedData.date.wddSimpleDateForm() ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .regular))
                        Text(selectFeedData.addr ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular))
                        
                        if let lat = selectFeedData.latitude,
                           let lng = selectFeedData.longitude,
                           let dLat = Double(lat),
                           let dLng = Double(lng) {
                            let loca = CLLocation(latitude: dLat, longitude: dLng)
                            NavigationLink(destination: {
                                FeedWriteV(
                                    store: Store(initialState: FeedWriteFeature.State(id: selectFeedData.id),
                                                 reducer: { FeedWriteFeature() }),
                                    isUpdateV: true,
                                    loca: loca,
                                    address: selectFeedData.addr,
                                    isActive: $isActive,
                                    selectFeedData: selectFeedData
                                )
                            }) {
                                if let img = selectFeedData.img1 ?? nil {
                                    Image(uiImage: UIImage(data: img)!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: g.size.width - 40, height: 200)
                                        .cornerRadius(16)
                                        .clipped()
                                }
                            }
                        }
                        
                        Text(selectFeedData.title)
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .regular))
                        Text(selectFeedData.comment ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular))
                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 20)
                    .background(VisualEffectBlur(blurStyle: .dark))
                    .cornerRadius(radius: 16.0, corners: [.topLeft, .topRight])
                }
                
            }
        }
        
    }
}

struct SelectTabV_Previews: PreviewProvider {
    static var previews: some View {
        SelectTabV(selectFeedData: .constant(nil),
                   isActive: .constant(false))
    }
}
