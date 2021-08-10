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
        let article = ArticleDB()
        article.author = item.author
        article.title = item.title
        article.newsDescription = item.description
        article.url = item.url
        article.urlToImage = item.urlToImage
        article.publishedAt = item.publishedAt
        
        try! realm.write {
            realm.add(article)
        }
    }
    
    public func removeFromDB(item: Article) {
        guard let url = item.url else {
            return
        }
        
        let results = realm.objects(ArticleDB.self).filter("url = '\(url)'")
        try! realm.write {
            realm.delete(results)
        }
    }
    
    public func getFromDB() -> Results<ArticleDB> {
        let results = realm.objects(ArticleDB.self)
        
        return results
    }
    
    public func isInDB(url: String) -> Bool {
        let results = realm.objects(ArticleDB.self).filter("url = '\(url)'")
        return results.count > 0
    }
    
}

//MARK: - ArticleDB

class ArticleDB: Object {
    @objc dynamic var author: String? = nil
    @objc dynamic var title: String? = nil
    @objc dynamic var newsDescription: String? = nil
    @objc dynamic var url: String? = nil
    @objc dynamic var urlToImage: String? = nil
    @objc dynamic var publishedAt: String? = nil
}
