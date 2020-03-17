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
            
            getTweeterNameAlert()
            
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
    func getTweeterNameAlert(){
        var tweeterName = "Default"
        let alert = UIAlertController(title: "Usuário", message: "Digite o nome do usuário que postará o tweet:", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Escreva aqui"
            
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields![0]
            tweeterName = textField!.text ?? "Default"
            
            self.getTweetAlert(tweeterName: tweeterName)
            
        })
        saveAction.isEnabled = false
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields![0], queue: OperationQueue.main) { (notification) in
            saveAction.isEnabled = alert.textFields![0].text != ""
        }
        
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getTweetAlert(tweeterName: String){

        let context = AppDelegate.viewContext
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", tweeterName)
        let requestedUsers = try? context.fetch(request)
        
        if requestedUsers!.count == 0{
            let alert = UIAlertController(title: "Atenção", message: "Não existe usuário com esse nome.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert,animated: true, completion: nil)
        }
        else{
            
            let alert = UIAlertController(title: "Tweet", message: "Escreva o tweet:\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            
            let textView = UITextView(frame: CGRect(x: 10, y: 80, width: 250, height: 100))
            textView.layer.cornerRadius = 5
            textView.layer.masksToBounds = true
            textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
            let saveAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                let text = textView.text!
                let user = requestedUsers![0]
                let tweet = Tweet(context: context)
                
                tweet.text = text
                tweet.created = Date()
                tweet.tweeter = user
                
                do{
                    try context.save()
                } catch{
                    print(error)
                    fatalError()
                }
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            saveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: textView, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = textView.text != ""
            }
            
            textView.backgroundColor = UIColor.clear
            alert.view.addSubview(textView)

            alert.addAction(saveAction)
            alert.addAction(cancelAction)

            self.present(alert, animated: true, completion: nil)
            
        }

        
        
    }
}

