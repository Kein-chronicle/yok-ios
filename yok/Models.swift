//
//  Models.swift
//  yok
//
//  Created by Kein-chronicle on 2020/07/05.
//  Copyright © 2020 kimjinwan. All rights reserved.
//

import Alamofire


class ApiClass {
    static func apiColler(
        _ url: String,
        _ parameters: Parameters,
        _ method: HTTPMethod,
        _ success: String,
        _ fail: String
    ) {
        print(url)
        let headers:HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        AF.request(
            url,
            method: method,
            parameters: parameters,
            headers: headers
        ).responseJSON(completionHandler: { (response) in
            // call fail
            guard let statusCode = response.response?.statusCode else {
                NotificationCenter.default.post(name: NSNotification.Name(fail), object: nil)
                return
            }
            // status code != 200 : fail
            if statusCode != 200 {
                NotificationCenter.default.post(name: NSNotification.Name(fail), object: nil)
                return
            }
            // status code == 200 : success
            guard let getData = response.value as? [String:Any] else {
                NotificationCenter.default.post(name: NSNotification.Name(success), object: nil)
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(success), object: nil, userInfo: getData)
        })
    }
}
