//
//  ContentView1.swift
//  NautAI
//
//  Created by Ben Stacy on 8/14/25.
//


import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
@Observable
class LMModel {
    var inputText = ""
    var isThinking = false
    var isAwaitingResponse = false
    var currentConversation: ChatConversation?
    var chatDataManager: ChatDataManager
    var savedMessages: [SavedMessage] = []
    var isViewingSavedChat = false
    
    var session = LanguageModelSession {
        """
        "You are a helpful and concise assistant. Provide clear, accurate answers in a professional."
        """
    }
    
    init(chatDataManager: ChatDataManager = ChatDataManager()) {
        self.chatDataManager = chatDataManager
    }
    
    func sendMessage() {
        Task {
            do {
                let userMessage = inputText
                let prompt = Prompt(inputText)
                inputText = ""
                
                // If viewing saved chat, switch to live mode to show new messages
                if isViewingSavedChat {
                    isViewingSavedChat = false
                }
                
                if currentConversation == nil {
                    let firstWords = String(userMessage.prefix(40))
                    await MainActor.run {
                        currentConversation = chatDataManager.createConversation(title: firstWords)
                    }
                }
                
                if let conversation = currentConversation {
                    await MainActor.run {
                        chatDataManager.saveMessage(content: userMessage, isUser: true, to: conversation)
                    }
                }
                
                let strame = session.streamResponse(to: prompt)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isAwaitingResponse = true
                }
                
                for try await prontresponse in strame {
                    isAwaitingResponse = false
                    print(prontresponse)
                }
                
                if let conversation = currentConversation,
                   let lastEntry = session.transcript.last,
                   case .response(let response) = lastEntry {
                    
                    var fullResponse = ""
                    for segment in response.segments {
                        if case .text(let text) = segment {
                            fullResponse += text.content
                        }
                    }
                    
                    if !fullResponse.isEmpty {
                        await MainActor.run {
                            chatDataManager.saveMessage(content: fullResponse, isUser: false, to: conversation)
                        }
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func newChat() {
        session = LanguageModelSession {
            """
            "You are a helpful and concise assistant. Provide clear, accurate answers in a professional."
            """
        }
        inputText = ""
        isThinking = false
        isAwaitingResponse = false
        currentConversation = nil
        savedMessages = []
        isViewingSavedChat = false
    }
    
    func loadConversation(_ conversation: ChatConversation) {
        session = LanguageModelSession {
            """
            "You are a helpful and concise assistant. Provide clear, accurate answers in a professional."
            """
        }
        currentConversation = conversation
        isViewingSavedChat = true
        
        let messages = chatDataManager.getMessages(for: conversation)
        savedMessages = messages.map { message in
            SavedMessage(
                id: message.id ?? UUID(),
                content: message.content ?? "",
                isUser: message.isUser,
                timestamp: message.timestamp ?? Date()
            )
        }
    }
}

struct SavedMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

@available(iOS 26.0, *)
struct MessageView: View {
    let segments: [Transcript.Segment]
    let isUser: Bool
    var body: some View {
        VStack {
            ForEach(segments, id: \.id) { segment in
                switch segment {
                case .text(let text):
                    if isUser {
                        // User messages with max-width constraint
                        HStack {
                            Spacer(minLength: 0)
                            Text(text.content)
                                .padding(10)
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(.white)
                                .background {
                                    Color.clear
                                        .glassEffect(.clear, in: .rect(cornerRadius: 15, style: .continuous))
                                        .clipShape(.rect(cornerRadius: 12))
                                }
                                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap naturally
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing) // 75% max width
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 10)
                    } else {
                        // Assistant messages with trailing padding to prevent extending too far right
                        Text(text.content)
                            .padding(10)
                            .font(.subheadline)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.white)
                            .background {
                                Color.clear
                                    .clipShape(.rect(cornerRadius: 12))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
/*                            .padding(.trailing, UIScreen.main.bounds.width * 0.25 + 10)*/ // Match where user bubble would start from the right
                    }
                case .structure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 26.0, *)
struct ContentView1: View {
    @StateObject var chatDataManager = ChatDataManager()
    @State var model: LMModel
    @State private var isSidebarVisible: Bool = false
    @State var currentView: theviews = .chatView
    @FocusState private var isInputFocused: Bool
    
    init() {
        let manager = ChatDataManager()
        _chatDataManager = StateObject(wrappedValue: manager)
        _model = State(wrappedValue: LMModel(chatDataManager: manager))
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            // Always show saved messages first (if any)
                            if !model.savedMessages.isEmpty {
                                ForEach(model.savedMessages) { message in
                                    SavedMessageView(content: message.content, isUser: message.isUser)
                                }
                            }
                            
                            // Then show live session messages (new messages in the conversation)
                            if !model.isViewingSavedChat {
                                ForEach(model.session.transcript) { entry in
                                    Group {
                                        switch entry {
                                        case .prompt(let prompt):
                                            MessageView(segments: prompt.segments, isUser: true)
                                        case .response(let response):
                                            MessageView(segments: response.segments, isUser: false)
                                        default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: model.session.transcript.count)
                        .animation(.easeInOut(duration: 0.3), value: model.savedMessages.count)
                        
                        if model.isAwaitingResponse {
                            if let last = model.session.transcript.last {
                                if case .prompt = last {
                                    Text("Thinking...").bold()
                                        .opacity(model.isThinking ? 0.5 : 1)
                                        .padding(.leading)
                                        .foregroundStyle(.white)
                                        .offset(y: 15)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onAppear {
                                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                                                model.isThinking.toggle()
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .defaultScrollAnchor(.bottom, for: .sizeChanges)
                    .safeAreaPadding(.bottom, 120)
                    .safeAreaPadding(.top, 24)
                    .contentShape(Rectangle()) // Make entire ScrollView tappable
                    .onTapGesture {
                        // Dismiss keyboard when tapping anywhere in the scroll view
                        isInputFocused = false
                    }
                    
                    // Animated Bottom Bar
                    VStack {
                        Spacer()
                        
                        AnimatedBottomBar(
                            highlightWhenEmptry: true,
                            hint: "Ask anything...",
                            tint: .white,
                            text: $model.inputText,
                            isFocused: $isInputFocused
                        ) {
                            // Leading actions (empty for now, but you can add buttons here)
                        } trailingAction: {
                            Button {
                                if !model.inputText.isEmpty && !model.session.isResponding {
                                    model.sendMessage()
                                    isInputFocused = false
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(model.inputText.isEmpty && !model.session.isResponding ? Color.gray : Color.white)
                                        .frame(width: 30, height: 30)
                                    
                                    Group {
                                        if model.session.isResponding {
                                            Rectangle()
                                                .fill(Color.black)
                                                .frame(width: 12, height: 12)
                                                .transition(.opacity)
                                        } else {
                                            Image(systemName: "arrow.up")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(Color.black)
                                                .transition(.opacity)
                                        }
                                    }
                                }
                                .animation(.easeOut(duration: 0.1), value: model.session.isResponding)
                            }
                            .disabled(model.inputText.isEmpty || model.session.isResponding)
                        } mainAction: {
                            // Main action (empty - the send button is now in trailing action)
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                    }
                }
                .navigationTitle("FoundationModels")
                .background(EmitterView().edgesIgnoringSafeArea(.all))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                                isSidebarVisible.toggle()
                            }
                        }) {
                            Label("", systemImage: "bubble.left.and.bubble.right")
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)
                     
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                model.newChat()
                                // Show keyboard after starting new chat
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isInputFocused = true
                                }
                            }
                        }) {
                            Label("", systemImage: "square.and.pencil")
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)
                    
                    ToolbarItem(placement: .principal) {
                        Text("NAUT")
                            .font(.holtwood2())
                    }
                }
            }
            
            // Sliding sidebar from leading edge using your separate SideView file
            if isSidebarVisible {
                ZStack(alignment: .leading) {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                                isSidebarVisible = false
                            }
                        }
                    
                    // Your separate SideView file
                    SideView(
                        currentView: $currentView,
                        enable: $isSidebarVisible,
                        Close: {
                            isSidebarVisible = false
                        },
                        chatDataManager: chatDataManager,
                        model: model,
                        onConversationSelected: { conversation in
                            model.loadConversation(conversation)
                        },
                        onDeleteConversation: { conversation in
                            chatDataManager.deleteConversation(conversation)
                            // If we're viewing the deleted conversation, start new chat
                            if model.currentConversation?.id == conversation.id {
                                model.newChat()
                            }
                        }
                    )
                    .offset(x: isSidebarVisible ? 0 : -UIScreen.main.bounds.width)
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.1), value: isSidebarVisible)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

@available(iOS 26.0, *)
struct SavedMessageView: View {
    let content: String
    let isUser: Bool
    
    var body: some View {
        if isUser {
            // User messages with max-width constraint
            HStack {
                Spacer(minLength: 0)
                Text(content)
                    .padding(10)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.white)
                    .background {
                        ZStack {
                            Color.clear
                                .glassEffect(.clear, in: .rect(cornerRadius: 15, style: .continuous))
                        }
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap naturally
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing) // 75% max width
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 10)
        } else {
            // Assistant messages with trailing padding to prevent extending too far right
            Text(content)
                .padding(10)
                .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(.white)
                .background {
                    Color.clear
                        .clipShape(.rect(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
/*                .padding(.trailing, UIScreen.main.bounds.width * 0.25 + 10)*/ // Match where user bubble would start from the right
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ContentView1()
    } else {
        Text("Requires iOS 26.0 or later")
    }
}
