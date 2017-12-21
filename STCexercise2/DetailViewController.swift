//
//  DetailViewController.swift
//  STCexercise2
//
//  Created by Abdullah Alhazmi on 20/12/2017.
//  Copyright © 2017 Abdullah Alhazmi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailArticleTitle: UILabel!

    @IBOutlet weak var detailArticleContent: UITextView!
    @IBOutlet weak var detailArticleImage: UIImageView!
    
    func configureView() {
        // Update the user interface for the detail item.
        
        //no large title on detiles screen
        navigationItem.largeTitleDisplayMode = .never
        
        // setting article information from pervious screen
        if let detailArticle = detailArticle {
            if let title = detailArticleTitle {
                title.text = detailArticle.title
            }
            if let content = detailArticleContent {
                content.text = detailArticle.content
            }
            if let image = detailArticleImage {
                image.downloadedFrom(link: detailArticle.image)
                image.contentMode = .scaleToFill
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailArticle: AnyObject? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

