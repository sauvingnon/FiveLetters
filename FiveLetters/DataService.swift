//
//  DataService.swift
//  FiveLetters
//
//  Created by Гриша Шкробов on 02.10.2024.
//

import Foundation

class DataService{
    
    public static let shared = DataService()
    
    private init() {
        loadWords()
    }
    
    private var words: [String] = []
    
    private func loadWords(){
        if let url = Bundle.main.url(forResource: "words", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(WordsStruct.self, from: data)
                words = jsonData.words
            } catch {
                print("error:\(error)")
                print("Загрузка json структуры stop не удалась!")
            }
        }
    }
    
    public func getRandomWordUppercased() -> String {
        let word = words[Int.random(in: 0..<words.count-1)].uppercased()
        debugPrint(word)
        return word
    }
    
}

struct WordsStruct: Codable {
    let words: [String]
}
