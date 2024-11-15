//
//  FeedV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 11/15/24.
//

import SwiftUI
import Combine
import Kingfisher

struct FeedV: View {
    var feedData: FeedDataModel?
    @State var opacity: Double = 1.0
    @State var images: [Data] = [Data]()
    @State var imgHeight: CGFloat = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text(feedData?.addr ?? "                ")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                .offset(x: 48, y: -5)
                
            Spacer().frame(height: 15)
            
            ImageSliderV(images: self.$images)
            .frame(height: imgHeight)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
            Spacer().frame(height: 15)
            VStack(alignment: .leading, spacing: 6) {
                Text(feedData?.title ?? "테스트 제목")
                    .font(.bold(size: 18))
                    .foregroundColor(.white)
                    .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                Text(feedData?.comment ?? "테스트 내용 입니다.")
                    .font(.regular(size: 16))
                    .foregroundColor(.white)
                    .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                Text(feedData?.date?.wddSimpleDateForm() ?? "0000-00-00 00:00:00")
                    .font(.regular(size: 12))
                    .foregroundColor(.white)
                    .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                Spacer().frame(height: 14)
            }
            .padding(.horizontal, 20)
            .onAppear(perform: {
                self.images.removeAll()
                var heights = [CGFloat]()
                if let img1 = self.feedData?.img1,
                   let url = URL(string: img1) {
                    self.getURLImageHeight(url: url) { height in
                        self.images.append(img1)
                        heights.append(height)
                        if images.count == 1 {
                            let totalHeight = heights.reduce(0, +)
                            let avgHeight = totalHeight / Double(heights.count)
                            self.imgHeight = avgHeight
                        }
                        if let img2 = self.feedData?.img2,
                           let url = URL(string: img2) {
                            self.getURLImageHeight(url: url) { height in
                                self.images.append(img2)
                                heights.append(height)
                                if images.count == 2 {
                                    let totalHeight = heights.reduce(0, +)
                                    let avgHeight = totalHeight / Double(heights.count)
                                    self.imgHeight = avgHeight
                                }
                                if let img3 = self.feedData?.img3,
                                   let url = URL(string: img3) {
                                    self.getURLImageHeight(url: url) { height in
                                        self.images.append(img3)
                                        heights.append(height)
                                        if images.count == 3 {
                                            let totalHeight = heights.reduce(0, +)
                                            let avgHeight = totalHeight / Double(heights.count)
                                            self.imgHeight = avgHeight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            })
            
        }
        .frame(maxWidth: .infinity)
        .background(DARK_COLOR)
    }
}
