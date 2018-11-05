//
//  User.swift
//  API Example
//
//  Created by XZ on 2018/10/28.
//  Copyright © 2018年 cho. All rights reserved.
//  用户类

import UIKit

enum States {
    case onDuty /// 出勤
    case getOffWork /// 退勤
    case goOut /// 外出
    case back  /// 戻り
}

class User: NSObject, NSCoding {

    struct UserPropertyKey {
        static let beOnDuty = "beOnDuty"
        static let getOffWork = "getOffWork"
        static let goOut = "goOut"
        static let back = "back"
        static let memo = "memo"
    }
    
    /// 出勤
    var beOnDuty: String = " 打刻時間            --:--"
    /// 退勤
    var getOffWork: String = " 打刻時間            --:--"
    /// 外出
    var goOut: String = "--:--"
    /// 戻り
    var back: String = "--:--"
    /// 备忘录
    var memo: String = ""
    /// 当前状态
    var currentState: States = .onDuty
    
    var current_state: String {
        get {
            switch currentState {
            case .onDuty:
                return "出勤"
            case .getOffWork:
                return "退勤"
            case .goOut:
                return "外出"
            case .back:
                return "戻り"
            }
        }
    }
    
    /// 当前时间
    var currentTime: String?
    
    // 构造方法
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(beOnDuty, forKey: UserPropertyKey.beOnDuty)
        aCoder.encode(getOffWork, forKey: UserPropertyKey.getOffWork)
        aCoder.encode(goOut, forKey: UserPropertyKey.goOut)
        aCoder.encode(back, forKey: UserPropertyKey.back)
        aCoder.encode(memo, forKey: UserPropertyKey.memo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        beOnDuty = aDecoder.decodeObject(forKey: UserPropertyKey.beOnDuty) as! String
        getOffWork = aDecoder.decodeObject(forKey: UserPropertyKey.getOffWork) as! String
        goOut = aDecoder.decodeObject(forKey: UserPropertyKey.goOut) as! String
        back = aDecoder.decodeObject(forKey: UserPropertyKey.back) as! String
        memo = aDecoder.decodeObject(forKey: UserPropertyKey.memo) as! String
    }
}

class UserSetting: NSObject, NSCoding {
    
    enum secureWays: String {
        case SMTP = "SMTP"
        case POPSMTP  = "POPSMTP"
        case None = "没有"
    }
    
    struct PropertyKey {
        static let idKey = "id"
        static let nameKey = "name"
        static let fromKey = "from"
        static let toKey = "to"
        static let serverKey = "server"
        static let SMTPPortKey = "SMTPPort"
        static let secureKey = "secure"
        static let secureWayKey = "secureWay"
        static let userNameKey = "userName"
        static let passwordKey = "password"
        static let sendLocationKey = "sendLocation"
        static let locationKey = "location"
        static let hourKey = "hour"
        static let minutesKey = "minutes"
    }
    
    /// 社員番号
    var id: String?
    /// 社員名
    var name: String?
    // 送信元メールアドレス / 发件人
    var from: String?
    // 送信先メールアドレス / 收件人
    var to: String?
    /// 送信元メールアドレス / 发送邮件服务器
    var server: String?
    /// SMTPポート/SMTP端口 587
    var SMTPPort: String?
    /// Secureの要否 / 是否加密？
    var secure: Bool = true
    /// 認証方式 
    var secureWay: secureWays = .SMTP 
    /// ユーザー / 用户
    var userName: String?
    /// パスワード / 密码
    var password: String?
    /// 位置情報を送信する / 发送位置信息
    var sendLocation: Bool = true
    /// 位置信息
    var location: String?
    /// 设置分割时间点 - 小时
    var hour: String = "06"
    /// 设置分割时间点 - 分钟
    var minutes: String = "00"
    
    override init() {
        super.init()
        
    }
 
    required init?(coder aDecoder: NSCoder) {

        id = aDecoder.decodeObject(forKey: PropertyKey.idKey) as? String
        name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as? String
        from = aDecoder.decodeObject(forKey: PropertyKey.fromKey) as? String
        to = aDecoder.decodeObject(forKey: PropertyKey.toKey) as? String
        server = aDecoder.decodeObject(forKey: PropertyKey.serverKey) as? String
        SMTPPort = aDecoder.decodeObject(forKey: PropertyKey.SMTPPortKey) as? String
        secure = aDecoder.decodeBool(forKey: PropertyKey.secureKey)
        secureWay = UserSetting.secureWays(rawValue: aDecoder.decodeObject(forKey: PropertyKey.secureWayKey) as! String)!
        userName = aDecoder.decodeObject(forKey: PropertyKey.userNameKey) as? String
        password = aDecoder.decodeObject(forKey: PropertyKey.passwordKey) as? String
        sendLocation = aDecoder.decodeBool(forKey: PropertyKey.sendLocationKey)
        location = aDecoder.decodeObject(forKey: PropertyKey.locationKey) as? String
        hour = aDecoder.decodeObject(forKey: PropertyKey.hourKey) as! String
        minutes = aDecoder.decodeObject(forKey: PropertyKey.minutesKey) as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.idKey)
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(from, forKey: PropertyKey.fromKey)
        aCoder.encode(to, forKey: PropertyKey.toKey)
        aCoder.encode(server, forKey: PropertyKey.serverKey)
        aCoder.encode(SMTPPort, forKey: PropertyKey.SMTPPortKey)
        aCoder.encode(secure, forKey: PropertyKey.secureKey)
        aCoder.encode(secureWay.rawValue, forKey: PropertyKey.secureWayKey)
        aCoder.encode(userName, forKey: PropertyKey.userNameKey)
        aCoder.encode(password, forKey: PropertyKey.passwordKey)
        aCoder.encode(sendLocation, forKey: PropertyKey.sendLocationKey)
        aCoder.encode(location, forKey: PropertyKey.locationKey)
        aCoder.encode(hour, forKey: PropertyKey.hourKey)
        aCoder.encode(minutes, forKey: PropertyKey.minutesKey)
        
    }
}
