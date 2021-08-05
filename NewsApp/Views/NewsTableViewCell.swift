//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDesc: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
