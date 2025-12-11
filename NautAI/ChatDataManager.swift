//
//  ChatDataManager.swift
//  NautAI
//
//  Created by Ben Stacy on 10/8/25.
//

import CoreData
import Foundation

@available(iOS 26.0, *)
class ChatDataManager: ObservableObject {
    private let viewContext: NSManagedObjectContext
    @Published var conversations: [ChatConversation] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchConversations()
    }
    
    func fetchConversations() {
        let request: NSFetchRequest<ChatConversation> = ChatConversation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ChatConversation.date, ascending: false)]
        
        do {
            conversations = try viewContext.fetch(request)
        } catch {
            print("Error fetching conversations: \(error)")
        }
    }
    
    func createConversation(title: String) -> ChatConversation {
        let conversation = ChatConversation(context: viewContext)
        conversation.id = UUID()
        conversation.title = title
        conversation.date = Date()
        
        saveContext()
        fetchConversations()
        return conversation
    }
    
    func saveMessage(content: String, isUser: Bool, to conversation: ChatConversation) {
        let message = ChatMessage(context: viewContext)
        message.id = UUID()
        message.content = content
        message.isUser = isUser
        message.timestamp = Date()
        message.conversation = conversation
        
        conversation.lastMessage = content
        conversation.date = Date()
        
        saveContext()
        fetchConversations()
    }
    
    func deleteConversation(_ conversation: ChatConversation) {
        viewContext.delete(conversation)
        saveContext()
        fetchConversations()
    }
    
    func getMessages(for conversation: ChatConversation) -> [ChatMessage] {
        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "conversation == %@", conversation)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ChatMessage.timestamp, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        PersistenceController.shared.save()
    }
}
