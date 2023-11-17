//
//  ChatView.swift
//  DemoChat
//
//  Created by Sihao Lu on 3/25/23.
//

import Combine
import SwiftUI

public struct ChatView: View {
    @ObservedObject var store: ChatStore
    @ObservedObject var assistantStore: AssistantStore

    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider


    @State private var isModalPresented = false
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var customInstructions: String = ""

    @State private var codeInterpreter: Bool = false
    @State private var retrieval: Bool = false


    @State private var isPickerPresented: Bool = false
    @State private var fileURL: URL?
    @State private var uploadedFileId: String?


    public init(store: ChatStore, assistantStore: AssistantStore) {
        self.store = store
        self.assistantStore = assistantStore
    }

    public var body: some View {
        ZStack {
            NavigationSplitView {
                ListView(
                    conversations: $store.conversations,
                    selectedConversationId: Binding<Conversation.ID?>(
                        get: {
                            store.selectedConversationID
                        }, set: { newId in
                            store.selectConversation(newId)
                        })
                )
                .toolbar {
                    ToolbarItem(
                        placement: .primaryAction
                    ) {

                        Menu {
                            Button("Create Chat") {
                                store.createConversation()

                            }
                            Button("Create Assistant") {
                                isModalPresented = true

                            }
                        } label: {
                            Image(systemName: "plus")
                        }

                        .buttonStyle(.borderedProminent)
                    }
                }
            } detail: {
                if let conversation = store.selectedConversation {
                    DetailView(
                        availableAssistants: assistantStore.availableAssistants, conversation: conversation,
                        error: store.conversationErrors[conversation.id],
                        sendMessage: { message, selectedModel in
                            Task {
                                await store.sendMessage(
                                    Message(
                                        id: idProvider(),
                                        role: .user,
                                        content: message,
                                        createdAt: dateProvider()
                                    ),
                                    conversationId: conversation.id,
                                    model: selectedModel
                                )
                            }
                        }, isSendingMessage: $store.isSendingMessage
                    )
                }
            }
            .sheet(isPresented: $isModalPresented) {
                AssistantModalContentView(name: $name, description: $description, customInstructions: $customInstructions,
                                          codeInterpreter: $codeInterpreter, retrieval: $retrieval, modify: false, isPickerPresented: $isPickerPresented, selectedFileURL: $fileURL) {
                    Task {
                        await handleOKTap()
                    }
                } onFileUpload: {
                    Task {
                        guard let fileURL else { return }

                        uploadedFileId = await assistantStore.uploadFile(url: fileURL)
                        if uploadedFileId == nil {
                            print("Failed to upload")
                        }
                    }
                }
            }
        }
    }
    func handleOKTap() async {
        
        // Reset state for Assistant creator.
        name = ""
        description = ""
        customInstructions = ""

        codeInterpreter = false
        retrieval = false
        fileURL = nil
        uploadedFileId = nil
        
        var fileIds = [String]()
        if let fileId = uploadedFileId {
            fileIds.append(fileId)
        }

        let asstId = await assistantStore.createAssistant(name: name, description: description, instructions: customInstructions, codeInterpreter: codeInterpreter, retrievel: retrieval, fileIds: fileIds.isEmpty ? nil : fileIds)

        guard let asstId else {
            print("failed to create Assistant.")
            return
        }

        store.createConversation(type: .assistant, assistantId: asstId)
    }
}
