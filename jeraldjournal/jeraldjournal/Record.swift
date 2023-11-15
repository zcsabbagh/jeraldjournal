import SwiftUI
import OpenAI
import Photos
import AVFoundation
import Speech
import Foundation
import Firebase
import FirebaseFirestore



struct ChatMessage {
    var sender: Sender
    var content: String
    var clickable: Bool = false
}


enum Sender {
    case user
    case ai
}

struct Record: View {

    @State private var messages: [ChatMessage] = [ChatMessage(sender: .ai, content: "Hey Zane, it's good to see you again. How'd you spend your day?")]
    @State private var currentMessage: String = ""
    @State private var selectedTab = 0
    @State private var isRecording = false
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var audioEngine: AVAudioEngine = AVAudioEngine()
    @State private var audioPlayer: AVAudioPlayer?
    let speechSynthesizer = AVSpeechSynthesizer()
    
    
    @State private var isJournalingFinished = false
    @State private var journalSummary: String = ""
    @State private var isJournalSummaryLoading: Bool = false
    @State private var navigateToFirstScreen = false
    
    var body: some View {
        NavigationView {
            if isJournalSummaryLoading {
                // Show a loading indicator or placeholder
                ProgressView("Loading...")
                    .navigationBarTitle("Journal Summary", displayMode: .inline)
            } else if isJournalingFinished {
                ScrollView {
                    Text(journalSummary)
                        .font(.body)
                        .padding()
                }
                .navigationBarTitle("Journal Summary", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Next") {
                            navigateToFirstScreen = true
                        }
                    }
                }
                .background(
                    NavigationLink(destination: PhotoSelection(), isActive: $navigateToFirstScreen) {
                        EmptyView()
                    }
                )
            } else {
                // Journaling interface
                VStack {
                    Spacer()
                    Button(action: toggleRecording) {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(isRecording ? .red : .blue)
                            .font(.system(size: 50))
                            .padding()
                    }
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button("Finish") {
                            finishJournaling()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: clearChat) {
                            Text("Clear Chat")
                        }
                    }
                }
            }
        }
        .onAppear(perform: setup)
    }
    
    func setup() {
        // ... setup code if needed ...
        speakText("Hey Zane! it's good to see you again. How'd you spend your day?")
        if isJournalSummaryLoading {
            print("Entering this task")
            Task {
                await fetchJournalSummary()
            }
            isJournalingFinished = true
        }
    }

    func fetchJournalSummary() async {
        print("Entering fetchJournalSummary")
        do {
            let response = try await getJournalResponse(conversation: messages)
            journalSummary = response.choices.first?.message.content ?? "No summary available."
            print(journalSummary)
        } catch {
            print("Failed to fetch journal summary: \(error.localizedDescription)")
            journalSummary = "Error: \(error.localizedDescription)"
        }
        DispatchQueue.main.async {
            isJournalSummaryLoading = false
            isJournalingFinished = true
        }
    }
    
    func finishJournaling() {
        isJournalSummaryLoading = true
        Task {
            await fetchJournalSummary()
            isJournalingFinished = true
        }
    }

    
    func getJournalResponse(conversation: [ChatMessage]) async throws -> ChatResult {
        print("Entering getJournalResponse")
        var chat_history = ""
        var num = 0
        var intro_msg = ""
        for message in messages {
            if num % 2 == 1 {
                intro_msg = "User: "
            } else {
                intro_msg = "AI: "
            }
            chat_history += intro_msg + message.content + "\n"
            num += 1
        }
        print("Chat history: ", chat_history, "\n")
//        let context = """
//        The chat history contains a complete summary of Zane's interactive journal with you today.
//        Use this chat history to write a detailed description of his day in second-person. \n
//        Do not add any of your own commentary. Do not be generic. This should be as detailed
//        as possible given the context.
//        """
        let context = """
        Write a summary of Zane's day based on the chat history.
        Do not add any of your own commentary.
        Your output should be shorter than the chat history.
        This should be written in second-person, in a matter-of-fact way.
        
        Talk about any activities they did, thoughts they had, feelings they had,
        or people they hung out with.
        """
        let chatMessages = conversation.map { Chat(role: $0.sender == .user ? .user : .assistant, content: context + $0.content) }
        let query = ChatQuery(model: .gpt3_5Turbo, messages: chatMessages)
        let result = try await openAI.chats(query: query)
        return result
    }
    
    
    func clearChat() {
        messages.removeAll()
        messages = []
    }
    
    func wordCount(_ s: String) -> Int {
        let words = s.split { $0.isWhitespace }
        return words.count
    }
    
    func setClickableStatus(forMessage content: String, to status: Bool) {
        if let index = messages.firstIndex(where: { $0.content == content }) {
            messages[index].clickable = status
        }
    }

    
    func getChatResponse(conversation: [ChatMessage]) async throws -> ChatResult {
        let context = """
        You're trying to help Zane journal about his day. Keep your commentary short, and ask him follow up questions. Vary the questions.
        If it's an appropriate point in the conversation, ask him about the specific people he mentioned, and get him to talk about them.
        Be humorous and occassionally sarcastic, you're talking to a Gen Z.
        """
        let chatMessages = conversation.map { Chat(role: $0.sender == .user ? .user : .assistant, content: context + $0.content) }
        let query = ChatQuery(model: .gpt3_5Turbo, messages: chatMessages)
        let result = try await openAI.chats(query: query)
        return result
    }
    
    func sendMessage() async {
        guard !currentMessage.isEmpty else { return }

        // Append user's message
        messages.append(ChatMessage(sender: .user, content: currentMessage))

        // Get AI response
        do {
            let response = try await getChatResponse(conversation: messages)
            let aiResponse = response.choices.first?.message.content ?? ""
            messages.append(ChatMessage(sender: .ai, content: aiResponse))
            try await speakText(aiResponse)
        } catch {
            messages.append(ChatMessage(sender: .ai, content: "Error: \(error.localizedDescription)"))
        }
        currentMessage = "" // Clear the current message
    }

    
    func playMP3(payload: Data) {

      do {

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [])
        try audioSession.setActive(true)

        let player = try AVAudioPlayer(data: payload)
        self.audioPlayer = player
        player.prepareToPlay()
        player.play()

      } catch {
        print("Error playing audio: \(error)")
      }
    }
    
    
//    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
    func speakText(_ text: String) {
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": "shimmer"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task = URLSession.shared.dataTask(with: request) { data, _, error in

          guard let data = data, error == nil else {
            print("API Error: \(error?.localizedDescription ?? "Unknown error")")
            return
          }

          print("Payload size: \(data.count) bytes")

          playMP3(payload: data)

        }

        task.resume()
    }

    
    
    func toggleRecording() {
        if isRecording {
            finishRecording(success: true)
            if isRecording == false { // Check if the recording was successfully finished
                Task {
                    await sendMessage() // Call sendMessage here
                }
            }
        } else {
            startRecording()
        }
    }

    func startRecording() {
        do {
           let audioSession = AVAudioSession.sharedInstance()
           try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
           try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
       } catch {
           print("Failed to set up audio session: \(error)")
           return
       }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("There was a problem starting the audio engine.")
            return
        }
        
        guard let speechRecognizer = SFSpeechRecognizer() else {
            print("Speech recognition is not supported on this device.")
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                self.currentMessage = result.bestTranscription.formattedString
                if result.isFinal {
                    self.isRecording = false
                    inputNode.removeTap(onBus: 0)
                }
            } else if let error = error {
                print("Recognition failed: \(error)")
                self.isRecording = false
                inputNode.removeTap(onBus: 0)
            }
        }

        isRecording = true
    }


    func finishRecording(success: Bool) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio() // End the recognition request
        recognitionTask?.cancel()      // Cancel the recognition task
        recognitionTask = nil          // Reset for next use
        recognitionRequest = nil       // Reset for next use
        isRecording = false
    }
    
}


struct MessageStyle: ViewModifier {
    var backgroundColor: Color
    var foregroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
    }
}

extension View {
    func messageStyle(backgroundColor: Color, foregroundColor: Color = .white) -> some View {
        self.modifier(MessageStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
}

struct Record_Previews: PreviewProvider {
    static var previews: some View {
        Record()
    }
}




// Additional styling functions
//extension Color {
//    init(hex: String) {
//        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        let hexNumber = Scanner(string: hexSanitized).scanUInt64() ?? 0
//        let red = Double((hexNumber & 0xFF0000) >> 16) / 255.0
//        let green = Double((hexNumber & 0x00FF00) >> 8) / 255.0
//        let blue = Double(hexNumber & 0x0000FF) / 255.0
//
//        self.init(red: red, green: green, blue: blue)
//    }
//}


//    func speakText(_ text: String) {
//
//
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setCategory(.playback, mode: .spokenAudio, options: [])
//        try? audioSession.setActive(true)
//
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.volume = 1.0 // This sets the volume to its maximum (range is 0.0 to 1.0)
//        speechSynthesizer.speak(utterance)
//    }
    

// OLD CHAT VIEW
//var body: some View {
//    NavigationView {
//        VStack {
//            List(messages, id: \.content) { message in
//                if message.sender == .user {
//                    HStack {
//                        Spacer()
//                        Text(message.content)
//                            .messageStyle(backgroundColor: .blue)
//                    }
//                } else {
//                    HStack {
//                        Text(message.content)
//                            .messageStyle(backgroundColor: .green)
//                        Spacer()
//                    }
//                }
//            }
//
//            HStack {
//                Button(action: toggleRecording) {
//                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
//                        .foregroundColor(isRecording ? .red : .blue)
//                        .padding()
//                }
//
//                TextField("Type a message...", text: $currentMessage, onCommit: {
//                    Task {
//                        await sendMessage()
//                    }
//                })
//                .padding(10)
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(10)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                Button(action: {
//                    Task {
//                        await sendMessage()
//                    }
//                }) {
//                    Text("Send")
//                }
//            }
//            .padding()
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: clearChat) {
//                    Text("Clear Chat")
//                }
//            }
//        }
//    }
//    .onAppear {
//        speakText("Hey Zane! it's good to see you again. How'd you spend your day?")
//    }
//}
