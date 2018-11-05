//
//  String+Extension.swift
//  API Example
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018年 cho. All rights reserved.
//

import Foundation

extension String {
    
    /// 判断字符串是否为空
    func isEmptyString() -> Bool {
        return self.replacingOccurrences(of: " ", with: "").isEmpty
    }
    
}

extension Optional where Wrapped == String {
    
    /// 判断字符串是否为nil
    var isNilOrEmpty: Bool {
        return self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
    
}
