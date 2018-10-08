//
//  AppDelegate.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

class AppDelegate: NSObject, NSApplicationDelegate, DevMateKitDelegate {
    
//    var activationController: DMActivationController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSViewController.awake()
        NSTextView.awake()
        
        Fabric.with([Crashlytics.self])
        #if DEBUG
            Fabric.sharedSDK().debug = true
        #endif
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        
        NSApplication.toggleDockIcon(showIcon: false)
        DevMateKit.sendTrackingReport(nil, delegate: nil)
//        DevMateKit.setupIssuesController(nil, reportingUnhandledIssues: true)
        DM_SUUpdater.shared().delegate = self
        
        // Setup trial
//        #if DEBUG
//            DMKitDebugAddTrialMenu()
//            DMKitDebugAddActivationMenu()
//        #endif
//        
//        activationController = DMActivationController.timeTrialController(for: DMTrialArea.forAllUsers, timeInterval: kDMTrialWeek, customWindowNib: "ActivationWindow")
//        activationController?.delegate = self
//        let successStepController = LicenseInfoStepController(nibName: "LicenseInfoStepView", bundle: Bundle.main)
//        activationController?.registerStep(successStepController, forActivationStep: DMActivationStandardStep.stepSuccess.rawValue)
//        if !NSApplication.activate() {
//            activationController?.startTrial()
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        LRUCache.shared.save()
    }
    
    // MARK: SUUpdaterDelegate_DevMateInteraction
    
    public func updaterDidNotFindUpdate(_ updater: DM_SUUpdater) {
        log.warning("not found update: \(updater)")
    }
    
    @nonobjc public func updaterShouldCheck(forBetaUpdates updater: DM_SUUpdater) -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    public func isUpdater(inTestMode updater: DM_SUUpdater) -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
//    // MARK: DMActivationControllerDelegate
//    
//    public func activationController(_ controller: DMActivationController!, activationStepForProposedStep proposedStep: DMActivationStep) -> DMActivationStep {
//        if proposedStep == DMActivationStandardStep.stepWelcome.rawValue && NSApplication.activate() {
//            return DMActivationStandardStep.stepSuccess.rawValue
//        }
//        return proposedStep
//    }
}
