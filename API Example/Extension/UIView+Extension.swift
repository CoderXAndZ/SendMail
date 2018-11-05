//
//  UIView+Extension.swift
//  API Example
//
//  Created by mac on 2018/10/27.
//  Copyright © 2018年 cho. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /// 设置边框
    func addBorder(color:UIColor, width:CGFloat) {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = width
    }
    
}
