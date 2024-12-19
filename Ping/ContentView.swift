//
//  ContentView.swift
//  Ping
//
//  Created by Thaw De Zin on 10/15/24.
//

import SwiftUI
import SwiftyPing

struct ContentView: View {
    @State private var pingResults: [String] = []  // Store ping responses
    @State private var pinger: SwiftyPing?
    @State private var scrollViewProxy: ScrollViewProxy?

    var body: some View {
        VStack {
            Text("Results")
                .font(.title)
                .padding()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(pingResults, id: \.self) { result in
                            Text(result)
                                .padding(5)
                                .background(result.contains("No internet") ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(5)
                                .padding(.horizontal)
                                .foregroundColor(result.contains("No internet") ? .red : .green)
                                .id(result) // Assign unique ID to each result for ScrollViewReader
                        }
                    }
                    .onChange(of: pingResults) { _ in
                        // Auto-scroll to the bottom whenever a new ping is added
                        if let lastResult = pingResults.last {
                            proxy.scrollTo(lastResult, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollViewProxy = proxy
                }
            }

            Button("Start") {
                startPing()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    func startPing() {
        do {
            // Configure and start ping to google.com
            let configuration = PingConfiguration(interval: 0.5, with: 5)
            pinger = try SwiftyPing(host: "google.com", configuration: configuration, queue: .global())

            pinger?.observer = { response in
                let timeString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                let duration = String(format: "%.3f", response.duration * 1000)  // Convert to ms

                var result: String
                if let byteCount = response.byteCount, byteCount > 0 {
                    result = """
                    \(timeString) | \(byteCount) bytes from \(response.ipAddress ?? "unknown"): \
                    icmp_seq=\(response.sequenceNumber) byteCount=\(byteCount) time=\(duration) ms
                    """
                } else {
                    result = "No internet connection."
                }
                
                DispatchQueue.main.async {
                    pingResults.append(result)
                }
            }

            try pinger?.startPinging()
        } catch {
            pingResults.append("Ping failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
