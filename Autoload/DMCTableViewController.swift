//
//  DMCTableViewController.swift
//  Autoload
//
//  Created by David McCarthy on 25/04/2022.
//  Copyright © 2022 David McCarthy. All rights reserved.
//

import SwiftUI

class DMCTableViewController: UITableViewController, Autoloadable {
    
    var autoLoader = Autoload()
    var tableData:TableData?
    
    var columns:String = "fname||' '||sname,c.name,identifier,o.email,o.mobile"
    var page:Int = 0
    var scrollIndex:Int = 0
    var scrollPosition:UITableView.ScrollPosition = .top
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")         // register cell name
        self.tableView.register(UINib(nibName: "UIOperatorCell", bundle: nil), forCellReuseIdentifier: "CellFromNib")
        
        autoLoader.url = "http://192.168.1.33:8000/tablemaker/centres/"
        autoLoader.database = "babbleton"
        autoLoader.table = "operators o"
        //autoLoader.columns = "fname||' '||sname,c.name,identifier,o.email,o.mobile"
        autoLoader.delegate = self;
        autoLoader.join = "inner join centres c on o.centreid=c.id"
        autoLoader.pagesize = 30
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        //autoLoader.test()
        autoLoader.select(columns:columns, offset: 0,filter: "",orderby: "1 asc")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  Count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let data:TableData = tableData else{
            return 0;
        }
        
        return data.rows.count
    }
    
    //  Populate row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFromNib", for: indexPath) as! UIOperatorCell

        guard let data:TableData = tableData else{
            return cell;
        }
        
        cell.nameLabel?.text = data.rows[indexPath.row][0]
        cell.centreLable?.text = data.rows[indexPath.row][1]
        cell.dialcodeLabel?.text = data.rows[indexPath.row][2]
        cell.emailLabel?.text = data.rows[indexPath.row][3]
        cell.mobileLabel?.text = data.rows[indexPath.row][4]
        
        cell.nameLabel.translatesAutoresizingMaskIntoConstraints = true
        cell.centreLable.translatesAutoresizingMaskIntoConstraints = true
        cell.dialcodeLabel.translatesAutoresizingMaskIntoConstraints = true
        cell.emailLabel.translatesAutoresizingMaskIntoConstraints = true
        cell.mobileLabel.translatesAutoresizingMaskIntoConstraints = true
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
      let isReachingEnd = scrollView.contentOffset.y >= 0
          && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        
        if((scrollView.contentOffset.y < -20) && !autoLoader.selecting && self.page > 0){
            
            self.page -= 1
            let offset:Int = self.page * (autoLoader.pagesize / 2)
            
            print("Selecting page: \(page)")
            
            scrollIndex = autoLoader.pagesize / 2
            scrollPosition = .top
        
            autoLoader.select(columns:columns, offset: offset,filter: "",orderby: "1 asc")
        }
        
        if(isReachingEnd && !autoLoader.selecting){
            
            self.page += 1
            let offset:Int = self.page * (autoLoader.pagesize / 2)
            
            scrollIndex = (autoLoader.pagesize / 2) - 1
            scrollPosition = .bottom
        
            autoLoader.select(columns:columns, offset: offset,filter: "",orderby: "1 asc")
        }
        
        //print("\(scrollView.contentOffset.y) \(autoLoader.selecting) \(self.page)")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func selected(data:TableData){
        
        let indexPath = IndexPath(row: self.scrollIndex, section: 0)
        
        self.tableData = data
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: false)
        
        
        
        //let indexPath = IndexPath(row: 25, section: 0)
        //self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        
        /*
        let indexPath = IndexPath(row: 24, section: 0)
            
        if(tableData!.offset != 0){
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }*/
    }
}
