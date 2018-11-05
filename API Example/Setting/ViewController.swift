//
//  ViewController.swift
//  API Example
//
//  Created by Zhang Shengliang on 2018/10/25.
//  Copyright © 2018年 cho. All rights reserved.
//  主界面

import UIKit

class ViewController: UIViewController {
    /// 时间卡/タイムカード
    @IBOutlet weak var labelBeginTime: UILabel!
    /// 出勤
    @IBOutlet weak var btnAttendance: UIButton!
    /// 出勤时间
    @IBOutlet weak var labelBeOnDuty: UILabel!
    /// 退勤
    @IBOutlet weak var btnExit: UIButton!
    /// 退勤时间
    @IBOutlet weak var labelGetOffWork: UILabel!
    /// 外出
    @IBOutlet weak var btnGoOut: UIButton!
    /// 外出时间
    @IBOutlet weak var labelGoOutTime: UILabel!
    /// 返回/戻り 时间
    @IBOutlet weak var labelBackTime: UILabel!
    /// 返回/戻り
    @IBOutlet weak var btnBackTime: UIButton!
    /// 备忘录/メモ
    @IBOutlet weak var textMemo: UITextField!
    
    let dateFormatter = DateFormatter()

    var user = User()
    var setting = UserSetting()
    
    /// 位置
    let locationTool = GetLocationTool()
    var locationString = ""
    
    /// 是否当天已清空数据
    var isClear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 获取位置
        locationTool.openLocation { [weak self] (latitude, longitude) in
            if let weakSelf = self {
                weakSelf.locationString = "\(latitude) \(longitude)"
            }
        }
        
        /// 获取存储的model
        let settingObject = UserDefaults.AccountInfo.getObject(forkey: .setting) as? UserSetting
        
        if let settingObj = settingObject {
            setting = settingObj
            
            // 获取位置
            if setting.sendLocation {
                setting.location = locationString
            }else {
                setting.location = ""
            }
            
            let setTime = Int(setting.hour)! * 60 * 60 + Int(setting.minutes)! * 60
            let currentTime = Date().nowTimeinterval()
            let mistiming = Double(currentTime - setTime)
            
            // 设置的多久之前的时间
            let settingTimeAgo = Date().stringToDate(timeInterval: mistiming)
            print("currentTime:", currentTime, "mistiming:", mistiming, "\n settingTimeAgo:",settingTimeAgo)

            // 是今天
            if Date().isToday(date: settingTimeAgo) {
                print("是否是今天：",Date().isToday(date: settingTimeAgo), "isClear:",isClear)
                if isClear == false {
                    UserDefaults.AccountInfo.removeObject(forkey: .user)
                    user = User()
                    isClear = true
                }else {
                    getUserDecodedObject()
                }
            }else {
                getUserDecodedObject()
                
                isClear = false
            }
            
            labelBeOnDuty.text = user.beOnDuty
            labelGetOffWork.text = user.getOffWork
            labelGoOutTime.text = user.goOut
            labelBackTime.text = user.back
        }

        print("打印数据：", user.beOnDuty)
        print("-----是否获取位置:\(setting.sendLocation)")
        print("-----位置:\(setting.location ?? "")")
        print("-----id:\(setting.id ?? "没有") ")
        print("-----hostname:\(setting.server ?? "没有") ")
        print("-----SMTPPort:\(setting.SMTPPort ?? "没有") ")
        print("-----userName:\(setting.userName ?? "没有") ")
        print("-----password:\(setting.password ?? "没有") ")
        print("-----to:\(setting.to ?? "没有") ")
        print("-----name:\(setting.name ?? "没有") ")
        print("-----from:\(setting.from ?? "没有") ")
        print("-----subject: \(user.current_state)情报")
        
    }
    
    /// 获取存储的User数据
    func getUserDecodedObject() {
        let decodedObject = UserDefaults.AccountInfo.getObject(forkey: .user) as? User
        
        if let decoded = decodedObject {
            user = decoded
        }
    }
    
    /// 出勤
    @IBAction func btnBeginWork(_ sender: UIButton) {
        user.currentState = .onDuty // "出勤"
        
        returnKeybordAndSendEmail()
    }
    
    /// 退勤
    @IBAction func getoffWork(_ sender: UIButton) {
        user.currentState = .getOffWork //  "退勤"
        
        returnKeybordAndSendEmail()
    }
    
    /// 外出
    @IBAction func goOUt(_ sender: UIButton) {
        user.currentState = .goOut //  "外出"
        
        returnKeybordAndSendEmail()
    }
    
    /// 返回
    @IBAction func backToWork(_ sender: UIButton) {
        user.currentState = .back // "戻り"

        returnKeybordAndSendEmail()
    }
    
    /// 回收键盘并发送邮件
    func returnKeybordAndSendEmail() {
        if self.textMemo.isFirstResponder {
            self.textMemo.resignFirstResponder()
        }
        
        guard setting.userName != nil else {
            ShowAutoHideAlertView("请到設定页面进行設置")
            return
        }
        
        let time = Date().nowDateString(formatter: "HH:mm")
        let now = Date().nowDateString(formatter: "yyyy/MM/dd HH:mm:ss")
        user.currentTime = now
        
        switch user.currentState {
        case .onDuty:
            let text = " 打刻時間            \(time)"
            labelBeOnDuty.text = text
            user.beOnDuty = text
        case .getOffWork:
            let text = " 打刻時間            \(time)"
            labelGetOffWork.text = text
            user.getOffWork = text
        case .goOut:
            labelGoOutTime.text = time
            user.goOut = time
        case .back:
            labelBackTime.text = time
            user.back = time
        }
        
        // 发送邮件
        print("发送邮件")
        
        MailCore2Tools().sendEmail(setting: setting, user: user) { [weak self] (isSuccess, message) in
            ShowAutoHideAlertView(message)
            
            if let weakSelf = self {
                if isSuccess {
                    // 发送成功将 memo = ""
                    weakSelf.user.memo = ""
                    weakSelf.textMemo.text = ""
                    // 存储数据
                    UserDefaults.AccountInfo.saveObject(object: weakSelf.user, key: .user)
                }
            }
        }
        
    }
}

extension ViewController: UITextFieldDelegate {
    
    func setupUI() {
        labelBeginTime.addBorder(color: .black, width: 1)
        btnAttendance.addBorder(color: .black, width: 3)
        btnExit.addBorder(color: .black, width: 3)
        btnGoOut.addBorder(color: .black, width: 3)
        btnBackTime.addBorder(color: .black, width: 3)
        
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        user.memo = textField.text ?? ""
    }
    
    /// 更新时间
    @objc func updateTime() {
        let now = Date().nowDateString(formatter: "yyyy/MM/dd HH:mm:ss")
        labelBeginTime.text = now
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

/// 1、获取当前位置 ✅
/// 2.存储数据 ✅
/// 3.时间判断是否是当天6点以后
/// POP方式，没有的方式发送
/// 别的服务器的方式  163邮箱，

