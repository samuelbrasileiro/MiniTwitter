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
    
    @IBOutlet var newUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }

    @IBAction func button(_ sender: UIButton) {
        // to access persistent container context
        let context = AppDelegate.viewContext
        
        if sender == sendButton{
            
            getTweeterNameAlert()
            
        }
        else if sender == newUserButton{
            getNewTweeterAlert()
        }
        
        else if sender == getButton{
            //vamos fazer o request dos TwitterUsers existentes no banco
            let userRequest: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            let tweetRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
            
            do {
                for user in try context.fetch(userRequest){
                    print("Name: \(user.name!)")
                    print("Tweets:")
                    var count = 0
                    
                    //imprimir os tweets existentes do tuiteiro
                    let order = NSSortDescriptor(key: "created", ascending: true)
                    user.tweets?.sortedArray(using: [order])
                    for tweet in user.tweets ?? [] {
                        let tweet = tweet as? Tweet
                        count += 1
                        print("\tTweet \(count):\n\t\t\(tweet!.text!)")
                    }
                }
            } catch{
                print(error)
                fatalError()
            }
            do {
                for tweet in try context.fetch(tweetRequest){
                    print("Text: \(tweet.text!)")
                    print("\tCreator: \((tweet.tweeter?.name)!)")
                    
                }
            } catch{
                print(error)
                fatalError()
            }
            
            
            
            
        }
        else if sender == clearButton{
            //vamos deletar todos os usuarios e todos os tweets
            let request1: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            do {
                for user in try context.fetch(request1){
                    context.delete(user)
                }
            } catch{
            
            }
            //OBS EU DETERMINEI NO ARQUIVO XCDATAMODELD A DELECAO DOS USUARIOS COMO CASCADE, OU SEJA DELETA TODOS OS TWEETS QUANDO SEU USUARIO É DELETADO, OU SEJA ESSA PARTE DE BAIXO É INUTIL
//            let request2: NSFetchRequest<Tweet> = Tweet.fetchRequest()
//            do {
//                for tweet in try context.fetch(request2){
//                    context.delete(tweet)
//                }
//            } catch{
//                
//            }
        }
    }
    
    
    //MARK:- Adicionar novo tweeter
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
        let context = AppDelegate.viewContext
        //vou fazer um request dos users existentes para checar se ja existe um com nome igual
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        
        request.predicate = NSPredicate(format: "name == %@", tweeterName)
        let requestedUsers = try? context.fetch(request)
        if requestedUsers!.count > 0{
            //se ja tem um user com o mesmo nome, mando um alerta para cancelar ou botar outro nome
            let alert = UIAlertController(title: "Atenção", message: "Já existe um usuário com este nome.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                //chamar essa funcao de novo
                self.getNewTweeterAlert()
            }))
            self.present(alert,animated: true, completion: nil)
        }
        else{
            //se nao tiver um user c esse nome, crio um
            let user = TwitterUser(context: context)
            user.name = tweeterName
            do{
                //isso aqui eh pra salvar o contexto
                try context.save()
            } catch{
                print(error)
                fatalError()
            }
            let alert = UIAlertController(title: "Ótimo! ;)", message: "O novo usuário, \(tweeterName), foi criado com sucesso!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert,animated: true, completion: nil)
        }
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

