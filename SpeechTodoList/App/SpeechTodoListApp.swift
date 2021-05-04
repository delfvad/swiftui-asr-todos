//
//  SpeechTodoListApp.swift
//  SpeechTodoList
//
//  Created by Vadim Zahariev on 3.05.21.
//

import SwiftUI

@main
struct SpeechTodoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
