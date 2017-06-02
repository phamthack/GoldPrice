//
//  ViewController.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 5/29/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//

import UIKit
import SwiftCharts

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let Color9DCDEC: UIColor = UIColor(hexString: "#9DCDEC")
    let Color0F85D1: UIColor = UIColor(hexString: "#9DCDEC")
    
    var goldPriceInfoList = [GoldPriceInfo]()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekdaysLabel: UILabel!
    @IBOutlet weak var monthyearLabel: UILabel!
        
    @IBOutlet weak var tableViewGoldPrice: UITableView!
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return goldPriceInfoList.count
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
        UIView.animate(withDuration: 1, animations: {
            cell.layer.transform = CATransform3DMakeScale(2,2,2)
        })
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy"
        let date = dateFormatter.date(from: goldPriceInfoList[indexPath.row].date)
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        let newDate = dateFormatter.string(from: date!)
        
        cell.textLabel?.textColor = Color9DCDEC
        cell.textLabel?.text = newDate
        
        cell.detailTextLabel?.textColor = Color9DCDEC
        cell.detailTextLabel?.text = String.init(format: "$%.2f",Double(goldPriceInfoList[indexPath.row].amount)!)
        
        cell.layoutSubviews()
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setDateInfo()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPersionalInfo))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
        
        let url = "https://rth-recruitment.herokuapp.com/api/prices/chart_data"
        get_data_from_url(url: url)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDateInfo() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        monthyearLabel.text = dateFormatter.string(from:date as Date)
        
        dateFormatter.dateFormat  = "EEEE"
        weekdaysLabel.text = dateFormatter.string(from:date as Date)
        
        dateFormatter.dateFormat  = "dd"
        dateLabel.text = dateFormatter.string(from:date as Date)
    }
    
    func showPersionalInfo(_tapGesture: UITapGestureRecognizer) {
        
        let persionalInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "persional_info_view") as! PersionalInfoViewController

        self.addChildViewController(persionalInfoViewController)
        
        persionalInfoViewController.view.frame = self.view.frame
        
        self.view.addSubview(persionalInfoViewController.view)
        
        persionalInfoViewController.didMove(toParentViewController: self)
    }
    
    func get_data_from_url(url:String)
    {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue("76524a53ee60602ac3528f38", forHTTPHeaderField: "X-App-Token")
        
        let session = URLSession.shared
        session.dataTask(with: request) {
            data, response, err in
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyObject]
                
                DispatchQueue.main.sync(execute: {
                    
                    for field in jsonResult {
                        let goldPrice = GoldPriceInfo()
                        goldPrice.amount = field["amount"] as? String ?? ""
                        goldPrice.date = field["date"] as? String ?? ""
                        
                        self.goldPriceInfoList.append(goldPrice)
                    }
                    
                    self.goldPriceInfoList.sort(by: { $0.date > $1.date })
                    self.tableViewGoldPrice.reloadData()
                    
                    let queue = DispatchQueue(label: "drawLineChartInfo")
                    queue.async {
                        
                        self.drawLineChartInfo()
                    }
                    
                })
            }
            catch {
                self.showMessage(_message: error.localizedDescription)
            }
            }.resume()
    }
    
    func drawLineChartInfo() {
        
        var chartPoints = [(CGPoint)]()
        
        for goldPriceInfo in goldPriceInfoList.sorted(by: { $0.date > $1.date }) {
            let index = goldPriceInfo.date.index(goldPriceInfo.date.startIndex, offsetBy: 2)
            let day = Double(goldPriceInfo.date.substring(to: index))
            
            chartPoints.append(CGPoint(x: day!,y: Double(goldPriceInfo.amount)!))
        }

        lineChartView.deltaX = 10
        lineChartView.deltaY = 10
        
        lineChartView.plot(chartPoints)
        
    }
    
    func showMessage(_message: String) {
        
        // create the alert
        let alert = UIAlertController(title: "Gold Price", message: _message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

