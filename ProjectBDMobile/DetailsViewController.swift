//
//  DetailsViewController.swift
//  ProjectBDMobile
//
//  Created by lpiem on 03/03/2021.
//
import CoreData
import UIKit

class DetailsViewController : UIViewController {
    var task : Task?
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelDatecrea: UILabel!
    @IBOutlet weak var labelDateMaj: UILabel!
    @IBOutlet weak var radioButton: UISegmentedControl!
    @IBOutlet weak var labelCategorie: UILabel!
    
    //récupération du contexte
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = task{
            labelTitle.text = task.title
            labelDatecrea.text = DateFormatter.localizedString(from: task.dateCrea!, dateStyle: .medium, timeStyle: .short)
            labelDescription.text = task.description_
            if let dateMaj = task.dateMaj {
                labelDateMaj.text = DateFormatter.localizedString(from: dateMaj, dateStyle: .medium, timeStyle: .short)
            }else{
                labelDateMaj.text = "aucune mise à jour effectuée"
            }
            if(task.checked == true){
                radioButton.selectedSegmentIndex = 0
            }else{
                radioButton.selectedSegmentIndex = 1
            }
            labelCategorie.text = task.categories?.nom
        }
    }
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func onValueChanged(_ sender: Any) {
        task!.checked.toggle()
        saveContext()
    }
}
