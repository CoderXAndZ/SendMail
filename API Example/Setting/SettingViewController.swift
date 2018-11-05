//
//  SettingViewController.swift
//  API Example
//
//  Created by XZ on 2018/10/28.
//  Copyright © 2018年 cho. All rights reserved.
//  设定页面

import UIKit

class SettingViewController: UIViewController {
    /// 社員番号
    @IBOutlet weak var textUserId: UITextField!
    /// 社員名
    @IBOutlet weak var textUserName: UITextField!
    /// 送信元メールアドレス / 发件人邮箱地址
    @IBOutlet weak var textFrom: UITextField!
    /// 送信先メールアドレス / 收件人
    @IBOutlet weak var textTo: UITextField!
    /// 送信メールサーバー / 发送邮件服务器
    @IBOutlet weak var textSendServer: UITextField!
    /// SMTPポート / 端口号
    @IBOutlet weak var textPort: UITextField!
    /// ユーザー / 邮箱名
    @IBOutlet weak var textMailUserName: UITextField!
    /// パスワード / 邮箱授权码
    @IBOutlet weak var textPassword: UITextField!
    /// 小时
    @IBOutlet weak var labelHour: UILabel!
    /// 分钟
    @IBOutlet weak var labelMinutes: UILabel!
    /// secure
    @IBOutlet weak var btnSecure: UIButton!
    /// SMTP
    @IBOutlet weak var btnSMTP: UIButton!
    /// POPSMTP
    @IBOutlet weak var btnPOPSMTP: UIButton!
    /// 没有
    @IBOutlet weak var btnNone: UIButton!
    /// 位置
    @IBOutlet weak var btnLocation: UIButton!
    
    var userSetting = UserSetting()
    
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 获取存储的model
        let settingObject = UserDefaults.AccountInfo.getObject(forkey: .setting) as? UserSetting
        
        if let settingObj = settingObject {
            userSetting = settingObj
            
            textUserId.text = userSetting.id
            textUserName.text = userSetting.name
            textSendServer.text = userSetting.server
            textFrom.text = userSetting.from
            textTo.text = userSetting.to
            textPort.text = userSetting.SMTPPort
            textMailUserName.text = userSetting.userName
            textPassword.text = userSetting.password
            btnSecure.isSelected = userSetting.secure
            btnLocation.isSelected = userSetting.sendLocation
            labelHour.text = userSetting.hour
            labelMinutes.text = userSetting.minutes
            
            setSecureWay()
        }
        print("打印数据：" ,userSetting.id ?? "")
    }
    
    /// 设置小时
    @IBAction func setHour(_ sender: UIButton) {

        let text = userSetting.hour
        
        var hour = Int(text)!
        if hour < 23 {
            hour = hour + 1
        }else {
            hour = 0
        }
        
        let hourStr = String.init(format: "%02d", hour)
        
        labelHour.text = hourStr
        userSetting.hour = hourStr
    }
    
    /// 设置分钟
    @IBAction func setMinutes(_ sender: UIButton) {

        let text = userSetting.minutes
        
        var minute = Int(text)!
        if minute < 59 {
            minute = minute + 1
        }else {
            minute = 0
        }
        let minStr = String.init(format: "%02d", minute)
        
        labelMinutes.text = minStr
        userSetting.minutes = minStr
        
    }
    
    /// secure
    @IBAction func secureAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        userSetting.secure = sender.isSelected
    }
    
    /// SMTP 认证
    @IBAction func SMTPCertification(_ sender: UIButton) {
        userSetting.secureWay = .SMTP
        setSecureWay()
    }
    
    /// POPSMTP认证
    @IBAction func POPSMTPCertification(_ sender: UIButton) {
        userSetting.secureWay = .POPSMTP // "POPSMTP"
        setSecureWay()
    }
    
    /// 没有
    @IBAction func NoneCertification(_ sender: UIButton) {
        userSetting.secureWay = .None
        setSecureWay()
    }
    
    ///
    func setSecureWay() {
        switch userSetting.secureWay {
        case .SMTP:
            btnSMTP.isSelected = true
            btnNone.isSelected = false
            btnPOPSMTP.isSelected = false
        case .POPSMTP:
            btnSMTP.isSelected = false
            btnNone.isSelected = false
            btnPOPSMTP.isSelected = true
        case .None:
            btnNone.isSelected = true
            btnSMTP.isSelected = false
            btnPOPSMTP.isSelected = false
        }
    }
    
    /// 添加位置
    @IBAction func addLocation(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        btnLocation.isSelected = sender.isSelected
        userSetting.sendLocation = sender.isSelected
    }
    
    /// 保存
    @IBAction func saveUserInfo(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        if userSetting.id.isNilOrEmpty {
            ShowAutoHideAlertView("请输入社員番号")
            return
        }else if userSetting.name.isNilOrEmpty {
            ShowAutoHideAlertView("请输入社員名")
            return
        }else if userSetting.server.isNilOrEmpty {
            ShowAutoHideAlertView("请输入送信元メールアドレス")
            return
        }else if userSetting.from.isNilOrEmpty {
            ShowAutoHideAlertView("请输入送信先メールアドレス")
            return
        }else if userSetting.to.isNilOrEmpty {
            ShowAutoHideAlertView("请输入送信メールサーバー")
            return
        }else if userSetting.SMTPPort.isNilOrEmpty {
            ShowAutoHideAlertView("请输入SMTPポート")
            return
        }else if userSetting.userName.isNilOrEmpty {
            ShowAutoHideAlertView("请输入ユーザー")
            return
        }else if userSetting.password.isNilOrEmpty {
            ShowAutoHideAlertView("请输入パスワード")
            return
        }
        
        // 存储
        UserDefaults.AccountInfo.saveObject(object: userSetting, key: .setting)
    }
}

extension SettingViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 100:
            userSetting.id = textField.text
        case 101:
            userSetting.name = textField.text
        case 102:
            userSetting.from = textField.text
        case 103:
            userSetting.to = textField.text
        case 104:
            userSetting.server = textField.text
        case 105:
            userSetting.SMTPPort = textField.text
        case 106:
            userSetting.userName = textField.text
        case 107:
            userSetting.password = textField.text
        default:
            break
        }
        
    }
}

extension SettingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
