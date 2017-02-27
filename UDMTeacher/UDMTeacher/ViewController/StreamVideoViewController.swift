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
    let SDKSampleAppLicenseKey = "GOSK-6043-0103-FEF1-44B3-1E78"
    let BlackAndWhiteEffectKey = "BlackAndWhiteKey"
    
    @IBOutlet weak var broadcastButton:UIButton!
    @IBOutlet weak var settingsButton:UIButton!
    @IBOutlet weak var switchCameraButton:UIButton!
    @IBOutlet weak var torchButton:UIButton!
    @IBOutlet weak var micButton:UIButton!
    @IBOutlet weak var timeStream: UILabel!
    
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
        
        goCoderConfig.hostAddress = "61.28.226.74"
        goCoderConfig.portNumber = 1935
        goCoderConfig.applicationName = "liveStream"
        goCoderConfig.streamName = streamName
        goCoderConfig.username = "teacher"
        goCoderConfig.password = "123456"
        
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
                
               // self.updateUIControls()
                
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
       //        UDMServer.share.turnStream(withCoures: coursesID, state: "0") { (data, msg, success) in
//            if success {
//                log.info("Turn Off Stream success!")
//            } else {
//                log.error("Turn Off Stream faild: \(msg)")
//            }
//        }
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
            if goCoder?.status.state == WZState.Running {
                UDMAlert.alertChoose(title: "Warring", message: "Are you sure stop stream?" , AcceptTitle: "OK", CancelTitle: "Cancel",inViewController: self, withDismissAction: { result in
                    if result {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.broadcastButton.enabled    = false
                            self.torchButton.enabled        = false
                            self.switchCameraButton.enabled = false
                            self.settingsButton.enabled     = true
                            
                            if self.goCoder?.status.state == WZState.Running {
                                self.goCoder?.endStreaming(self)
                            }
                            else {
                                self.receivedGoCoderEventCodes.removeAll()
                                self.goCoder?.startStreaming(self)
                                let audioMuted = self.goCoder?.audioMuted ?? false
                                self.micButton.setImage(UIImage(named: audioMuted ? "mic_off_button" : "mic_on_button"), forState: UIControlState.Normal)
                            }

                        })
                        return
                    } else {
                        
                    }
                })
            } else {
            // Disable the U/I controls
            self.broadcastButton.enabled    = false
            torchButton.enabled        = false
            switchCameraButton.enabled = false
            settingsButton.enabled     = true
            
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
    }
    
    @IBAction func didTapSwitchCameraButton(sender:AnyObject?) {
        if let otherCamera = goCoder?.cameraPreview?.otherCamera() {
            if !otherCamera.supportsWidth(goCoderConfig.videoWidth) {
            goCoderConfig.loadPreset(otherCamera.supportedPresetConfigs.last!.toPreset())
                goCoder?.config = goCoderConfig
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
        
        self.goCoder?.endStreaming(self)
        self.goCoder?.unregisterAudioSink(self as WZAudioSink)
        self.goCoder?.unregisterVideoSink(self as WZVideoSink)
        self.goCoder?.cameraPreview?.stopPreview()
        self.goCoder = nil

        UDMServer.share.turnStream(withCoures: self.coursesID, state: "0") { (data, msg, success) in
            if success {
                log.info("Turn Off Stream success!")
                self.goCoder?.endStreaming(self)
                
            } else {
                log.error("Turn Off Stream faild: \(msg)")
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })

    }
    
    func updateUIControls() {
        if self.goCoder?.status.state != WZState.Idle && self.goCoder?.status.state != WZState.Running {
            // If a streaming broadcast session is in the process of starting up or shutting down,
            // disable the UI controls
            self.broadcastButton.enabled    = false
            self.torchButton.enabled        = false
            self.switchCameraButton.enabled = false
            self.settingsButton.enabled     = false
            self.micButton.enabled          = true
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
    
    var timer = NSTimer() //make a timer variable, but don't do anything yet
    let timeInterval:NSTimeInterval = 1.0 //smaller interval
    let timerEnd:NSTimeInterval =  1800.0 //seconds to end the timer
    var timeCount:NSTimeInterval = 0.0 // counter for the timer
    
    //MARK: - Timer
    
    func timeString(time:NSTimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        let hours = Int(minutes) / 60
        return String(format:"%02i:%02i:%02i",Int(hours),minutes,Int(seconds))
    }
    
    func timerDidEnd(timer:NSTimer){
            //timer that counts up
            timeCount = timeCount + timeInterval
            if timeCount >= timerEnd{  //test for target time reached.
                timer.invalidate()
            } else { //update the time on the clock if not reached
                timeStream.text = timeString(timeCount)
            }
        }
    
    func resetTime() {
        timer.invalidate()
        timeCount = 0.0
        timeStream.text = timeString(timeCount)
    }
}

// MARK: - WZStatusCallback Protocol Instance Methods
extension StreamVideoViewController: WZStatusCallback, WZVideoSink, WZAudioSink {
    func onWZStatus(status: WZStatus!) {
        switch (status.state) {
        case WZState.Idle:
            log.info("-->  WZState.Idle")
            dispatch_async(dispatch_get_main_queue(), {
                self.broadcastButton.setImage(UIImage(named:"start_button"), forState: UIControlState.Normal)
                self.settingsButton.hidden = false
                //self.updateUIControls()
            })
            
        case WZState.Running:
            log.info("-->  WZState.Running")
            self.timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(StreamVideoViewController.timerDidEnd(_:)), userInfo: nil, repeats: true)
            dispatch_async(dispatch_get_main_queue(), {
                self.broadcastButton.setImage(UIImage(named:"stop_button"), forState: UIControlState.Normal)
                self.broadcastButton.enabled    = true
                self.settingsButton.hidden = true
                //self.updateUIControls()
            })
        case WZState.Starting:
            log.info("-->  WZState.Starting")
            /*dispatch_async(dispatch_get_main_queue(), {
                self.updateUIControls()
            })*/
        case WZState.Stopping:
            log.info("-->  WZState.Stopping")
            self.resetTime()
            dispatch_async(dispatch_get_main_queue(), {
                self.broadcastButton.setImage(UIImage(named:"start_button"), forState: UIControlState.Normal)
                self.broadcastButton.enabled = true;
                self.settingsButton.hidden = false
                //self.updateUIControls()
//                UDMServer.share.turnStream(withCoures: self.coursesID, state: "0") { (data, msg, success) in
//                    if success {
//                        log.info("Turn Off Stream success!")
//                    } else {
//                        log.error("Turn Off Stream faild: \(msg)")
//                    }
//                }
            })
        }
        
    }
    
    func onWZEvent(status: WZStatus!) {
        // If an event is reported by the GoCoder SDK, display an alert dialog describing the event,
        // but only if we haven't already shown an alert for this event
        
        dispatch_async(dispatch_get_main_queue(), {
            if !self.receivedGoCoderEventCodes.contains(status.event) {
                self.receivedGoCoderEventCodes.append(status.event)
                UDMAlert.alert(title: "Incomplete Streaming Settings", message: "Live Streaming Event" , dismissTitle: "OK", inViewController: self, withDismissAction: {
                    
                })
            }
            
           // self.updateUIControls()
        })
    }
    
    func onWZError(status: WZStatus!) {
        // If an error is reported by the GoCoder SDK, display an alert dialog containing the error details
        dispatch_async(dispatch_get_main_queue(), {
            UDMAlert.alert(title: "Incomplete Streaming Settings", message: "Live Streaming Error" , dismissTitle: "OK", inViewController: self, withDismissAction: {
                
            })
           // self.updateUIControls()
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
