//
//  Home.swift
//  jeraldjournal
//
//  Created by Zane Sabbagh on 11/14/23.
//
import Foundation
import SwiftUI
import FirebaseFirestore

struct Home: View {
    @State private var username: String = "Loading..."
    private var db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Button(action: {
                    addNewDocument()
                }) {
                    Image(systemName: "book")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.blue))
                }
                .padding(.bottom, 50)
  
                // Navigation link to go to Record view
                NavigationLink(destination: Record()) {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.blue))
                }
                .padding(.bottom, 50)

                Text(username) // Updated this to use the @State property
                .onAppear {
                    self.fetchUsername()
                }
            }
        }
    }

    // Function to add a new document to Firestore
    func addNewDocument() {
        print ("new document")
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    func fetchUsername() {
        // Reference to the user document
        let userRef = db.collection("users").document("100100")
        
        // Asynchronously get the document
        userRef.getDocument { (document, error) in
            // Check for document
            if let document = document, document.exists {
                // Try to get the username from the document
                let data = document.data()
                self.username = data?["username"] as? String ?? "Unknown 2"
            } else {
                // Handle the error or the case where the document does not exist
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                self.username = "Unknown"
            }
        }
    }

}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

