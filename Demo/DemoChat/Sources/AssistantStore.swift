//
//  ChatStore.swift
//  DemoChat
//
//  Created by Sihao Lu on 3/25/23.
//

import Foundation
import Combine
import OpenAI

public final class AssistantStore: ObservableObject {
    public var openAIClient: OpenAIProtocol
    let idProvider: () -> String
    @Published var selectedAssistantId: String?

    @Published var availableAssistants: [Assistant] = []

    public init(
        openAIClient: OpenAIProtocol,
        idProvider: @escaping () -> String
    ) {
        self.openAIClient = openAIClient
        self.idProvider = idProvider
    }

    // MARK: Models

    @MainActor
    func createAssistant(name: String, description: String, instructions: String, codeInterpreter: Bool, retrievel: Bool, fileIds: [String]? = nil) async -> String? {
        do {
            var tools = [Tool]()
            if codeInterpreter {
                tools.append(Tool(toolType: "code_interpreter"))
            }
            if retrievel {
                tools.append(Tool(toolType: "retrieval"))
            }

            // TODO: Replace with actual gpt-4-1106-preview model.
            let query = AssistantsQuery(model: Model("gpt-4-1106-preview"), name: name, description: description, instructions: instructions, tools:tools, fileIds: fileIds)
            let response = try await openAIClient.assistants(query: query, method: "POST")

            // Returns assistantId
            return response.id

        } catch {
            // TODO: Better error handling
            print(error.localizedDescription)
        }
        return nil
    }

    @MainActor
    func getAssistants(limit: Int) async -> [Assistant] {
        do {
            let response = try await openAIClient.assistants(query: nil, method: "GET")

            var assistants = [Assistant]()
            for result in response.data ?? [] {
                let codeInterpreter = response.tools?.filter { $0.toolType == "code_interpreter" }.first != nil
                let retrieval = response.tools?.filter { $0.toolType == "retrieval" }.first != nil

                assistants.append(Assistant(id: result.id, name: result.name, description: result.description, instructions: result.instructions, codeInterpreter: codeInterpreter, retrieval: retrieval))
            }
            availableAssistants = assistants
            return assistants

        } catch {
            // TODO: Better error handling
            print(error.localizedDescription)
        }
        return []
    }

    func selectAssistant(_ assistantId: String?) {
        selectedAssistantId = assistantId
    }

    @MainActor
    func uploadFile(url: URL) async -> String? {
        do {
            let fileData = try Data(contentsOf: url)

            // TODO: Support all the same types as openAI (not just pdf).
            let result = try await openAIClient.files(query: FilesQuery(purpose: "assistants", file: fileData, fileName: url.lastPathComponent, contentType: "application/pdf"))
            return result.id
        }
        catch {
            print("error = \(error)")
            return nil
        }
    }
}
