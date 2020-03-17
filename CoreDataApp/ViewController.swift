//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Samuel Brasileiro on 17/03/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var getButton: UIButton!
    
    @IBOutlet var clearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }

    @IBAction func button(_ sender: UIButton) {
        // to access persistent container context
        let context = AppDelegate.viewContext
        
        if sender == sendButton{
            
            let tweet = Tweet(context: context)
            
            tweet.text = "Eu não aguento mais o Daniel do BBB"
            tweet.created = Date()
//            let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
//            request.predicate = NSPredicate(format: "name == %@", name)
//            do {
//                for user in try context.fetch(request){
//                    print("text = \(user.name)")
//                }
//            } catch{
//                
//            }
            let user = TwitterUser(context: tweet.managedObjectContext!)
            user.name = "Samuel"
            user.addToTweets(tweet)
            tweet.tweeter = user
            
            do{
                try context.save()
            } catch{
                print(error)
                fatalError()
            }
        }
        if sender == getButton{
            let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let yesterday = NSDate(timeIntervalSinceNow: -24*60*60)
            //request.predicate = NSPredicate(format: "created > %@", yesterday)
            do {
                for tweet in try context.fetch(request){
                    print("text = \(tweet.name)")
                }
            } catch{
                
            }
            
            
            
        }
        if sender == clearButton{
            let request1: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            do {
                for user in try context.fetch(request1){
                    context.delete(user)
                }
            } catch{
                
            }
            let request2: NSFetchRequest<Tweet> = Tweet.fetchRequest()
            do {
                for tweet in try context.fetch(request2){
                    context.delete(tweet)
                }
            } catch{
                
            }
        }
    }
    
}

