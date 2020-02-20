//
//  PendingNotifications.swift
//  LocalNotificationsLecture
//
//  Created by casandra grullon on 2/20/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import Foundation
import UserNotifications

class PendingNotifications {
    //creating one class to maintain this function instead of repeatidly writing it in our app
    public func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> () ) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("there are \(requests.count) pending requests")
            completion(requests)
        }
    }
    
}
