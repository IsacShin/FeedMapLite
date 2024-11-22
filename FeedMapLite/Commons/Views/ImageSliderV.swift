//
//  ImageSliderV.swift
//  FeedMap
//
//  Created by 신이삭 on 2023/08/25.
//

import SwiftUI
import Kingfisher
import UIKit

struct ImageSliderV: View {
    @Binding var images: [Data]
    
    var body: some View {
        GeometryReader { p in
            TabView {
                ForEach($images, id: \.self) { item in
                    if let imgData = UIImage(data: item.wrappedValue) {
                        Image(uiImage: imgData)
                            .resizable()
                            .scaledToFit()
                            .modifier(ImageModifier(contentSize: CGSize(width: p.size.width, height: p.size.height)))
                    }
                   
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
        
    }
}
