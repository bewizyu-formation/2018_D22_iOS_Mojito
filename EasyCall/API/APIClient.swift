//
//  APIClient.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import Foundation

enum ApiError : Error {
    case InvalidToken
    case UnknownUser
    case InvalidPassword
    case PhoneUnique
    case UnknownContact
    case BadShapeId
    case UnknownError
}

class APIClient {
    
    
    static let instance = APIClient()
    
    // API URL
    private let urlServer = "https://familink-api.cleverapps.io"
    // API URL PART FOR USER
    private let urlLogin = "/public/login"
    private let urlCurrentUser = "/secured/users/current"
    private let urlUser = "/secured/users"
    private let urlForgotPassword = "/public/forgot-password"
    private let urlSignIn = "/public/sign-in?contactsLength=0"
    // API URL PART FOR PROFILES
    private let urlProfiles = "/public/profiles"
    // API URL PART FOR CONTACTS
    private let urlContacts = "/secured/users/contacts"
    
    
    private let KEY_SERVER_TOKEN = "token"
    private let KEY_SERVER_MESSAGE = "message"
    private let KEY_SERVER_ID = "_id"
    private let KEY_SERVER_PASSWORD = "password"
    private let KEY_SERVER_PHONE = "phone"
    private let KEY_SERVER_FIRSTNAME = "firstName"
    private let KEY_SERVER_LASTNAME = "lastName"
    private let KEY_SERVER_EMAIL = "email"
    private let KEY_SERVER_PROFILE = "profile"
    private let KEY_SERVER_GRAVATAR = "gravatar"
    private let KEY_SERVER_FAMILINK_USER = "isFamilinkUser"
    private let KEY_SERVER_EMERGENCY_USER = "isEmergencyUser"
    
    private let ERROR_SERVER_INVALID_TOKEN = "Security token invalid or expired"
    private let ERROR_SERVER_USER_UNKNOWN = "User not found"
    private let ERROR_SERVER_INVALID_PASSWORD = "Password is not valid"
    private let ERROR_SERVER_PHONE_UNIQUE = "user validation failed: phone: Error, expected `phone`to be unique."
    private let ERROR_SERVER_UNKNOWN_CONTACT = "idContact not found :"
    private let ERROR_SERVER_BAD_SHAPE_ID = "Cast to ObjectId failed for value"
    
    private init () {}
    
    // MARK: - API for user
    // LOGIN USER
    @discardableResult
    func login(phone: String, password: String, onSuccess:@escaping (String) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlLogin)")! )
        request.httpMethod = "POST"
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_PHONE : phone,
            self.KEY_SERVER_PASSWORD : password,
            ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            let dataDictionnary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
            if let token = dataDictionnary[self.KEY_SERVER_TOKEN] {
                onSuccess(token)
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func getCurrentUser(token: String, onSuccess:@escaping ([String]) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlCurrentUser)")! )
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization" )
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            let dataDictionnary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
            if let phone = dataDictionnary[self.KEY_SERVER_PHONE], let firstName = dataDictionnary[self.KEY_SERVER_FIRSTNAME],
                let lastName = dataDictionnary[self.KEY_SERVER_LASTNAME], let email = dataDictionnary[self.KEY_SERVER_EMAIL],
                let profile = dataDictionnary[self.KEY_SERVER_PROFILE] {
                onSuccess([phone, firstName, lastName, email, profile])
            } else {
                onError(self.getErrorFromData(data: data))
            }
            
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func updateUser(token: String, firstName: String, lastName: String, email: String, profile: String, onSuccess:@escaping ([String]) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlUser)")! )
        request.httpMethod = "PUT"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization" )
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_FIRSTNAME : firstName,
            self.KEY_SERVER_LASTNAME : lastName,
            self.KEY_SERVER_EMAIL : email,
            self.KEY_SERVER_PROFILE : profile
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            let dataDictionnary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
            if let phone = dataDictionnary[self.KEY_SERVER_PHONE], let firstName = dataDictionnary[self.KEY_SERVER_FIRSTNAME],
                let lastName = dataDictionnary[self.KEY_SERVER_LASTNAME], let email = dataDictionnary[self.KEY_SERVER_EMAIL],
                let profile = dataDictionnary[self.KEY_SERVER_PROFILE] {
                onSuccess([phone, firstName, lastName, email, profile])
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func forgotPassword(phone: String, onSuccess:@escaping () -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlForgotPassword)")! )
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_PHONE : phone,
            ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else{
                onError(ApiError.UnknownError)
                return
            }
            
            if self.isRequestSucessfull(codeStatus: response.statusCode){
                onSuccess()
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func createUser(phone: String, firstName: String, lastName: String, email: String, profile: String, onSuccess:@escaping ([String]) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlSignIn)")! )
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_PHONE : phone,
            self.KEY_SERVER_FIRSTNAME : firstName,
            self.KEY_SERVER_LASTNAME : lastName,
            self.KEY_SERVER_EMAIL : email,
            self.KEY_SERVER_PROFILE : profile
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            let dataDictionnary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
            if let phone = dataDictionnary[self.KEY_SERVER_PHONE], let firstName = dataDictionnary[self.KEY_SERVER_FIRSTNAME],
                let lastName = dataDictionnary[self.KEY_SERVER_LASTNAME], let email = dataDictionnary[self.KEY_SERVER_EMAIL],
                let profile = dataDictionnary[self.KEY_SERVER_PROFILE] {
                onSuccess([phone, firstName, lastName, email, profile])
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - API for profile
    @discardableResult
    func getProfiles(onSuccess:@escaping ([String]) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlProfiles)")! )
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            if let dataArray = try! JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                onSuccess(dataArray)
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - API for contact
    @discardableResult
    func getContacts(token: String, onSuccess:@escaping ([[String:Any]]) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContacts)")! )
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization" )
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            if let dataArrayDictionnary = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] {
                onSuccess(dataArrayDictionnary)
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func createContact(token: String, phone: String, firstName: String, lastName: String, email: String, profile: String,
                       gravatar: String, isFamilinkUser: Bool, isEmergencyUser: Bool,
                       onSuccess:@escaping ([String:Any]) -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContacts)")! )
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization" )
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_PHONE : phone,
            self.KEY_SERVER_FIRSTNAME : firstName,
            self.KEY_SERVER_LASTNAME : lastName,
            self.KEY_SERVER_EMAIL : email,
            self.KEY_SERVER_PROFILE : profile,
            self.KEY_SERVER_GRAVATAR : gravatar,
            self.KEY_SERVER_FAMILINK_USER : isFamilinkUser,
            self.KEY_SERVER_EMERGENCY_USER : isEmergencyUser
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else{
                onError(ApiError.UnknownError)
                return
            }
            
            guard let data = data else {
                onError(ApiError.UnknownError)
                return
            }
            
            if self.isRequestSucessfull(codeStatus: response.statusCode){
                let dataDictionnary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                onSuccess(dataDictionnary)
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func deleteContact(token: String, id: String, onSuccess:@escaping () -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContacts)"+"/"+id)! )
        request.httpMethod = "DELETE"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization" )
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else{
                onError(ApiError.UnknownError)
                return
            }
            
            if self.isRequestSucessfull(codeStatus: response.statusCode){
                onSuccess()
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func updateContact(token: String, id: String, phone: String, firstName: String, lastName: String,
           email: String, profile: String, gravatar: String, isFamilinkUser: Bool, isEmergencyUser: Bool,
           onSuccess:@escaping () -> (), onError:@escaping (Error)->()) -> URLSessionTask {
        
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContacts)"+"/"+id)! )
        request.httpMethod = "PUT"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization" )
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_PHONE : phone,
            self.KEY_SERVER_FIRSTNAME : firstName,
            self.KEY_SERVER_LASTNAME : lastName,
            self.KEY_SERVER_EMAIL : email,
            self.KEY_SERVER_PROFILE : profile,
            self.KEY_SERVER_GRAVATAR : gravatar,
            self.KEY_SERVER_FAMILINK_USER : isFamilinkUser,
            self.KEY_SERVER_EMERGENCY_USER : isEmergencyUser
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else{
                onError(ApiError.UnknownError)
                return
            }
            
            if self.isRequestSucessfull(codeStatus: response.statusCode){
                onSuccess()
            } else {
                onError(self.getErrorFromData(data: data))
            }
        }
        task.resume()
        return task
    }
    
    
    // MARK: - Checking request code and data error message
    func isRequestSucessfull(codeStatus: Int) -> Bool {
        if (codeStatus == 200 || codeStatus == 204) {
            return true
        } else {
            return false
        }
    }
    
    func getErrorFromData(data: Data?) -> ApiError {
        
        guard let data = data else {
            return ApiError.UnknownError
        }
        guard let dataDictionnary = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:String] else {
            return ApiError.UnknownError
        }
        guard let message = dataDictionnary["message"] else {
            return ApiError.UnknownError
        }
        
        if (message.contains(ERROR_SERVER_PHONE_UNIQUE)) {
            return ApiError.PhoneUnique
        }
        if (message.contains(ERROR_SERVER_UNKNOWN_CONTACT)) {
            return ApiError.UnknownContact
        }
        if (message.contains(ERROR_SERVER_BAD_SHAPE_ID)) {
            return ApiError.BadShapeId
        }
        
        switch (message) {
        case ERROR_SERVER_INVALID_TOKEN:
            return ApiError.InvalidToken
        case ERROR_SERVER_USER_UNKNOWN:
            return ApiError.UnknownUser
        case ERROR_SERVER_INVALID_PASSWORD:
            return ApiError.InvalidPassword
        default:
            return ApiError.UnknownError
        }
    }
}
