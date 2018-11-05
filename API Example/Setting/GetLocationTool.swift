//
//  GetLocationTool.swift
//  API Example
//
//  Created by mac on 2018/10/31.
//  Copyright © 2018年 cho. All rights reserved.
//  定位

import UIKit
import CoreLocation

class GetLocationTool: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!

    private var completionBlock: ((_ lat: String, _ longi: String)->())?
    
    /// 开启定位
    func openLocation(completion:@escaping ((_ lat: String, _ longi: String)->())) {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // 定位方式
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新距离
        locationManager.distanceFilter = 150

        // 使用应用程序期间允许访问位置数据
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            // 开启定位
            locationManager.startUpdatingLocation()
        }
        completionBlock = completion
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            // 判断是否为空
            if location.horizontalAccuracy > 0 {
                let latitude = "\(location.coordinate.latitude)"
                let longtitude = "\(location.coordinate.longitude)"
                
                print("经度：\(latitude) 纬度：\(longtitude)")
                
                manager.stopUpdatingLocation()
                completionBlock?(latitude, longtitude)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位出现失败: \(error)")
    }
    
    // 出现错误
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        print("定位出现错误: \(error ?? "" as! Error)")
    }
}
