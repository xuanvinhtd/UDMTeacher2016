//
//  StreamVideoViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit
import R5Streaming

final class StreamVideoViewController: UIViewController {
    // MARK: - Properties
    var currentView : R5VideoViewController? = nil
    var publishStream : R5Stream? = nil
    var streamName = ""
    var coursesID = ""
    
    override func configItems() {
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
        };
        r5_set_log_level((Int32)(r5_log_level_debug.rawValue))
        
        setupDefaultR5VideoViewController()
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        setupPublisher(connection)
        // show preview and debug info
        // self.publishStream?.getVideoSource().fps = 2;
        self.currentView!.attachStream(publishStream!)
        
        //self.publishStream!.publish(StreamTool.getParameter("streamName") as! String, type: R5RecordTypeLive)
        self.publishStream!.publish(streamName, type: R5RecordTypeLive)
        
        self.view.autoresizesSubviews = true
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configItems()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UDMServer.share.turnStream(withCoures: coursesID, state: "0") { (data, msg, success) in
            if success {
                log.info("Turn off stream success.")
                self.closeStream()
            } else {
                UDMAlert.alert(title: "ERROR", message: msg, dismissTitle: "Cancel", inViewController: self, withDismissAction: nil)
                return
            }
        }
    }
    
    // MARK: - Func setup R5Stream
    func getConfig()->R5Configuration{
        // Set up the configuration
        let config = R5Configuration()
        config.host = UDMConfig.R5Stream.hostName
        config.port = UDMConfig.R5Stream.port
        config.contextName = UDMConfig.R5Stream.context
        config.`protocol` = 1;
        config.buffer_time = UDMConfig.R5Stream.buffer_time
        return config
    }

    func setupPublisher(connection: R5Connection){
        
        self.publishStream = R5Stream(connection: connection)
        self.publishStream!.delegate = self
        
        if(UDMConfig.R5Stream.onVideo){
            // Attach the video from camera to stream
            let videoDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).last as? AVCaptureDevice
            let camera = R5Camera(device: videoDevice, andBitRate: Int32(UDMConfig.R5Stream.bitrate))
            camera.width = Int32(UDMConfig.R5Stream.camera_width)
            camera.height = Int32(UDMConfig.R5Stream.camera_height)
            camera.orientation = 90
            self.publishStream!.attachVideo(camera)
        }
        if(UDMConfig.R5Stream.onAudio){
            // Attach the audio from microphone to stream
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            let microphone = R5Microphone(device: audioDevice)
            microphone.bitrate = 32
            microphone.device = audioDevice;
            NSLog("Got device %@", audioDevice)
            self.publishStream!.attachAudio(microphone)
        }
    }
    
    func getNewR5VideoViewController(rect : CGRect) -> R5VideoViewController{
        let view : UIView = UIView(frame: rect)
        let r5View : R5VideoViewController = R5VideoViewController();
        r5View.view = view;
        return r5View;
    }
    
    func closeStream(){
        log.info("closing stream")
        if( self.publishStream != nil ){
            self.publishStream!.stop()
        }
        self.removeFromParentViewController()
    }
    
    func setupDefaultR5VideoViewController() -> R5VideoViewController{
        let r5View : R5VideoViewController = getNewR5VideoViewController(self.view.frame);
        self.addChildViewController(r5View);
        view.addSubview(r5View.view)
        r5View.showPreview(true)
        r5View.showDebugInfo(UDMConfig.R5Stream.isDebugView)
        currentView = r5View;
        return currentView!
    }

}
// MARK: - Delegate R5Stream
extension StreamVideoViewController: R5StreamDelegate {
    func onR5StreamStatus(stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        NSLog("Status: %s ", r5_string_for_status(statusCode))
    }
}
