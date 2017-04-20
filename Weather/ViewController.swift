//
//  ViewController.swift
//  Weather
//
//  Created by Artem on 06.03.17.
//  Copyright © 2017 Artem. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelCondition: UILabel!
    @IBOutlet weak var labelDegree: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var degree: Int!
    var condition: String!
    var imageURL: String!
    var nameCity: String!
    
    
    var exists: Bool = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.delegate = self
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/current.json?key=d026166b001349119d3223107170603&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    if let current = json["current"] as? [String: AnyObject] {
                        
                        if let temp = current["temp_c"] as? Int {
                            self.degree = temp
                         }
                        if let condition = current["condition"] as? [String: AnyObject] {
                            self.condition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imageURL = "http:\(icon)"
                        }
                    }
                    if let location = json["location"] as? [String: AnyObject] {
                        self.nameCity = location["name"] as! String
                    }
                    if let _ = json["error"] {
                        self.exists = false
                    }
                    
                    DispatchQueue.main.async {
                        if self.exists {
                            self.labelCondition.isHidden = false
                            self.labelDegree.isHidden = false
                            self.imageView.isHidden = false
                            self.labelDegree.text = "\(self.degree.description)°"
                            self.labelCity.text = self.nameCity
                            self.labelCondition.text = self.condition
                            self.imageView.downloadImage(from: self.imageURL!)
                        } else {
                            self.labelCity.text = "No matching city found"
                            self.labelCondition.isHidden = true
                            self.labelDegree.isHidden = true
                            self.imageView.isHidden = true
                            self.exists = true
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
         
        task.resume()
    }
}

extension UIImageView {
    func downloadImage(from url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        
        task.resume()
    }
}





