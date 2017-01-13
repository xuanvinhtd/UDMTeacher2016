//
//  UDMDictionaryBuilder.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import Foundation

struct UDMDictionaryBuilder {
    static let share = UDMDictionaryBuilder()
    private init() {}
    
    private func builder(withModel model: String, funcName: String, token: String?) -> [String:String] {
        var result: [String: String] = [:]
        //Common paramater
        result["model"] = model
        result["func"] = funcName
        if let _token = token {
            result["token"] = _token
        }
        return result
    }
    // MARK: - USER
    private func builderUser(withModel model: String, funcName: String,token: String?, email: String?, password: String?, currentPassword: String?, newPassword: String?, fullName: String?, sex: String?, phoneNumber: String?, birthday: String?, city: String?) -> [String: String]{
        
        let commonDictionary = builder(withModel: model, funcName: funcName, token: token)
        var result: [String: String] = [:]
        if let _email = email {
            result["email"] = _email
        }
        if let _password = password {
            result["password"] = _password
        }
        if let _currentPassword = currentPassword {
            result["currentPassword"] = _currentPassword
        }
        if let _newPassword = newPassword {
            result["newPassword"] = _newPassword
        }
        if let _fullName = fullName {
            result["fullName"] = _fullName
        }
        if let _sex = sex {
            result["sex"] = _sex
        }
        if let _phoneNumber = phoneNumber {
            result["phoneNumber"] = _phoneNumber
        }
        if let _city = city {
            result["city"] = _city
        }
        if let _birthday = birthday {
            result["birthday"] = _birthday
        }
        result.update(commonDictionary)
        return result
    }
    
    func login(withEmail email: String, password: String) -> [String: String] {
        return builderUser(withModel: ModelName.Teacher.rawValue,
                           funcName: FuncName.LoginMail.rawValue,
                           token: nil,
                           email: email,
                           password: password,
                           currentPassword: nil,
                           newPassword: nil,
                           fullName: nil,
                           sex: nil,
                           phoneNumber: nil,
                           birthday: nil,
                           city: nil)
    }
    
    func resetPassword(withEmail email: String) -> [String: String] {
        
        return builderUser(withModel: ModelName.Teacher.rawValue,
                           funcName: FuncName.ResetPassword.rawValue,
                           token:nil,
                           email: email,
                           password: nil, currentPassword: nil, newPassword: nil,
                           fullName: nil, sex: nil, phoneNumber: nil, birthday: nil, city: nil)
    }
    
    // MARK: - COURSE
    private func builderCourse(withModel model: String, funcName: String, token: String?, idCategory: String?, courseID: String?, limit: String?, offset: String?) -> [String: String]{
        let commonDictionary = builder(withModel: model, funcName: funcName, token: token)
        var result: [String: String] = [:]
        if let _idCategory = idCategory {
            result["categoryID"] = _idCategory
        }
        if let _limit = limit {
            result["limit"] = _limit
        }
        if let _offset = offset {
            result["offset"] = _offset
        }
        if let _courseID = courseID {
            result["coursesID"] = _courseID
        }
        result.update(commonDictionary)
        return result
    }
    
    func getCourseList(withID id: String?) -> [String: String] {
        return builderCourse(withModel: ModelName.Teacher.rawValue,
                             funcName: FuncName.GetCourseData.rawValue,
                             token: UserManager.share.info.token,
                             idCategory: nil, courseID: nil,
                             limit: nil,
                             offset: nil)
    }
    
    func getCoursesDetail(with courseID: String?) -> [String: String] {
        return builderCourse(withModel: ModelName.Teacher.rawValue,
                             funcName: FuncName.GetCourseDetail.rawValue,
                             token: UserManager.share.info.token,
                             idCategory: nil, courseID: courseID,
                             limit: nil,
                             offset: nil)
    }
    
    func turnOnOffCourseLive(with courseID: String, status: String) -> [String: String] {
        let commonDictionary = builder(withModel: ModelName.Course.rawValue,
                                       funcName: FuncName.TurnLive.rawValue,
                                       token: UserManager.share.info.token)
        var result: [String: String] = [:]
        result["coursesID"] = courseID
        result["status"] = status
        result.update(commonDictionary)
        return result
    }
    
    func getRateList(withCourseId id: String) -> [String: String] {
        
        return builderCourse(withModel: ModelName.Course.rawValue,
                             funcName: FuncName.GetRateList.rawValue,
                             token: UserManager.share.info.token,
                             idCategory: nil, courseID: id,
                             limit: nil,
                             offset: nil)
    }
    
    // MARK: - Model Curriculums
    func getCurriculums(with courseID: String?) -> [String: String] {
        return builderCourse(withModel: ModelName.Curriculums.rawValue,
                             funcName: FuncName.GetData.rawValue,
                             token: UserManager.share.info.token,
                             idCategory: nil, courseID: courseID,
                             limit: nil,
                             offset: nil)
    }
}