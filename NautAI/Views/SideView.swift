//
//  SideView.swift
//  NautAI
//
//  Created by Ben Stacy on 9/5/25.
//


import SwiftUI

@available(iOS 26.0, *)
struct SideView: View {
    @Binding var currentView: theviews
    @Binding var enable: Bool
    var Close: () -> Void
    
    // Add these to connect with the chat data
    @ObservedObject var chatDataManager: ChatDataManager
    var model: LMModel
    var onConversationSelected: (ChatConversation) -> Void
    var onDeleteConversation: (ChatConversation) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("Search")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(height: 40)
                        .padding(.horizontal)
                        .background(.gray.opacity(0.2), in: .capsule)
                        
                        Button {
                            withAnimation(.spring(duration: 0.2)) {
                                Close()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.gray)
                                .background(.gray.opacity(0.2), in: .circle)
                        }
                        .tint(.primary)
                        .disabled(!enable)
                    }
                    
                    Text("Conversations")
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                    
                    // Use List for swipe actions to work properly
                    if chatDataManager.conversations.isEmpty {
                        Text("No conversations yet")
                            .foregroundStyle(.white)
                    } else {
                        List {
                            ForEach(chatDataManager.conversations, id: \.id) { conversation in
                                Button {
                                    onConversationSelected(conversation)
                                    Close()
                                } label: {
                                    ConversationItem(
                                        title: conversation.title ?? "Untitled",
                                        date: formatDate(conversation.date ?? Date())
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 15, trailing: 0))
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            onDeleteConversation(conversation)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } preview: {
                                    ConversationPreview(conversation: conversation, chatDataManager: chatDataManager)
                                        .onAppear {
                                            // Blur the background when preview appears
                                            // This is handled by the ZStack blur below
                                        }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .padding(.leading, -20) // Remove List's default padding
                    }
                    
                    Spacer()
                }
//                .padding(.top, 32)
                .padding(.horizontal)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct ConversationItem: View {
    var title: String
    var date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(date)
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

@available(iOS 26.0, *)
struct ConversationPreview: View {
    let conversation: ChatConversation
    @ObservedObject var chatDataManager: ChatDataManager
    
    var body: some View {
        ZStack {
            // EmitterView background matching your ContentView1
            EmitterView()
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    // Show the most recent messages
                    let messages = chatDataManager.getMessages(for: conversation).suffix(5)
                    
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            if message.isUser {
                                // User messages with glass effect (matching ContentView1)
                                HStack {
                                    Spacer(minLength: 0)
                                    Text(message.content ?? "")
                                        .padding(10)
                                        .font(.subheadline)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(.white)
                                        .background {
                                            Color.clear
                                                .glassEffect(.clear, in: .rect(cornerRadius: 15, style: .continuous))
                                                .clipShape(.rect(cornerRadius: 12))
                                        }
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: 280, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 10)
                            } else {
                                // Assistant messages (matching ContentView1)
                                Text(message.content ?? "")
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
                                    .padding(.trailing, 70)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .frame(width: 400, height: 550)
        .overlay(
            RoundedRectangle(cornerRadius: 32.5)
                .stroke(Color.white, lineWidth: 1)
        )
//        .cornerRadius(20)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        SideView(
            currentView: .constant(.chatView),
            enable: .constant(true),
            Close: {},
            chatDataManager: ChatDataManager(),
            model: LMModel(),
            onConversationSelected: { _ in },
            onDeleteConversation: { _ in }
        )
    } else {
        // Fallback on earlier versions
    }
}

