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
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(5)
                                .padding(.horizontal)
                        }
                    }
                    .onChange(of: pingResults) { _ in
                        // Auto-scroll to the bottom whenever a new ping is added
                        if let lastID = pingResults.last {
                            proxy.scrollTo(lastID, anchor: .bottom)
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
            // Configure and start ping to chat.openai.com
            let configuration = PingConfiguration(interval: 0.5, with: 5)
            pinger = try SwiftyPing(host: "google.com", configuration: configuration, queue: .global())

            pinger?.observer = { response in
                let timeString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                let duration = String(format: "%.3f", response.duration * 1000)  // Convert to ms
                
                let result = """
                \(timeString) | \(response.byteCount ?? 64) bytes from \(response.ipAddress ?? "unknown"): \
                icmp_seq=\(response.sequenceNumber) byteCount=\(response.byteCount ?? 0) time=\(duration) ms
                """
                // byteCount zero ဖြစ်နေရင် လိုင်းမရတော့လို့
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
