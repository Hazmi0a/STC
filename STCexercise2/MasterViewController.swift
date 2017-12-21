//
//  MasterViewController.swift
//  STCexercise2
//
//  Created by Abdullah Alhazmi on 20/12/2017.
//  Copyright © 2017 Abdullah Alhazmi. All rights reserved.
//

import UIKit
import RealmSwift

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellContent: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
}

class MasterViewController: UITableViewController {
    

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    
    let realm = try! Realm()
    var rowCount = 0
    
    var allArticles: Results<Article>!
    var refresher: UIRefreshControl!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //large navbar title
        largeNavbarTitle()
        // table views need to be told to let Auto Layout drive the height of each cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30

        allArticles = realm.objects(Article.self)
        self.rowCount = allArticles.count
        jsonToArticles()
        
        // Pull to refresh

        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Refreshing")
        
        refresher.addTarget(self, action: #selector(MasterViewController.jsonToArticles), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refresher)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let object = allArticles[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailArticle = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleTableViewCell
        
        
        let object = allArticles[indexPath.row]
        cell.cellTitle?.text = object.title
        cell.cellContent?.text = object.content
        
        cell.cellImage?.image = UIImage(named: "placeholder")
        
        // if the article has no image
        if (object.image != ""){
            //this is an a func in an UIImageView extention
            cell.cellImage?.downloadedFrom(link: object.image)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    // my func
    
    func largeNavbarTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    @objc func jsonToArticles() {
        // the linked json
        let url = URL(string: "https://no89n3nc7b.execute-api.ap-southeast-1.amazonaws.com/staging/exercise")!
        
        //
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                
                print(error!)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        // extracting json
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //change the navbar title
                        
                        if let title = jsonResult["title"] as? String {
                            print(title)
                            self.navigationController?.navigationItem.title = title
                        }
            
                        if let articles = jsonResult["articles"] as? NSArray {
                            do {
                                
                                //clearing realm, because the data is the same from the server, dont need to check for duplicates and append the rest
                                
                                let realm = try! Realm()
                                let allArticles = realm.objects(Article.self)
                                
                                if allArticles.count > 0 {
                                    try realm.write {
                                        realm.deleteAll()
                                    }
                                }
                                
                            } catch {
                                
                                print("Delete failed")
                                
                            }
                            // looping through json
                            for article in articles as [AnyObject] {
                                
                                if ("\(article["title"])" != " " || "\(article["content"])" != " "){
                                    let newArticle = Article(value: ["title" : "\(article["title"]!!)",
                                        "date": "\(article["date"]!!)",
                                        "content": "\(article["content"]!!)",
                                        "image": "\(article["image_url"]!!)"
                                        ])
                                    
                                    // Saving Articles to realm
                                    do {
                                        let realm = try! Realm()
                                        try realm.write {
                                            realm.add(newArticle)
                                        }
                                    } catch {
                                        // to handle the error appropriately, for development purposes only
                                        let nserror = error as NSError
                                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                    }
                                }
                                
                            }
//                            let realm = try! Realm()
//                            let allArticles = realm.objects(Article.self)
//                            print(allArticles)
                            DispatchQueue.main.async{
                                self.tableView.reloadData()
                            }
                            self.refresher.endRefreshing()
                            
                        }
                        
                    } catch {
                        
                        print("JSON Processing Failed")
                        
                    }
                    
                }
                
            }
            
            
        }
        
        task.resume()
        
        
    }


}

