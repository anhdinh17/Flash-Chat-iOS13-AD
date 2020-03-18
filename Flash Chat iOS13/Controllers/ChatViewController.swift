//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    // create a reference to our database
    let db = Firestore.firestore()
    
    // message array
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set data source of the TableView
        tableView.dataSource = self
        
        title = K.appName
        
        // hide the back button
        navigationItem.hidesBackButton = true
        
        // register .xib file
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    // func to pull up all data saved inside of our database
    func loadMessages(){
        
        // tap into collection and document
        // getDocuments is to retrieve data from documents (codes from Firestore)
        // we changed from getDocuments() to addSnapshotListener so that every time
        // we add something to database,it triggers all the codes inside closure, it will get data from document, reload the TableView
        db.collection(K.FStore.collectionName)
            .order(by:K.FStore.dateField) // sorting data by "data" on database
            .addSnapshotListener { (querySnapshot, error) in
            self.messages = [] // set array to be empty
                        
            if let e = error{
                print("There was error retrieving data from Firestore. \(e)")
            } else{
                if let snapshotDocument = querySnapshot?.documents{
                    
                    // querySnapshot.documents = array of QueryDocumentSnapshot
                    // that contains data read from a document
                    for doc in snapshotDocument{ // each doc is one object of QueryDocumentSnapshot, one doucument in firebase
                        
                        let data = doc.data()
                        // .data() is the a dicitionary that contains "sender" and 'body' of the message, that makes data now a dictionary
                        print(data)
                        print(doc)
                        // get the key-value from the "data" dictionary
                        // castdown to String
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            let newMessage = Message(sender: messageSender, body: messageBody) // create new instance of Message to store sender's email and content of the text
                            self.messages.append(newMessage) // append it to message array
                            
                            // loading data happened inside closure
                            // using DispatchQueue
                            DispatchQueue.main.async {
                                // tap into tableView to trigger Delegate Data Source codes
                                // to reload the cell
                                self.tableView.reloadData()

                                // codes to scroll down to last message:
                                // create indexPath for the "at" parameter
                                let indexPath = IndexPath(row: self.messages.count-1,section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // users hit send button
    @IBAction func sendPressed(_ sender: UIButton) {
        // when users hit send button, we store texts from Text field into messageBody,
        // we also store email of sender if they are signed in into messageSender
        // the Auth.auth().currentUser?.email is from Firestore under iOS/Manage User
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error{
                    print("There was an issue saving data to Firestore, \(e)")
                } else{
                    print("Successfully save data")
                    
                    // cleat text field after hitting send button
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                    
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        // Codes to log out from Firebase
        do {
            try Auth.auth().signOut()
            // back to welcome screen when log out
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError { // catch error if there's any
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

// protocol Delegate for data source that tells how many rows of the tableView
// this one prints out message.
extension ChatViewController: UITableViewDataSource {
    // this func tells how many rows(cells) table view has
    // in this case, it equals to length of message array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count // return number of rows(cells)
    }
    
    // this func is called as many times as the cells that the above func returns
    // and this func decides how to display each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row] // instance of each element object
        
        // set the cell to be like UILabel,UIButton, etg.
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        // as! because "dequeueReusableCell" returns a UITableView, but now we're using MessageCell.xib which inherits from UITableView class so we need to cast it down to MessageCell
        
        // print the content of each cell from message array
        cell.label.text = message.body
        
        // check if the sender of the message equals the current user who is signed in
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true // hide the "you"
            cell.rightImageView.isHidden = false // make sure the "me" is on
            
            // set color for the bubble and text
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        else{ // if the sender is not the current signed in
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
    
}
