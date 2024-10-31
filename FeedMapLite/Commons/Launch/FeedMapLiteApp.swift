//
//  FeedMapLiteApp.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import SwiftUI
import ComposableArchitecture
import GoogleMaps
import GooglePlaces
import SwiftData

@main
struct FeedMapLiteApp: App {
    
    var modelContainer: ModelContainer = {
        let schema = Schema([FeedDataModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        GMSServices.provideAPIKey(GMAP_KEY)
        GMSPlacesClient.provideAPIKey(GMAP_KEY)
    }
    
    var body: some Scene {
        WindowGroup {
            TabV()
                .modelContainer(modelContainer)
        }
    }
}
