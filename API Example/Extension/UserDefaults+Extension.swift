//
//  UserDefaults+Extension.swift
//  API Example
//
//  Created by mac on 2018/10/29.
//  Copyright © 2018年 cho. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// 账户信息
    struct AccountInfo: UserDefaultsSettable {

        enum defaultKeys: String {
            case user = "CurrentUser"
            case setting = "UserSetting"
        }
    }
    
}

protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaultsSettable where defaultKeys.RawValue == String {
    
    /// 存储对象
    static func saveObject(object: NSCoding, key: defaultKeys) {
        
        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedObject, forKey: key.rawValue)
    }
    
    /// 获取对象
    static func getObject(forkey key: defaultKeys) -> Any? {
        
        let decodedObject = UserDefaults.standard.object(forKey: key.rawValue)
        
        if let decoded = decodedObject {
            let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as! Data)
            return object
        }
        
        return nil
    }
    
    /// 删除对象
    static func removeObject(forkey key: defaultKeys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    /// 存储单一属性
    static func set(value: String?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    /// 获取单一字符串属性
    static func string(forKey key: defaultKeys) -> String? {
        let aKey = key.rawValue
        return UserDefaults.standard.string(forKey: aKey)
    }
  
}
