//
//  PointSuite.swift
//  PointZero
//
//  Created by Александр Борунов on 06.03.15.
//  Copyright (c) 2015 Александр Борунов. All rights reserved.
//

import Foundation
import SwiftHTTP
import JSONJoy


class PointSuite : NSObject {
    // это синглтон
    class var instance:PointSuite {
        struct Static {
            static let _instance = PointSuite()
        }
        return Static._instance
    }
    
//    override init() {
//        super.init()
//    }
  
    var loginName = ""
    var password = ""
    var token  = ""
    var csrf_token  = ""
    
    var isLogin = false
    
    var postsline = [MetaPost]()
    var authorsList = [Author]()
    
    
    
    func doLoginProcedure() {

        // возьмем пару логин/пароль в настройках системы
        let systemDefaults = SystemProperties.instance
        
        
        if let s = systemDefaults.sysDefaults["login"] {
            self.loginName = s
        } else {
            self.loginName = "bobo"
        }
        if let s = systemDefaults.sysDefaults["password"] {
            self.password = s
        } else {
            self.password = "bobopass"
        }

        
        
        // сбросим кэш предыдущих запросов
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        for  cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as [NSHTTPCookie]
        {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }

        // попробуем залогиниться
        var request=HTTPTask()
        
        request.requestSerializer = HTTPRequestSerializer()
        request.responseSerializer = JSONResponseSerializer() // типа чтобы разпознать JSON в ответе
        request.POST("http://point.im/api/login",
            parameters: ["login": self.loginName, "password": self.password],
            success: {(response: HTTPResponse) in

                let answer = LoginAnswer(JSONDecoder(response.responseObject!))
//                println(response.responseObject)
                println("token is \(answer.token)")
                println("csrf_token is \(answer.csrf_token)")
                println("Server error is \(answer.error)")
                self.isLogin = true
            },
            failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
                self.isLogin = false
            }
        )

    }
    
    func doLogoutProcedure()
    {
        let request = HTTPTask()


        
        request.responseSerializer = JSONResponseSerializer() // типа чтобы разпознать JSON в ответе
        request.POST("http://point.im/api/logout",
            parameters: ["csrf_token": self.csrf_token],
            success: {(response: HTTPResponse) in
                var answer = LoginAnswer(JSONDecoder(response.responseObject!))
                println("Logout \(answer.ok)")
                
            },
            failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
            }
        )
        self.isLogin = false
        SystemProperties.instance.saveDefaults()
    }

    func loadPostsInLineBefore(before : UInt) {
        
        var request=HTTPTask()
        
        request.requestSerializer = HTTPRequestSerializer()
        request.responseSerializer = JSONResponseSerializer() // типа чтобы разпознать JSON в ответе
        request.requestSerializer.headers["Authorization:"] = self.token
        
        request.GET("http://point.im/api/recent",
            parameters: ["before" : "0"],
            success: {(response: HTTPResponse) in
                if let dict = response.responseObject as? Dictionary<String,AnyObject> {
//                    dict["has_next"]
                    if let arrayOfPosts = dict["posts"] as? [MetaPost] {
                        for p in arrayOfPosts {
                            self.postsline.append(p)
                        }
                        
                    }
                    if let b = dict["has_next"] as? String {
                        println("has_next: \(b)")
                    }
                    
//                    println("print the whole response: \(response)")
                }
            },
            failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")

            }
        )
        

    }
    
    
    
    
    func doSomethingInQueue() {
    
    
    
    
    
    
    }
    
    
    
}



