//
//  ContentView.swift
//  SpeechTodoList
//
//  Created by Vadim Zahariev on 3.05.21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.created, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>
    
    @State private var recording = false
    @ObservedObject private var mic = MicManager(numberOfSamples: 30)
    private var speechManager = SpeechManager()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(todos) { item in
                        Text(item.text ?? " - ")
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle("Speech Todo List")
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.primary.opacity(0.7))
                    .padding()
                    .overlay(VStack {
                        visualizerView()
                    })
                    .opacity(recording ? 1 : 0)
                
                VStack {
                    recordButton()
                }
            }.onAppear {
                speechManager.checkPermissions()
            }
        }
    }
    
    private func recordButton() -> some View {
        Button(action: addItem) {
            Image(systemName: recording ? "stop.fill" : "mic.fill")
                .font(.system(size: 40))
                .padding()
                .cornerRadius(10)
        }.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
    }
    
    private func normolizedSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2,CGFloat(level) + 50) / 2
        return CGFloat(level * (100 / 25))
    }
    
    private func visualizerView() -> some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(mic.soundSamples, id: \.self) { level in
                    VizualBarView(value: self.normolizedSoundLevel(level: level))
                }
            }
        }
    }
    
    private func addItem() {
        if speechManager.isRecording {
            self.recording = false
            mic.stopMonitoring()
            speechManager.stopRecording()
        } else {
            self.recording = true
            mic.startMonitoring()
            speechManager.start { (speechText) in
                guard let text = speechText, !text.isEmpty else {
                    self.recording = false
                    return
                }
                
                DispatchQueue.main.async {
                    withAnimation {
                        let newItem = Todo(context: viewContext)
                        newItem.id = UUID()
                        newItem.text = text
                        newItem.created = Date()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        speechManager.isRecording.toggle()
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map{todos[$0]}.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        List {
//            ForEach(items) { item in
//                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//            }
//            .onDelete(perform: deleteItems)
//        }
//        .toolbar {
//            #if os(iOS)
//            EditButton()
//            #endif
//
//            Button(action: addItem) {
//                Label("Add Item", systemImage: "plus")
//            }
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
