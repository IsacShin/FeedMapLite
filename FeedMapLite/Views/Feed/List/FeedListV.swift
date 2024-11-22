//
//  FeedListV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import SwiftUI
import ComposableArchitecture

struct FeedListV: View {
    @Environment(\.modelContext) private var modelContext
    var store: StoreOf<FeedListFeature>

    @State var scrollOffset = CGFloat.zero
    @State var scrollToTop = false
    @State private var isActive = false

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                GeometryReader { g in
                    ZStack {
                        VStack(spacing: 0) {
                            if let feedList = viewStore.feedListRawData {
                                if feedList.count > 0 {
                                    ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
                                        LazyVStack(alignment: .leading) {
                                            ForEach(feedList.indices, id: \.self) { index in
                                                FeedV(feedData: feedList[index])
                                                    .listRowInsets(EdgeInsets())
                                                    .listRowBackground(DARK_COLOR)
                                            }
                                            Divider()
                                                .background(.white)
                                        }
                                        .onChange(of: scrollToTop, { oldValue, newValue in
                                            if newValue {
                                                scrollToTop = false
                                                withAnimation {
                                                    proxy.scrollTo(0, anchor: .top)
                                                }
                                            }
                                        })
                                    }.refreshable {
                                        self.store.send(.getFeedList(context: self.modelContext))
                                    }
                                    .overlay(alignment: .bottomTrailing) {
                                        Button {
                                            withAnimation {
                                                self.scrollToTop = true
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
                            } else {
                                EmptyV()
                            }
                            
                            Divider()
                                .background(.white)
                        }

                        if viewStore.isLoading {
                            CommonLoadingV()
                        }
                        
                        if viewStore.feedListRawData?.count ?? 0 == 0 {
                            EmptyV()
                        }
                    }
                    .onAppear {
                        self.store.send(.getFeedList(context: self.modelContext))
                    }
                }
                .background(DARK_COLOR)

                .navigationTitle("My Feed")
                .navigationBarTitleDisplayMode(.automatic)
            }
        }
    }
}

struct EmptyV: View {
    var body: some View {
        DARK_COLOR
            .overlay {
                Text("작성된 피드가 없습니다.")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
            }
            .offset(y: 34)
    }
}

#Preview {
    FeedListV(store: Store(initialState: FeedListFeature.State(), reducer: {
        FeedListFeature()
    }))
}
