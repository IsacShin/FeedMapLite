//
//  WebViewFeature.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/26/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WebViewFeature {
    
    @ObservableState
    struct State: Equatable {
        var jsAlert: String?
        var isShowIndicator: Bool = false
        var isShowAlert: Bool = false
        var isDismiss: Bool = false
    }
    
    enum Action {
        case showIndicator(isShowIndicator: Bool)
        case showAlert(isShowAlert: Bool, alertMsg: String?)
        case dismiss
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .showIndicator(isShowIndicator):
                state.isShowIndicator = isShowIndicator
                return .none
            case let .showAlert(isShowAlert, alertMsg):
                state.isShowAlert = isShowAlert
                state.jsAlert = alertMsg
                return .none
            case .dismiss:
                state.isDismiss = true
                return .none
            }
        }
    }
}
