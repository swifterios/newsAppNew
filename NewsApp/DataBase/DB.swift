//
//  DB.swift
//  NewsApp
//
//  Created by Владислав on 09.08.2021.
//

import Foundation
import RealmSwift

final class DB {
    
    static let shared = DB()
    
    let realm = try! Realm()

    
    public func addToDB(item: Article) {
        try! realm.write {
            
        }
    }
    
    
}