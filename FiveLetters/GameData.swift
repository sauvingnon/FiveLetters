//
//  GameData.swift
//  FiveLetters
//
//  Created by Гриша Шкробов on 02.10.2024.
//

struct GameData: Codable{
    let currentPlayerInput: String
    let currentWordIndex: Int
    let currentLetterIndex: Int
    let tryCounter: Int
    let currentWord: String
    let guessedWords: [String]
}
