//
//  FeedWriteFeature.swift
//  FeedMapLite
//
//  Created by 신이삭 on 9/5/24.
//

import Foundation
import ComposableArchitecture
import CoreLocation
import Combine
import UIKit
import SwiftData

@Reducer
struct FeedWriteFeature {
    struct State: Equatable {
        @BindingState var comment: String = ""
        @BindingState var title: String = ""
        var addr: String = ""
        var imgs: [UIImage] = []
        var alertType: CommonAlertType = .feedTitleNotExists
        @BindingState var showAlert = false
        @BindingState var showPhotoPicker = false
        var isLoading = false
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case removeImgAction(idx: Int)
        case showPhotoPicker(isShow: Bool)
        case showAlert(isShow: Bool, alertType: CommonAlertType)
        case uploadFeed(isUpdateV: Bool, loca: CLLocation?, context: ModelContext)
        case setData(feedData: FeedDataModel?, address: String?)
        case removeFeed(feedData: FeedDataModel, context: ModelContext)
        case setImages(imgs: [UIImage])
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer() // 바인딩 된 state값을 업데이트 시켜줌
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .removeImgAction(idx):
                state.imgs.remove(at: idx)
                return .none
            case let .showPhotoPicker(isShow):
                state.showPhotoPicker = isShow
                return .none
            case .showAlert(isShow: let isShow,
                            alertType: let alertType):
                state.showAlert = isShow
                state.alertType = alertType
                return .none
            case .uploadFeed(isUpdateV: let isUpdateV, loca: let loca, context: let context):
                if state.title == "" {
                    return .run { send in
                        await send(.showAlert(isShow: true,
                                              alertType: .feedTitleNotExists))
                    }
                } else if state.comment == "" {
                    return .run { send in
                        await send(.showAlert(isShow: true,
                                              alertType: .feedCommentNotExists))
                    }
                } else if state.imgs.count <= 0 {
                    return .run { send in
                        await send(.showAlert(isShow: true,
                                                  alertType: .feedImgNotExists))
                    }
                } else {
                    guard let loca = loca else {
                        return .none
                    }
                    
                    state.isLoading = true
                    
                    let latitude = String(format: "%.4f", Double(loca.coordinate.latitude))
                    let longitude = String(format: "%.4f", Double(loca.coordinate.longitude))
                    let feedData = FeedDataModel(title: state.title,
                                                 addr: state.addr,
                                                 date: Date.now.wddSimpleDateForm(),
                                                 comment: state.comment,
                                                 latitude: latitude,
                                                 longitude: longitude,
                                                 img1: state.imgs.count > 0 ? state.imgs[0].jpegData(compressionQuality: 0.1) : nil,
                                                 img2: state.imgs.count > 1 ? state.imgs[1].jpegData(compressionQuality: 0.1) : nil,
                                                 img3: state.imgs.count > 2 ? state.imgs[2].jpegData(compressionQuality: 0.1) : nil)

                    if isUpdateV {
                        // 수정
                        let feedList = try! context.fetch(FetchDescriptor<FeedDataModel>())
                        guard let updateFeed = feedList.filter({ $0.id == feedData.id }).first else {
                            return .none
                        }
                        
                        updateFeed.title = state.title
                        updateFeed.date = Date.now.wddSimpleDateForm()
                        updateFeed.comment = state.comment
                        updateFeed.img1 = state.imgs.count > 0 ? state.imgs[0].jpegData(compressionQuality: 0.1) : nil
                        updateFeed.img2 = state.imgs.count > 1 ? state.imgs[1].jpegData(compressionQuality: 0.1) : nil
                        updateFeed.img3 = state.imgs.count > 2 ? state.imgs[2].jpegData(compressionQuality: 0.1) : nil
                        return .run { send in
                            await send(.showAlert(isShow: true,
                                                  alertType: .feedWriteSuccess))
                        }
                    } else {
                        // 등록
                        context.insert(feedData)
                        return .run { send in
                            await send(.showAlert(isShow: true,
                                                  alertType: .feedWriteSuccess))
                        }
                    }
                }
                
            case .setData(feedData: let feedData,
                          address: let address):
                if let feedData = feedData {
                    state.title = feedData.title
                    state.comment = feedData.comment ?? ""
                    state.addr = feedData.addr ?? ""
                    if let img1 = feedData.img1, let imgData = UIImage(data: img1) {
                        state.imgs.append(imgData)
                    }
                    if let img2 = feedData.img2, let imgData = UIImage(data: img2) {
                        state.imgs.append(imgData)
                    }
                    if let img3 = feedData.img3, let imgData = UIImage(data: img3) {
                        state.imgs.append(imgData)
                    }
                } else {
                    if let address = address {
                        state.addr = address
                    }
                }
                return .none
            case .removeFeed(feedData: let feedData, context: let context):
                context.delete(feedData)
                return .run { send in
                    await send(.showAlert(isShow: true,
                                              alertType: .feedDeleteSuccess))
                }
            case .setImages(imgs: let imgs):
                state.imgs = imgs
                return .none
            }
        }
    }
}
