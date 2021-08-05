//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var newsData: NewsModel?

    //MARK: - Outlets
    
    @IBOutlet weak var newsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLastNewsFromAPI()
        
        newsTableView.dataSource = self
        newsTableView.delegate = self

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
                self?.newsTableView.isHidden = true
            }
        }
        
        self.updateNewsTableView()
    }
    
    //MARK: - Other funcs
    
    func updateNewsTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.newsTableView.reloadData()
        }
    }

    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        cell.newsTitle.text = newsData?.articles[indexPath.row].title
        cell.newsDesc.text = newsData?.articles[indexPath.row].description
        
        return cell
    }
}


