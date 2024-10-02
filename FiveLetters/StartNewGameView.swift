//
//  ViewController.swift
//  FiveLetters
//
//  Created by Гриша Шкробов on 01.10.2024.
//

import UIKit

class StartNewGameView: UIViewController {
    
    @IBOutlet weak var continueGameButton: UIButton!
    private var gameData: GameData?

    @IBAction func continueGameButtonTapped(_ sender: UIButton) {
        let gameVC = GameViewController(gameData: gameData)
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let gameData = loadGameDataFromUserDefaults() {
            self.gameData = gameData
            continueGameButton.isHidden = false
        }else
        {
            continueGameButton.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func loadGameDataFromUserDefaults() -> GameData? {
        if let savedGameData = UserDefaults.standard.data(forKey: "savedGameData") {
            let decoder = JSONDecoder()
            if let gameData = try? decoder.decode(GameData.self, from: savedGameData) {
                return gameData
            }
        }
        
        debugPrint("Не удалось загрузить данные!")
        
        return nil
    }
    
    func pushToGame() {
        let gameVC = GameViewController()
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        pushToGame()
    }
    


}

