//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import SDWebImage
import RealmSwift
import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var newsData: NewsModel?
    var dbNewsData: Results<ArticleDB>?
    var currentDay = 0
    
    //MARK: - Outlets
    
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews(sender:)), for: .valueChanged)
        return refreshControl
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLastNewsByDay(day: currentDay)
        dbNewsData = DB.shared.getFromDB()
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        
        newsTableView.refreshControl = refreshControl
    }
    
    //MARK: - API funcs
    
    func getLastNewsByDay(day: Int) {
        APIManager.shared.getLastNewsByDay(day: currentDay) { [weak self] result in
            switch result {
            case .success(let model):
                if self?.newsData != nil {
                    self?.newsData?.articles.append(contentsOf: model.articles)
                } else {
                    self?.newsData = model
                }
                
                self?.updateNewsTableView()
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.newsTableView.isHidden = true
                }
            }
        }
    }
    
    //MARK: - Other funcs
    
    func updateNewsTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.newsTableView.reloadData()
        }
    }
    
    func displayEndLabel() {
        DispatchQueue.main.async { [weak self] in
            self?.endLabel.isHidden = false
        }
    }
    
    func hideEndLabel() {
        DispatchQueue.main.async { [weak self] in
            self?.endLabel.isHidden = true
        }
    }
    
    @objc func refreshNews(sender: UIRefreshControl) {
        newsData = nil
        dbNewsData = nil
        currentDay = 0
        getLastNewsByDay(day: currentDay)
        dbNewsData = DB.shared.getFromDB()
        hideEndLabel()
        
        sender.endRefreshing()
    }
    
    @objc func removeFromSaved(_ sender: UIButton) {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        
        if segmentIndex == 0 {
            guard let article = newsData?.articles[sender.tag] else {
                return
            }
            
            DB.shared.removeFromDB(item: article)
        } else {
            guard let dbNewsDataLocal = dbNewsData else {
                return
            }
            var article = Article()
            
            article.url = dbNewsDataLocal[sender.tag].url

            DB.shared.removeFromDB(item: article)
        }
        
        sender.removeTarget(nil, action: #selector(removeFromSaved(_:)), for: .touchUpInside)
        sender.setImage(UIImage(systemName: "star"), for: .normal)
        sender.addTarget(self, action: #selector(addToSaved(_:)), for: .touchUpInside)
        updateNewsTableView()
    }
    

    
    @objc func addToSaved(_ sender: UIButton) {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        
        guard let article = newsData?.articles[sender.tag] else {
            return
        }
        
        
        if segmentIndex == 0 {
            guard let article = newsData?.articles[sender.tag] else {
                return
            }
            
            DB.shared.addToDB(item: article)
        } else {
            guard let dbNewsDataLocal = dbNewsData else {
                return
            }
            var article = Article()
            
            article.author = dbNewsDataLocal[sender.tag].author
            article.description = dbNewsDataLocal[sender.tag].newsDescription
            article.publishedAt = dbNewsDataLocal[sender.tag].publishedAt
            article.title = dbNewsDataLocal[sender.tag].title
            article.url = dbNewsDataLocal[sender.tag].url
            article.urlToImage = dbNewsDataLocal[sender.tag].urlToImage

            DB.shared.addToDB(item: article)
        }
        
        sender.removeTarget(nil, action: #selector(addToSaved(_:)), for: .touchUpInside)
        sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
        sender.addTarget(self, action: #selector(removeFromSaved(_:)), for: .touchUpInside)
        updateNewsTableView()
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.updateNewsTableView()
    }
    

    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        
        switch segmentIndex {
        case 0:
            return newsData?.articles.count ?? 0
        case 1:
            return dbNewsData?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        
        let url: String?
        let imageUrl: String?
        
        switch segmentIndex {
        case 0:
            let data = newsData?.articles[indexPath.row]
            cell.newsTitle.text = data?.title
            cell.newsDesc.text = data?.description
            url = data?.url
            imageUrl = data?.urlToImage
        case 1:
            guard let dbNewsDataLocal = dbNewsData else {
                return cell
            }
            cell.newsTitle.text = dbNewsDataLocal[indexPath.row].title
            cell.newsDesc.text = dbNewsDataLocal[indexPath.row].newsDescription
            url = dbNewsDataLocal[indexPath.row].url
            imageUrl = dbNewsDataLocal[indexPath.row].urlToImage
        default:
            return cell
        }
        
        cell.saveButton.tag = indexPath.row
    
        guard let urlToArticle = url else {
            return cell
        }
        
        if DB.shared.isInDB(url: urlToArticle) {
            
            cell.saveButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            cell.saveButton.addTarget(self, action: #selector(removeFromSaved(_:)), for: .touchUpInside)
            
        } else {
            cell.saveButton.setImage(UIImage(systemName: "star"), for: .normal)
            cell.saveButton.addTarget(self, action: #selector(addToSaved(_:)), for: .touchUpInside)
            
        }
        
        guard let urlToImage = imageUrl else {
            return cell
        }
        
        cell.newsImage.sd_setImage(with: URL(string: urlToImage), completed: nil)

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 2 == newsData?.articles.count {
            if currentDay <= 7 {
                getLastNewsByDay(day: currentDay)
                currentDay += 1
            } else {
                displayEndLabel()
            }
        }
    }
}


