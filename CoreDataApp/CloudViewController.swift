//
//  CloudViewController.swift
//  CoreDataApp
//
//  Created by Samuel Brasileiro on 16/08/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class TweetCloud{
    let text: String
    let user: String
    init(user: String, text: String) {
        self.text = text
        self.user = user
    }
}

class CloudViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 105
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as? TweetTableViewCell else{
            fatalError("Can't dequeue tweet table view cell")
        }
        let tweet = tweets[indexPath.row]
        print(tweet)
        cell.tweetText.text = tweet.text!
        cell.userName.text = tweet.tweeter?.name
        
        
        return cell
    }
    
    var tweets: [Tweet] = []
    var users: [TwitterUser] = []
    let privateDatabase = CKContainer(identifier: "iCloud.samuel.CoreDataApp").privateCloudDatabase
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var getButton: UIButton!
    
    @IBOutlet var clearButton: UIButton!
    
    @IBOutlet var newUserButton: UIButton!
    
    @IBOutlet var tweetsTableView: UITableView!
    
    @IBAction func button(_ sender: UIButton) {
        if sender == sendButton{
            getTweeterNameAlert()
            
        }
        else if sender == newUserButton{
            getNewTweeterAlert()
        
        }
        
        else if sender == getButton{
            //vamos fazer o request dos TwitterUsers existentes no banco
            
        }
        else if sender == clearButton{
            
        }
    }
    
    func getNewTweeterAlert(){
        var tweeterName = "Default"
        //uma view de alerta para escrever o nome do novo user
        let alert = UIAlertController(title: "Usuário", message: "Digite o novo nome do usuário:", preferredStyle: .alert)
        //add o text field
        alert.addTextField { (textField) in
            textField.placeholder = "Escreva aqui"
            
        }
        //add botao de cancelar
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        //add botao de salvar
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            //chega aqui se o botao de salvar foi apertado
            let textField = alert?.textFields![0]
            tweeterName = textField!.text ?? "Default"
            
            self.checkExistenceUser(tweeterName: tweeterName)
            
        })
        
        //no começo o botao de salvar eh desabilitado
        saveAction.isEnabled = false
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields![0], queue: OperationQueue.main) { (notification) in
            //o botao so se habilita quando o textfield n eh vazio
            saveAction.isEnabled = alert.textFields![0].text != ""
        }
        
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
        
    }
    
    func checkExistenceUser(tweeterName: String){
        
        //vou fazer um request dos users existentes para checar se ja existe um com nome igual
        
        
        let predicate = NSPredicate(format: "name == %@", tweeterName)
        
        let query = CKQuery(recordType: "TweetUser", predicate: predicate)
        
        
        let operation = CKQueryOperation(query: query)
        
        var count = 0
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                count += 1
                print(record["name"] ?? "iih")
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            
            DispatchQueue.main.async {
                print("here")
                
                if count > 0{
                    let alert = UIAlertController(title: "Atenção", message: "Já existe um usuário com este nome na nuvem.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                            //chamar essa funcao de novo
                            self.getNewTweeterAlert()
                        }))
                    self.present(alert,animated: true, completion: nil)
                }
                else{
                    let record = CKRecord(recordType: "TweetUser")
                    record.setValue(tweeterName, forKey: "name")
                    
                    self.privateDatabase.save(record) { (savedRecord, error) in
                        
                        DispatchQueue.main.async {
                            if error == nil {
                                let alert = UIAlertController(title: "Ótimo! ;)", message: "O novo usuário, \(tweeterName), foi criado com sucesso!", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert,animated: true, completion: nil)
                            } else {
                                let alert = UIAlertController(title: "Eita", message: "Deu erro em alguma coisa...\n" + error!.localizedDescription, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert,animated: true, completion: nil)
                            }
                        }
                        
                    }
                    
                    
                }
                
            }
            
        }
        
        privateDatabase.add(operation)
        
    }
    
    
    //MARK:- Fazer tweet
    
    func getTweeterNameAlert(){
        var tweeterName = "Default"
        //criar alerta com textview pra pegar o nome
        //aqui é praticamente igual ao getNewTwitterAlert
        let alert = UIAlertController(title: "Usuário", message: "Digite o nome do usuário que postará o tweet:", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Escreva aqui"
            
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields![0]
            tweeterName = textField!.text ?? "Default"
            //fazer o alerta para pegar o texto
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
        //fazer um request dos usuarios
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", tweeterName)
        let requestedUsers = try? context.fetch(request)
        
        if requestedUsers!.count == 0{
            //se nao existir usuario c esse nome, tentar de novo
            let alert = UIAlertController(title: "Atenção", message: "Não existe usuário com esse nome.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(_) in
                self.getTweeterNameAlert()
            }))
            self.present(alert,animated: true, completion: nil)
        }
        else{
            //se existir, continuamos e criamos outro alerta com um espaço de texto para digitar o tweet
            let alert = UIAlertController(title: "Tweet", message: "Escreva o tweet:\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            
            let textView = UITextView(frame: CGRect(x: 10, y: 80, width: 250, height: 100))
            textView.layer.cornerRadius = 5
            textView.layer.masksToBounds = true
            
            textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
            
            let saveAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                //se clicar no botao de salvar, cadastramos o tweet no banco, e ligamos ao relacionamento de tweet-usuario
                let text = textView.text!
                let user = requestedUsers![0]
                let tweet = Tweet(context: context)
                
                tweet.text = text
                tweet.created = Date()
                tweet.tweeter = user
                
                user.addToTweets(tweet)
                
                do{
                    //salvamos o contexto
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
