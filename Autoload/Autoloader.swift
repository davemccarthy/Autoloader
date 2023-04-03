//
//  Autoloader.swift
//  Autoload
//
//  Created by David McCarthy on 06/11/2021.
//  Copyright © 2021 David McCarthy. All rights reserved.
//

import SwiftUI

public struct TableData: Decodable {
    
    let id: String
    let count:Int
    let limit: Int
    let offset: Int
    let message: String
    let columns: [String]
    let rows:[[String]]
}

public struct TrashData: Decodable {
    
    let id: String
    let message: String
}

public protocol Autoloadable {
    
    func selected(data:TableData)
    func deleted(data:TrashData)
}

class Autoload {
    
    var session:URLSession = URLSession.shared
    var delegate: Autoloadable?
    
    var id = ""
    var domain = ""
    var database = ""
    var table = ""
    var join = ""
    var pagesize:Int = 1000
    
    var selecting = false
    
    init() {
        
        let config = URLSessionConfiguration.default
        
        config.httpAdditionalHeaders = ["X-CSRFToken" : "RNeZCW8x8guHHqIUtbMOHuRztRRwNsvAj8nvPgWFQzzDVYASUHHW1ITdJTB3lyGB"]
        session = URLSession(configuration: config)
    }
    
    //  Select database rows
    func select(columns:String, offset:Int = 0, filter:String = "", groupby:String="", orderby:String = ""){
        
        let params:[String : Any] = [
            "database" : "\(database)",
            "table" : "\(table)",
            "columns" : "\(columns)",
            "join" : "\(join)",
            "filter" : "\(filter)",
            "groupby" : "\(groupby)",
            "orderby" : "\(orderby)",
            "limit" : "\(self.pagesize)",
            "offset" : "\(offset)"
        ]
        
        query(method: "tablemaker", params: params) { code, jsonData in
            
            let tableData: TableData = try! JSONDecoder().decode(TableData.self, from: jsonData)
        
            self.delegate?.selected(data:tableData)
        }
    }
    
    //  Delete database row
    func delete(key:String, condition:String, completion:@escaping (Bool,String) -> ()){
        
        let params:[String : Any] = [
            "database" : "\(database)",
            "table" : "\(table)",
            "key" : "\(key)",
            "condition" : "\(condition)"
        ]
        
        query(method: "tabledeleter", params: params) { code, jsonData in
            
            let trashData: TrashData = try! JSONDecoder().decode(TrashData.self, from: jsonData)
            
            completion(code == 200 ? true : false, trashData.message)
        }
    }
    
    //  Generic database proxy query
    func query(method:String,params:[String : Any],completion:@escaping (Int,Data) -> ()){
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        var request = URLRequest(url: URL(string: "\(domain)/\(method)/ios/")!)
        
        request.httpBody = ("Params=\(jsonString)").data(using: .utf8)
        request.httpMethod = "POST"
        
        self.selecting = true
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
        
            guard var jsonData:Data = data else {
                
                if let error = error {
                    print("HTTP Request Failed \(error)")
                }
                
                return;
            }
        
            DispatchQueue.main.async {
            
                let httpResponse = response as! HTTPURLResponse
            
                completion(httpResponse.statusCode,jsonData)
            }
        })
            
        task.resume()
    }
}

