//
//  StreamVideoViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit
import WowzaGoCoderSDK

final class StreamVideoViewController: UIViewController {
// MARK: - Properties
    
    let SDKSampleSavedConfigKey = "SDKSampleSavedConfigKey"
    let SDKSampleAppLicenseKey = "GOSK-3643-0103-1B8B-C7F8-9A04"
    let BlackAndWhiteEffectKey = "BlackAndWhiteKey"
    
    @IBOutlet weak var broadcastButton:UIButton!
    @IBOutlet weak var settingsButton:UIButton!
    @IBOutlet weak var switchCameraButton:UIButton!
    @IBOutlet weak var torchButton:UIButton!
    @IBOutlet weak var micButton:UIButton!
    
    var streamName = "DefaultName"
    var coursesID = "1"
    
   // var wz: Wowza!
    var goCoder:WowzaGoCoder?
    var goCoderConfig:WowzaConfig!
    
    var receivedGoCoderEventCodes = Array<WZEvent>()
    
    var blackAndWhiteVideoEffect = false
    
    var goCoderRegistrationChecked = false
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reload any saved data
        blackAndWhiteVideoEffect = NSUserDefaults.standardUserDefaults().boolForKey(BlackAndWhiteEffectKey)
        WowzaGoCoder.setLogLevel(WowzaGoCoderLogLevel.Default)

        if let savedConfig:NSData = NSUserDefaults.standardUserDefaults().objectForKey(SDKSampleSavedConfigKey) as? NSData {
            if let wowzaConfig = NSKeyedUnarchiver.unarchiveObjectWithData(savedConfig) as? WowzaConfig {
                goCoderConfig = wowzaConfig
            }
            else {
                goCoderConfig = WowzaConfig()
            }
        }
        else {
            goCoderConfig = WowzaConfig()
        }
        
        goCoderConfig.hostAddress = "61.28.226.35"
        goCoderConfig.portNumber = 1935
        goCoderConfig.applicationName = "live"
        goCoderConfig.streamName = streamName
        goCoderConfig.username = "teacher"
        goCoderConfig.password = "#teacher"
        
        //wz = Wowza.initWithConfig(&goCoderConfig)
        
        // Log version and platform info
        print("WowzaGoCoderSDK version =\n major: \(WZVersionInfo.majorVersion())\n minor: \(WZVersionInfo.minorVersion())\n revision: \(WZVersionInfo.revision())\n build: \(WZVersionInfo.buildNumber())\n string: \(WZVersionInfo.string())\n verbose string: \(WZVersionInfo.verboseString())")
        
        print("Platform Info:\n\(WZPlatformInfo.string())")
        
        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
            let error = goCoderLicensingError as NSError
            UDMAlert.alert(title: "GoCoder SDK Licensing Error", message: error.localizedFailureReason ?? "Error" , dismissTitle: "OK", inViewController: self, withDismissAction: {
                
            })

            //self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        let savedConfigData = NSKeyedArchiver.archivedDataWithRootObject(goCoderConfig)
        NSUserDefaults.standardUserDefaults().setObject(savedConfigData, forKey: SDKSampleSavedConfigKey)
        // Update the configuration settings in the GoCoder SDK
        if (goCoder != nil) {
            goCoder?.config = goCoderConfig
            blackAndWhiteVideoEffect = NSUserDefaults.standardUserDefaults().boolForKey(UDMConfig.BlackAndWhiteEffectKey)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        goCoder?.cameraPreview?.previewLayer?.frame = view.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !goCoderRegistrationChecked {
            goCoderRegistrationChecked = true
            if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
                let error = goCoderLicensingError as NSError
                UDMAlert.alert(title: "GoCoder SDK Licensing Error", message: error.localizedFailureReason ?? "Error" , dismissTitle: "OK", inViewController: self, withDismissAction: {
                    
                })
                //self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
            }
            else {
                // Initialize the GoCoder SDK
                if let goCoder = WowzaGoCoder.sharedInstance() {
                    self.goCoder = goCoder
                    
                    // Request camera and microphone permissions
                    WowzaGoCoder.requestPermissionForType(WowzaGoCoderPermissionType.Camera, response: { (permission) in
                        log.info("Camera permission is: \(permission == WowzaGoCoderCapturePermission.Authorized ? "authorized" : "denied")")
                    })
                    
                    WowzaGoCoder.requestPermissionForType(WowzaGoCoderPermissionType.Microphone, response: { (permission) in
                        log.info("Camera permission is: \(permission == WowzaGoCoderCapturePermission.Authorized ? "authorized" : "denied")")
                    })
                    
                    self.goCoder?.registerAudioSink(self as WZAudioSink)
                    self.goCoder?.registerVideoSink(self as WZVideoSink)
                    self.goCoder?.config = self.goCoderConfig
                    
                    // Specify the view in which to display the camera preview
                    self.goCoder?.cameraView = self.view
                    
                    // Start the camera preview
                    self.goCoder?.cameraPreview?.startPreview()
                }
                
                self.updateUIControls()
                
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UDMServer.share.turnStream(withCoures: coursesID, state: "0") { (data, msg, success) in
            if success {
                log.info("Turn Off Stream success!")
            } else {
                log.error("Turn Off Stream faild: \(msg)")
            }
        }
    }
    
    
    
    //MARK - UI Action Methods
    @IBAction func didTapBroadcastButton(sender:AnyObject?) {
        // Ensure the minimum set of configuration settings have been specified necessary to
        // initiate a broadcast streaming session
        if let configError = goCoder?.config.validateForBroadcast() {
            let error = configError as NSError
            UDMAlert.alert(title: "Incomplete Streaming Settings", message: error.localizedFailureReason ?? "Error" , dismissTitle: "OK", inViewController: self, withDismissAction: {
                
            })
        }
        else {
            // Disable the U/I controls
            self.broadcastButton.enabled    = false
            torchButton.enabled        = false
            switchCameraButton.enabled = false
            settingsButton.enabled     = false
            
            if goCoder?.status.state == WZState.Running {
                goCoder?.endStreaming(self)
            }
            else {
                receivedGoCoderEventCodes.removeAll()
                goCoder?.startStreaming(self)
                let audioMuted = goCoder?.audioMuted ?? false
                micButton.setImage(UIImage(named: audioMuted ? "mic_off_button" : "mic_on_button"), forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func didTapSwitchCameraButton(sender:AnyObject?) {
        if let otherCamera = goCoder?.cameraPreview?.otherCamera() {
            if !otherCamera.supportsWidth(goCoderConfig.videoWidth) {
//                goCoderConfig.
//                goCoderConfig.load(otherCamera.supportedPresetConfigs.last!.toPreset())
//                goCoder?.config = goCoderConfig
            }
            
            goCoder?.cameraPreview?.switchCamera()
            torchButton.setImage(UIImage(named: "torch_on_button"), forState: UIControlState.Normal)
            self.updateUIControls()
        }
    }
    
    @IBAction func didTapTorchButton(sender:AnyObject?) {
        var newTorchState = goCoder?.cameraPreview?.camera?.torchOn ?? true
        newTorchState = !newTorchState
        goCoder?.cameraPreview?.camera?.torchOn = newTorchState
        torchButton.setImage(UIImage(named: newTorchState ? "torch_off_button" : "torch_on_button"), forState: UIControlState.Normal)
    }
    
    @IBAction func didTapMicButton(sender:AnyObject?) {
        var newMutedState = self.goCoder?.audioMuted ?? true
        newMutedState = !newMutedState
        goCoder?.audioMuted = newMutedState
        micButton.setImage(UIImage(named: newMutedState ? "mic_off_button" : "mic_on_button"), forState: UIControlState.Normal)
    }
    
    @IBAction func didTapSettingsButton(sender:AnyObject?) {
//        if let settingsNavigationController = UIStoryboard(name: "GoCoderSettings", bundle: nil).instantiateViewController(withIdentifier: "settingsNavigationController") as? UINavigationController {
//            
//            if let settingsViewController = settingsNavigationController.topViewController as? SettingsViewController {
//                settingsViewController.addAllSections()
//                settingsViewController.removeDisplay(.recordVideoLocally)
//                settingsViewController.removeDisplay(.backgroundMode)
//                let viewModel = SettingsViewModel(sessionConfig: goCoderConfig)
//                viewModel?.supportedPresetConfigs = goCoder?.cameraPreview?.camera?.supportedPresetConfigs
//                settingsViewController.viewModel = viewModel!
//            }
//            
//            
//            self.present(settingsNavigationController, animated: true, completion: nil)
//        }
    }
    
    func updateUIControls() {
        if self.goCoder?.status.state != WZState.Idle && self.goCoder?.status.state != WZState.Running {
            // If a streaming broadcast session is in the process of starting up or shutting down,
            // disable the UI controls
            self.broadcastButton.enabled    = false
            self.torchButton.enabled        = false
            self.switchCameraButton.enabled = false
            self.settingsButton.enabled     = false
            self.micButton.enabled           = true
            self.micButton.enabled          = false
        }
        else {
            // Set the UI control state based on the streaming broadcast status, configuration,
            // and device capability
            self.broadcastButton.enabled    = true
            self.switchCameraButton.enabled = (self.goCoder?.cameraPreview?.cameras?.count)! > 1
            self.torchButton.enabled        = self.goCoder?.cameraPreview?.camera?.hasTorch ?? false
            let isStreaming                 = self.goCoder?.isStreaming ?? false
            self.settingsButton.enabled     = !isStreaming
            // The mic icon should only be displayed while streaming and audio streaming has been enabled
            // in the GoCoder SDK configuration setiings
            self.micButton.enabled          = isStreaming && self.goCoderConfig.audioEnabled
            self.micButton.enabled           = !self.micButton.enabled
        }
    }
}

// MARK: - WZStatusCallback Protocol Instance Methods
extension StreamVideoViewController: WZStatusCallback, WZVideoSink, WZAudioSink {
    func onWZStatus(status: WZStatus!) {
//        switch (status.state) {
//        case WZState.idle:
//            dispatch_async(dispatch_get_main_queue(), { 
//              //  self.broadcastButton.setImage(UIImage(named: "start_button"), for: UIControlState())
//              //  self.updateUIControls()
//            })
//            
//        case WZState.running:
//            dispatch_async(dispatch_get_main_queue(), {
//               // self.broadcastButton.setImage(UIImage(named: "stop_button"), for: UIControlState())
//               // self.updateUIControls()
//            })
//        case WZState.stopping, WZState.starting:
//            dispatch_async(dispatch_get_main_queue(), {
//                //self.updateUIControls()
//            })
//        }
        
    }
    
    func onWZEvent(status: WZStatus!) {
        // If an event is reported by the GoCoder SDK, display an alert dialog describing the event,
        // but only if we haven't already shown an alert for this event
        
        dispatch_async(dispatch_get_main_queue(), {
//            if !self.receivedGoCoderEventCodes.contains(status.event) {
//                self.receivedGoCoderEventCodes.append(status.event)
//                self.showAlert("Live Streaming Event", status: status)
//            }
//            
//            self.updateUIControls()
        })
    }
    
    func onWZError(status: WZStatus!) {
        // If an error is reported by the GoCoder SDK, display an alert dialog containing the error details
        dispatch_async(dispatch_get_main_queue(), {
           // self.showAlert("Live Streaming Error", status: status)
          //  self.updateUIControls()
        })
    }
    
    
    //MARK: - WZVideoSink Protocol Methods
    func videoFrameWasCaptured(imageBuffer: CVImageBuffer, framePresentationTime: CMTime, frameDuration: CMTime) {
//        if goCoder != nil && goCoder!.isStreaming && blackAndWhiteVideoEffect {
//            // convert frame to b/w using CoreImage tonal filter
//            var frameImage = CIImage(cvImageBuffer: imageBuffer)
//            if let grayFilter = CIFilter(name: "CIPhotoEffectTonal") {
//                grayFilter.setValue(frameImage, forKeyPath: "inputImage")
//                if let outImage = grayFilter.outputImage {
//                    frameImage = outImage
//                    
//                    let context = CIContext(options: nil)
//                    context.render(frameImage, to: imageBuffer)
//                }
//                
//            }
//        }
    }
    
    func videoCaptureInterruptionStarted() {
        goCoder?.endStreaming(self)
    }
    //MARK: - WZAudioSink Protocol Methods
    
    func audioLevelDidChange(level: Float) {
        //        print("Audio level did change: \(level)");
    }
}
