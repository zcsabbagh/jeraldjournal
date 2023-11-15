//
//  FirstScreen.swift
//  test-gpt
//
//  Created by Zane Sabbagh on 10/9/23.
//

import Foundation
import SwiftUI
import Photos
// render first screeen
struct PhotoSelection: View {
    @State private var recentPhotos: [UIImage] = []
        @State private var navigateToSecondScreen = false
        var entryId: String
        var body: some View {
            NavigationStack {
                VStack {
                    Text("Pick a cover photo")
                        .font(.largeTitle)
                    
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                        ForEach(recentPhotos, id: \.self) { image in
                            NavigationLink(destination: MusicSelection(), isActive: $navigateToSecondScreen) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 136, height: 225)
                                    .clipped()
                                    .cornerRadius(15)
                            }
                            .buttonStyle(.plain) // To avoid button styling on the image
                        }
                    }
                    .padding()
                }
                .onAppear(perform: fetchRecentPhotos)
            }
        }
    
    func fetchRecentPhotos() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.fetchPhotos()
                }
            case .denied, .restricted:
                print("Permission denied or restricted")
            case .notDetermined:
                print("Permission not determined yet")
            case .limited:
                print("Permission limited")
            @unknown default:
                print("Unknown authorization status")
            }
        }
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()

        // Define the time range for the fetch
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@", oneDayAgo as NSDate)

        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 4

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Check if the fetch result has assets
        guard fetchResult.count > 0 else { return }
        
        fetchResult.enumerateObjects { (asset, _, _) in
            let imageManager = PHImageManager.default()
            let targetSize = PHImageManagerMaximumSize // request the original image
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
                if let image = image {
                    self.recentPhotos.append(image)
                }
            }
        }
    }

}



//
//  ContentView.swift
//  test-gpt
//
//  Created by Zane Sabbagh on 10/7/23.
//
//
//import SwiftUI
//import CoreData
//
//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//            Text("Select an item")
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
//}
//
//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
//
//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
