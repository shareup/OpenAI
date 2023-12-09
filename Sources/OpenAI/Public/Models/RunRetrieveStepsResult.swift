//
//  RunRetreiveStepsResult.swift
//  
//
//  Created by Chris Dillard on 11/07/2023.
//

import Foundation

public struct RunRetreiveStepsResult: Codable, Equatable {
    
    public struct StepDetailsTopLevel: Codable, Equatable {

        public let stepDetails: StepDetailsSecondLevel

        enum CodingKeys: String, CodingKey {
            case stepDetails = "step_details"
        }

        public struct StepDetailsSecondLevel: Codable, Equatable {

            public let toolCalls: [ToolCall]?

            enum CodingKeys: String, CodingKey {
                case toolCalls = "tool_calls"
            }

            public struct ToolCall: Codable, Equatable {
                public let type: String
                public let code: CodeToolCall?
                
                public struct CodeToolCall: Codable, Equatable {
                    public let input: String
                    public let outputs: [[String: String]]

                }
            }
        }
    }

    public let data: [StepDetailsTopLevel]
}
