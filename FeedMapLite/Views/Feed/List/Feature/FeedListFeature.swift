//
//  FeedListFeature.swift
//  FeedMapLite
//
//  Created by 신이삭 on 11/15/24.
//

import Foundation
import ComposableArchitecture
import CoreLocation
import Combine
import UIKit
import SwiftData

@Reducer
struct FeedListFeature {
    struct State: Equatable {
        var isLoading: Bool = false
        var feedListRawData: [FeedDataModel]? = nil
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case getFeedList(context: ModelContext)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer() // 바인딩 된 state값을 업데이트 시켜줌
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .getFeedList(context):
                state.isLoading = true
                let feedList = try! context.fetch(FetchDescriptor<FeedDataModel>())
                state.feedListRawData = feedList
                state.isLoading = false
                return .none
            }
        }
    }
}
