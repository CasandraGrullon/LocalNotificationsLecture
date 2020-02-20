//
//  CreateNotificationViewController.swift
//  LocalNotificationsLecture
//
//  Created by casandra grullon on 2/20/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit

protocol CreateNotificationControllerDelegate: AnyObject {
    func didCreateNotification(_ createNotificationVC: CreateNotificationViewController)
}

class CreateNotificationViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: CreateNotificationControllerDelegate?
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 5
        //seconds at some point in date
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func createLocalNotification() {
        //step 1: create the content
        let content = UNMutableNotificationContent()
        content.title = titleTextField.text ?? "No Title"
        content.body = "Local Notifications are awesome when used appropriately"
        content.subtitle = "Learning Local Notifications"
        content.sound = .default // only works in the background
        //you can add your own sound == content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "file.mp3"))
        
        //step 2: create identifier
        let identifier = UUID().uuidString // unique string created everytime
        
        //TODO: userInfo dictionary can hold additional data >o>
        //content.userInfo = ["":""]
        
        //step 3: create an attachment
        if let imageURL = Bundle.main.url(forResource: "dog", withExtension: "png") {
            do {
            let attachment = try UNNotificationAttachment(identifier: identifier , url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("error with attachment: \(error)")
            }
          
        } else {
            print("image resource could not be found")
        }
        
        //step 4: create trigger(s) examples == timeInterval, calander, location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        //step 5: create a request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //step 6: add request to the UNNotificationCenter
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error when adding request: \(error)")
            } else {
                print("request was successfully added")
            }
        }
        
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        guard sender.date > Date() else {return} //prevents user from choosing previous date or time
        
        timeInterval = sender.date.timeIntervalSinceNow + 5 //sets up time stamp of the exact date plus 5 seconds. +5 is a default value if the user doesnt choose a time/date
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        createLocalNotification()
        delegate?.didCreateNotification(self)
        dismiss(animated: true, completion: nil)
    }
    
}
