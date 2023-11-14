//
//  MusicSelection.swift
//  test-gpt
//
//  Created by Zane Sabbagh on 11/14/23.
//

import Foundation
import SwiftUI
import MusicKit


struct MusicSelection: View {
    
    @State private var isAuthorized = false
    @State private var recentlyPlayedSongs: [Song] = []
   

    var body: some View {
           VStack {
               if !isAuthorized {
                   Button("Connect to Apple Music") {
                       requestMusicAuthorization()
                   }
               } else {
                   List(recentlyPlayedSongs, id: \.id) { song in
                       Text(song.title)
                   }
               }
           }
           .onAppear {
               fetchRecentlyPlayedSongs { songs in
                   self.recentlyPlayedSongs = songs
               }
           }
       }

    func fetchRecentlyPlayedSongs(completion: @escaping ([Song]) -> Void) {
        Task {
            do {
                var request = MusicRecentlyPlayedRequest<Song>()
                request.limit = 5  // Limit to 5 songs
                let response = try await request.response()
                let songs = response.items  // Get the songs
                completion(Array(songs))
            } catch {
                print("Error fetching recently played songs: \(error)")
                completion([])
            }
        }
    }


    func requestMusicAuthorization() {
        Task {
            switch await MusicAuthorization.request() {
            case .authorized:
                print("Access granted")
                isAuthorized = true
                // Update UI for authorized state
            case .denied, .restricted, .notDetermined:
                print("Access not granted")
                // Handle other states
            @unknown default:
                print("Unknown authorization state")
                // Handle unknown state
            }
        }
    }
    
    
}



