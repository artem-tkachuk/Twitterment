//
//  ViewController.swift
//  Twitterment
//
//  Created by Artem Tkachuk on 8/8/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import SwifteriOS
import SwiftyJSON
import CoreML

class ViewController: UIViewController {
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var handleTextField: UITextField!
    
    let MAX_TWEETS = Int(ProcessInfo.processInfo.environment["MAX_TWEETS"]!)!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: ProcessInfo.processInfo.environment["API_KEY"]!, consumerSecret: ProcessInfo.processInfo.environment["API_SECRET"]!)
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - predictPressed()
    @IBAction func predictPressed(_ sender: UIButton) {
        if let request = handleTextField.text  {
            if request != "" {
                swifter.searchTweet(using: request, lang: "en", count: MAX_TWEETS, tweetMode: .extended, success: { (results, metadata) in
                    let tweets = self.parseTweets(results)
                    
                    do {
                        let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                        let overallScore = self.tallyUpPredictions(predictions)
                        self.updateSentimentLabel(with: overallScore)
                    } catch {
                        print("Error while classifying sentiments for the tweets, \(error)")
                    }
                }) { (error) in
                    print("There was an error with the Twitter API Request, \(error)")
                }
            }
        }
    }
    
    
    //MARK: - parseTweets()
    func parseTweets(_ results: SwifteriOS.JSON) -> [TweetSentimentClassifierInput] {
        var tweets = [TweetSentimentClassifierInput]()
        
        for i in 0..<self.MAX_TWEETS {
            if let tweet = results[i]["full_text"].string {
                let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                tweets.append(tweetForClassification)
            }
        }
        
        return tweets
    }
    
    
    //MARK: - tallyUpPredictions()
    func tallyUpPredictions(_ predictions: [TweetSentimentClassifierOutput]) -> Int {
        var overallScore = 0
        
        for pred in predictions {
            if pred.label == "Pos" {
             overallScore += 1
            } else if pred.label == "Neg" {
                overallScore -= 1
            }
        }
        
        return overallScore
    }
    
    
    //MARK: - updateSentimentLabel()
    func updateSentimentLabel(with overallScore: Int) {
        var emojicon: String
        
        switch overallScore {
            case 20...:
                emojicon = "😍"
            case 10..<20:
                emojicon = "😃"
            case 1..<10:
                emojicon = "🙂"
            case 0:
                emojicon = "😐"
            case -10..<0:
                emojicon = "😕"
            case -20..<(-10):
                emojicon = "😠"
            default:
                emojicon = "🤬"
        }
        
        sentimentLabel.text = emojicon
    }
}

