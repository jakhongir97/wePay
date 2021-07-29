//
//  ResponseErrors.swift
//  UzNavi
//
//  Created by Jakhongir Nematov on 08/12/20.
//

enum Result<T> {
    case Success(T)
    case Error(APIError, String? = nil)
}

enum APIError: Error {
    case requestFailed
    case invalidData
    case responseUnsuccessful
    case serverError
    case notAuthorized
    case fromMessage
    case notEnoughBalance
}
