//
//  ListView.swift
//  DemoChat
//
//  Created by Sihao Lu on 3/25/23.
//

import SwiftUI

struct AssistantsListView: View {
    @Binding var conversations: [Assistant]
    @Binding var selectedAssistantId: String?

    var body: some View {
        List(
            $conversations,
            editActions: [.delete],
            selection: $selectedAssistantId
        ) { $conversation in
                Text(
                    conversation.name
                )
                .lineLimit(2)

        }
        .navigationTitle("Assistants")
    }
}
