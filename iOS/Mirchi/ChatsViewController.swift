//
//  ChatsViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 29/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import SwipeCellKit
import GoogleMobileAds
import DropletIF

class ChatsViewController: UIViewController{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableHeaderViewContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingMatchesView: UIView!
    @IBOutlet weak var noChatsView: UIView!
    @IBOutlet weak var noChatsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerAdView: GADBannerView!
    @IBOutlet weak var bannerAdViewHeightZeroConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerAdViewHeightVisibleConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBannerAd()
        NotificationCenter.default.addObserver(self, selector: #selector(configureBannerAd), name: DropletConstants.NotificationName.subscriptionStatusUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChatService.shared.addDelegate(delegate: self)
        loadingMatchesView.isHidden = ChatService.shared.haveLoadedChats()
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ChatService.shared.removeDelegate(delegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderViewHeight()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func configureBannerAd(){
        bannerAdViewHeightVisibleConstraint.priority = .defaultLow
        bannerAdViewHeightZeroConstraint.priority = .defaultHigh
        if !Config.Features.adsEnabled{
            return
        }
        if Config.Features.adsRemovedIfSubscribed && StoreService.shared.isSubscribed() {
            return
        }
        bannerAdView.delegate = self
        bannerAdView.adUnitID = Config.AdMob.matchesBannerID
        bannerAdView.rootViewController = self
        bannerAdView.adSize = kGADAdSizeSmartBannerPortrait
        bannerAdView.load(AdsService.shared.getRequest())
    }
//
    func updateTableHeaderViewHeight(){
        guard let tableHeaderView = self.tableView.tableHeaderView else { return }
        var frame = tableHeaderView.frame
        frame.size.height = tableHeaderViewContainer.frame.size.height
        tableHeaderView.frame = frame
        self.tableView.tableHeaderView = tableHeaderView
    }
    
    func goToChatWithUser(user:User){
        guard let chat = ChatService.shared.getChatFor(opponent: user) else{
            return
        }
        self.performSegue(withIdentifier: "toChatViewController", sender: chat)
    }

    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toChatViewController"{
            if let cell = sender as? NewMatchCell, let indexPath = collectionView.indexPath(for: cell){
                return ChatService.shared.getMatches(nameQuery: searchBar.text).count > indexPath.row
            }else if sender as? Chat != nil{
                return true
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? ChatViewController{
            toVC.transitioningDelegate = self
            if let cell = sender as? ChatCell, let indexPath = tableView.indexPath(for: cell){
                let chat = ChatService.shared.getChats(nameQuery: searchBar.text)[indexPath.row]
                toVC.chat = chat
            }else if let cell = sender as? NewMatchCell, let indexPath = collectionView.indexPath(for: cell){
                let chat = ChatService.shared.getMatches(nameQuery: searchBar.text)[indexPath.row]
                toVC.chat = chat
            }else if let chat = sender as? Chat{
                toVC.chat = chat
            }
        }else if let toVC = segue.destination as? ReportViewController, let chat = sender as? Chat{
            toVC.transitioningDelegate = self
            toVC.user = chat.opponent
            toVC.delegate = self
        }
    }
}

extension ChatsViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        collectionView.reloadData()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

extension ChatsViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ChatService.shared.getMatches(nameQuery: searchBar.text).count
        noChatsViewTopConstraint.constant = tableHeaderView.bounds.size.height
        if count == 0{
            if (searchBar.text == nil || searchBar.text!.isEmpty){
                noChatsViewTopConstraint.constant = 0
            }
            collectionView.isScrollEnabled = false
            return 5
        }
        //noChatsViewTopConstraint.constant = (count == 0 && (searchBar.text == nil || searchBar.text!.isEmpty) ? 0 : tableHeaderView.bounds.size.height)
        //return max(count, 5)
        collectionView.isScrollEnabled = true
        return count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMatchCell", for: indexPath) as! NewMatchCell
        if ChatService.shared.getMatches(nameQuery: searchBar.text).count > indexPath.row{
            let chat = ChatService.shared.getMatches(nameQuery: searchBar.text)[indexPath.row]
            cell.configureCell(chat: chat)
        }else{
            cell.configureCell(name: nil, imageUrl: nil)
        }
        return cell
    }
}

extension ChatsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = ChatService.shared.getChats(nameQuery: searchBar.text).count
        noChatsView.isHidden = !(count == 0 && (searchBar.text == nil || searchBar.text!.isEmpty))
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        let chat = ChatService.shared.getChats(nameQuery: searchBar.text)[indexPath.row]
        cell.configureCell(chat: chat)
        cell.delegate = self
        return cell
    }
}

extension ChatsViewController: UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder{
            searchBar.resignFirstResponder()
        }
    }
}

extension ChatsViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let reportAction = SwipeAction(style: .default, title: NSLocalizedString("CHATS_ROW_SWIPE_REPORT_BUTTON", comment: "Report Button")) { (action, indexPath) in
            //Report chat at indexPath
            guard ChatService.shared.getChats(nameQuery: self.searchBar.text).count > indexPath.row else { return }
            let chat = ChatService.shared.getChats(nameQuery: self.searchBar.text)[indexPath.row]
            self.performSegue(withIdentifier: "toReportViewController", sender: chat)
        }
        reportAction.backgroundColor = UIColor.orange
        reportAction.image = UIImage(named:"ReportIcon")
        
        let unmatchAction = SwipeAction(style: .destructive, title: NSLocalizedString("CHATS_ROW_SWIPE_UNMATCH_BUTTON", comment: "Unmatch Button")) { (action, indexPath) in
            //Unmatch chat at indexPath
            guard ChatService.shared.getChats(nameQuery: self.searchBar.text).count > indexPath.row else { return }
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("CHATS_UNMATCH_ALERT_TITLE", comment: "Unmatch Alert Title"), message: NSLocalizedString("CHATS_UNMATCH_ALERT_BODY", comment: "Unmatch Alert Body"))
            alert.addAction(title: NSLocalizedString("CHATS_UNMATCH_ALERT_UNMATCH_BUTTON", comment: "Unmatch Button"), style: .destructive, handler: {
                let chat = ChatService.shared.getChats(nameQuery: self.searchBar.text)[indexPath.row]
                ChatService.shared.unmatch(chat: chat, completion: { (error) in
                    if let error = error{
                        print("Error unmatching: \(error.localizedDescription)")
                        return
                    }
                    self.tableView.beginUpdates()
                    //self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                    action.fulfill(with: .delete)
                    self.tableView.endUpdates()
                })
            })
            alert.addAction(title: NSLocalizedString("CHATS_UNMATCH_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
            alert.transitioningDelegate = self
            self.present(alert, animated: true, completion: nil)
        }
        //unmatchAction.backgroundColor = UIColor.red
        unmatchAction.image = UIImage(named:"UnmatchIcon")
        
        return [unmatchAction, reportAction]
    }
}

extension ChatsViewController: ChatServiceDelegate{
    func didReceiveNewMatch() {
        collectionView.reloadData()
    }
    
    func chatDidReceiveMessage(chat: Chat, message: Message, isNew: Bool) {
        tableView.reloadData()
    }
    
    func chatUpdated(chat: Chat, deleted: Bool) {
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func chatsLoaded() {
        UIView.animate(withDuration: 1.5, animations: {
            self.loadingMatchesView.alpha = 0.0
        }) { (complete) in
            self.loadingMatchesView.isHidden = ChatService.shared.haveLoadedChats()
            self.loadingMatchesView.alpha = 1.0
        }
    }
}

extension ChatsViewController: ReportViewControllerDelegate{
    func didCancelReport() {
        self.dismiss(animated: true) {
            if let interstitial = AdsService.shared.getInterstitial(){
                interstitial.present(fromRootViewController: self)
            }
        }
    }
    
    func didSendReport(user: User) {
        self.dismiss(animated: true) {
            if let interstitial = AdsService.shared.getInterstitial(){
                interstitial.present(fromRootViewController: self)
            }
        }
    }
}

extension ChatsViewController: GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerAdViewHeightZeroConstraint.priority = .defaultLow
        bannerAdViewHeightVisibleConstraint.priority = .defaultHigh
        self.view.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
        bannerAdViewHeightZeroConstraint.priority = .defaultHigh
        bannerAdViewHeightVisibleConstraint.priority = .defaultLow
        self.view.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
