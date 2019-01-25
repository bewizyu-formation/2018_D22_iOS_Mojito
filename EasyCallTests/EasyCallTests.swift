//
//  EasyCallTests.swift
//  EasyCallTests
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import XCTest
@testable import EasyCall

class EasyCallTests: XCTestCase {
    
    let timeOutLimit: Double = 5
    var correctPhone: String!
    var correctPassword: String!
    var wrongContactId: String!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.correctPhone = "0600000002"
        self.correctPassword = "0000"
        self.wrongContactId = "imnotacorrectid"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.correctPhone = ""
        self.correctPassword = ""
        self.wrongContactId = ""
    }
    
    func testCorrectLogin() {
        
        let expectation = XCTestExpectation(description: "token is returned")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            XCTAssertNotNil(token)
            expectation.fulfill()
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testWrongLogin() {
        
        let expectation = XCTestExpectation(description: "error wrong login")
        
        let wrongPhone = "06000000024151"
        
        APIClient.instance.login(phone: wrongPhone, password: self.correctPassword, onSuccess: {(token) in
            XCTAssert(false)
        }, onError: { (error) in
            print(error)
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.UnknownUser)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testWrongPassword() {
        
        let expectation = XCTestExpectation(description: "error wrong password")
        
        let wrongPassword = "1111"
        APIClient.instance.login(phone: self.correctPhone, password: wrongPassword, onSuccess: {(token) in
            XCTAssert(false)
        }, onError: { (error) in
            print(error)
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidPassword)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testGetUserInfosCorrectToken() {
        
        let expectation = XCTestExpectation(description: "correct user is returned")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.getCurrentUser(token: token, onSuccess: { (userInfos) in
                print(userInfos)
                XCTAssert(userInfos[0] == self.correctPhone)
                expectation.fulfill()
            }, onError: { (error) in
                XCTAssert(false)
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testGetUserInfosWrongToken() {
        
        let expectation = XCTestExpectation(description: "error invalid token")
        
        APIClient.instance.getCurrentUser(token: "", onSuccess: { (userInfos) in
            XCTAssert(false)
        }, onError: { (error) in
            print(error)
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidToken)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testUpdateUserInfosCorrectToken() {
        
        let expectation = XCTestExpectation(description: "user is updated")
        
        let firstName = "Niko"
        let lastName = "Hodicq"
        let email = "nhodicq@bewizyu.com"
        let profile = "SENIOR"
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.updateUser(token: token, firstName: firstName, lastName: lastName, email: email, profile: profile, onSuccess: { (userInfos) in
                print(userInfos)
                XCTAssert(userInfos[0] == self.correctPhone && userInfos[1] == firstName && userInfos[2] == lastName && userInfos[3] == email && userInfos[4] == profile)
                expectation.fulfill()
            }, onError: { (error) in
                XCTAssert(false)
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testUpdateUserInfosWrongToken() {
        
        let expectation = XCTestExpectation(description: "error invalid token")
        
        let firstName = "Niko"
        let lastName = "Hodicq"
        let email = "nhodicq@bewizyu.com"
        let profile = "SENIOR"
        
        APIClient.instance.updateUser(token: "", firstName: firstName, lastName: lastName, email: email, profile: profile, onSuccess: { (userInfos) in
            XCTAssert(false)
        }, onError: { (error) in
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidToken)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testForgotPasswordCorrectPhone() {
        let expectation = XCTestExpectation(description: "code 204")
        
        APIClient.instance.forgotPassword(phone: self.correctPhone, onSuccess: {
            XCTAssert(true)
            expectation.fulfill()
        }, onError: { (error) in
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testForgotPasswordWrongPhone() {
        let expectation = XCTestExpectation(description: "error unknown user")
        
        let wrongPhone = "06000000024151"
        
        APIClient.instance.forgotPassword(phone: wrongPhone, onSuccess: {
            XCTAssert(false)

        }, onError: { (error) in
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.UnknownUser)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testGetProfiles() {
        let expectation = XCTestExpectation(description: "profiles returned")
        
        APIClient.instance.getProfiles(onSuccess: { (profiles) in
            XCTAssertNotNil(profiles)
            expectation.fulfill()
        }, onError: { (error) in
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testGetContactsCorrectToken() {
        let expectation = XCTestExpectation(description: "contacts returned")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.getContacts(token: token, onSuccess: { (contacts) in
                XCTAssertNotNil(contacts)
                expectation.fulfill()
            }, onError: { (error) in
                XCTAssert(false)
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testGetContactsWrongToken() {
        let expectation = XCTestExpectation(description: "contacts not returned : invalid token")
        
        APIClient.instance.getContacts(token: "", onSuccess: { (contacts) in
            XCTAssert(false)
        }, onError: { (error) in
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidToken)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testCreateContactCorrectToken() {
        let expectation = XCTestExpectation(description: "contact created")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.createContact(token: token, phone: "0606060606", firstName: "Jean",
                         lastName: "Balaise", email: "j.b@gmail.com", profile: "MEDECIN",
                         gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { (contact) in
                XCTAssertNotNil(contact)
                expectation.fulfill()
            }, onError: { (error) in
                XCTAssert(false)
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testCreateContactWrongToken() {
        let expectation = XCTestExpectation(description: "contact not created : invalid token")
        
        APIClient.instance.createContact(token: "", phone: "0606060606", firstName: "Jean",
         lastName: "Balaise", email: "j.b@gmail.com", profile: "MEDECIN",
         gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { (contact) in
            XCTAssert(false)
        }, onError: { (error) in
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidToken)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testUpdateContactCorrectToken() {
        let expectation = XCTestExpectation(description: "contact updated")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.createContact(token: token, phone: "0607070707", firstName: "Jeanne",
                 lastName: "Balaise", email: "jeanne.balaise@gmail.com", profile: "MEDECIN",
                 gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { (contact) in
                    XCTAssertNotNil(contact)
                    let idContact = contact["_id"] as! String
                    APIClient.instance.updateContact(token: token, id: idContact,
                         phone: "0607070708", firstName: "Jeannine",
                         lastName: "Balaise", email: "jeannine.balaise@gmail.com", profile: "FAMILLE",
                         gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { () in
                            XCTAssert(true)
                            expectation.fulfill()
                    }, onError: { (error) in
                        XCTAssert(false)
                    })
                    
            }, onError: { (error) in
                XCTAssert(false)
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testUpdateContactWrongId() {
        let expectation = XCTestExpectation(description: "contact updated")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.updateContact(token: token, id: self.wrongContactId,
             phone: "0606060606", firstName: "Jean",
             lastName: "Balaise", email: "j.b@gmail.com", profile: "MEDECIN",
             gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { () in
                XCTAssert(false)
            }, onError: { (error) in
                guard let error = error as? ApiError else{
                    return
                }
                XCTAssert(error == ApiError.UnknownContact)
                expectation.fulfill()
            })
        }, onError: { (error) in
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testUpdateContactWrongToken() {
        let expectation = XCTestExpectation(description: "contact not updated : invalid token")
        
        APIClient.instance.updateContact(token: "", id: self.wrongContactId,
            phone: "0606060606", firstName: "Jean",
            lastName: "Balaise", email: "j.b@gmail.com", profile: "MEDECIN",
            gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { () in
            XCTAssert(false)
        }, onError: { (error) in
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidToken)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testDeleteContactCorrectToken() {
        let expectation = XCTestExpectation(description: "contact deleted")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.createContact(token: token, phone: "0607070707", firstName: "Jeanne",
                 lastName: "Balaise", email: "jeanne.balaise@gmail.com", profile: "MEDECIN",
                 gravatar: "", isFamilinkUser: false, isEmergencyUser: false, onSuccess: { (contact) in
                    XCTAssertNotNil(contact)
                    let idContact = contact["_id"] as! String
                    APIClient.instance.deleteContact(token: token, id: idContact, onSuccess: { () in
                        XCTAssert(true)
                        expectation.fulfill()
                    }, onError: { (error) in
                        XCTAssert(false)
                    })
                                                
            }, onError: { (error) in
                XCTAssert(false)
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testDeleteContactWrongId() {
        let expectation = XCTestExpectation(description: "contact deleted")
        
        APIClient.instance.login(phone: self.correctPhone, password: self.correctPassword, onSuccess: { (token) in
            APIClient.instance.deleteContact(token: token, id: self.wrongContactId, onSuccess: { () in
                XCTAssert(false)
            }, onError: { (error) in
                guard let error = error as? ApiError else{
                    return
                }
                XCTAssert(error == ApiError.BadShapeId)
                expectation.fulfill()
            })
        }, onError: { (error) in
            print(error)
            XCTAssert(false)
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
    
    func testDeleteContactWrongToken() {
        let expectation = XCTestExpectation(description: "contact not deleted : invalid token")
        
        APIClient.instance.deleteContact(token: "", id: self.wrongContactId, onSuccess: { () in
            XCTAssert(false)
        }, onError: { (error) in
            guard let error = error as? ApiError else{
                return
            }
            XCTAssert(error == ApiError.InvalidToken)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: self.timeOutLimit)
    }
}
