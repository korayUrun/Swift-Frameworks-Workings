//
//  CartViewModel.swift
//  ReactiveCartApp
//
//  Created by Koray Urun on 19.03.2026.
//

import Combine
import Foundation

@MainActor
final class CartViewModel : ObservableObject {
    
    // inputs
    @Published var items: [CartItem] = [
        CartItem(name: "iPhone 15",   price: 45000),
        CartItem(name: "AirPods Pro", price: 8500),
        CartItem(name: "MagSafe",     price: 2200),
    ]
    
    @Published var taxRate: Double = 18
    @Published var discountPercent: Double = 0
    
    
    // Outputs - view okuyabilir ancak değiştiremez
    @Published private(set) var subtotal: String = "₺0"
    @Published private(set) var discountAmount: String = "₺0"
    @Published private(set) var taxAmount: String = "₺0"
    @Published private(set) var total: String = "₺0"
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){ setupPipelines() }
    
    private func setupPipelines(){
        
        Publishers.CombineLatest3($items, $taxRate, $discountPercent)
            .map{ items, tax , disc in
                let sub = items.reduce(0) {$0 + $1.lineTotal}
                let discAmt = sub * disc / 100
                let taxAmt = (sub - discAmt) * tax / 100
                let total = sub - discAmt + taxAmt
                return (sub, discAmt, taxAmt, total)
            }
            .sink { [weak self] sub, disc, tax, total in
                let f = { "\(String(format: "%.0f", $0))₺" }
                self?.subtotal = f(sub)
                self?.discountAmount = f(disc)
                self?.taxAmount = f(tax)
                self?.total = f(total)
            }
            .store(in : &cancellables)
 
    }
    
    
    func updateQuantity(id: UUID, quantity: Int){
        guard let idx = items.firstIndex(where : {$0.id == id}) else {return}
        items[idx].quantity = max(1,quantity)
    } // quantity itemi değiştirir ve bu değişim pipeline'ı tetikleyerek tüm outputları günceller.
    // struct kullanınca eleman değişikliği = diziye yeni bir şey yazılması. @Published diziye yazılınca tetiklenir.
    // memberwise copy
    
    
    
    
}

