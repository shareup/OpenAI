//
//  ThreadsQuery.swift
//
//
//  Created by Chris Dillard on 11/07/2023.
//

import Foundation

public struct ThreadsQuery: Equatable, Codable {
    public let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case messages
    }

    public init(messages: [Message]) {
        self.messages = messages
    }
    
    public struct Message: Equatable, Codable  {
        public enum Role: String, Equatable, Codable {
            case user
            case assistant
        }
        public var role: Role
        public var content: String // TODO: Support array as a possible content
        public var attachments: [Attachment]
        
        public init(role: Role, content: String, attachments: [Attachment] = []) {
            self.role = role
            self.content = content
            self.attachments = attachments
        }
    }
}
