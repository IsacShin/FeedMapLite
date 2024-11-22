//
//  TabV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import SwiftUI
import ComposableArchitecture

enum TabType {
    case MAP, FEED
}

struct TabV: View {
    @State var selectTab: TabType = .MAP
    private var mapStore = Store(initialState: MapFeature.State()) {
        let environment = MapFeature.Environment(geocodeApiClient: .liveValue,
                                                 locationManager: LocationManager(),
                                                 mainQueue: .main.eraseToAnyScheduler())
        MapFeature(environment: environment)
    }
    
    private var feedListStore = Store(initialState: FeedListFeature.State()) {
        FeedListFeature()
    }

    init() {
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        UITabBar.appearance().backgroundColor = UIColor.darkGray
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
    }
    
    var body: some View {
        TabView(selection: $selectTab) {
            
            MapV(store: self.mapStore)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(TabType.MAP)
            
            FeedListV(store: self.feedListStore)
                .tabItem {
                    Image(systemName: "list.bullet.below.rectangle")
                    Text("Feed")
                }
                .tag(TabType.FEED)
        }
        .tint(.white)
    }
}

#Preview {
    TabV()
}
