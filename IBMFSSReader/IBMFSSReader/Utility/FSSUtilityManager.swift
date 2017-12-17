//
//  FSSUtilityManager.swift
//  IBMFSSNewsLetter
//
//  Created by Rohit on 16/12/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit
import ZoomAuthentication

@objc protocol FSSUtilityManagerDelegate: class {
    func userEnrollmentStatus(result: ZoomEnrollmentResult)
    func userAuthenticationStatus(result: ZoomAuthenticationResult)
}

class FSSUtilityManager: NSObject {
    static let sharedFSSUtility = FSSUtilityManager()
    var presetingViewController: UIViewController?
    var delegate: FSSUtilityManagerDelegate?
    func fetchEncryptionKeyForUser(userID: String)-> String {
        return "appDefinedEncryptionKeyFor_APP_USER"
    }
    
    private func initlizeAppToken() {
        ZoomSDK.initialize(
            appToken: kZoomAuthAppToken,
            enrollmentStrategy: .ZoomOnly,
            interfaceCustomization: ZoomCustomization()) { (result) in
                if result {
                    print("login enabled")
                } else {
                    print("initilizationfailed \(ZoomSDK.getStatus().description)")
                }
        }
    }
    
    func checkEnrollmentStatus() -> Bool {
        return ZoomSDK.isUserEnrolled(userID: kCurrentAppUser)
    }
    
    func performZoomAuthenticationEnrollment() {
        self.initlizeAppToken()
        DispatchQueue.main.async {
            if ZoomSDK.isUserEnrolled(userID: kCurrentAppUser) {
                self.performZoomAuthenticationLogin()
            } else {                
                let enrollVC = ZoomSDK.createEnrollmentVC()
                enrollVC.prepareForEnrollment(
                    delegate: self,
                    userID: kCurrentAppUser,
                    applicationPerUserEncryptionSecret: self.fetchEncryptionKeyForUser(userID: kCurrentAppUser),
                    secret: "secret_data"
                )
                enrollVC.modalTransitionStyle = .coverVertical
                enrollVC.modalPresentationStyle = .overFullScreen
                self.presetingViewController?.present(enrollVC, animated: true, completion: nil)
            }
        }
    }
    
    func performZoomAuthenticationLogin() {
        DispatchQueue.main.async {
            let authVC = ZoomSDK.createAuthenticationVC()
            authVC.prepareForAuthentication(
                delegate: self,
                userID: kCurrentAppUser,
                applicationPerUserEncryptionSecret: self.fetchEncryptionKeyForUser(userID: kCurrentAppUser)
            )
            authVC.modalTransitionStyle = .coverVertical
            authVC.modalPresentationStyle = .overFullScreen
            self.presetingViewController?.present(authVC, animated: true, completion: nil)
        }
    }
}

// MARK : - ZoomEnrollmentDelegate method
extension FSSUtilityManager: ZoomEnrollmentDelegate {
    func onZoomEnrollmentResult(result r: ZoomEnrollmentResult) {
        delegate?.userEnrollmentStatus(result: r)
/*
        print("zoom enrollment result : \(r)")
        switch(r.status) {
        case .UserWasEnrolled:
            print("status \(r.status)")
        case .UserNotEnrolled:
            print("status \(r.status)")
        case .FailedBecauseAppTokenNotValid:
            print("status \(r.status)")
        case .FailedBecauseUserCancelled:
            print("status \(r.status)")
        case .FailedBecauseCameraPermissionDeniedByUser:
            print("status \(r.status)")
        case .FailedBecauseCameraPermissionDeniedByAdministrator:
            print("status \(r.status)")
        case .FailedBecauseOfTimeout:
            print("status \(r.status)")
        case .FailedBecauseOfLowMemory:
            print("status \(r.status)")
        case .FailedBecauseOfOSContextSwitch:
            print("status \(r.status)")
        case .FailedBecauseOfDiskWriteError:
            print("status \(r.status)")
        case .FailedBecauseUserCouldNotValidateFingerprint:
            print("status \(r.status)")
        case .FailedBecauseFingerprintDisabled:
            print("status \(r.status)")
        case .FailedBecauseWifiNotOnInDevMode:
            print("status \(r.status)")
        case .FailedBecauseNoConnectionInDevMode:
            print("status \(r.status)")
        case .UserFailedToProvideGoodEnrollment:
            print("status \(r.status)")
        }
*/
    }
}

// MARK : - ZoomAuthenticateDelegate method
extension FSSUtilityManager: ZoomAuthenticationDelegate {
    func onZoomAuthenticationResult(result r: ZoomAuthenticationResult){
        delegate?.userAuthenticationStatus(result: r)
        /*
        print("zoom enrollment result : \(r)")
        switch(r.status) {
        case .UserWasAuthenticated:
            print("status \(r.status)")
        case .FailedBecauseUserFailedAuthentication:
            print("status \(r.status)")
        case .FailedBecauseUserCancelled:
            print("status \(r.status)")
        case .FailedBecauseUserMustEnroll:
            print("status \(r.status)")
        case .FailedBecauseCameraPermissionDenied:
            print("status \(r.status)")
        case .FailedBecauseAppTokenNotValid:
            print("status \(r.status)")
        case .FailedToAuthenticateTooManyTimesAndUserWasDeleted:
            print("status \(r.status)")
        case .FailedBecauseOfTimeout:
            print("status \(r.status)")
        case .FailedBecauseOfLowMemory:
            print("status \(r.status)")
        case .FailedBecauseOfOSContextSwitch:
            print("status \(r.status)")
        case .FailedBecauseTouchIDUnavailable:
            print("status \(r.status)")
        case .FailedBecauseWifiNotOnInDevMode:
            print("status \(r.status)")
        case .FailedBecauseNoConnectionInDevMode:
            print("status \(r.status)")
        case .FailedBecauseTouchIDSettingsChanged:
            print("status \(r.status)")
        }
        */
    }
}

