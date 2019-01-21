//
//  LoginModel.swift
//  igloo
//
//  Created by 冯奕琦 on 2018/12/18.
//  Copyright © 2018 冯奕琦. All rights reserved.
//

import Foundation

class LoginModel {
    
    //配置储存
    let defaults = UserDefaults.standard
    
    //公开登陆状态
    static var login:Bool{
        get{
           let login = UserDefaults.standard.object(forKey: Constants.isLogin) as! Bool
           return login
        }
    }
    //公开 iglooID 用户喜欢或者拥有地点
    static var iglooID:String{
        get{
            return UserDefaults.standard.object(forKey: Constants.iglooID) as! String
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Constants.iglooID)
        }
    }
    static var owenLocationIDArray:[String]{
        get{
            return UserDefaults.standard.object(forKey: Constants.usersOwenPlacesDefaultJsonKey) as! [String]
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Constants.usersOwenPlacesDefaultJsonKey)
        }
    }
    static var owenLikedLocationIDArray:[String]{
        get{
            return UserDefaults.standard.object(forKey: Constants.usersLikePlacesDefaultJsonKey) as! [String]
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Constants.usersLikePlacesDefaultJsonKey)
        }
    }
    
    //内部可改变的状态
    var isLogin:Bool{
        get{
            return defaults.object(forKey: Constants.isLogin) as! Bool
        }
        set{
            defaults.set(newValue, forKey: Constants.isLogin)
        }
    }
    
    //Google登陆方法
    
    func loginWithGoogle(googleID:String,GoogleName:String,action:@escaping (Bool)->Void){
        Network.login(withGoogle: true,GoogleId: googleID,GoogleName: GoogleName) { (JSON) in
            //JSON对象返回
            let result = JSON[Constants.success] as! Bool
            if result == true {
                //确认登陆
                self.isLogin = true
                //储存第三方id
                self.defaults.set(googleID, forKey: Constants.thirdPartyID)
                //储存JSON
                LoginModel.iglooID = JSON[Constants.iglooID] as! String
                LoginModel.owenLocationIDArray = JSON[Constants.usersOwenPlacesDefaultJsonKey] as! [String]
                LoginModel.owenLikedLocationIDArray = JSON[Constants.usersOwenPlacesDefaultJsonKey] as! [String]
            }
            action(result)//界面操作block
        }
    }
    
    //igloo登陆方法
    func loginWithIgloo(phoneNumber:String,password:String,action:@escaping (Bool) -> Void) {
        Network.login(withGoogle: false,number:phoneNumber,password:password){ (JSON) in
            //JSON对象返回
            let result = JSON[Constants.success] as! Bool
            if result == true {
                //确认登陆
                self.isLogin = true
                //储存第三方number,password
                self.defaults.set(phoneNumber, forKey: Constants.phoneNumber)
                self.defaults.set(password, forKey: Constants.password)
                //储存JSON
                LoginModel.iglooID = JSON[Constants.iglooID] as! String
                LoginModel.owenLocationIDArray = JSON[Constants.usersOwenPlacesDefaultJsonKey] as! [String]
                LoginModel.owenLikedLocationIDArray = JSON[Constants.usersOwenPlacesDefaultJsonKey] as! [String]
            }
            action(result)//界面操作block
        }
    }
    
    //退出登陆
    func logout()  {
        isLogin = false
    }
    
    
    
}