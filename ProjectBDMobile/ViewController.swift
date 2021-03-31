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
    
        tasks = fetchItems()
    }
    
    private func fetchItems(searchQuery: String? = nil) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "dateCrea", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor2]

        do {
            return try self.managedContext.fetch(fetchRequest)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsViewController,
           segue.identifier == "detailsTask" {
            destination.task = tasks[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }
}
