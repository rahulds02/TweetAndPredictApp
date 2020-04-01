//
//  ViewController.swift
//  TweetAndPredict
//
//  Created by Rahul Sharma on 25/03/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = tweetSentimentClassifier()
    let swifter = Swifter(consumerKey: "CWwd4pFUl0oWiYEXfggZKxrMc", consumerSecret: "myBVLHv9OiREZllvof6yNGfIsvlbFmbg4nzgFiNBq9Q0bzEa3O")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
        
    }
    
    func fetchTweets() {
     
        //let prediction = try! sentimentClassifier.prediction(text: "@Apple is a terrible company")
        // print(prediction.label)
        
        guard let searchText = textField.text else {
            return
        }
        
        swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
            print(results)
            
            //            if let tweet = results[0]["full_text"].string {
            //                print(tweet)
            //            }
            
            var tweets = [tweetSentimentClassifierInput]()
            
            for i in 0..<self.tweetCount {
                if let tweet = results[i]["full_text"].string {
                    let tweetForClassification = tweetSentimentClassifierInput(text: tweet)
                    tweets.append(tweetForClassification)
                }
            }
            
            self.makePrediction(with: tweets)
            
        }) { (error) in
            print("error is \(error)")
        }
    }
    
    func makePrediction(with tweets: [tweetSentimentClassifierInput]) {
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var score = 0
            
            print(predictions[0].label)
            
            for pred in predictions {
                //print(pred.label)
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    score = score + 1
                } else if sentiment == "Neg" {
                    score = score - 1
                }
            }
            
           updateUI(with: score)
            
        } catch {
            print("error is \(error)")
        }
        
    }
    
    func updateUI(with score: Int) {
        
        if score > 20 {
            self.sentimentLabel.text = "😀"
        } else if score > 10 {
            self.sentimentLabel.text = "😊"
        } else if score > 0 {
            self.sentimentLabel.text = "😐"
        } else if score > -20 {
            self.sentimentLabel.text = "🙁"
        } else {
            self.sentimentLabel.text = "😡"
        }
        
    }
    
}

