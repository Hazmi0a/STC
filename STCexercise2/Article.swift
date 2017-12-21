//
//  AllRealmObjects.swift
//  STCexercise2
//
//  Created by Abdullah Alhazmi on 20/12/2017.
//  Copyright © 2017 Abdullah Alhazmi. All rights reserved.
//

import Foundation
import RealmSwift

class Article: Object {
    
    @objc dynamic var title = ""
    @objc dynamic var date = ""
    @objc dynamic var content = ""
    @objc dynamic var image = ""
    
}
