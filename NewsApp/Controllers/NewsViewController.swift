//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import SDWebImage
import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var newsData: NewsModel?
    var currentPage = 2
    
    //MARK: - Outlets
    
    @IBOutlet weak var newsTableView: UITableView!
    
    let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLastNewsFromAPI()
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        
        newsTableView.refreshControl = refreshControl
    }
    
    //MARK: - API funcs
    
    func getLastNewsFromAPI() {
        APIManager.shared.getLastNews { [weak self] result in
            switch result {
            case .success(let model):
                self?.newsData = model
                self?.updateNewsTableView()
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.newsTableView.isHidden = true
                }
            }
        }
    }
    
    func getNewsByPage(page: Int) {
        APIManager.shared.getNewsByPage(page: currentPage) { [weak self] result in
            switch result {
            case .success(let model):
                self?.newsData?.articles.append(contentsOf: model.articles)
                self?.updateNewsTableView()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    //MARK: - Other funcs
    
    func updateNewsTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.newsTableView.reloadData()
        }
    }
    
    @objc func refreshNews(sender: UIRefreshControl) {
        newsData = nil
        currentPage = 2
        getLastNewsFromAPI()
        
        sender.endRefreshing()
    }

    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        let data = newsData?.articles[indexPath.row]
        cell.newsTitle.text = data?.title
        cell.newsDesc.text = data?.description
        if let imageUrl = data?.urlToImage, data?.urlToImage != nil {
            cell.newsImage.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 2 == newsData?.articles.count {
            if currentPage <= 7 {
                getNewsByPage(page: currentPage)
                currentPage += 1
            }
        }
    }
}


