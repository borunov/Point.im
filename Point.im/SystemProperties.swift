//
//  Сохраним системные настройки.swift
//  Point.im
//
//  Created by Александр Борунов on 23.03.15.
//  Copyright (c) 2015 Александр Борунов. All rights reserved.
//

import Foundation


class SystemProperties: NSObject {
    
    class var sharedReader:SystemProperties {
        
        struct Static{
            static let _instance = SystemProperties()
        }
        
        return Static._instance
    }
    
    let keysSysDefaults = ["login","password","lastSeen"]

    
    var sysDefaults = Dictionary<String, String>()
    
    
    
    
    
    
    
    override init() {
        super.init()
        if caniCloud() == true {
            // здесь загрузка из облака
        } else {
            // читаем из локальных настроек
            for k in keysSysDefaults {
                if let s = NSUserDefaults.standardUserDefaults().stringForKey(k)? {
                    sysDefaults[k] = s
                    
                } else {
                    sysDefaults[k] = ""
                    // по идее раз что-то не считалось, надо установить какие-то значения по умочанию
                    // НАДО ЭТО СДЕЛАТЬ
                }
                println("\"" + k + "\": \"" + sysDefaults[k]! + "\"")
            }
        }
    }
    
    func caniCloud() -> Bool {
        // есть ли возможность получить или сохранить настройки из/в iCloud?
        // пока ее нет
        return false
    }
    
    func saveDefaults() {
        if caniCloud() == true {
            // здесь загрузка в облако
        } else {
            // пишем локально
            for k in keysSysDefaults {
                NSUserDefaults.standardUserDefaults().setObject(sysDefaults[k], forKey: k)
            }
        }
        
    }
    
    
    
    
}