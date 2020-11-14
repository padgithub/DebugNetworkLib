//
//  ViewController.swift
//  DebugNetworkLibExample
//
//  Created by Phung Anh Dung on 11/14/20.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var session: URLSession!
    var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession(configuration: URLSessionConfiguration.default)
        
        webView.load(URLRequest(url: URL(string: "https://google.com")!))
        
        
    }
    
    @IBAction func callAPI(_ sender: Any) {
        callDemo()
    }
    
    @IBAction func postAPI(_ sender: Any) {
        let parameters = ["salary": 13, "name": "jack","age":124] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://dummy.restapiexample.com/api/v1/create")! //change the url

            //create the session object
            let session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                print(error.localizedDescription)
            }

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                guard error == nil else {
                    return
                }

                guard let data = data else {
                    return
                }

                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                        // handle json...
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
    }
    
    func callDemo() {
        dataTask?.cancel()
        
        if let url = URL(string: "https://  /\(100)/\(100)/?random") {
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    
                } else {
                    guard let data = data else { return }
                    guard let response = response as? HTTPURLResponse else {  return }
                    guard response.statusCode >= 200 && response.statusCode < 300 else { return }
                }
            })
            
            dataTask?.resume()
        }
    }

}

