//
//  ListVC.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/19.
//

import UIKit

class ListVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var adView: GADNativeView!
    
    var willAppear = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ListCell", bundle: .main), forCellWithReuseIdentifier: "ListCell")
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        gadObserve()
    }
    
    func deleteItem(_ item: BrowserItem) {
        BrowserUtil.shared.remove(item)
        self.collectionView.reloadData()
    }
    
    @IBAction func addAction() {
        BrowserUtil.shared.add()
        self.dismiss(animated: true)
        
        FirebaseUtil.log(event: .browserNew, params: ["bro": "tab"])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear = true
        GADUtil.share.load(.native)
        GADUtil.share.load(.interstitial)
        
        FirebaseUtil.log(event: .tabShow)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willAppear = false
        GADUtil.share.disappear(.native)
    }
    
    @IBAction func backAction() {
        self.dismiss(animated: true)
    }
    
    func gadObserve() {
        NotificationCenter.default.addObserver(forName: .nativeUpdate, object: nil, queue: .main) { [weak self] noti in
            guard let self = self else { return }
            if let ad = noti.object as? NativeADModel, self.willAppear {
                if Date().timeIntervalSince1970 - (GADUtil.share.tabNativeAdImpressionDate ?? Date(timeIntervalSinceNow: -11)).timeIntervalSince1970 > 10 {
                    self.adView.nativeAd = ad.nativeAd
                    GADUtil.share.tabNativeAdImpressionDate = Date()
                } else {
                    NSLog("[ad] 10s tab 原生广告刷新或数据填充间隔.")
                }
            } else {
                self.adView.nativeAd = nil
            }
        }
    }
}

extension ListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BrowserUtil.shared.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath)
        if let cell = cell as? ListCell {
            let item = BrowserUtil.shared.indexItems(indexPath.row)
            cell.item = item
            cell.closeHandle = { [weak self] in
                self?.deleteItem(item)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 156, height: 204)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = BrowserUtil.shared.indexItems(indexPath.row)
        BrowserUtil.shared.select(item)
        self.dismiss(animated: true)
    }
    
}
