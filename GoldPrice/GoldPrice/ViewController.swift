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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekdaysLabel: UILabel!
    @IBOutlet weak var monthyearLabel: UILabel!
        
    @IBOutlet weak var tableViewGoldPrice: UITableView!
    
    var goldPriceInfoList = [GoldPriceInfo]()
    
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
        
        cell.textLabel?.textColor = UIColor(hexString: "#9DCDEC")
        cell.textLabel?.text = newDate
        
        cell.detailTextLabel?.textColor = UIColor(hexString: "#9DCDEC")
        cell.detailTextLabel?.text = String.init(format: "$%.2f",Double(goldPriceInfoList[indexPath.row].amount)!)
        
        cell.layoutSubviews()
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setDateInfo()
        
        let url = "https://rth-recruitment.herokuapp.com/api/prices/chart_data"
        
        get_data_from_url(url: url)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(_tapGesture: UITapGestureRecognizer) {
        
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "persional_info_view") as! PersionalInfoViewController

        self.addChildViewController(popvc)
        
        popvc.view.frame = self.view.frame
        
        self.view.addSubview(popvc.view)
        
        popvc.didMove(toParentViewController: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    
                    self.drawLineChartInfo()
                })
            }
            catch {
                self.showMessage(_message: error.localizedDescription)
            }
            }.resume()
    }
    
    func setDateInfo() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        monthyearLabel.text = dateFormatter.string(from:date as Date)
        
        let dateFormatterDayOfWeek = DateFormatter()
        dateFormatterDayOfWeek.dateFormat  = "EEEE"
        weekdaysLabel.text = dateFormatterDayOfWeek.string(from:date as Date)
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat  = "dd"
        dateLabel.text = dateFormatterDay.string(from:date as Date)
    }
    
    func drawLineChartInfo() {
        var listDate = [Double]()
        var listAmount = [Double]()
        
        var chartPoints = [(Double, Double)]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy"
        
        for goldPriceInfo in goldPriceInfoList {
            
            let date = dateFormatter.date(from: goldPriceInfo.date)
            let timeInterval = date?.timeIntervalSince1970
            
            // convert to Integer
            let dateValue = Double(timeInterval!)
            
            listDate.append(dateValue)
            listAmount.append(Double(goldPriceInfo.amount)!)
            chartPoints.append((dateValue,Double(goldPriceInfo.amount)!))
        }
        
        let guideLineConfig = GuidelinesConfig(dotted: true, lineWidth: 5, lineColor: UIColor(hexString: "#0F85D1"))
        
        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(from: listDate.min()!, to: listDate.max()!, by: 1),
            yAxisConfig: ChartAxisConfig(from: listAmount.min()!, to: listAmount.max()!, by: 1),
            guidelinesConfig: guideLineConfig
        )
        
        let frame = CGRect(x: 0, y: 0, width: 300, height: 139)
        
        let chart = LineChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Date",
            yTitle: "Amount",
            lines: [
                (chartPoints: chartPoints, color: UIColor(hexString: "#0F85D1"))
            ]
        )
        
        self.lineChartView.addSubview(chart.view)
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

