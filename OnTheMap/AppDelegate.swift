//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Macbook on 12/15/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let client = Client.sharedInstance()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkForUserID()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let parameters = [String: AnyObject]()
        let urlRequest = Client.sharedInstance().OTMUrlParameter(parameters: parameters, withPathExtension: "/api/session", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        client.taskManager(request: request){(data, response, error) in
            print("session deleted")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func checkForUserID() {
        if UserDefaults.standard.bool(forKey: "HasUserObjectID") {
            print("Pin Has Been Placed")
        } else {
            print("There is no UserObjectID!")
            UserDefaults.standard.set(nil, forKey: "UserObjectID")
            UserDefaults.standard.set(false, forKey: "HasUserObjectID")
            UserDefaults.standard.synchronize()
        }
    }
}

