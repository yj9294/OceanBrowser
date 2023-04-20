//
//  HomeBottomCell.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/19.
//

import UIKit

class HomeBottomCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    var item: HomeBottomItem? {
        didSet {
            button.setImage(UIImage(named: item?.rawValue ?? ""), for: .normal)
            if item == .back {
                self.button.isEnabled = BrowserUtil.shared.canGoBack
            } else if item == .forword {
                self.button.isEnabled = BrowserUtil.shared.canGoForword
            } else {
                self.button.isEnabled = true
            }
            
            if item == .tab {
                button.setTitle("\(BrowserUtil.shared.count)", for: .normal)
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -17, bottom: 0, right: 0)
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            } else {
                button.setTitle("", for: .normal)
            }
        }
    }

}
