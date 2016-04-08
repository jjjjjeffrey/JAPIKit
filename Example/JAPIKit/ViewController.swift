//
//  ViewController.swift
//  JAPIKit
//
//  Created by zengdaqian on 04/08/2016.
//  Copyright (c) 2016 zengdaqian. All rights reserved.
//

import UIKit
import JAPIKit



class APILogin: APIRequest {
    init(username: String, password: String) {
        super.init()
        self.parameters = ["username": username, "password": password]
        self.method = .POST
        self.URLString = "http://121.42.171.213:3001/api/login"
        self.encoding = .JSON
    }
}

class ViewController: UIViewController {
    
    deinit {
        APINotification.removeAll(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        APINotification.NetworkError.addObserver(self, selector: #selector(networkErrorNotification(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func networkErrorNotification(notification: NSNotification) {
        print("networkErrorNotification")
    }
    
    @IBAction func requestButtonClicked(sender: UIButton) {
        APILogin(username: "15727635331", password: "111111").request { (result) in
            switch result {
            case let .Success(result):
                if let rt = result {
                    print(rt.description)
                }
            case let .Failure(_, error):
                print(error.description())
                return
            }
            
        }
        
    }

}

