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
    var message: [Message] = []
    
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
            self.message = [] // set array to be empty
                        
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
                            self.message.append(newMessage) // append it to message array
                            
                            // loading data happened inside closure
                            // using DispatchQueue
                            DispatchQueue.main.async {
                                // tap into tableView to trigger Delegate Data Source codes
                                // to reload the cell
                                self.tableView.reloadData()
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
    // this func tells how many rows table view has
    // in this case, it equals to length of message array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count // return number of rows
    }
    
    // this func returns a reusable cell for each row of the table view
    // indexPath.row is the position of each row starting from 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        // as! because "dequeueReusableCell" returns a UITableView, but now we're using MessageCell.xib which inherits from UITableView class so we need to cast it down to MessageCell
        
        // print the content of each cell from message array
        cell.label.text = message[indexPath.row].body
        
        return cell
    }
    
    
}
