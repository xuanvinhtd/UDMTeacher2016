//
//  UDMServer.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/24/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import Foundation

struct UDMServer {
    static let share = UDMServer()
    private init() {}
    
    // EXECUTES API
    private func executeRequestAPI(withData info: [String: String]?, AndCompletion completion: Result) {
        guard let _info = info else {
            log.info("Requester Infomation nil")
            return
        }
        AlamofireManager.share.requestUrlByPOST(withURL: UDMConfig.API.doman, paramater: _info, encode: .URLEncodedInURL, Completion: completion)
    }
    
    private func executeUploadAPI(withData info: [String: AnyObject]?, url: String, AndCompletion completion: Result) {
        guard let _info = info else {
            log.info("Requester Infomation nil")
            return
        }
        AlamofireManager.share.requestUrlByPOST(withURL: url, paramater: _info, Completion: completion)
    }
    
    func signInAccount(withData info: [String: String]?, Completion completion: Result) {
        executeRequestAPI(withData: info, AndCompletion: completion)
    }
    
    func getListDataFromServer(withData info: [String: String]?, Completion completion: Result) {
        executeRequestAPI(withData: info, AndCompletion: completion)
    }
    
    func updateObject(withData info: [String: String]?, Completion completion: Result) {

    }
    
    // REQUEST API
    func login(withEmail email: String, password: String, completion: Result) {
        let data = UDMDictionaryBuilder.share.login(withEmail: email, password: password)
        self.executeRequestAPI(withData: data) { (data, msg, success) in
            guard let _data = data["data"] as? [String: AnyObject] else {
                log.error("Not found data.")
                completion(data: [String: AnyObject](), msg: "Not found data.", success: false)
                return
            }
            completion(data: _data, msg: msg, success: success)
        }
    }
    
    func resetPassword(withEmail email: String, completion: Result) {
        let data = UDMDictionaryBuilder.share.resetPassword(withEmail: email)
        self.executeRequestAPI(withData: data) { (data, msg, success) in
            guard let _data = data["data"] as? [String: AnyObject] else {
                log.error("Not found data.")
                completion(data: [String: AnyObject](), msg: "Not found data.", success: false)
                return
            }
            completion(data: _data, msg: msg, success: success)
        }
    }
    
    func getList(withData data:[String: String], Andcompletion completion: Results ) {
        self.getListDataFromServer(withData: data) { (data, msg ,success) in
            guard let _data = data["data"] as? [[String: AnyObject]] else {
                log.error("Not found data.")
                completion(data: [[String: AnyObject]](), msg: "Not found data.", success: false)
                return
            }
            completion(data: _data, msg: msg, success: success)
        }
    }
    
    func getCourses(completion: Results) {
        let data = UDMDictionaryBuilder.share.getCourseList(withID: "1")
        self.getList(withData: data, Andcompletion: completion)
    }
    
    func getCoursesDetail(withCourseID id: String, completion: Results) {
        let data = UDMDictionaryBuilder.share.getCoursesDetail(with: id)
        self.getList(withData: data, Andcompletion: completion)
    }
    
    func getCurriculumns(withCourseID id: String, completion: Results) {
        let data = UDMDictionaryBuilder.share.getCurriculums(with: id)
        self.getList(withData: data, Andcompletion: completion)
    }
    
    func getReviews(withCourseID id: String, completion: Results) {
        let data = UDMDictionaryBuilder.share.getRateList(withCourseId: id)
        self.getList(withData: data, Andcompletion: completion)
    }
    
    func turnStream(withCoures id: String, state: String, completion: Results) {
        let data = UDMDictionaryBuilder.share.turnOnOffCourseLive(with: id, status: state)
        self.executeRequestAPI(withData: data) { (data, msg ,success) in
            guard let _data = data["data"] as? [[String: AnyObject]] else {
                log.error("Not found data.")
                completion(data: [[String: AnyObject]](), msg: "Not found data.", success: false)
                return
            }
            completion(data: _data, msg: msg, success: success)
        }
    }
}
