//
//  ViewController.swift
//  Audio Capture and Playback
//
//  Created by Grant Maloney on 11/9/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBAction func playButtonAction(_ sender: Any) {
        playBack()
    }
    @IBAction func recordButtonAction(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.image = UIImage(named: "record")
        
        playButton.image = UIImage(named: "play")
        
        recordingSession = AVAudioSession.sharedInstance()
        
        label.text = "Welcome to Audio Capture"
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        if self.checkSavedAudioFile() == nil {
                            self.playButton.isEnabled = false
                        }
                    } else {
                        self.playButton.isEnabled = false
                        self.recordButton.isEnabled = false
                    }
                }
            }
        } catch {
            createAlert(message: "Failed to record audio")
        }
    }
    
    func startRecording() {
        let settings = [
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ] as [String : Any]
        
        do {
            if let audioFile = checkSavedAudioFile() {
                audioRecorder = try AVAudioRecorder(url: audioFile, settings: settings)
            }
            audioRecorder.delegate = self
            audioRecorder.record()
            label.text = "Recording audio..."
            recordButton.image = UIImage(named: "stop")
            playButton.isEnabled = false
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            label.text = "Successfully recorded audio"
            recordButton.image = UIImage(named: "record")
            playButton.isEnabled = true
        } else { //Recording failed
            createAlert(message: "Recording failed")
            recordButton.image = UIImage(named: "record")
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func playBack() {
        if let player = player {
            let time = String(format: "%.2f", player.currentTime)
            if player.isPlaying {
                player.pause()
                label.text = "Paused audio at \(time) seconds"
                recordButton.isEnabled = true
                playButton.image = UIImage(named: "play")
                return
            } else {
                label.text = "Resuming audio at \(time) seconds"
                player.play()
                recordButton.isEnabled = false
                playButton.image = UIImage(named: "pause")
                return
            }
        }
        
        do {
            if let audioFile = checkSavedAudioFile() {
                player = try AVAudioPlayer(contentsOf: audioFile)
            }
            player?.numberOfLoops = 0
            player?.prepareToPlay()
            player?.delegate = self
            player?.play()
            label.text = "Playing audio"
            recordButton.isEnabled = false
            playButton.image = UIImage(named: "pause")
        } catch {
            createAlert(message: "Unable to play audio")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.image = UIImage(named: "play")
        recordButton.isEnabled = true
        self.player = nil
        label.text = "Audio finished"
    }
    
    func createAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func checkSavedAudioFile() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0].appendingPathComponent("recording.caf")
    }
}

