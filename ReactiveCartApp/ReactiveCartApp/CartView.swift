//
//  ContentView.swift
//  ReactiveCartApp
//
//  Created by Koray Urun on 19.03.2026.
//

import SwiftUI

struct CartView: View {
    
    @StateObject private var vm = CartViewModel()
    
    
    var body: some View {
    
        NavigationStack{
            
            List{
                // Ürünler
                Section("Ürünler"){
                    ForEach(vm.items){item in
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.headline)
                                Text("\(Int(item.price))₺ × \(item.quantity)")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Stepper("",value: Binding(
                                get : {item.quantity},
                                set : {vm.updateQuantity(id: item.id, quantity: $0)}
                            ), in : 1...99)
                        }
                    }
                }
                
                // Kontroller
                Section("Ayarlar"){
                    HStack{
                        Text("KDV %\(Int(vm.taxRate))")
                        Slider(value: $vm.taxRate, in: 0...30, step: 1)
                    }
                    
                    HStack {
                        Text("İndirim %\(Int(vm.discountPercent))")
                        Slider(value: $vm.discountPercent, in: 0...50, step: 5)
                    }
                    
                }
                
                // Özet
                Section("Özet") {
                        SummaryRow(label: "Ara toplam",  value: vm.subtotal)
                        SummaryRow(label: "İndirim",     value: vm.discountAmount)
                        SummaryRow(label: "KDV",         value: vm.taxAmount)
                        SummaryRow(label: "TOPLAM",     value: vm.total)
                }
                
                
                
            }
            .navigationTitle("Sepet")
            
            
            
        }
        
   
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CartView()
}
