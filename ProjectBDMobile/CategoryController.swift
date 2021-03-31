//
//  CategoryController.swift
//  ProjectBDMobile
//
//  Created by lpiem on 24/02/2021.
//

import Foundation
import CoreData
import UIKit

class CategoryController: UITableViewController {
    
    private var categoryList: [Categorie] = []
    
    //récupération du contexte
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        categoryList = fetchItems()
    }
    
    private func fetchItems(searchQuery: String? = nil) -> [Categorie] {
        let fetchRequest: NSFetchRequest<Categorie> = Categorie.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nom", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try self.managedContext.fetch(fetchRequest)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alertController = UIAlertController(title: "Nouvelle catégorie",
                                                message: "Ajouter une catégorie à la liste",
                                                preferredStyle: .alert)

        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "Nom : "
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

            self.createCategory(name: textFieldTitle.text!)
            self.categoryList = self.fetchItems()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Modification categorie",
                                                message: "Modifier le nom de la catégorie",
                                                preferredStyle: .alert)

        alertController.addTextField { (textFieldTitle) in
            textFieldTitle.placeholder = "Nom : "
        }

        let cancelButton = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)

        let saveButton = UIAlertAction(title: "Modifier",
                                       style: .default) { _ in
            guard let textFieldTitle = alertController.textFields?[0]
            else {
                return
            }

            //self.categoryList(name: textFieldTitle.text!)
            self.categoryList[indexPath.row].nom = textFieldTitle.text
            self.categoryList[indexPath.row].dateMaj = Date()
            self.tableView.reloadData()
        }

        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true)
        
    }
    
    @IBAction func editCategory(_ sender: Any) {
        
    }
    
    private func createCategory(name: String, date: Date = Date()) {
        let category = Categorie(context: managedContext)
        category.nom = name
        category.dateCrea = date

        saveContext()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath)
        let category = categoryList[indexPath.row]
        cell.textLabel?.text = category.nom
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
        let categoryindex = categoryList[index]

        managedContext.delete(categoryindex)
        saveContext()

        categoryList.remove(at: index)

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as? UINavigationController
        let detailsViewcontroller = navigationController?.topViewController
        
        if let detailsViewcontroller = detailsViewcontroller as? DetailsCategorieController,
           segue.identifier == "goToDetailsCategory" {
            detailsViewcontroller.categorie = categoryList[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }
    
    
}
