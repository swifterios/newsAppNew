//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    //MARK: - Outlets
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDesc: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var showmoreButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    @IBAction func showmoreClicked(_ sender: UIButton) {
        newsDesc.numberOfLines = 3
        self.updateConstraints()
        self.updateConstraintsIfNeeded()
        print(newsDesc.text)
    }
    
}
