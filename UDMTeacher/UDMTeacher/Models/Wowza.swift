//
//  Wowza.swift
//  UDMTeacher
//
//  Created by OSXVN on 1/10/17.
//  Copyright © 2017 XUANVINHTD. All rights reserved.
//

import Foundation

struct Wowza {
    var supportedPresetConfigs:[WowzaConfig]
    var videoQualityDisplayNames: [String] {
        var names = [String]()
        for c: WowzaConfig in supportedPresetConfigs {
            names.append(c.description)
        }
        return names
    }
    
    var selectedVideoQuality: Int {
        var selected = 0
        var index = 0
        for c: WowzaConfig in supportedPresetConfigs {
            if (c.videoWidth == self.config.videoWidth &&
                c.videoHeight == self.config.videoHeight &&
                c.videoBitrate == self.config.videoBitrate &&
                c.videoFrameRate == self.config.videoFrameRate &&
                c.videoKeyFrameInterval == self.config.videoKeyFrameInterval) {
                selected = index
                break
            }
            index += 1
        }
        return selected
    }
    var videoConfigDescription: String {
        return self.config.description
    }
    
    var hostAddress: String {
        get {
            return self.config.hostAddress ?? ""
        }
        set (newValue) {
            self.config.hostAddress = newValue
        }
    }
    var port: UInt {
        get {
            return self.config.portNumber
        }
        set(newValue) {
            self.config.portNumber = newValue
        }
    }
    var applicationName: String {
        get {
            return self.config.applicationName ?? "VinhDefault"
        }
        set (newValue) {
            self.config.applicationName = newValue
        }
    }
    var streamName: String {
        get {
            return self.config.streamName ?? "Vinh"
        }
        set (newValue) {
            self.config.streamName = newValue
        }
    }
    var username: String {
        get {
            return self.config.username ?? "Vinh"
        }
        set {
            self.config.username = newValue
        }
    }
    var password: String {
        get {
            return self.config.password ?? "Vinh"
        }
        set (newValue) {
            self.config.password = newValue
        }
    }
    
    // the user-selected orientation mode
    var capturedVideoRotates: Bool {
        get {
            return self.config.capturedVideoRotates
        }
        set {
            self.config.capturedVideoRotates = newValue
        }
    }
    
    var videoPreviewRotates: Bool {
        get {
            return self.config.videoPreviewRotates
        }
        set {
            self.config.videoPreviewRotates = newValue
        }
    }
    
    var broadcastVideoOrientation: WZBroadcastOrientation {
        get {
            return self.config.broadcastVideoOrientation
        }
        set {
            self.config.broadcastVideoOrientation = newValue
        }
    }
    
    var broadcastScaleMode: WZBroadcastScaleMode  {
        get {
            return self.config.broadcastScaleMode
        }
        set {
            self.config.broadcastScaleMode = newValue
        }
    }
    
    // the user-selected black-and-white mode (on or off)
    var blackAndWhite: Bool
    
    // the user-selected custom frame width and height
    var customFrameWidth: UInt {
        get {
            return self.config.videoWidth
        }
        set {
            self.config.videoWidth = newValue
        }
    }
    var customFrameHeight: UInt {
        get {
            return self.config.videoHeight
        }
        set {
            self.config.videoHeight = newValue
        }
    }
    
    // the user-selected custom video bitrate, frame rate and key frame interval
    var customVideoBitrate: UInt {
        get {
            return self.config.videoBitrate
        }
        set {
            self.config.videoBitrate = newValue
        }
    }
    var customVideoFrameRate: UInt {
        get {
            return self.config.videoFrameRate
        }
        set {
            self.config.videoFrameRate = newValue
        }
    }
    var customVideoKeyFrameInterval: UInt {
        get {
            return self.config.videoKeyFrameInterval
        }
        set {
            self.config.videoKeyFrameInterval = newValue
        }
    }
    
    // Audio settings
    var audioBitrate: UInt {
        get {
            return self.config.audioBitrate
        }
        set {
            return self.config.audioBitrate = newValue
        }
    }
    
    var audioSampleRate: UInt {
        get {
            return self.config.audioSampleRate
        }
        set {
            return self.config.audioSampleRate = newValue
        }
    }
    
    var audioChannels: UInt {
        get {
            return self.config.audioChannels
        }
        set {
            self.config.audioChannels = newValue
        }
    }
    
    // Low bandwidth settings
    var videoBitrateScale: Float32 {
        get {
            return self.config.videoBitrateLowBandwidthScalingFactor
        }
        set {
            self.config.videoBitrateLowBandwidthScalingFactor = newValue
        }
    }

    var videoFrameBufferMultiplier: UInt {
        get {
            return self.config.videoFrameBufferSizeMultiplier
        }
        set {
            self.config.videoFrameBufferSizeMultiplier = newValue
        }
    }

    var videoFrameSkipCount: UInt {
        get {
            return self.config.videoFrameRateLowBandwidthSkipCount
        }
        set {
            self.config.videoFrameRateLowBandwidthSkipCount = newValue
        }
    }
    
    // the user-selected local recording mode (on or off)
    var recordVideoLocally: Bool
    
    // the user-selected local background broadcasting mode (on or off)
    var backgroundBroadcastEnabled: Bool {
        get {
            return self.config.backgroundBroadcastEnabled
        }
        set {
            self.config.backgroundBroadcastEnabled = newValue
        }
    }
    
    private var config: WowzaConfig
    
    mutating func initWithConfig(c: WowzaConfig) -> Wowza {
        self.config = c
        return self
    }
}