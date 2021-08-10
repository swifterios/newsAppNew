//
//  NewsModel.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import Foundation

struct NewsModel: Codable {
    let totalResults: Int?
    var articles: Articles
}

struct Article: Codable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
}

typealias Articles = [Article]
