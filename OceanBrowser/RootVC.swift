//
//  RootVC.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/18.
//

import UIKit

class RootVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [LaunchVC(), HomeVC()]
        self.selectedIndex = 0
        self.tabBar.isHidden  = true
        
        FirebaseUtil.log(property: .local)
        FirebaseUtil.log(event: .open)
        FirebaseUtil.log(event: .openCold)
    }

}
