//
//  PushNotificationManager.swift
//  wePay
//
//  Created by Admin NBU on 18/08/21.
//

import UIKit

class PushNotificationSender {
    
    static func sendPushNotification(to token: String, groupID: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["groupID" : groupID]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAHlK9rSA:APA91bEetllwN3R5vtjIq0b8KRS7N0RMRJN7lc3jtiIQsiOHEjNE3zbTIgu7o7ZdieLF56gCvJlIIYfXlatIodvOW-SwO-hbW7_KqkA9ujiuUa2nkCjIIX4EE79RQTcimZshPNFCHmv1", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
