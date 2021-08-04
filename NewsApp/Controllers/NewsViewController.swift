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
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        getLastNewsFromAPI()
    }
    
    //MARK: - API funcs
    
    public func getLastNewsFromAPI() {
        APIManager.shared.getLastNews { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let model):
                    self?.newsData = model
                    self?.updateNewsTableView()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    //MARK: - Other funcs
    
    public func updateNewsTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.newsTableView.reloadData()
        }
    }

    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        
        return cell
    }
}


