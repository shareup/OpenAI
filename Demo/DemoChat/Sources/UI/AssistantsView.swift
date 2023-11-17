//
//  ChatView.swift
//  DemoChat
//
//  Created by Sihao Lu on 3/25/23.
//

import Combine
import SwiftUI

public struct AssistantsView: View {
    @ObservedObject var store: ChatStore
    @ObservedObject var assistantStore: AssistantStore

    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider

    // state to select file
    @State private var isPickerPresented: Bool = false
    @State private var fileURL: URL?
    @State private var uploadedFileId: String?

    // state to modify assistant
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var customInstructions: String = ""

    @State private var codeInterpreter: Bool = false
    @State private var retrieval: Bool = false

    public init(store: ChatStore, assistantStore: AssistantStore) {
        self.store = store
        self.assistantStore = assistantStore
    }

    public var body: some View {
        ZStack {
            NavigationSplitView {
                AssistantsListView(
                    conversations: $assistantStore.availableAssistants, selectedAssistantId: Binding<String?>(
                        get: {
                            assistantStore.selectedAssistantId

                        }, set: { newId in
                            assistantStore.selectAssistant(newId)

                            let selectedAssistant = assistantStore.availableAssistants.filter { $0.id == assistantStore.selectedAssistantId }.first

                            name = selectedAssistant?.name ?? ""
                            description = selectedAssistant?.description ?? ""
                            customInstructions = selectedAssistant?.instructions ?? ""
                            codeInterpreter = selectedAssistant?.codeInterpreter ?? false
                            retrieval = selectedAssistant?.retrieval ?? false


                        })
                )
                .toolbar {
                    ToolbarItem(
                        placement: .primaryAction
                    ) {
                        Menu {
                            Button("Get Assistants") {
                                Task {
                                    let _ = await assistantStore.getAssistants(limit: 20)
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                        }

                        .buttonStyle(.borderedProminent)
                    }
                }
            } detail: {
                // TODO: Allow modifying Assistant.
                if let selectedAssistantId = assistantStore.selectedAssistantId {


                    AssistantModalContentView(name: $name, description: $description, customInstructions: $customInstructions,
                                              codeInterpreter: $codeInterpreter, retrieval: $retrieval, modify: true, isPickerPresented: $isPickerPresented, selectedFileURL: $fileURL) {
                        Task {
                            await handleOKTap()
                        }
                    } onFileUpload: {
                        Task {
                            guard let fileURL else { return }

                            uploadedFileId = await assistantStore.uploadFile(url: fileURL)
                        }
                    }
                }
            }
        }
    }

    func handleOKTap() async {

        // When OK is tapped that means we should save the modified assistant and start a new thread.
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
