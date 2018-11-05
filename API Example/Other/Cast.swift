//
//  Cast.swift
//  API
//
//  Created by Cho on 2018/10/15.
//  Copyright © 2018 Cho. All rights reserved.
//

import Foundation
import Alamofire


typealias ResponseBody<T: Decodable> = (T) -> Void
typealias ResponseError = (_ statusCode: Int, _ error: Error) -> Void

final class CastAPI {
    
    private init() {}
    
    static var xToken: String = ""
    #if BETA
    static var base = "https://staging.api.io/api/v1"
    #else
    static var base = "https://api.io/api/v1"
    #endif
    
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iso8601Extend)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Extend)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private static func makeURLRequest(path: String, method: HTTPMethod, token: String? = nil) -> URLRequest {
        var url = try! URLRequest(url: "\(base)\(path)", method: method)
        if let token = token, !token.isEmpty {
            url.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return url
    }
    
    static func makeURLRequest<T: Encodable>(path: String, method: HTTPMethod, token: String? = nil, requestBody: T) -> URLRequest {
        var request = makeURLRequest(path: path, method: method, token: token)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! jsonEncoder.encode(requestBody)
        return request
    }
    
    static func send<T: Decodable>(_ urlRequest: URLRequest, _ success: @escaping ResponseBody<T>, _ error: @escaping ResponseError) -> DataRequest {
        
        if let body = urlRequest.httpBody {
            print("Request URL: \(urlRequest)\nRequest Body:\n\t\(String(data: body, encoding: .utf8)!)")
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let request = Alamofire.request(urlRequest)
        request.responseData { result in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            // print(result.debugDescription)
            
            if let fatalError = result.error {
                print(fatalError)
                error(result.response?.statusCode ?? -1, fatalError)
                return
            }
            
            guard let data = result.data, let response = result.response else { return }
            let statusCode = response.statusCode
            
            print("Response Status: \(statusCode), from \(urlRequest.httpMethod!) \(urlRequest), time: \((result.metrics?.taskInterval.duration ?? -1))s")
            // Response headerからtokenがあれば取得する
            if let token = response.allHeaderFields["x-token"] as? String {
                xToken = token
            }
            
            do {
                switch statusCode {
                case 204:
                    let data = "{}".data(using: .utf8)!
                    let obj = try jsonDecoder.decode(T.self, from: data)
                    success(obj)
                case 0...399:
                    // Response body
                    //                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    //                    dprint(data, "Response Body (Raw): \n\t\(jsonDictionary as AnyObject)")
                    let obj = try jsonDecoder.decode(T.self, from: data)
                    //                    dprint("Response Body (Decoded): \n\t\(obj)")
                    success(obj)
                case 400...499:
                    // Client error
                    print(String(data: data, encoding: .utf8)!)
                    error(statusCode, APIError(message: String(data: data, encoding: .utf8)!))
                default:
                    // Server error
                    print(String(data: data, encoding: .utf8)!)
                    error(statusCode, APIError(message: String(data: data, encoding: .utf8)!))
                }
            } catch let fatalError {
                if let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(data, "Response Body (Raw): \n\t\(jsonDictionary as AnyObject)")
                } else {
                    print(data)
                }
                print(fatalError)
                error(statusCode, fatalError)
            }
        }
        return request
    }
}

class APIError: Error, LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
    
    let message: String
    
    init(message: String) {
        self.message = message
    }
}

extension DateFormatter {
    static var iso8601Extend: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
}

extension CastAPI {
    @discardableResult
    static func getUser(userId: Int, success: @escaping (UserResponseBody) -> Void, error: @escaping ResponseError) -> DataRequest {
        let request = makeURLRequest(path: "/users/\(userId)", method: .get, token: xToken)
        return send(request, success, error)
    }

    struct UserResponseBody: Codable {
        var user: User
    }

    typealias UserId = Int
    struct User: Codable {
        let id: UserId
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name = "ueserName"
        }
    }
}
