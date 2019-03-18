//
//  SettingsData.swift
//  Audio Capture and Playback
//
//  Created by Grant Maloney on 3/17/19.
//  Copyright © 2019 Grant Maloney. All rights reserved.
//

import UIKit
import AVFoundation

struct SettingsData {
    let qualityKey: AVAudioQuality
    let encoderBitRate: Int
    let numberOfChannels: Int
    let sampleRate: Double
    let mediaType: String
    
    init(qualityKey: AVAudioQuality, encoderBitRate: Int, numberOfChannels: Int, mediaType: String) {
        self.qualityKey = qualityKey
        self.encoderBitRate = encoderBitRate
        self.numberOfChannels = numberOfChannels
        self.sampleRate = 44100.0
        self.mediaType = mediaType
    }
    
    var settings: [String : Any] {
        return [AVEncoderAudioQualityKey: self.qualityKey.rawValue,
        AVEncoderBitRateKey: self.encoderBitRate,
        AVNumberOfChannelsKey: self.numberOfChannels,
        AVSampleRateKey: self.sampleRate]
    }
}
