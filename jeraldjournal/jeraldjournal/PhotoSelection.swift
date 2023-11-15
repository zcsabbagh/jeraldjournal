//
//  FirstScreen.swift
//  test-gpt
//
//  Created by Zane Sabbagh on 10/9/23.
//

import Foundation
import SwiftUI
import Photos
import FirebaseStorage
import FirebaseFirestore
// render first screeen
struct PhotoSelection: View {
    var entryId: String
    @State private var recentPhotos: [UIImage] = []
    @State private var navigateToSecondScreen = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Pick a cover photo")
                    .font(.largeTitle)
                
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    ForEach(recentPhotos.indices, id: \.self) { index in
                        Button(action: {
                            // Call upload function here when a photo is selected
                            uploadImagesAndSaveURL(image: recentPhotos[index], entryId: entryId)
                            //                            uploadCoverAndSaveURL(image: recentPhotos[index], entryId: entryId)
                        }) {
                            Image(uiImage: recentPhotos[index])
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
    
    func uploadImagesAndSaveURL(image: UIImage, entryId: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        
        // Create a reference to the file you want to upload
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child("users/100100/\(entryId)/\(UUID().uuidString).jpg")
        
        // Upload the image data to Firebase Storage
        let uploadTask = imagesRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("Error during the upload: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Metadata contains file metadata such as size, content-type, and download URL.
            imagesRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting the download URL: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                // Save the download URL to the Firestore entry's images array
                saveImageURLToFirestore(downloadURL: downloadURL.absoluteString)
            }
        }
    }
    
    func saveImageURLToFirestore(downloadURL: String) {
        let db = Firestore.firestore()
        let entryRef = db.collection("users").document("100100").collection("entries").document(entryId)
        
        // Assuming the field containing the URLs is named 'imageURLs'
        entryRef.updateData([
            "imageURLs": FieldValue.arrayUnion([downloadURL])
        ]) { error in
            if let error = error {
                // Handle any errors
            } else {
                // Update the local state if necessary
            }
        }
    }
}
    
//    func uploadCoverAndSaveURL(image: UIImage, entryId: String) {
//        // Unique identifier for the image to avoid overwriting existing images
//        let uniqueImageId = UUID().uuidString
//        print("Entered cover upload")
//        
//        // Updated storage path with the unique image ID
//        let storageRef = Storage.storage().reference()
//        let imagesRef = storageRef.child("users/100100/\(entryId)/cover/\(UUID().uuidString).jpg")
//        
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
//
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
//            guard metadata != nil else {
//                // Handle the error
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//
//            storageRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    // Handle the error
//                    print(error?.localizedDescription ?? "Unknown error")
//                    return
//                }
//
//                let db = Firestore.firestore()
//                let photoURL = downloadURL.absoluteString
//
//                // Updated Firestore path with the correct fields and document IDs
//                let documentRef = db.collection("users").document("100100")
//                                       .collection("entries").document(entryId)
//
//                // Save the URL to the Firestore document in the 'cover' field
//                documentRef.setData(["cover": photoURL], merge: true) { error in
//                    if let error = error {
//                        print("Error writing document: \(error)")
//                    } else {
//                        print("Document successfully written with cover image URL.")
//                    }
//                }
//            }
//        }
//    }
//}

    
    

//struct PhotoSelection_Previews: PreviewProvider {
//    static var previews: some View {
//        Record(entryId: String())
//    }
//}


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
