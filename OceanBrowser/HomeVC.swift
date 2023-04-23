//
//  HomeVC.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/18.
//

import UIKit
import AppTrackingTransparency
import MobileCoreServices
import WebKit
import IQKeyboardManagerSwift


class HomeVC: UIViewController, UITextFieldDelegate, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var browserCollection: UICollectionView!
    @IBOutlet weak var bottomCollection: UICollectionView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var cleanView: UIView!
    
    @IBOutlet weak var adView: GADNativeView!
    var willAppear = false
    
    var date: Date = Date()


    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        browserCollection.register(UINib(nibName: "HomeBrowserCell", bundle: .main), forCellWithReuseIdentifier: "HomeBrowserCell")
        bottomCollection.register(UINib(nibName: "HomeBottomCell", bundle: .main), forCellWithReuseIdentifier: "HomeBottomCell")
        gadObserve()
        Task{
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                ATTrackingManager.requestTrackingAuthorization(){ _ in }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStatus()
        BrowserUtil.shared.addedWebView(from: self)
        
        willAppear = true
        GADUtil.share.load(.native)
        GADUtil.share.load(.interstitial)
        
        FirebaseUtil.log(event: .homeShow)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BrowserUtil.shared.removeWebView()
        
        willAppear = false
        GADUtil.share.disappear(.native)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        BrowserUtil.shared.frame = contentView.frame
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchAction()
        return true
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        bottomCollection.reloadData()
        webView.load(navigationAction.request)
        return nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        refreshStatus()
    }
}

extension HomeVC {
    
    func gadObserve() {
        NotificationCenter.default.addObserver(forName: .nativeUpdate, object: nil, queue: .main) { [weak self] noti in
            guard let self = self else { return }
            if let ad = noti.object as? NativeADModel, self.willAppear {
                if Date().timeIntervalSince1970 - (GADUtil.share.homeNativeAdImpressionDate ?? Date(timeIntervalSinceNow: -11)).timeIntervalSince1970 > 10 {
                    self.adView.nativeAd = ad.nativeAd
                    GADUtil.share.homeNativeAdImpressionDate = Date()
                } else {
                    NSLog("[ad] 10s home 原生广告刷新或数据填充间隔.")
                }
            } else {
                self.adView.nativeAd = nil
            }
        }
    }
    
    func refreshStatus() {
        stopButton.isHidden = !BrowserUtil.shared.isLoading
        searchButton.isHidden = BrowserUtil.shared.isLoading
        textField.text = BrowserUtil.shared.url
        progressView.progress = Float(BrowserUtil.shared.progrss)
        BrowserUtil.shared.delegate = self
        BrowserUtil.shared.uiDelegate = self
        if BrowserUtil.shared.progrss > 0, BrowserUtil.shared.progrss < 1.0 {
            progressView.isHidden = false
        } else {
            progressView.isHidden = true
        }
        if BrowserUtil.shared.url == nil  {
            BrowserUtil.shared.removeWebView()
        }
        if BrowserUtil.shared.progrss == 0.1 {
            date = Date()
            FirebaseUtil.log(event: .webStart)
        }
        
        if BrowserUtil.shared.progrss == 1.0 {
            stopButton.isHidden = true
            searchButton.isHidden = false
            
            let time = Date().timeIntervalSince1970 - date.timeIntervalSince1970
            FirebaseUtil.log(event: .webSuccess, params: ["bro": "\(ceil(time))"])
        }
        bottomCollection.reloadData()

    }
    
    @IBAction func searchAction() {
        view.endEditing(true)
        if let text = textField.text, text.count > 0 {
            BrowserUtil.shared.loadUrl(text, from: self)
            FirebaseUtil.log(event: .search, params: ["bro": text])
        } else {
            alert("Please enter your search content.")
        }
    }
    
    @IBAction func stopSearchAction() {
        view.endEditing(true)
        textField.text = ""
        BrowserUtil.shared.stopLoad()
    }
    
    func goBack() {
        BrowserUtil.shared.goBack()
        if BrowserUtil.shared.canGoBack {
            hiddenSettingView()
        }
    }
    
    func goForword() {
        BrowserUtil.shared.goForword()
        if BrowserUtil.shared.canGoForword {
            hiddenSettingView()
        }
    }
    
    func cleanAction() {
        hiddenSettingView()
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.cleanView.alpha = 1
        }
        
        FirebaseUtil.log(event: .cleanClick)
    }
    
    func tabAction() {
        let vc = ListVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        hiddenSettingView()
    }
    
    @IBAction func showSettingView() {
        if settingView.alpha == 1.0 {
            hiddenSettingView()
        } else {
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.settingView.alpha = 1
            }
        }
    }
    
    @IBAction func hiddenSettingView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.settingView.alpha = 0
        }
    }
    
    @IBAction func newBrowser() {
        hiddenSettingView()
        BrowserUtil.shared.removeWebView()
        BrowserUtil.shared.add()
        refreshStatus()
        
        FirebaseUtil.log(event: .browserNew, params: ["bro": "setting"])
    }
    
    @IBAction func shareAction() {
        hiddenSettingView()
        var url = "https://itunes.apple.com/cn/app/id6447860064"
        if !BrowserUtil.shared.item.isNavigation, let text = BrowserUtil.shared.item.webView.url?.absoluteString {
            url = text
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(vc, animated: true)
        
        FirebaseUtil.log(event: .shareClick)
    }
    
    @IBAction func copyAction() {
        hiddenSettingView()
        if !BrowserUtil.shared.item.isNavigation, let text = BrowserUtil.shared.item.webView.url?.absoluteString {
            UIPasteboard.general.setValue(text, forPasteboardType: kUTTypePlainText as String)
            self.alert("Copy successed.")
        } else {
            UIPasteboard.general.setValue("", forPasteboardType: kUTTypePlainText as String)
            self.alert("Copy successed.")
        }
        
        FirebaseUtil.log(event: .copyClick)
    }
    
    @IBAction func rateAction() {
        hiddenSettingView()
        if let url = URL(string: "https://itunes.apple.com/cn/app/id6447860064") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func privacyAction() {
        hiddenSettingView()
        let vc = PrivacyVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func termsAction() {
        hiddenSettingView()
        let vc = TermsVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func showCleanViewAction() {
        
        hiddenCleanView()
        let vc = CleanVC()
        vc.modalPresentationStyle = .fullScreen
        vc.completionHandle = { [weak self] in
            self?.alert("Cleaned")
            FirebaseUtil.log(event: .cleanSuccess)
            FirebaseUtil.log(event: .cleanAlert)
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func hiddenCleanView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.cleanView.alpha = 0
        }
    }
    
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == browserCollection {
            return HomeBrowserItem.allCases.count
        } else {
            return HomeBottomItem.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == browserCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBrowserCell", for: indexPath)
            if let cell = cell as? HomeBrowserCell {
                cell.item = HomeBrowserItem.allCases[indexPath.row]
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBottomCell", for: indexPath)
            if let cell = cell as? HomeBottomCell {
                cell.item = HomeBottomItem.allCases[indexPath.row]
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == browserCollection {
            return CGSize(width: 76, height: 84)
        } else {
            return CGSize(width: 34, height: 34)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == browserCollection {
            return (width - 16*2 - 76 * 4) / 3.0 - 4
        } else {
            return (width - 20*2 - 34 * 5) / 4.0 - 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomCollection {
            switch HomeBottomItem.allCases[indexPath.row] {
            case .back:
                goBack()
            case .forword:
                goForword()
            case .clean:
                cleanAction()
            case .tab:
                tabAction()
            case .setting:
                showSettingView()
            }
        } else {
            view.endEditing(true)
            let text = "https://www.\(HomeBrowserItem.allCases[indexPath.row].rawValue).com"
            textField.text = text
            BrowserUtil.shared.loadUrl(text, from: self)
            
            FirebaseUtil.log(event: .clickSearch, params: ["bro": HomeBrowserItem.allCases[indexPath.row].rawValue])
        }
    }
    
}


enum HomeBrowserItem: String, CaseIterable {
    case google, facebook, twitter, youtube, instagram, amazon, gmail, yahoo
    
    var icon: UIImage {
        UIImage(named: self.rawValue) ?? UIImage()
    }
}

enum HomeBottomItem: String, CaseIterable {
    case back, forword, clean, tab, setting
}

