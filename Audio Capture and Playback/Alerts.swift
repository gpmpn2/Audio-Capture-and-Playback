//
//  Alerts.swift
//  Audio Capture and Playback
//
//  Created by Grant Maloney on 3/18/19.
//  Copyright © 2019 Grant Maloney. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    class func createAlert(title: String, message: String, parent: Any) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let parent = parent as? UIViewController {
            parent.present(alert, animated: true, completion: nil)
        }
    }
}
