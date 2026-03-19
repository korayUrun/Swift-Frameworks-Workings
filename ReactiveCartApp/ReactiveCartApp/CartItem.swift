//
//  CartItem.swift
//  ReactiveCartApp
//
//  Created by Koray Urun on 19.03.2026.
//

import Foundation

struct CartItem : Equatable, Identifiable {
    let id = UUID()
    let name : String
    let price : Double
    var quantity : Int
    
    var lineTotal : Double {Double(quantity) * price}
    
    init(name: String, price: Double, quantity: Int = 1) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
    
}
