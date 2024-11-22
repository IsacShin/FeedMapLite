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
            ImageSliderV(images: self.$images)
                .frame(height: imgHeight)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .background(.black)
                .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
            Spacer().frame(height: 15)
            VStack(alignment: .leading, spacing: 6) {
                Text(feedData?.addr ?? "                ")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                Spacer().frame(height: 2)
                HStack {
                    Text(feedData?.title ?? "테스트 제목")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                    Spacer()
                    Text(feedData?.date ?? "0000-00-00 00:00:00")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                }
                
                Text(feedData?.comment ?? "테스트 내용 입니다.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .modifier(BlinkingAnimModifier(shouldShow: feedData == nil, opacity: opacity))
                
                Spacer().frame(height: 6)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .background(DARK_COLOR)
        .onAppear(perform: {
            self.images.removeAll()
            if let img1 = self.feedData?.img1 {
                self.images.append(img1)
            }
            if let img2 = self.feedData?.img2 {
                self.images.append(img2)
            }
            if let img3 = self.feedData?.img3 {
                self.images.append(img3)
            }
        })
    }
}
