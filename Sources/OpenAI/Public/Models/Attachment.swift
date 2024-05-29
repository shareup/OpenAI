import Foundation

public struct Attachment: Codable, Equatable {
    public var fileId: String?
    public var tools: [Tool]?
    
    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case tools
    }
    
    public init(fileId: String? = nil, tools: [Tool]? = nil) {
        self.fileId = fileId
        self.tools = tools
    }
}
