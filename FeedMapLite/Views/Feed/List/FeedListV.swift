//
//  FeedListV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import SwiftUI

struct FeedListV: View {
    @State var scrollOffset = CGFloat.zero
    @State var scrollToTop = false
    @State var isLoading: Bool = false

    var body: some View {
        GeometryReader { g in
            ZStack {
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: 10)
                    
                    if let list = self.list, list.count > 0 {
                        ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
//                            LazyVStack(alignment: .leading) {
//                                ForEach(list.indices, id: \.self) { index in
//                                    FeedV(vm: self.vm, feedData: list[index])
//                                        .listRowInsets(EdgeInsets())
//                                        .listRowBackground(DARK_COLOR)
//                                }
//                            }
//                            .onChange(of: scrollToTop) { newValue in
//                                if newValue {
//                                    scrollToTop = false
//                                    withAnimation {
//                                        proxy.scrollTo(0, anchor: .top)
//                                    }
//                                }
//                            }
                            
                        }.refreshable {
                            self.isLoading = true
//                            vm.getFeedList(type: "all") {
//                                self.isLoading = false
//                            }
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                withAnimation {
                                    scrollToTop = true
                                }
                            } label: {
                                Image("btnArrowSt1")
                                    .frame(width: 40,height: 40)
                                    .background(DARK_COLOR.opacity(0.8))
                                    .clipShape(Circle())
                                    .aspectRatio(contentMode: .fit)
                                    .offset(x: -10, y: -10)
                            }
                            .opacity(self.scrollOffset > 0 ? 1.0 : 0.0)
                            
                        }
                        
                    }
                }

                if isLoading {
                    CommonLoadingV()
                }
                
                if self.list?.count == 0 {
                    DARK_COLOR
                        .overlay {
                            Text("작성된 피드가 없습니다.")
                                .font(.bold(size: 17))
                                .foregroundColor(.white)
                        }
                        .offset(y: 54)
                }
            }
            
        }
        .background(DARK_COLOR)

    }
}

#Preview {
    FeedListV()
}
