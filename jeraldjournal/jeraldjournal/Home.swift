import SwiftUI
import FirebaseFirestore

struct Home: View {
    @State private var username: String = "Loading..."
    @State private var newEntryId: String?
    @State private var navigateToRecord = false
    private var db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                // Navigation link to go to Photo Selection
//                NavigationLink(destination: PhotoSelection()) {
//                    Image(systemName: "book")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Circle().fill(Color.blue))
//                }
  
                
          

                // Navigation link to go to Record view
                NavigationLink(destination: Record(entryId: newEntryId ?? ""), isActive: $navigateToRecord) {
                    EmptyView()
                }
                .hidden() // Hide the NavigationLink so it doesn't interfere with your layout
                Button(action: {
                    addEntry()
                }) {
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
    
    
    func addEntry() {
        let entriesRef = db.collection("users").document("100100").collection("entries")
        
        // Get the current timestamp
        let timestamp = Timestamp(date: Date())
        
        // Initialize an empty Conversation array
        let conversation: [String] = []
        
        // Initialize the summary, image fields
        let summary = ""
        let journalImages: [String] = []
        
        // Add a new document with the current timestamp and an empty Conversation array
        var ref: DocumentReference? = nil
        ref = entriesRef.addDocument(data: [
            "timestamp": timestamp,
            "conversation": conversation,  // Add the Conversation array here
            "summary": summary
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                // Set the new entry ID and trigger navigation
                DispatchQueue.main.async {
                    self.newEntryId = ref?.documentID
                    self.navigateToRecord = true
                }
            }
        }
    }


    

}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
