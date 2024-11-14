//
//  ContentView.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import SwiftUI
import Combine
import GoogleMaps
import GooglePlaces
import ComposableArchitecture

struct MapV: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var cancellables: Set<AnyCancellable> = []
    @State private var showFeedWrite = false
    @State private var isActive = false
    @State private var isSelectTab = false

    var store: StoreOf<MapFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .center) {
                            MapView(store: viewStore)
                                .ignoresSafeArea(.all)
                            
                            VStack(alignment: .center, spacing: 0) {
                                Spacer().frame(height: 16)
                                
                                NavigationLink(destination: CommonWebV(
                                    store: Store(initialState: WebViewFeature.State(),
                                                 reducer: {
                                    WebViewFeature()
                                }), urlStr: "https://isacshin.github.io/daumSearch/")) {
                                    Image("searchBar")
                                        .resizable()
                                        .aspectRatio(353/58, contentMode: .fill)
                                        .frame(width: geometry.size.width - 40, height: 58)
                                }
                                
                                Spacer()
                                
                                Button {
                                    guard let location = viewStore.centerLocation else { return }
                                    print(location.coordinate.latitude)
         
                                    viewStore.send(.fetchAddrGeocode(param: .reversed(GeocodeAPI.ReversedRequest(latlng: "\(location.coordinate.latitude),\(location.coordinate.longitude)",
                                                                                                                 key: GMAP_KEY))))
                                    
                                } label: {
                                    HStack {
                                        Image("cRefres")
                                            .colorMultiply(.black)
                                        Spacer().frame(width: 6)
                                        Text("현 지역에서 검색")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 137, height: 40)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                }
                                
                                Spacer().frame(height: 20)
                            }
                            .frame(minHeight: geometry.size.height)
                            
                            if self.isSelectTab {
                                SelectTabV(selectFeedData: viewStore.$selectFeedRawData,
                                           isActive: $isActive)
                            }
                        }
                    }
                    
                    .navigationDestination(isPresented: $showFeedWrite, destination: {
                        
                        FeedWriteV(store: Store(initialState: FeedWriteFeature.State(),
                                                reducer: {
                            FeedWriteFeature()
                        }),
                                   isUpdateV: false,
                                   loca: viewStore.centerLocation,
                                   address: viewStore.centerAddr,
                                   isActive: $isActive)
                    })
                }
                .tint(.white)
                .navigationViewStyle(StackNavigationViewStyle())

                if viewStore.isLoading {
                    CommonLoadingV()
                }
            }
            .onChange(of: isActive, {
                if isActive {
                    //getFeedList
                    viewStore.send(.getFeedList)
                    viewStore.send(.isShowSelectTab(isSelectTab: false, selectData: nil))
                }
            })
            .onChange(of: viewStore.isSelectTab, {
                self.isSelectTab = viewStore.isSelectTab
            })
            .task {
                self.setNaviBarAppearnce()
                let notiCenter = NotificationCenter.default.publisher(for: Notification.Name("addrInfo"))
                notiCenter
                    .sink { noti in
                        guard let userInfo = noti.userInfo,
                              let jibunAddress = userInfo["jibunAddress"] as? String else { return }
                        viewStore
                            .send(.fetchAddrGeocode(param: .normal(GeocodeAPI.Request(address: jibunAddress,
                                                                                      key: GMAP_KEY))))
                    }
                    .store(in: &self.cancellables)
                
                if !viewStore.isInitialized {
                    viewStore.send(.requestLocation(context: self.modelContext))
                }

            }
            .alert(isPresented: viewStore.$showAlert) {
                let msg = viewStore.alertType.rawValue
                switch viewStore.alertType {
                case .isCheckCurrentLocationFail:
                    return Alert(title: Text(msg), dismissButton: .default(Text("확인"), action: {
                        guard let uUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        UIApplication.shared.open(uUrl)
                    }))
                case .feedNotExists:
                    return Alert(
                        title: Text(msg),
                        primaryButton: .default(Text("확인"))  {
                            self.showFeedWrite.toggle()
                        },
                        secondaryButton: .cancel(Text("취소")))
                default:
                    return Alert(title: Text(msg), dismissButton: .default(Text("확인"), action: {
                        dismiss()
                    }))
                }
            }
        }

    }
}

extension MapV {
    func setNaviBarAppearnce() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.darkGray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.setBackIndicatorImage(UIImage(), transitionMaskImage: UIImage()) // 뒤로가기 아이콘을 빈 이미지로 설정
        
        UINavigationBar.appearance().topItem?.backButtonTitle = ""
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MapV(store: Store(initialState: MapFeature.State(),
                      reducer: {
        MapFeature(environment: MapFeature.Environment(geocodeApiClient: .liveValue,
                                                       locationManager: LocationManager(),
                                                       mainQueue: .main.eraseToAnyScheduler()))
    }))
}
