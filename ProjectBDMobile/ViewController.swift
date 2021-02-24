//
//  ViewController.swift
//  ProjectBDMobile
//
//  Created by lpiem on 24/02/2021.
//
import CoreData
import UIKit

class ViewController: UITableViewController {

    //récupération du contexte
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}

