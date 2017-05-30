//
//  ViewController.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 5/29/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//

import UIKit
import SwiftCharts

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = goldPriceInfoList[indexPath.row].date
        cell.detailTextLabel?.text = goldPriceInfoList[indexPath.row].amount
                return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setDateInfo()
        
        let url = "https://rth-recruitment.herokuapp.com/api/prices/chart_data"
        
        get_data_from_url(url: url)
        
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
                print("json error: \(error)")
            }
            }.resume()
    }
    
    func setDateInfo() {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-yyyy"
        monthyearLabel.text = dateFormatter.string(from:date as Date)
        
        let dateFormatterDayOfWeek = DateFormatter()
        dateFormatterDayOfWeek.dateFormat  = "EEEE"
        weekdaysLabel.text = dateFormatterDayOfWeek.string(from:date as Date)
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat  = "dd"
        dateLabel.text = dateFormatterDay.string(from:date as Date)
    }
    
    func drawLineChartInfo() {
        
        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(from: 2, to: 14, by: 2),
            yAxisConfig: ChartAxisConfig(from: 0, to: 14, by: 2)
        )
        let frame = CGRect(x: 0, y: 0, width: 375, height: 139)
        
        let chart = LineChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            lines: [
                (chartPoints: [(2.0, 10.6), (4.2, 5.1), (7.3, 3.0), (8.1, 5.5), (14.0, 8.0)], color: UIColor(hexString: "#0F85D1"))
            ]
        )
        
        self.lineChartView.addSubview(chart.view)

//        
//        let f: (CGFloat) -> CGPoint = {
//            let noiseY = (CGFloat(arc4random_uniform(2)) * 2 - 1) * CGFloat(arc4random_uniform(4))
//            let noiseX = (CGFloat(arc4random_uniform(2)) * 2 - 1) * CGFloat(arc4random_uniform(4))
//            let b: CGFloat = 5
//            let y = 2 * $0 + b + noiseY
//            return CGPoint(x: $0 + noiseX, y: y)
//        }
//        
//        var xs = [Double]()
//        
//        for goldPriceInfo in goldPriceInfoList {
//            xs.append(Double(goldPriceInfo.amount)!)
//        }
//        
//        let points = xs.map({f(CGFloat($0 * 10))})
//
//        lineChart.deltaX = 20
//        lineChart.deltaY = 30
//        
//        lineChart.plot(points)

    }
}

