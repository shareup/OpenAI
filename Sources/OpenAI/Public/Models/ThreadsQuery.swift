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
        public var content: [Content]
        public var attachments: [Attachment]
        
        enum CodingKeys: String, CodingKey {
            case role
            case content
            case attachments
        }
        
        public enum Content: Equatable, Codable {
            case text(String)
            case imageFile(ImageFile)
            case imageURL(ImageURL)
            
            public enum ImageDetail: String, Codable {
                case auto
                case low
                case high
            }
            
            var contentType: ContentType {
                switch self {
                case .text:
                    .text
                case .imageFile:
                    .imageFile
                case .imageURL:
                    .imageURL
                }
            }
            
            enum ContentType: String, Codable {
                case text
                case imageFile = "image_file"
                case imageURL = "image_url"
            }

            public struct ImageFile: Equatable, Codable {
                public let fileID: String
                public let detail: ImageDetail
                
                enum CodingKeys: String, CodingKey {
                    case fileID = "file_id"
                    case detail
                }
                
                public init(fileID: String, detail: ImageDetail = .auto) {
                    self.fileID = fileID
                    self.detail = detail
                }
            }
            
            public struct ImageURL: Equatable, Codable {
                public let url: String
                public let detail: ImageDetail
                
                public init(url: String, detail: ImageDetail = .auto) {
                    self.url = url
                    self.detail = detail
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case type
                case text
                case imageURL = "image_url"
                case imageFile = "image_file"
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(contentType, forKey: .type)
                switch self {
                case .text(let text):
                    try container.encode(text, forKey: .text)
                case .imageFile(let imageFile):
                    try container.encode(imageFile, forKey: .imageFile)
                case .imageURL(let imageURL):
                    try container.encode(imageURL, forKey: .imageURL)
                }
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(ContentType.self, forKey: .type)
                switch type {
                case .text:
                    let text = try container.decode(String.self, forKey: .text)
                    self = .text(text)
                case .imageFile:
                    let file = try container.decode(ImageFile.self, forKey: .imageFile)
                    self = .imageFile(file)
                case .imageURL:
                    let url = try container.decode(ImageURL.self, forKey: .imageURL)
                    self = .imageURL(url)
                }
            }
        }
        
        public init(
            role: Role,
            text: String,
            attachments: [Attachment] = []
        ) {
            self.role = role
            self.content = [.text(text)]
            self.attachments = attachments
        }
    }
}
