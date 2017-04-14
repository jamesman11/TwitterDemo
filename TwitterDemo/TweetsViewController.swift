//
//  TweetsViewController.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tweets: [Tweet] = []
    
    @IBOutlet var tweetsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchTimeline(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tweetsTableView.insertSubview(refreshControl, at: 0)
        fetchTimeline(refreshControl)
        
        navigationController?.navigationBar.barTintColor = Helper.UIColorFromHex(rgbValue: 0x3ec8ef, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: TwitterClient.newTweetNotification), object: nil, queue: OperationQueue.main, using: {
            (Notification) -> Void in
                let tweetObject = Notification.object as! NSDictionary
                let tweet = Tweet(data: tweetObject)
                self.tweets.insert(tweet, at: 0)
                self.tweetsTableView.reloadData()
        })

    }
    
    func fetchTimeline(_ refreshControl:UIRefreshControl){
        TwitterClient.sharedInstance?.homeTimeline(success: {(tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: {(error:Error) -> () in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func onFavorite(_ sender: AnyObject) {
        let row = sender.tag
        let indexPath = IndexPath(row: row!, section: 0)
        let cell = self.tweetsTableView.cellForRow(at: indexPath) as! TweetsTableViewCell
        cell.isFavorite = !cell.isFavorite
        var image:UIImage?
        if cell.isFavorite {
            image = UIImage(named: "star-filled")
        } else {
            image = UIImage(named: "star")
        }
        cell.favoriteButton.setImage(image, for: .normal)
    }
    
    @IBAction func onRetweet(_ sender: AnyObject) {
    }
    @IBAction func onReply(_ sender: AnyObject) {
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweetDetailSegue" {
            let cell = sender as! TweetsTableViewCell
            let dc = segue.destination as! TweetDetailViewController
            dc.tweet = cell.tweet
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetsTableViewCell
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet 
        cell.contentLabel.text = tweet.text
        cell.nameLabel.text = tweet.name
        cell.favoriteButton.tag = indexPath.row
        cell.replyButton.tag = indexPath.row
        cell.retweetButton.tag = indexPath.row
        cell.handlerNameLabel.text = tweet.screen_name
        cell.timeLabel.text = tweet.timestamp
        cell.profileImage.setImageWith(tweet.profileUrl!)
        return cell
    }
}
