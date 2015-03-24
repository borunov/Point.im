//
//  PointDataStructures.swift
//  PointZero
//
//  Created by Александр Борунов on 06.03.15.
//  Copyright (c) 2015 Александр Борунов. All rights reserved.
//

import Foundation
import JSONJoy

public protocol UnwrapString {
}


class PointJSONAbstractClass : NSObject {
    // абстрактный класс нужен лишь для имплементации 
    // функции unwrapString которая вместо nil вернет пустую строку
    // все это нужно что бы позже принятые данные можно было отображать
    
    func unwrapString(s:String?) -> String {
        if s == nil {
            return ""
        } else {
            return s!
        }
    }
    func unwrapUInt(s:UInt?) -> UInt {
        if s == nil {
            return 0
        } else {
            return s!
        }
    }
    
    

}


class LoginAnswer : PointJSONAbstractClass, JSONJoy {
    var token: String?
    var csrf_token: String?
    var error: String?
    var ok: String?
//    override init() {
//        
//    }
    required init(_ decoder: JSONDecoder) {
        token = decoder["token"].string
        csrf_token = decoder["csrf_token"].string
        error = decoder["error"].string
        ok = decoder["ok"].string
    }
}


class Author : PointJSONAbstractClass, JSONJoy {
    var login = ""  /* "Daemon" Логин автора поста */
    var id : UInt = 0 /* 195 ID автора поста */
    var avatarURL = "" /* "daemon.jpg?r=4717"  Аватарка автора */
    var name = "" // "Daemon" Имя автора поста */
    override init() {
        super.init()
    }
    required init(_ decoder: JSONDecoder) {
        super.init()
        login = unwrapString(decoder["login"].string)
        id = unwrapUInt(decoder["id"].unsigned)
        avatarURL = unwrapString(decoder["avatar"].string)
        name = unwrapString(decoder["name"].string)
    }
}

class Comment : PointJSONAbstractClass, JSONJoy {
    // комментарий к посту
    var created = ""    // Дата и время написания комментария           "created": "2014-03-29T16:57:35.688586"
    var text = ""       // Текст     "text": "@skobkin-ru, \u0430 \u043a\u0438\u043d\u044c \u0441\u0432\u043e\u0439 CSS \u043f\u043e\u0433\u043e\u043d\u044f\u0442\u044c",
    var author = Author() // Объект автора комментария
    var post_id = ""    // В каком посте оставлен этот комментарий      "post_id": "llq",
    var to_comment_id: UInt = 0 // Параметр id комментария, на который написан ответ. null - значит комментарий не является ответом (комментарий первого уровня)                    "to_comment_id": null,
    var is_rec = false  // Является ли комментарий рекомендацией         "is_rec": false,
    var id : UInt = 0   // Идентификатор комментария в посте (уникален только в пределах родительского поста)   "id": 1

    
    
    override init() {
        super.init()
    }
    required init(_ decoder: JSONDecoder) {
        super.init()
        created = unwrapString(decoder["created"].string)
        text = unwrapString(decoder["text"].string)
        author = Author(decoder["author"])
        post_id = unwrapString(decoder["post_id"].string)
        to_comment_id = unwrapUInt(decoder["to_comment_id"].unsigned)
        is_rec = decoder["is_rec"].bool
        id = unwrapUInt(decoder["id"].unsigned)
    }
}


class Post : PointJSONAbstractClass, JSONJoy {
    // пост
    var tags : [String] = []        // Массив тегов                 "tags": ["point","log","web","dev","CSS","point+"],
    var comments_count: UInt = 0    // Количество комментариев      "comments_count": 5,
    var author = Author()           // Объект автора поста
    var text = ""                   // Текст поста                  "text": "@skobkin-ru, \u0430 \u043a",
    var created = ""                // Дата и время написания       "created": "2014-03-29T16:57:35.688586"
    var type = ""                   // Тип поста                    "type": "post",
    var id = ""                     // Символьный идентификатор (используется в URL) "id": "llq",

    var isPrivate = false           // Приватный ли пост            "private": false
                                    // ИМЯ ПЕРЕМЕННОЙ ОТЛИЧАЕТСЯ ОТ СТРОКИ JSONа !!!!

//    var comments : [Comment] = []   // массив комментариев
    
    
    
    override init() {
        super.init()
    }
    required init(_ decoder: JSONDecoder) {
        super.init()

        // взяли массив по тегу "tags", и если он не пуст, то пробежали по нему и взяли все строки к нам в массив self.tags
        if let tempTagsArray = decoder["tags"].array {
            tags = []
            for t in tempTagsArray {
                tags.append(unwrapString(t.string))
            }
        }

        comments_count = unwrapUInt(decoder["comments_count"].unsigned)
        author = Author(decoder["author"])
        text = unwrapString(decoder["text"].string)
        created = unwrapString(decoder["created"].string)
        type = unwrapString(decoder["type"].string)
        id = unwrapString(decoder["id"].string)
        isPrivate = decoder["private"].bool // это нормально
        
        
//        // взяли массив по тегу "comments", и если он не пуст, то пробежали по нему и взяли все строки к нам в массив self.comments
//        comments = [Comment]() // пустой массив комментов
//        if let tempCommentsArray = decoder["comments"].array {
//            for c in tempCommentsArray {
//                 comments.append(Comment(c))
//             }
//        }
     }
}




class Recomendation : PointJSONAbstractClass, JSONJoy {
    // объект рекомендации поста
    var text = ""           // Текст рекомендации               "text": "",
    var comment_id = ""     // Идентификатор комментария        "comment_id": null,
    var author = Author()   // Пользователь, который рекомендовал пост или комментарий
    
    
    
    override init() {
        super.init()
    }
    required init(_ decoder: JSONDecoder) {
        super.init()
        text = unwrapString(decoder["text"].string)
        comment_id = unwrapString(decoder["comment_id"].string)
        author = Author(decoder["author"])
    }
}





class MetaPost : PointJSONAbstractClass, JSONJoy {
    // метапост это то что выдается в ленте, содержит пост
    var bookmarked = false          // Добавлен ли пост в закладки              "bookmarked": false,
    var uid: UInt = 0               // Уникальный идентификатор в выборке, используется для пагинации (параметр before) "uid": 1291267,
    var subscribed = true           // Статус подписки на пост (комментарии)    "subscribed": true,
    var editable = false            // Разрешено ли редактирование              "editable": false,
    var recommended = true          // Рекомендован ли пост                     "recommended": true,
    var rec = Recomendation()       // заполняется если recommended==false
    var post = Post()               // Объект поста
    
    
    
    override init() {
        super.init()
    }
    required init(_ decoder: JSONDecoder) {
        super.init()
        
        bookmarked = decoder["bookmarked"].bool
        uid = unwrapUInt(decoder["uid"].unsigned)
        subscribed = decoder["subscribed"].bool
        editable = decoder["editable"].bool

        recommended = decoder["recommended"].bool
        if recommended == false {
            // у нас есть рекомендации
            rec = Recomendation(decoder["rec"])
        } else {
            rec = Recomendation()
        }
        
        post = Post(decoder["post"])        
    }
}





