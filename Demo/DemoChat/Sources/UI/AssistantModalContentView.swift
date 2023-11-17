//
//  AssistantModalContentView.swift
//
//
//  Created by Chris Dillard on 11/9/23.
//

import SwiftUI

struct AssistantModalContentView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var customInstructions: String

    @Binding var codeInterpreter: Bool
    @Binding var retrieval: Bool

    var modify: Bool

    @Environment(\.dismiss) var dismiss

    @Binding var isPickerPresented: Bool
    @Binding var selectedFileURL: URL?
    

    var onCommit: () -> Void
    var onFileUpload: () -> Void


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 50)
                }
                Section(header: Text("Custom Instructions")) {
                    TextEditor(text: $customInstructions)
                        .frame(minHeight: 100)
                }

                Toggle(isOn: $codeInterpreter, label: {
                    Text("Code interpreter")
                })

                Toggle(isOn: $retrieval, label: {
                    Text("Retrieval")
                })
                if let selectedFileURL {
                    HStack {
                        Text("File: \(selectedFileURL.lastPathComponent)")

                        Button("Remove") {
                            self.selectedFileURL = nil
                        }
                    }
                }
                else {
                    Button("Upload File") {
                        isPickerPresented = true
                    }
                    .sheet(isPresented: $isPickerPresented) {
                        DocumentPicker { url in
                            selectedFileURL = url
                            onFileUpload()
                        }
                    }
                }
            }
            .navigationTitle("Enter Assistant Details")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("OK") {
                    onCommit()
                    dismiss()
                }
            )
        }
    }
}
