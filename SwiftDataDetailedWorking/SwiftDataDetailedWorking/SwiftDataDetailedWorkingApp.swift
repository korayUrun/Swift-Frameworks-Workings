//
//  SwiftDataDetailedWorkingApp.swift
//  SwiftDataDetailedWorking
//
//  Created by Koray Urun on 5.02.2026.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataDetailedWorkingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Container: Uygulamanın hangi modelleri saklayacağını burada kaydediyoruz.
        .modelContainer(for: [Author.self, Book.self])
    }
}
