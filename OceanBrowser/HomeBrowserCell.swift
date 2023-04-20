//
//  HomeBrowserCell.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/19.
//

import UIKit

class HomeBrowserCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!

    var item: HomeBrowserItem? {
        didSet {
            title.text = item?.rawValue
            icon.image = item?.icon
        }
    }
}
