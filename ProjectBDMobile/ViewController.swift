//
//  ViewController.swift
//  ProjectBDMobile
//
//  Created by lpiem on 24/02/2021.
//
import CoreData
import UIKit

class ViewController: UITableViewController {

    private var tasks: [Task] = []
    
    //récupération du contexte
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longClick(index:Int)))
        
        tasks = fetchItems()
    }
    

    @objc func longClick(indexPath:Int){
        tasks[indexPath].checked.toggle()
        saveContext()
    }
    
    private func fetchItems(searchQuery: String? = nil) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//        if let searchQuery = searchQuery, !searchQuery.isEmpty {
//            let predicate = NSPredicate(format: "%K contains[cd] %@",
//                                        argumentArray: [#keyPath(Task.title), searchQuery])
//            fetchRequest.predicate = predicate
//        }

        do {
            return try self.managedContext.fetch(fetchRequest)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func addTask(_ sender: Any) {
        let alertController = UIAlertController(title: "Nouvelle tâche",
                                                message: "Ajouter une tâche à la liste",
                                                preferredStyle: .alert)

        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "Votre titre …"
        }
        
        alertController.addTextField { (textFieldDescription) in
            textFieldDescription.placeholder = "Votre description …"
        }

        let cancelButton = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)

        let saveButton = UIAlertAction(title: "Ajouter",
                                       style: .default) { _ in
            guard let textFieldTitle = alertController.textFields?[0],
                  let textFieldDescription = alertController.textFields?[1]
            else {
                return
            }

            self.createTask(title: textFieldTitle.text!, description: textFieldDescription.text!)
            self.tasks = self.fetchItems()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
    }
    
    private func createTask(title: String, description:String, date: Date = Date()) {
        let task = Task(context: managedContext)
        task.title = title
        task.description_ = description
        task.dateCrea = date

        saveContext()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath)
        let task = tasks[indexPath.row]
        cell.accessoryType = task.checked ? .checkmark : .none
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.description_
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }

        let index = indexPath.row
        let task = tasks[index]

        managedContext.delete(task)
        saveContext()

        tasks.remove(at: index)

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        cell.accessoryType = tasks[indexPath.row].checked ? .checkmark : .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? DetailsViewController {
//        let addController = destination.topViewController as! DetailsViewController
        if let destination = segue.destination as? DetailsViewController,
           segue.identifier == "detailsTask" {
            destination.task = tasks[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }
}
