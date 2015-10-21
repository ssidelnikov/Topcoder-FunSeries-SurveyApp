//
//  ViewController.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Harshit on 24/09/15.
//  Copyright (c) 2015 topcoder. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating {
    
    
    var dataArray:NSMutableArray!
    var plistPath:String!
    var tableData=[String]()
    var filteredTableData=[String]()
    var refreshControl:UIRefreshControl!
    
    var searchController: UISearchController!
    
    let dataUrl = "http://www.mocky.io/v2/560920cc9665b96e1e69bb46"
    
    @IBOutlet var Label: UILabel!
    @IBOutlet var SurveyTable: UITableView!
    @IBOutlet weak var MessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SurveyTable.delegate=self;
        SurveyTable.dataSource=self;
        
        // Do any additional setup after loading the view, typically from a nib.
//        if let path = NSBundle.mainBundle().pathForResource("data", ofType: "plist"){
//            if let arrayOfDictionaries = NSArray(contentsOfFile: path){
//                for dict in arrayOfDictionaries {
//                    tableData.append(dict.objectForKey("title") as! String)
//                }
//            }
//        }
//        print(tableData, terminator: "");
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        SurveyTable.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        let tableViewController = UITableViewController()
        tableViewController.tableView = SurveyTable
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchData:", forControlEvents: .ValueChanged)
        tableViewController.refreshControl = refreshControl
        
        fetchData(self)
    }
    
    func fetchData(sender: AnyObject) {
        refreshControl.beginRefreshing()
        Alamofire.request(.GET, dataUrl)
            .responseJSON { response in
                if response.result.isSuccess {
                    var titles = [String]()
                    if let data = response.result.value {
                        let array = data as! NSMutableArray
                        for a in array {
                            if let title = a["title"] as? String {
                                titles.append(title)
                            }
                        }
                    }
                    self.tableData = titles
                } else {
                    self.MessageLabel.text = "Unable to fetch data."
                    UIView.animateWithDuration(0.5, animations: {
                        self.MessageLabel.alpha = 1.0
                        }, completion: { _ in
                            UIView.animateWithDuration(0.5, delay: 1.5, options: .CurveLinear, animations: {
                                self.MessageLabel.alpha = 0
                                }, completion: { _ in})
                    })
                }
                self.SurveyTable.reloadData()
                self.refreshControl.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(SurveyTable: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(SurveyTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.active) {
            return filteredTableData.count
        } else {
            return tableData.count
        }
    }
    
    func tableView(SurveyTable: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = SurveyTable.dequeueReusableCellWithIdentifier("cell")!
            var text: String
            if (searchController.active) {
                text = filteredTableData[indexPath.row]
            } else {
                text = tableData[indexPath.row]
            }
            cell.textLabel!.text = text
            return cell
    }
    
    // MARK: -Search
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
            SurveyTable.reloadData()
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Title") {
        self.filteredTableData = self.tableData.filter({(string: String) -> Bool in
            let categoryMatch = (scope == "Title")
            let stringMatch = string.lowercaseString.rangeOfString(searchText.lowercaseString)
            return categoryMatch && (stringMatch != nil)
        })
    }
    
}


