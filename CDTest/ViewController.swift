//
//  ViewController.swift
//  CDTest
//
//  Created by Jim Baughman on 10/24/16.
//  Copyright © 2016 MWCS. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var itemidtext = "123"
    var nametext = "Jones"
    var amounttext = "53"
    var fetchedStatsArray = [] as NSArray

    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeTranscription()
        getTranscriptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exportButton(_ sender: UIButton) {
        exportDatabase()
    }

    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func storeTranscription() {
        let context = getContext()
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "ItemList", in: context)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        transc.setValue(itemidtext, forKey: "itemID")
        transc.setValue(nametext, forKey: "productname")
        transc.setValue(amounttext, forKey: "amount")
        
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    func getTranscriptions () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try getContext().fetch(fetchRequest)
            fetchedStatsArray = searchResults as NSArray
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(trans.value(forKey: "productname"))")
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func exportDatabase() {
        let exportString = createExportString()
        saveAndExport(exportString: exportString)
    }
    
    func saveAndExport(exportString: String) {
        let exportFilePath = NSTemporaryDirectory() + "itemlist.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        //var fileHandleError: NSError? = nil
        var fileHandle: FileHandle? = nil
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
        } catch {
            print("Error with fileHandle")
        }
        
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            
            fileHandle!.closeFile()
            
            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func createExportString() -> String {
        var itemIDvar: String?
        var productNamevar: String?
        var amountvar: String?
        
        
        var export: String = NSLocalizedString("itemID, productName, Amount \n", comment: "")
        for (index, bidder) in fetchedStatsArray.enumerated() {
            if index <= fetchedStatsArray.count - 1 {
                itemIDvar = (bidder as AnyObject).value(forKey: "itemID") as! String?
                productNamevar = (bidder as AnyObject).value(forKey: "productname") as! String?
                amountvar = (bidder as AnyObject).value(forKey: "amount") as! String?
                
                let itemIDString = itemIDvar
                let procductNameSting = productNamevar
                let amountSting = amountvar
                export += "\(itemIDString!),\(procductNameSting!),\(amountSting!) \n"
            }
        }
        print("This is what the app will export: \(export)")
        return export
    }
    
    
}

