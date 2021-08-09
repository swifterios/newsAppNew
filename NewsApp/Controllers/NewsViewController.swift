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
        
        DB.shared.getInfo()
        
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
        currentDay = 0
        getLastNewsByDay(day: currentDay)
        hideEndLabel()
        
        sender.endRefreshing()
    }
    
    @IBAction func addToSaved(_ sender: UIButton) {
        guard let article = newsData?.articles[sender.tag] else {
            return
        }
        
        DB.shared.addToDB(item: article)
        
    }
    

    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentIndex = segmentedControl.selectedSegmentIndex

        let cell = newsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        let data = newsData?.articles[indexPath.row]
        cell.newsTitle.text = data?.title
        cell.newsDesc.text = data?.description
        cell.saveButton.tag = indexPath.row
        if let imageUrl = data?.urlToImage, data?.urlToImage != nil {
            cell.newsImage.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        
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


