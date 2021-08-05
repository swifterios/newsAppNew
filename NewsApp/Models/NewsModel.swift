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
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
}

typealias Articles = [Article]
