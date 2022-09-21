//
//  APIError.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/30/22.
//

import Foundation


enum APIError: Error {

    // MARK: - Cases

    case unknown
    case unreachable
    case failedRequest
    case invalidResponse
    case failedDecode
    case resourceNotFound

    // MARK: - Properties

    var message: String {
        switch self {
        case .unreachable:
            return "You need to have a network connection."
        case .unknown,
                .failedRequest,
                .invalidResponse,
                .failedDecode,
                .resourceNotFound:
            return "The list of delcarations could not be fetched."
        }
    }

}
