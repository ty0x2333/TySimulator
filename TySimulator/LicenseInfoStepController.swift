//
//  LicenseInfoStepController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/12/4.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class LicenseInfoStepController: DMSuccessStepController {
    
    @IBOutlet weak var userNameTextField: NSTextField!
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var licenseIdentifierTextField: NSTextField!
    
    override func restoreState(_ saveContainer: [AnyHashable : Any]!) {
        
        self.applicationIconView.image = NSApp.applicationIconImage
        var error: Int = DMKevlarError.testError.rawValue
        if _my_secret_activation_check!(&error).boolValue || DMKevlarError.noError == DMKevlarError(rawValue: error) {
            let userLicense = _my_secret_license_info_getter!()?.takeUnretainedValue() as? Dictionary<String, Any>
            
            if let userName = userLicense?[DMKevlarLicenseUserNameKey] as? String {
                userNameTextField.stringValue = userName.isEmpty ? "Unknown" : userName
            }
            
            if let email = userLicense?[DMKevlarLicenseUserEmailKey] as? String {
                emailTextField.stringValue = email.isEmpty ? "Unknown" : email
            }
            
            if let licenseId = userLicense?[DMKevlarLicenseActivationIdKey] as? String {
                licenseIdentifierTextField.stringValue = licenseId.isEmpty ? "Unknown" : licenseId
            }
        }
    }
    
}
