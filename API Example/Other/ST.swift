//
//  ST.swift
//  API
//
//  Created by Zhang Shengliang on 2018/10/25.
//  Copyright © 2018年 Cho. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, json: JSON)
}

public protocol JSONSerializable {
    init?(json: JSON)
}

public extension ResponseObjectSerializable where Self: JSONSerializable {
    init?(response: HTTPURLResponse, json: JSON) {
        self.init(json: json)
    }
}

public enum STApi {
    
    public enum HostType {
        case local, staging, production
    }
    
    public typealias Parameters = [String: Any]
    public typealias Header = [String: String]
    
    case login(email: String, password: String, isAutoLogin: Bool)
    case refreshToken(refreshToken: String)
    case getNotice(noticeId: Int, token: String)
    
    public var request: DataRequest {
        switch self {
        case let .login(email, password, isAutoLogin):
            return self.request(
                params: [
                    "email": email,
                    "password": password,
                    "auto_login": isAutoLogin
                ],
                header: defaultHeader
            )
        case let .refreshToken(refreshToken):
            return self.request(params: ["refresh_token": refreshToken], header: defaultHeader)
        case let .getNotice(_, token):
            return self.request(
                params: nil,
                header: header(token: token)
            )
        }
    }
    
    public var urlString: String {
        return STApi.host + self.path
    }
    
    public static var host: String {
        let type = HostType.local
        switch type {
        case .local:        return "http://api.localhost.local:3000"
        case .staging:      return "https://stg.ST.jp/api"
        case .production:   return "https://api.ST.jp"
        }
    }
    
    public var path: String {
        switch self {
        case .login:                                            return "/v1/accounts/login"
        case .refreshToken:                                     return "/v1/accounts/refresh_token"
        case let .getNotice(nId,_):                             return "/v1/notifications/\(String(nId))"
        }
    }
    
    public var defaultHeader: Header {
        return [
            "X-Os-Type": "iOS",
            "X-App-Version": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "unknown"
        ]
    }
    
    func header(token: String) -> Header {
        var header = defaultHeader
        header["Authorization"] = "Bearer \(token)"
        return header
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login:                    return .post
        case .refreshToken:             return .patch
        case .getNotice:                return .get
        }
    }
    
    private func request(params: Parameters?, header: Header?) -> Alamofire.DataRequest {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let enocoding = {() -> ParameterEncoding in
            switch self.method {
            case .get:  return URLEncoding.queryString
            case _:     return JSONEncoding.default
            }
        }
        
        return SessionManager.default.request(urlString, method: method, parameters: params, encoding: enocoding(), headers: header)
    }
}


public enum Result<T> {
    case success(T)
    case failure(SukoyakuError)
    
    public var value: T? {
        switch self {
        case let .success(t):   return t
        case .failure(_):       return nil
        }
    }
}

public enum SukoyakuError: Error {
    
    public enum ResponseObjectSerializableError {
        case invalidParamaters
        
        func description() -> String {
            switch self {
            case .invalidParamaters:    return "取得されたデータで問題が発生しています。\n時間が経っても改善されない場合は開発者に連絡してください。"
            }
        }
    }
    
    public enum APIError: Int {
        case
        unknown = 0,
        badRequest = 400,                       // 400
        unauthorized = 401,                     // 401
        paymentRequired = 402,                  // 402
        forbidden = 403,                        // 403
        notFound = 404,                         // 404
        methodNotAllowed = 405,                 // 405
        notAcceptable = 406,                    // 406
        proxyAuthenticationRequired = 407,      // 407
        requestTimeout = 408,                   // 408
        conflict = 409,                         // 409
        gone = 410,                             // 410
        system = 500                            // 500
        
        func description() -> String {
            switch self {
            case .unknown:      return "原因不明のエラー"
            case .badRequest:   return "リクエストに問題があります。\n時間が経っても改善されない場合は開発者に連絡してください。"
            case .unauthorized: return "認証エラーです。\nもう一度ログインしてください。"
            case .notFound:     return "APIが存在しません。\n時間が経っても改善されない場合は開発者に連絡してください。"
            case .system:       return "システムエラーが発生しました。\n時間が経っても改善されない場合は開発者に連絡してください。"
            case _:             return "エラーです。\n時間が経っても改善されない場合は開発者に連絡してください。"
            }
        }
    }
    
    case unknown
    case api(reason: APIError, description: String?)
    case responseSerialize(reason: ResponseObjectSerializableError)
    case accountValidate
    case network
    
    public var description: String {
        get {
            switch self {
            case .unknown:                              return "原因不明のエラーが発生しました。"
            case let .api(reason: e, description: d):   return (d == "" ? nil : d) ?? e.description()
            case let .responseSerialize(reason: e):     return e.description()
            case .network:                              return "ネットワークエラーです。回線状況をご確認ください。"
            case .accountValidate:                      return "アカウントに不正があります。再度ログインしてください。"
            }
        }
    }
}


extension Alamofire.DataRequest {
    
    static let responseQueue = DispatchQueue(label: "SK.response-queue", attributes: .concurrent)
    
    func responseObject<T: ResponseObjectSerializable>(authorization: Bool = true, completionHandler: @escaping (Alamofire.DataResponse<T>) -> Void) {
        
        let responseSerializer = DataResponseSerializer<T> { request, response, dataOrNil, error in
            if let error = error {
                if (error as NSError).code == URLError.notConnectedToInternet.rawValue {
                    return .failure(SukoyakuError.network)
                }
                return .failure(error)
            }
            
            //            debugPrint(request ?? "")
            
            guard let response = response else { return .failure(AFError.responseValidationFailed(reason: .dataFileNil)) }
            
            guard let data = dataOrNil else { return .failure(AFError.responseSerializationFailed(reason: .inputDataNil)) }
            
            switch response.statusCode {
            case let c where c >= 400:
                let json = try! JSON(data: data)
                let error = SukoyakuError.api(reason: SukoyakuError.APIError(rawValue: c) ?? .unknown, description: json["userMessage"].string)
                if authorization  {
                    if case .api(.unauthorized, _) = error {
//                        Account.current.forcedLogout()
                    }
                }
                return .failure(error)
            case _:
                break
            }
            let json = try! JSON(data: data)
            //            debugPrint(json)
            guard let object: T = T(response: response, json: json) else { return .failure(SukoyakuError.responseSerialize(reason: .invalidParamaters)) }
            return .success(object)
        }
        
        
        self.response(queue: DataRequest.responseQueue, responseSerializer: responseSerializer, completionHandler: {response in
            DispatchQueue.main.async {
                completionHandler(response)
            }
        })
    }
    
    func responseObject<T: ResponseObjectSerializable>(refreshHandler: @escaping (Account) -> Void, completionHandler: @escaping (Alamofire.DataResponse<T>) -> Void) {
        self.responseObject(authorization: false) { (response: DataResponse<T>) in
            switch response.result {
            case .failure(SukoyakuError.api(.unauthorized, _)):
                break
/*
                guard let rt = Account.current.token?.refreshToken else {
                    Account.current.forcedLogout()
                    completionHandler(response)
                    return
                }
                Account.current.refreshToken(refreshToken: rt, completion: { (r) in
                    switch r {
                    case let .success(a):
                        switch a {
                        case .registered:
                            refreshHandler(a)
                        case _:
                            completionHandler(response)
                        }
                    case .failure(.api):
                        Account.current.forcedLogout()
                        completionHandler(response)
                    case .failure(_):
                        completionHandler(response)
                    }
                })
 */
            case _:
                completionHandler(response)
            }
        }
    }
}


public enum Account {
    case none, registered
    
    /// ログイン
    public func login(email: String, password: String, isAutoLogin: Bool, completion: @escaping (Result<Account>) -> Void) {
        STApi.login(email: email, password: password, isAutoLogin: isAutoLogin).request.responseObject { (response: DataResponse<Token>) in
            switch response.result {
            case let .success(t):
                break
                //                Defaults[.email] = email
                //                t.save(email: email)
                //                completion(.success(.current))
            //                Tracker.deviceID = ""
            case .failure(let e) where e is SukoyakuError:
                completion(.failure(e as! SukoyakuError))
            case .failure(_):
                completion(.failure(SukoyakuError.unknown))
            }
        }
    }
    
    /// Access tokenのリフレッシュ
    func refreshToken(refreshToken: String, completion: @escaping (Result<Account>) -> Void) {
        
        STApi.refreshToken(refreshToken: refreshToken).request.responseObject { (response: DataResponse<RefreshToken>) in
            switch response.result {
            case let .success(t):
                break
                //                guard let email = Defaults[.email] else {
                //                    completion(.failure(.unknown))
                //                    return
                //                }
                //
                //                t.save(email: email)
            //                completion(.success(.current))
            case .failure(let e) where e is SukoyakuError:
                completion(.failure(e as! SukoyakuError))
            case .failure(_):
                completion(.failure(SukoyakuError.unknown))
            }
        }
    }
}

public struct Token {
    
    public enum LoginType: String {
        case firstLogin =       "first_login"
        case registered =       "registered"
        case changePassword =   "change_password"
    }
    
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    public let loginType: LoginType
}

struct RefreshToken {
    let accessToken: String
    let scope: String
    let expiresAt: Date
}

extension Token: JSONSerializable, ResponseObjectSerializable {
    
    public init?(json: JSON) {
        guard
            let accessToken = json["access_token"].string,
            let expiresAt = json["expires_at"].string as? Date,//.flatMap({ $0.date(formatType: .jsonISODateTimeFormat) }),
            let loginType = json["login_type"].string.flatMap({ LoginType(rawValue: $0) })
            else {
                return nil
        }
        
        self.init(
            accessToken: accessToken,
            refreshToken: json["refresh_token"].string,
            expiresAt: expiresAt, loginType: loginType
        )
    }
}

extension RefreshToken: JSONSerializable, ResponseObjectSerializable {
    
    init?(json: JSON) {
        guard
            let accessToken = json["access_token"].string,
            let scope = json["scope"].string,
            let expiresAt = json["expires_at"].string as? Date //?.date(formatType: .jsonISODateTimeFormat)
            else { return nil }
        self.accessToken = accessToken
        self.scope = scope
        self.expiresAt = expiresAt
    }
}
