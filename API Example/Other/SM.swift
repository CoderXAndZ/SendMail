//
//  SM.swift
//  API
//
//  Created by Zhang Shengliang on 2018/10/25.
//  Copyright © 2018年 Cho. All rights reserved.
//

import Foundation
import UIKit


protocol Api {
    var headers:[String:String] { get }
    var fullyURL: URL { get }
    var baseURL: String { get }
    var version: String { get }
    var path: String { get }
    var parameters: [String: Any] { get }
}

public enum HTTPmethod: String{
    case post = "POST"
    case get  = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

struct Domain {
    #if DEBUG//Sandbox
    static let  apiDomain = "api-sandbox.sm.com"
    static let  webDomain = "ss-sandbox.sm.com"
    #else
    static let  apiDomain = "api.sm.com"
    static let  webDomain = "ss.sm.com"
    #endif
}

protocol SMApi {
    var method:         HTTPmethod  { get }
    var tokenNeeded:    Bool        { get }
}

extension SMApi {
    
    var token:(userId: String, appToken: String)? {
        return nil
    }
    
    var commonHeader: [String: String] {
        var headers = [String: String]()
        
        if tokenNeeded, let token = token {
            headers["userId"] = token.userId
            headers["appToken"] = token.appToken
        }
        return headers
    }
}

enum SoundMoovzApi: Api{
    var headers:[String:String] {
        var _headers = [String:String]()
        
        let username = "BM"
        let password = "PW"
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        _headers["Authorization"] = "Basic \(base64LoginString)"
        _headers["User-Agent"] = "SoundMoovz/\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion);)"
        _headers["Accept-Language"] = "\(Locale.current.identifier)"
        
        switch self {
        case .live(let live):
            live.headers.forEach({ (key, value) in
                _headers[key] = value
            })        }
        
        return _headers
    }
    
    var fullyURL: URL {
        return URL(string: "\(baseURL)\(path)")!
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .live(let l):          return l.path
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .live(let l):          return l.params
        }
    }

//    func run<B: Body>(with service: SoundMoovzApiService) -> Observable<(HTTPURLResponse, B)>? {
    func run<B: Body>() -> (HTTPURLResponse, B)? {
    
        let smApi: SMApi
        switch self {
        case .live(let api):        smApi = api
        }
        
        if smApi.tokenNeeded && smApi.token == nil { return nil }
        
        switch smApi.method {
//        case .get:  return service.get(api: self)
//        case .put:  return service.put(api: self)
//        case .post: return service.post(api: self)
        default: return nil
        }
    }
    
    var baseURL: String {
        return "https://" + Domain.apiDomain + "/api"
    }
    
    case live(Live)
    
    enum Live: SMApi
    {
        case start
        case finish(liveId: String)
        case message(liveId: String, message: String)
        
        var path: String {
            let base = "/lives"
            
            switch self {
            case .start:                    return base
            case .finish(let liveId):       return base + "/\(liveId)/finish"
            case .message(let liveId, _):   return base + "/\(liveId)/message"
            }
        }
        
        var method: HTTPmethod {
            switch self {
            case .start:    return .post
            case .finish:   return .put
            case .message:  return .post
            }
        }
        
        var tokenNeeded: Bool {
            switch self {
            case .start, .finish, .message:
                return true
            default:
                return false
            }
        }
        
        var params:[String: Any] {
            var params = [String: Any]()
            
            switch self {
            case .message(_, let message):
                params["message"] = message
            default:
                break
            }
            return params
        }
        
        var headers:[String: String] {
            return commonHeader
        }
    }
}

class Body//: Mappable
{
    var status:ApiStatus.Status200?
    var message:String?
    var finishAt:Date?
    var url:URL?
    var date:Int64?
    
//    required init?(map: Map) {}
//    func mapping(map: Map)
//    {
//        status <- (map["status"], EnumTransform<ApiStatus.Status200>())
//        message <- map["message"]
//        finishAt <- map["finishAt"]
//        url <- (map["url"], URLTransform())
//        date <- map["date"]
//    }

}

class Live:Body
{
    var liveId:String?
    var streamPath:String?
    var start:Date?
    
//    override func mapping(map: Map)
//    {
//        super.mapping(map: map)
//
//        liveId <- map["liveId"]
//        streamPath <- map["streamPath"]
//        start <- map["start"]
//    }
}



enum ApiStatus{
    
    enum Status200:String{
        
        case OK = "ok"
        case InMaintenance = "In Maintenance"
        case UpdateRequired = "Update Required"
        case UpdateNotify = "Update Notify"
        
        func toNSError() -> NSError{
            return NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey:self.rawValue])
        }
    }
    case NoError
    case Success_200(status:Status200?)
    case AuthorizationRequired_401
    case NotFound_404
    case Unavailable_503
    case StandardError(resp:HTTPURLResponse)
    case UnknownError_999
    
    init(code:Int){
        switch code {
        case 0: self = .NoError
        case 200: self = .Success_200(status: nil)
        case 401: self = .AuthorizationRequired_401
        case 404: self = .NotFound_404
        case 503: self = .Unavailable_503
        default: self = .UnknownError_999
        }
    }
    
    var code:Int{
        switch self {
        case .NoError:
            return 0
        case .Success_200:
            return 200
        case .AuthorizationRequired_401:
            return 401
        case .NotFound_404:
            return 404
        case .Unavailable_503:
            return 503
        case .StandardError(let resp):
            return resp.statusCode
        case .UnknownError_999:
            return 999
            
        }
    }
    
    var message:String{
        switch self {
        case .NoError:
            return "no error"
        case .Success_200:
            return "success"
        case .AuthorizationRequired_401:
            return "Authorization required"
        case .NotFound_404:
            return "ErrorMsgKey.NotFound"
        case .Unavailable_503:
            return "Server temporary unavailable."
        case .StandardError(let resp):
            return "response status \(resp.statusCode)"
        case .UnknownError_999:
            return "ErrorMsgKey.Unknown"
        }
    }
    
    func toNSError() -> NSError{
        
        switch self {
            
        case .Success_200(let status):
            
            if let _s = status {
                return _s.toNSError()
            }
            
        default:
            
            break;
        }
        return NSError(domain: "", code: self.code, userInfo: [NSLocalizedDescriptionKey:self.message])
    }
}



class SoundMoovzApiService
{
    /*
    private(set) var error:Variable<ApiStatus> = Variable(ApiStatus.NoError)
    static private var isShowingAlert:Variable<Bool> = Variable(false)
    
    private let db = DisposeBag()
    
    init(){
        
        error.asObservable()
            .subscribe(onNext:{ (apistatus:ApiStatus) in
                
                switch apistatus {
                    
                case .UnknownError_999:
                    SoundMoovzApiService.showAlertError(title: "Global.Error".localized, message: "Global.NetworkUnable".localized)
                    
                default:
                    break
                }
            })
            .addDisposableTo(db)
    }
    
    
    func baseBehavior<B: Body>(apiService:Observable<(HTTPURLResponse, B)>) -> Observable<(HTTPURLResponse, B)>{
        return Observable.create({ (obs) -> Disposable in
            return apiService
                .subscribe(onNext: { [unowned self](resp, body) in
                    
                    guard (200..<300) ~= resp.statusCode else{
                        let error = ApiStatus(code: resp.statusCode)
                        if case .AuthorizationRequired_401 = error, (resp.url?.absoluteString ?? "").hasPrefix(SoundMoovzApi.soundshare(ss: .base).baseURL) {
                            // SoudShareAPI401エラーの場合、強制ログアウトする
                            self.error.value = error
                            AccountManager.shared.logout(confirm: false)
                        } else {
                            self.error.value = ApiStatus.StandardError(resp: resp)
                            
                            if let message = body.message {
                                SoundMoovzApiService.showAlertError(title: "Global.Error".localized, message: message.localized)
                            }
                        }
                        
                        obs.onError(self.error.value.toNSError())
                        return
                    }
                    
                    if let status = body.status, status != .OK {
                        // update required
                        if status == .UpdateRequired{
                            if let path = body.url {
                                
                                PopUp.shared.showUpdateAlert(status: ServerStatus.UpdateRequired,
                                                             msg: body.message ?? status.rawValue,
                                                             path: path.absoluteString,
                                                             targetVC: UIApplication.topViewController())
                            }
                        }
                        self.error.value = ApiStatus.Success_200(status: status)
                        obs.onError(status.toNSError())
                    }
                    
                    // success
                    obs.onNext((resp, body))
                    obs.onCompleted()
                    
                    }, onError: { [unowned self](err:Error) in
                        LOG("api error \(err)")
                        var apistatus = ApiStatus.UnknownError_999
                        if let aferror = err as? Alamofire.AFError {
                            
                            switch aferror {
                                
                            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
                                // ignore
                                apistatus = ApiStatus.NoError
                                
                            default:
                                break
                                
                            }
                            
                            
                        }
                        
                        
                        self.error.value = apistatus
                        obs.onError(apistatus.toNSError())
                })
        })
        
    }
    
    func get<B: Body>(api:SoundMoovzApi) -> Observable<(HTTPURLResponse, B)>{
        LOG("api get \(api.fullyURL.absoluteString) \(api.parameters.description)")
        let _api = api as Api
        return baseBehavior(apiService: ApiService.get(api: _api))
    }
 */
}
