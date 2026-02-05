//
//  ContView.swift
//  SwiftDataDetailedWorking
//
//  Created by Koray Urun on 5.02.2026.
//

import SwiftUI
import SwiftData

struct ContentView : View {
    @Environment(\.modelContext) private var modelContext
    
    // Verileri isme göre alfabetik sıralıyoruz
    @Query(sort: \Book.title) private var allBooks : [Book]
    
    @State private var isShowingAddSheet = false
    @State private var bookToEdit : Book? // Güncelleme için seçilen kitap
    
    var body : some View {
        NavigationStack{
            List{
                if allBooks.isEmpty {
                    ContentUnavailableView("Kitap Kolekysiyonu Boş",systemImage: "books.vertical",
                    description: Text("Yeni bir kitap eklemek için sağ üstteki + butonuna tıklayın."))
                } else {
                    ForEach(allBooks) { book in
                        BookRowView(book : book)
                        // HIG : Swipe Actions
                            .swipeActions(edge: .trailing, allowsFullSwipe: true){
                                Button(role : .destructive){
                                    modelContext.delete(book)
                                } label : {
                                    Label("Sil", systemImage : "trash")
                                }
                            }
                        
                            .swipeActions(edge : .leading) {
                                Button{
                                    bookToEdit = book
                                } label : {
                                    Label("Düzenle", systemImage : "pencil")
                                }
                                .tint(.orange)
                            }
                        // HIG : Context Menu : uzun basınca çıkan menü
                            .contextMenu {
                                Button {
                                    bookToEdit = book
                                } label : {
                                    Label("Kitabı düzenle", systemImage : "pencil")
                                }
                                
                                Button(role : .destructive){
                                    modelContext.delete(book)
                                } label : {
                                    Label("Kitabı Sil", systemImage : "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kütüphanem")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action : {isShowingAddSheet = true}) {
                        Image(systemName : "plus.circle.fill")
                            .font(.title3)// daha belirgin HIG butonu
                    }
                }
            }
            
            // Sayfa ekleme sheet'i
            .sheet(isPresented : $isShowingAddSheet){
                AddBookSheet()
            }
            // Düzenleme sheet'i (bookToEdit dolduğunde tetiklenir)
            .sheet(item: $bookToEdit){ book in
                AddBookSheet(bookToEdit: book)
            }
  
        }
 
    }
     
}

struct BookRowView : View {
    let book : Book
    var body : some View {
        VStack(alignment: .leading, spacing : 4){
            Text(book.title)
                .font(.headline)
            HStack{
                Text(book.author?.name ?? "Bilinmiyor")
                Spacer()
                Text("\(book.pageCount) sf")
                    .padding(.horizontal,8)
                    .padding(.vertical,2)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical,4)
    }
}


struct AddBookSheet : View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Eğer kitap gelirse düzenleme moduna geçer
    var bookToEdit : Book?
    
    @State private var title = ""
    @State private var authorName = ""
    @State private var genre = "Kurgu"
    @State private var pageCount = ""
    
    var isEditing : Bool {bookToEdit != nil}
    
    
    var body : some View {
        NavigationStack{
            Form {
                Section {
                    TextField("Kitap Adı", text: $title)
                    TextField("Yazar Adı", text: $authorName)
                } header:{
                    Text("Temel Bilgiler")
                }
                
                Section{
                    TextField("Sayfa Sayısı", text : $pageCount)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Kitap Detayları")
                }
            }
            .navigationTitle(isEditing ? "Kitabı Düzenle" : "Yeni Kitap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") {dismiss()}
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(isEditing ? "Güncelle" : "Ekle"){
                        saveAction()
                        dismiss()
                    }
                    .bold()
                    .disabled(title.isEmpty || authorName.isEmpty)
                }
            }
            .onAppear {
                // eger duzenleme modundaysak mevcut verileri yuklee
                if let book = bookToEdit {
                    title = book.title
                    authorName = book.author?.name ?? ""
                    pageCount = String(book.pageCount)
                    genre = book.genre
                }
            }
        }
    }
    
    private func saveAction() {
        if let book = bookToEdit {
            // GÜNCELLEME (Update)
            book.title = title
            book.genre = genre
            book.pageCount = Int(pageCount) ?? 0
            
            // Yazar ismi değişmişse yeni yazar oluştur veya mevcutu bul
            if book.author?.name != authorName {
                let authorPredicate = #Predicate<Author> { $0.name == authorName }
                let descriptor = FetchDescriptor<Author>(predicate: authorPredicate)
                let existingAuthors = (try? modelContext.fetch(descriptor)) ?? []
                
                if let foundAuthor = existingAuthors.first {
                    book.author = foundAuthor
                } else {
                    let newAuthor = Author(name: authorName)
                    modelContext.insert(newAuthor)
                    book.author = newAuthor
                }
            }
            
            // ÖNEMLİ: Manuel Save (Bazen Autosave gecikebilir)
            try? modelContext.save()
            
        } else {
            // YENİ EKLEME (Create)
            let newAuthor = Author(name: authorName)
            let newBook = Book(title: title, genre: genre, pageCount: Int(pageCount) ?? 0)
            newBook.author = newAuthor
            
            modelContext.insert(newBook)
        }
    }
    
    
}












#Preview {
    ContentView()
    // Bu satır, önizleme için geçici (bellekte) bir veritabanı oluşturur.
    // inMemory: true sayesinde simülatördeki gerçek verilerin karışmaz.
        .modelContainer(for : [Author.self,Book.self], inMemory: true)
}
