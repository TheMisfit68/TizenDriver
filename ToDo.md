# TizenDriver ToDo

Make send command check the runstate and fire of the commandqueue (instead of have it running constantly in the background like it was a plc-Class).What happens if 2 commands fire of the same commandqueue??


- [ ] Refactor TizenDriver (=Websocket) to Async/Await when available.

copilot example:
import Foundation

// Create a URL for the WebSocket endpoint
guard let url = URL(string: "ws://127.0.0.1:8080") else {
    fatalError("Invalid URL")
}

// Create a WebSocket task
let socketTask = URLSession.shared.webSocketTask(with: url)

// Start the task
socketTask.resume()

// A function to receive messages asynchronously
func receiveMessages() async throws {
    for try await message in socketTask.messages {
        switch message {
        case .string(let text):
            print("Received string: \(text)")
        case .data(let data):
            print("Received data: \(data)")
        @unknown default:
            fatalError("Received an unknown message type")
        }
    }
}

// Call the function to start receiving messages
Task {
    do {
        try await receiveMessages()
    } catch {
        print("Error: \(error)")
    }
}

only delete commands from the queue when they get succesfully executed => teuotthave the running queue retry until they do???
have the execution of command check reachability, connectionstate, pairingstate
 
set IP address fixed for upstairs T.V.
correct channel list for upstairs T.V.
test IP cams on browser
