//
//  ViewController.swift
//  LocalNotificationsLecture
//
//  Created by casandra grullon on 2/20/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // data for tabelview
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let center = UNUserNotificationCenter.current()
    
    private let pendingNotifications = PendingNotifications()
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        configureRefreshControl()
        checkForNotificationAuthorization()
        loadNotifications()
        //allows us to see the notification while the app is open
        center.delegate = self
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemPink
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController,
            let createVC = navController.viewControllers.first as? CreateNotificationViewController else {
            fatalError("could not downcast to CreateNotificationViewController")
        }
        createVC.delegate = self
    }
    
    @objc private func loadNotifications() {
        pendingNotifications.getPendingNotifications { (requests) in
            self.notifications = requests
            //stop the refresh control from animating and remove from UI
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func checkForNotificationAuthorization() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        //alert notifications (a pop up alert), sound notifications (app makes a noise).
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requestion authorization: \(error)")
                return
            }
            if granted {
                print("access was granted")
            } else {
                print("access not granted")
            }
        }
    }

}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationsCell", for: indexPath)
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        return cell
    }
    //function that allows us to swipe and delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNotification(at: indexPath)
        }
    }
    private func removeNotification(at indexpath: IndexPath) {
        let notification = notifications[indexpath.row]
        let identifier = notification.identifier
        
        //remove from UNNotificationCenter
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        //remove from notifications array
        notifications.remove(at: indexpath.row)
        
        //remove from tableView
        tableView.deleteRows(at: [indexpath], with: .automatic)
    }
}

extension NotificationsViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension NotificationsViewController: CreateNotificationControllerDelegate {
    func didCreateNotification(_ createNotificationVC: CreateNotificationViewController) {
        loadNotifications()
    }
}
