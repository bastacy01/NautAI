//
//  ContentView.swift
//  NautAI
//
//  Created by Ben Stacy on 12/7/24.
//


import SwiftUI

struct ContentView: View {
    @State private var userMessage: String = ""
    @State private var messages: [Message] = []
    @State private var botResponses = [
        "NAUT AI is a Large Language Model (LLM) designed to understand, generate, and manipulate human language. It’s trained on vast datasets and uses deep learning techniques to predict and generate text."
    ]
    @State private var isBotTyping: Bool = false
    @State private var botTypingMessage: String = ""

    var body: some View {
        ZStack {
            EmitterView()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        print("Menu button tapped")
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                    
                    Text("NAUT")
                        .font(.holtwood2())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        print("Share/Edit button tapped")
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding(.top, 50)
                .padding()
                .background(Color.black.opacity(0.5))
                
                // Chat Area
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(alignment: .leading, spacing: 20) {
                            if messages.isEmpty {
                                // Placeholder for empty chat
                                Text("Start the conversation!")
                                    .foregroundColor(.clear)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 50)
                                Image("astronautlogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .offset(x: 115, y: 80)
                                    .opacity(0.5)
                                
                            } else {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            if isBotTyping {
                                HStack {
                                    Text(botTypingMessage)
                                        .font(.system(size: 14)).monospaced()
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 15)
                        .padding(.horizontal)
                        .onChange(of: messages) { _ in
                            if let lastMessageID = messages.last?.id {
                                withAnimation {
                                    scrollView.scrollTo(lastMessageID, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .background(Color.clear)
                
                HStack {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                        .padding(.leading, 10)
                        
                        ZStack(alignment: .leading) {
                            if userMessage.isEmpty {
                                Text("Message")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                            }
                            TextField("", text: $userMessage)
                                .padding(10)
                                .foregroundColor(.white)
                                .accentColor(.white)
                        }
                        
                        Button(action: sendMessage) {
                            if isBotTyping {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .font(.system(size: 14))
                                    .background(
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 30, height: 30)
                                    )
                            } else {
                                Image(systemName: "arrow.up")
                                    .foregroundColor(.black)
                                    .fontWeight(.medium)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 30, height: 30)
                                    )
                            }
                        }
                        .offset(x: 5)
                        .disabled(userMessage.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.trailing, 10)
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                }
                .padding()
                .background(Color.black.opacity(0.3))
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarBackButtonHidden(true)
        }
    }

    func sendMessage() {
        guard !userMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let userMessageObj = Message(id: UUID(), content: userMessage, isUser: true)
        messages.append(userMessageObj)
        userMessage = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            simulateTyping()
        }
    }

    func simulateTyping() {
        isBotTyping = true
        botTypingMessage = ""
        let response = botResponses.randomElement() ?? ""
        
        var currentIndex = 0
        let animationInterval = 0.03 // Time between appending characters

        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { timer in
            if currentIndex < response.count {
                withAnimation(.easeInOut(duration: animationInterval)) {
                    let index = response.index(response.startIndex, offsetBy: currentIndex)
                    botTypingMessage.append(response[index])
                }
                currentIndex += 1
            } else {
                timer.invalidate()
                    let botMessage = Message(id: UUID(), content: botTypingMessage, isUser: false)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isBotTyping = false
                        messages.append(botMessage)
                        botTypingMessage = ""
                    }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .font(.system(size: 14)).monospaced()
                    .background(Color("Component").opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                Text(message.content)
                    .font(.system(size: 14)).monospaced()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
