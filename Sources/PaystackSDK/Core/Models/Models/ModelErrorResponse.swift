//
// ModelErrorResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ModelErrorResponse: Codable {

    public var status: Bool
    public var message: String

    public init(status: Bool, message: String) {
        self.status = status
        self.message = message
    }


}
