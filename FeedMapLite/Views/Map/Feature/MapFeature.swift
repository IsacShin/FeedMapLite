//
//  MapReducer.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/31/24.
//

import Foundation
import ComposableArchitecture
import CoreLocation
import Combine
import SwiftData

@Reducer
struct MapFeature {
    // UI 렌더 시 필요한 데이터 집합
    struct State: Equatable {
        // 초기화
        var isInitialized: Bool = false
        // View관련
        var zoomLevel: Float = 15
        var alertType: CommonAlertType = .isCheckCurrentLocationFail
        @BindingState var showAlert = false
        @BindingState var showFeedWrite = false
        var isCheckCurrentLocationFail: Bool = false
        var moveLocation: CLLocation? = nil
        var isSelectTab: Bool = false
        var isFeedCheck: Bool = false
        var centerLocation: CLLocation? = nil
        var isUpdateCheck: Bool = false
        var centerAddr: String? = nil
        var isActive = false
        
        // 네트워크 요청
        var isLoading: Bool = false
        var errorMessage: String?
        var feedListRawData: [FeedDataModel]? = nil
        @BindingState var selectFeedRawData: FeedDataModel? = nil
        
        // 현재 위치 상태 추가
        var currentLocation: CLLocation? = nil
        
        var context: ModelContext?
    }
    // 유저 이벤트 및 View에서 생길 수 있는 모든 Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        // 화면진입시 초기화
        case initialize
        // 역 지오코딩 API요청
        case fetchAddrGeocode(param: GeocodeRequest)
        // 역 지오코딩 API응답
        case fetchAddrGeocodeResponse(result: Result<GeocodeAPI.Response, APIError>)
        // 지도설정 변경
        case setMapView(zoomLevel: Float? = nil,
                        moveLocation: CLLocation? = nil,
                        isUpdateCheck: Bool = false)
        // 중앙위치 설정
        case setCenterPosition(cLocation: CLLocation)
        
        // CoreLocation 관련 액션
        case requestLocation(context: ModelContext)
        case locationManager(LocationManager.Action)
        
        case showAlert(isShow: Bool, alertType: CommonAlertType)
        case isExistFeedCheck(cLocation: CLLocation?)
        
        case getFeedList
        
        case isShowSelectTab(isSelectTab: Bool, selectData: FeedDataModel?)
    }
    
    struct Environment {
        var geocodeApiClient: GeocodeAPIClient
        var locationManager: LocationManager
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }
    
    var environment: Environment
    
    // 스토어의 상태변화 관찰하여 State 상태 변경
    var body: some ReducerOf<Self> {
        BindingReducer() // 바인딩 된 state값을 업데이트 시켜줌
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .initialize:
                state.isInitialized = true
                return .run { send in
                    await send(.getFeedList)
                }
            case .getFeedList:
                let feedList = try! state.context?.fetch(FetchDescriptor<FeedDataModel>())
                state.isUpdateCheck = true
                state.feedListRawData = feedList
                return .none
            case .fetchAddrGeocode(param: let geocodeRequest):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let result = try await environment.geocodeApiClient.fetchData(geocodeRequest)
                    await send(.fetchAddrGeocodeResponse(result: result))
                }
            case let .fetchAddrGeocodeResponse(.success(result)):
                print("DEBUG: API 결과 > result = \(result)")
                state.isLoading = false
                
                if let formatted_address = result.results?.first?.formatted_address {
                    state.centerAddr = formatted_address
                }
                
                if let location = result.results?.first?.geometry?.location,
                   let lat = location.lat,
                   let lng = location.lng {
                    let moveLocation = CLLocation(latitude: CLLocationDegrees(lat),
                                                  longitude: CLLocationDegrees(lng))
                    
                    return .run { send in
                        await send(.setMapView(zoomLevel: nil,
                                               moveLocation: moveLocation,
                                               isUpdateCheck: true))
                    }
                }
                return .none
            case let .isExistFeedCheck(cLocation: loca):
                guard let loca = loca else { return .none }
                let latitude = String(format: "%.4f", Double(loca.coordinate.latitude))
                let longitude = String(format: "%.4f", Double(loca.coordinate.longitude))
                
                let feedList = try! state.context?.fetch(FetchDescriptor<FeedDataModel>())
                if let _ = feedList?.filter({ $0.latitude == latitude && $0.longitude == longitude }).first { // 피드 존재 시
                    return .run { send in
                        await send(.showAlert(isShow: true,
                                              alertType: .feedExists))
                    }
                } else {
                    return .run { send in
                        await send(.showAlert(isShow: true,
                                              alertType: .feedNotExists))
                    }
                }
            case let .fetchAddrGeocodeResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .setMapView(zoomLevel: let zoomLevel,
                             moveLocation: let moveLocation,
                             isUpdateCheck: let isUpdateCheck):
                state.isUpdateCheck = isUpdateCheck
                
                if let zoomLevel = zoomLevel {
                    state.zoomLevel = zoomLevel
                }
                
                if let moveLocation = moveLocation {
                    state.moveLocation = moveLocation
                }
                
                return .run { send in
                    await send(.isExistFeedCheck(cLocation: moveLocation))
                }
                
                // 위치 요청을 처리
            case .requestLocation(context: let context):
                state.isLoading = true
                state.context = context
                return .run { send in
                    await withCheckedContinuation { continuation in
                        environment.locationManager.setDelegate(
                            delegate: LocationManager.Delegate(
                                didChangeAuthorization: { status in
                                    Task { @MainActor in
                                        send(.locationManager(.didChangeAuthorization(status)))
                                        continuation.resume()
                                    }
                                },
                                didUpdateLocations: { result in
                                    Task { @MainActor in
                                        send(.locationManager(.didUpdateLocations(result)))
                                        continuation.resume()
                                    }
                                }
                            )
                        )
                        environment.locationManager.requestLocation()
                    }
                    await send(.initialize)
                }
                
            case let .locationManager(.didChangeAuthorization(status)):
                state.isLoading = false
                return .run { send in
                    switch status {
                    case .authorizedAlways, .authorizedWhenInUse: break
                    default:
                        await send(.showAlert(isShow: true,
                                              alertType: .isCheckCurrentLocationFail))
                    }
                }
                
            case let .locationManager(.didUpdateLocations(.success(location))):
                state.isUpdateCheck = true
                state.moveLocation = location
                state.isLoading = false
                return .none
                
            case .locationManager(.didUpdateLocations(.failure)):
                // 위치 업데이트 실패 시 처리
                return .run { send in
                    await send(.showAlert(isShow: true,
                                          alertType: .isCheckCurrentLocationFail))
                }
                
            case .showAlert(isShow: let isShow,
                            alertType: let alertType):
                state.showAlert = isShow
                state.alertType = alertType
                return .none
                
            case let .setCenterPosition(cLocation):
                state.centerLocation = cLocation
                return .none
                
            case let .isShowSelectTab(isSelectTab, selectData):
                state.isSelectTab = isSelectTab
                state.selectFeedRawData = selectData
                return .none
            }
        }
    }
}
