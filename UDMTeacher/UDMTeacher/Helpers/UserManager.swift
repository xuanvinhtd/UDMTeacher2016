//
//  UserManager.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/24/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import Foundation

class UserManager {
    // MARK: - Properties
    static let share = UserManager()
    var info = User()
    var isInternet = true
    var isLogInSuccess = false
    
    private init () {}
    
    func getInfos() -> [String: String?] {
        var data: [String: String?] = [:]
        data["FullName"] = info.fullName
        data["Email"] = info.email
        data["Sex"] = info.sex
        data["BirthDay"] = info.birthday.formatDateFromString(info.birthday)
        data["City"] = info.city
        data["Phone Number"] = info.phoneNumber
        data["Description"] = info.description
        data["Money"] = String(info.money)
        
        return data
    }
}