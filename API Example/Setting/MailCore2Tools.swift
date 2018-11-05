//
//  MailCore2Tools.swift
//  API Example
//
//  Created by mac on 2018/10/30.
//  Copyright © 2018年 cho. All rights reserved.
//  发送邮件

import UIKit

class MailCore2Tools: NSObject {
    
    /// 发送邮件
    func sendEmail(setting: UserSetting, user: User, completion:@escaping (_ isSuccess: Bool, _ msg: String)->()) {
        
        switch setting.secureWay {
        case .SMTP:
            let smtpSession = MCOSMTPSession()
            // smtp.163.com "smtp.qq.com"
            smtpSession.hostname = setting.server
            
            // 465 587
            smtpSession.port = UInt32(setting.SMTPPort ?? "")!
            
            // rongtuoyouxuan@163.com  1935786892@qq.com   928186296@qq.com
            smtpSession.username = setting.userName
            
            // llgggsngfjjjebjg   zjvgzzeukzaqcgjh   efumhglhenstbbhi
            smtpSession.password = setting.password
            smtpSession.connectionType = .startTLS
            smtpSession.authType = MCOAuthType.saslPlain
            
            print("hostname:\(setting.server ?? "没有") ")
            print("SMTPPort:\(setting.SMTPPort ?? "没有") ")
            print("userName:\(setting.userName ?? "没有") ")
            print("password:\(setting.password ?? "没有") ")
            
            // 判断登陆的代码
            let smtpOperation = smtpSession.loginOperation()
            smtpOperation?.start({ (error) in
                if (error != nil) {
                    completion(false, "登录邮箱失败！\(error ?? "" as! Error)")
                    print("login account failure: \(error ?? "" as! Error)")
                } else {
                    print("login account successed!")
                }
            })
            
            smtpSession.connectionLogger = {(connectionID, type, data) in
                if data != nil {
                    if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                        print("Connectionlogger: \(string)")
                    }
                }
            }
            
            let builder = MCOMessageBuilder()
            // 17615818324@163.com "1935722630@qq.com" "Rool"
            builder.header.to = [MCOAddress(displayName: setting.to, mailbox: setting.to)]
            // rongtuoyouxuan@163.com "1935786892@qq.com" "Matt R"
            builder.header.from = MCOAddress(displayName: setting.name, mailbox: setting.from)
            builder.header.subject = "\(user.current_state)情报"
            builder.textBody = "<社員>\(setting.id ?? "")\n<氏名>\(setting.name ?? "")\n<出退>\(user.current_state)\n<時間>\(user.currentTime ?? "")\n<位置>\(setting.location ?? "")\n<メモ>\(user.memo)"
            
            print("to:\(setting.to ?? "没有") ")
            print("name:\(setting.name ?? "没有") ")
            print("builder.textBody:\n\(builder.textBody ?? "没有") ")
            print("from:\(setting.from ?? "没有") ")
            print("subject: \(user.current_state)情报")
            
            let rfc822Data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: rfc822Data!)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    completion(false, "发送失败！\(error ?? "" as! Error)")
                    print("SMTP发送失败: \(error ?? "" as! Error)")
                } else {
                    completion(true, "发送成功！")
                    print("SMTP发送成功!")
                }
            }
        case .POPSMTP:
            let popSession = MCOPOPSession()
            popSession.hostname = setting.server
            popSession.port = UInt32(setting.SMTPPort ?? "")!
            popSession.username = setting.userName
            popSession.password = setting.password
            popSession.connectionType = .startTLS
            
            // 登陆邮箱
            let popOperation = popSession.checkAccountOperation()
            popOperation?.start({ (error) in
                if (error != nil) {
                    completion(false, "登录邮箱失败！\(error ?? "" as! Error)")
                    print("POP登录邮箱失败: \(error ?? "" as! Error)")
                } else {
                    print("POP登录邮箱成功!")
                }
            })
            
            print("POP SMTP")
        case .None:
            print("None")
        }
        
    }
    
}
