import SwiftUI
import FirebaseAuth

// MARK: - Homeowner inbox
struct HomeownerInboxView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = MessagingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading { ProgressView() }
                else if vm.conversations.isEmpty {
                    ContentUnavailableView("No Messages",
                        systemImage: "message",
                        description: Text("Conversations appear here after a provider accepts your booking"))
                } else {
                    List(vm.conversations) { convo in
                        NavigationLink(destination: ChatView(conversation: convo,
                                                             currentUserID: authVM.currentUserID)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Booking: \(convo.bookingID)")
                                    .font(.subheadline.bold())
                                Text("Tap to open chat")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
            .onAppear { vm.fetchConversations(role: "homeowner") }
        }
    }
}

// MARK: - Chat view (shared by homeowner and provider)
struct ChatView: View {
    let conversation: Conversation
    let currentUserID: String
    @StateObject private var vm = MessagingViewModel()
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.messages) { message in
                            ChatBubble(message: message,
                                       isFromMe: message.senderID == currentUserID)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { _, _ in
                    if let last = vm.messages.last?.id {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 12) {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                Button {
                    guard let id = conversation.id else { return }
                    vm.sendMessage(conversationID: id, text: messageText)
                    messageText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let id = conversation.id { vm.listenToMessages(conversationID: id) }
        }
        .onDisappear { vm.stopListening() }
    }
}

// MARK: - Chat bubble
struct ChatBubble: View {
    let message: Message
    let isFromMe: Bool

    var body: some View {
        HStack {
            if isFromMe { Spacer() }
            Text(message.text)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(isFromMe ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isFromMe ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .frame(maxWidth: 280, alignment: isFromMe ? .trailing : .leading)
            if !isFromMe { Spacer() }
        }
    }
}
