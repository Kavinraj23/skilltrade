import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class MessagingViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?

    // MARK: - Fetch conversations for current user
    func fetchConversations(role: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        let field = role == "homeowner" ? "homeownerID" : "providerID"

        db.collection("conversations")
            .whereField(field, isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                self.conversations = snapshot?.documents.compactMap {
                    try? $0.data(as: Conversation.self)
                } ?? []
            }
    }

    // MARK: - Listen to messages in a conversation
    func listenToMessages(conversationID: String) {
        messagesListener?.remove()
        db.collection("messages")
            .whereField("conversationID", isEqualTo: conversationID)
            .order(by: "sentAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.messages = snapshot?.documents.compactMap {
                    try? $0.data(as: Message.self)
                } ?? []
            }
    }

    // MARK: - Send a message
    func sendMessage(conversationID: String, text: String) {
        guard let uid = Auth.auth().currentUser?.uid, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        db.collection("messages").addDocument(data: [
            "conversationID": conversationID,
            "senderID": uid,
            "text": text,
            "sentAt": Timestamp(date: Date())
        ])
    }

    func stopListening() {
        messagesListener?.remove()
    }
}
