//
//  DetailsCategorieController.swift
//  ProjectBDMobile
//
//  Created by lpiem on 31/03/2021.
//

import Foundation
import CoreData
import UIKit

class DetailsCategorieController: UITableViewController {
    let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
    var categorie:Categorie!
    var detailsTaskListByCategorie: [Task]? = []
    
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailsTaskListByCategorie = fetchItems()
    }
    
    private func fetchItems(searchQuery: String? = nil) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "categories == %@",categorie)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let result = try self.managedContext.fetch(fetchRequest)
            return result
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsTaskListByCategorie?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskByCategorie", for: indexPath)
        let taskByCategorie = detailsTaskListByCategorie?[indexPath.row]
        cell.textLabel?.text = taskByCategorie?.title
        cell.detailTextLabel?.text = taskByCategorie?.description_
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
        let categoryindex = detailsTaskListByCategorie?[index] ?? nil
        if(categoryindex != nil){
            managedContext.delete(categoryindex!)
        }
        saveContext()

        detailsTaskListByCategorie?.remove(at: index)

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    @IBAction func addTaskInCategory(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Ajout d'une tâche à la catégorie",
                                                message: "ajoutez votre tâche",
                                                preferredStyle: .alert)

        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "title : "
        }

        let cancelButton = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)

        let saveButton = UIAlertAction(title: "Ajouter",
                                       style: .default) { _ in
            guard let textFieldTitle = alertController.textFields?[0]
            else {
                return
            }
            var values:[Task] = []
            let fetchRequest2: NSFetchRequest<Task> = Task.fetchRequest()
            do {
                values = try self.managedContext.fetch(fetchRequest2)
            } catch {
                fatalError(error.localizedDescription)
            }
            if(self.detailsTaskListByCategorie != nil){
                for item in self.detailsTaskListByCategorie!{
                    if(textFieldTitle.text! != item.title){
                        for item2 in values{
                            if textFieldTitle.text! == item2.title{
                                item2.categories = self.categorie
                                self.detailsTaskListByCategorie!.append(item2)
                            }
                        }
                    }
                }
            }else{
                for item2 in values{
                    if textFieldTitle.text! == item2.title{
                        item2.categories = self.categorie
                        self.detailsTaskListByCategorie!.append(item2)
                    }
                }
            }
            
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
        task.categories = self.categorie
        saveContext()
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
            self.detailsTaskListByCategorie = self.fetchItems()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsViewController,
           segue.identifier == "detailsTaskbyCategory" {
            destination.task = detailsTaskListByCategorie?[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Modification de la tâche",
                                                message: "Modifier le nom de la catégorie",
                                                preferredStyle: .alert)

        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "Titre : "
        }
        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "Description : "
        }

        let cancelButton = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)

        let saveButton = UIAlertAction(title: "Modifier",
                                       style: .default) { _ in
            guard let textFieldTitle = alertController.textFields?[0],
                  let textFieldDescription = alertController.textFields?[1]
            else {
                return
            }

            self.detailsTaskListByCategorie?[indexPath.row].title = textFieldTitle.text
            self.detailsTaskListByCategorie?[indexPath.row].description_ = textFieldDescription.text
            self.detailsTaskListByCategorie?[indexPath.row].dateMaj = Date()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
    }
}
