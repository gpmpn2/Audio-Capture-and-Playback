//
//  ViewController.swift
//  Audio Capture and Playback
//
//  Created by Grant Maloney on 11/9/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var optionButton: UIButton!
    @IBAction func playButtonAction(_ sender: Any) {
        playBack()
    }
    @IBAction func setSettings(_ sender: Any) {
        guard let selectedOptionOne = selectedOptionOne,
            let selectedOptionTwo = selectedOptionTwo,
            let selectedOptionThree = selectedOptionThree,
            let selectedOptionFour = selectedOptionFour
        else {
            Alerts.createAlert(title: "Error", message: "Invalid selected option!", parent: self)
            return
        }
        
        var audioQuality: AVAudioQuality!
        var outputOption: Int!
        
        switch selectedOptionOne {
        case "Min":
            audioQuality = .min
            break
        case "Low":
            audioQuality = .low
            break
        case "Med":
            audioQuality = .medium
            break
        case "High":
            audioQuality = .high
            break
        case "Max":
            audioQuality = .max
            break
        default:
            audioQuality = .min
            break
        }
        
        switch selectedOptionThree {
        case "Mono":
            outputOption = 1
            break
        case "Stereo":
            outputOption = 2
            break
        default:
            outputOption = 1
            break
        }
        
        settings = SettingsData(qualityKey: audioQuality, encoderBitRate: selectedOptionTwo, numberOfChannels: outputOption, mediaType: selectedOptionFour.lowercased())
        settingsToolbar.isHidden = true
        settingsPicker.isHidden = true
        label.isHidden = false
        optionButton.isHidden = false
    }
    
    @IBAction func cancelSettings(_ sender: Any) {
        settingsToolbar.isHidden = true
        settingsPicker.isHidden = true
        label.isHidden = false
        optionButton.isHidden = false
        settings = nil
    }
    
    @IBOutlet weak var settingsToolbar: UIToolbar!
    @IBOutlet weak var settingsPicker: UIPickerView!
    @IBAction func recordButtonAction(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    @IBAction func openSettings(_ sender: Any) {
        selectedOptionOne = "Min"
        selectedOptionTwo = 8
        selectedOptionThree = "Mono"
        selectedOptionFour = "CAF"
        settingsToolbar.isHidden = false
        settingsPicker.isHidden = false
        label.isHidden = true
        optionButton.isHidden = true
    }
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer?
    var settings: SettingsData?
    
    let bitRateKeys = [8, 16, 32, 64]
    let fileTypes = ["CAF", "MP4", "M4A", "IMA4"]
    let outputTypes = ["Mono", "Stereo"]
    let qualities = ["Min", "Low", "Med", "High", "Max"]
    
    var selectedOptionOne: String?
    var selectedOptionTwo: Int?
    var selectedOptionThree: String?
    var selectedOptionFour: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.image = UIImage(named: "record")
        
        playButton.image = UIImage(named: "play")
        
        recordingSession = AVAudioSession.sharedInstance()
        
        label.text = "Welcome to Audio Capture"
        
        settingsPicker.delegate = self
        settingsPicker.dataSource = self
        
        settingsPicker.isHidden = true
        settingsToolbar.isHidden = true
        
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
        guard let settings = settings
        else {
            Alerts.createAlert(title: "Error", message: "Please select settings before recording audio!", parent: self)
            return
        }
        
        do {
            if let audioFile = checkSavedAudioFile() {
                audioRecorder = try AVAudioRecorder(url: audioFile, settings: settings.settings)
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
        guard let settings = settings else { return nil }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0].appendingPathComponent("recording.\(settings.mediaType)")
    }
    
    
    //Pickerview stuff
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: //AVEncoderAudioQualityKey
            return qualities.count
        case 1: //AVEncoderBitRateKey
            return bitRateKeys.count
        case 2: //AVNumberOfChannelsKey
            return outputTypes.count
        case 3:
            return fileTypes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: //AVEncoderAudioQualityKey
            return qualities[row]
        case 1: //AVEncoderBitRateKey
            return "\(bitRateKeys[row])"
        case 2: //AVNumberOfChannelsKey
            return outputTypes[row]
        case 3:
            return fileTypes[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: //AVEncoderAudioQualityKey
            selectedOptionOne = qualities[row]
            break
        case 1: //AVEncoderBitRateKey
            selectedOptionTwo = bitRateKeys[row]
            break
        case 2: //AVNumberOfChannelsKey
            selectedOptionThree = outputTypes[row]
            break
        case 3:
            selectedOptionFour = fileTypes[row]
            break
        default:
            break
        }
    }
}

