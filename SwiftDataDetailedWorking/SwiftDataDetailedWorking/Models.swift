//
//  Models.swift
//  SwiftDataDetailedWorking
//
//  Created by Koray Urun on 5.02.2026.
//

import Foundation
import SwiftData

@Model
final class Author {
    // @Attribute(.unique): Aynı isimde iki yazar eklenmesini önler (Constraint)
    @Attribute(.unique) var name : String
    
    // @Relationship: Yazar silindiğinde ona ait tüm kitaplar da silinir (Cascade)
    // inverse: Book modelindeki 'author' alanı ile bu alanı birbirine bağlar
    @Relationship(deleteRule : .cascade, inverse: \Book.author)
    var books : [Book] = []
    
    init(name : String){
        self.name = name
    }
}

@Model
final class Book {
    var title : String
    var genre : String
    var pageCount : Int
    var author : Author? // ilişkinin diğer ucu
    
    init(title: String, genre: String, pageCount : Int){
        self.title = title
        self.genre = genre
        self.pageCount = pageCount
    }
}
