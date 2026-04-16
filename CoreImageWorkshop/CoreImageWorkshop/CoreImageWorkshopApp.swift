//  CoreImageWorkshopApp.swift
//  Created by Katya on 16/04/2026.

import SwiftUI

@main
struct CoreImageWorkshopApp: App {
    init() {
        FilterConstructor.registerAll()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
