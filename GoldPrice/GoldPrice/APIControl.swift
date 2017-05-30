//
//  APIControl.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 5/29/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//

import Foundation

class APIControl {
    var url: String
    
    init(url: String) {
        self.url = url
    }
    
    func GetGoldPrice(taskCallback: @escaping ([AnyObject]) -> ()) {
//        
//        var goldPriceList = [GoldPriceInfo]()
//        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue("76524a53ee60602ac3528f38", forHTTPHeaderField: "X-App-Token")

        let session = URLSession.shared
        
        
        session.dataTask(with: request) {
            data, response, err in
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyObject]
                taskCallback(jsonResult)
//                
//                DispatchQueue.main.sync(execute: {
//                    
//                    for field in jsonResult {
//                        let goldPrice = GoldPriceInfo()
//                        goldPrice.amount = field["amount"] as? String ?? ""
//                        goldPrice.date = field["date"] as? String ?? ""
//                        
//                        goldPriceList.append(goldPrice)
//                    }
//                })
            }
            catch {
                print("json error: \(error)")
            }
        }.resume()
//        
//        return goldPriceList
    }
}
