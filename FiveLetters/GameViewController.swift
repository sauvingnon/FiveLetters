//
//  Untitled.swift
//  FiveLetters
//
//  Created by Гриша Шкробов on 01.10.2024.
//
import UIKit
import Foundation

class GameViewController: UIViewController{
    
    // Кнопка проверки слова
    private var buttonCheck: UIButton?
    // Кнопка удаления слова
    private var buttonErase: UIButton?
    // Игровое поле
    private var gridView: UIView?
    // Клавиатура
    private var keyboardView: UIView?
    // Массив для кнопок (двумерный)
    private var buttonArray: [[UIButton]] = []
    // Индекс слова, с которым взаимодействует игрок
    private var currentWordIndex = 0
    // Индекс буквы, с которой взаимодействует игрок
    private var currentLetterIndex = 0
    // Текущее слово
    private var currentWord = DataService.shared.getRandomWordUppercased()
    // Текущее кол-во попыток для слова
    private var tryCounter = 6
    // Список отгаданных слов
    private var guessedWords: [String] = []
    
    private var gameData: GameData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        setupGrid()
        setupKeyboard()
        setupObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveGameData()
    }
    
    private func setupObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(saveGameData), name: Notification.Name("needSaveGameData"), object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let gameData {
            self.guessedWords = gameData.guessedWords
            self.tryCounter = gameData.tryCounter
            self.currentWord = gameData.currentWord
            self.currentWordIndex = gameData.currentWordIndex
            self.currentLetterIndex = gameData.currentLetterIndex
            
            // Отобразить уже отгаданные слова
            for word in guessedWords {
                let indexWord = guessedWords.firstIndex(of: word) ?? 0
                let letterArray = Array(word)
                for (indexLetter, letter) in letterArray.enumerated() {
                    let button = buttonArray[indexWord][indexLetter]
                    button.setTitle(String(letter), for: .normal)
                    button.setBackgroundImage(UIImage(named: "green_rectangle"), for: .normal)
                }
            }
            
            // Отобразить прошлый ввод пользователя
            var index = 0
            for letter in gameData.currentPlayerInput{
                if(letter.isLetter){
                    let button = buttonArray[currentWordIndex][index]
                    button.setTitle(String(letter), for: .normal)
                    index += 1
                }
            }
            
            
            if(index == 5){
                buttonCheck?.setBackgroundImage(UIImage(named: "check_button_active"), for: .normal)
            }
            
            if(index > 0){
                buttonErase?.setBackgroundImage(UIImage(named:"erase_button_active"), for: .normal)
            }
            
//            checkGameRules()
        }
        
    }
    
    // Инициализатор
    init(gameData: GameData? = nil) {
        self.gameData = gameData
        super.init(nibName: nil, bundle: nil) // Вызываем инициализатор суперкласса
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func saveGameDataToUserDefaults(gameData: GameData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(gameData) {
            UserDefaults.standard.set(encoded, forKey: "savedGameData")
        }else{
            debugPrint("Преобразование в JSON не удалось!")
        }
    }
    
    // Сохранение данных игры
    @objc
    public func saveGameData(){
        
        if(guessedWords.count < 1 || guessedWords.count > 5){
            UserDefaults.standard.removeObject(forKey: "savedGameData")
            return
        }
        
        // Текущий ввод пользователя
        let playerWord: String = {
            var result = ""
            
            buttonArray[currentWordIndex].forEach { button in
                result += button.titleLabel?.text ?? " "
            }
            
            return result
        }()
        
        let gameData = GameData(currentPlayerInput: playerWord, currentWordIndex: currentWordIndex, currentLetterIndex: currentLetterIndex, tryCounter: tryCounter, currentWord: currentWord, guessedWords: guessedWords)
        
        debugPrint("Текущий ввод - \(playerWord)")
        debugPrint("Индекс буквы - \(currentLetterIndex)")
        
        saveGameDataToUserDefaults(gameData: gameData)
        
        debugPrint("Игра сохранена")
        
    }
    
    // Расчет ширины
    private func calculateTotalWidth(for row: [String], buttonSize: CGFloat, spacing: CGFloat) -> CGFloat {
        let columns = row.count
        return CGFloat(columns) * buttonSize + CGFloat(columns - 1) * spacing
    }
    
    // Добавление клавиатуры
    private func setupKeyboard(){
        // Двумерный массив символов клавиатуры
        let keyboardArray: [[String]] = [["Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х", "Ъ"],
                                       ["Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э"],
                                         ["Я", "Ч", "С", "М", "И", "Т", "Ь", "Б", "Ю"]]
        
        // Размеры ячеек и отступы
        let buttonWidth: CGFloat = 25
        let buttonHeight: CGFloat = 40
        let xSpacing: CGFloat = 5
        let ySpacing: CGFloat = 15
        
        var rowCounter: CGFloat = 0
        
        let keyboardView = UIView()
        
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        self.keyboardView = keyboardView
        
        let totalHeight = CGFloat(keyboardArray.count) * buttonHeight + CGFloat(keyboardArray.count - 1) * ySpacing
        
        NSLayoutConstraint.activate([
            
            keyboardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keyboardView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            keyboardView.topAnchor.constraint(greaterThanOrEqualTo: gridView!.bottomAnchor, constant: 50),
            keyboardView.widthAnchor.constraint(equalToConstant: view.frame.width),
            keyboardView.heightAnchor.constraint(equalToConstant: totalHeight)
            
        ])
        
        for row in keyboardArray {
            
            // Вычисляем общую ширину сетки
            let totalWidth = calculateTotalWidth(for: row, buttonSize: CGFloat(buttonWidth), spacing: CGFloat(xSpacing))
            // Центрируем сетку по горизонтали
            let startX = (view.frame.width - totalWidth) / 2
            
            var columnCounter = 0
            
            for buttonText in row {
                let button = UIButton(type: .system)
                button.setTitle(buttonText, for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
                button.setBackgroundImage(UIImage(named: "letter_empty"), for: .normal)
                button.contentMode = .scaleAspectFit
                
                // Устанавливаем размеры и положение кнопки с учетом отступов
                let xPosition = startX + CGFloat(columnCounter) * CGFloat((buttonWidth + xSpacing))
                let yPosition = ((buttonHeight + ySpacing) * rowCounter)
                button.frame = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
                button.addTarget(self, action: #selector(keyboardButtonTapped(sender:)), for: .touchUpInside)
                keyboardView.addSubview(button)
                
                // Создание двух крайних кнопок на клавиатуре - удаление и ввод
                if(rowCounter == 2){
                    let checkButtonHeight = 40.0
                    let checkButtonWidth = 38.0
                    
                    let buttonCheck = UIButton(type: .system)
                    buttonCheck.setBackgroundImage(UIImage(named: "check_button_unactive"), for: .normal)
                    buttonCheck.contentMode = .scaleToFill
                    
                    var xPosition = startX - xSpacing - checkButtonWidth
                    buttonCheck.frame = CGRect(x: xPosition, y: yPosition, width: checkButtonWidth, height: checkButtonHeight)
                    buttonCheck.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
                    keyboardView.addSubview(buttonCheck)
                    self.buttonCheck = buttonCheck
                    
                    let eraseButtonHeight = 40.0
                    let eraseButtonWidth = 38.0
                    
                    let buttonErase = UIButton(type: .system)
                    buttonErase.setBackgroundImage(UIImage(named: "erase_button_unactive"), for: .normal)
                    buttonErase.contentMode = .scaleToFill
                    
                    xPosition = startX + CGFloat(9) * CGFloat((buttonWidth + xSpacing))
                    buttonErase.frame = CGRect(x: xPosition, y: yPosition, width: eraseButtonWidth, height: eraseButtonHeight)
                    buttonErase.addTarget(self, action: #selector(eraseButtonTapped), for: .touchUpInside)
                    keyboardView.addSubview(buttonErase)
                    self.buttonErase = buttonErase
                    
                    
                }
                
                columnCounter += 1
            }
            
            rowCounter += 1
            
        }
    }
    
    // Клавиша удаления нажата
    @objc
    private func eraseButtonTapped(){
        if(currentLetterIndex == 0){
            return
        }
        
        currentLetterIndex += -1
        
        buttonCheck?.setBackgroundImage(UIImage(named:"check_button_unactive"), for: .normal)
        
        let button = buttonArray[currentWordIndex][currentLetterIndex]
        button.setTitle(" ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named:"empty_rectangle"), for: .normal)
        
        if(currentLetterIndex == 0){
            buttonErase?.setBackgroundImage(UIImage(named:"erase_button_unactive"), for: .normal)
        }
        
        
    }
    
    // Клавиша проверки нажата
    @objc
    private func checkButtonTapped(){
        
        if(currentLetterIndex < 5){
            return
        }
        
        let playerWord: String = {
            var result = ""
            
            buttonArray[currentWordIndex].forEach { button in
                result += button.titleLabel?.text ?? " "
            }
            
            return result
        }()
        
        checkGameRules()
        
        if(playerWord == currentWord){
            if(currentWordIndex == 5){
                let alert = UIAlertController(title: "Поздравляем, вы выиграли!", message: "Вы отгадали все слова!", preferredStyle: .alert)

                // Добавляем кнопку "ОК"
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {_ in 
                    self.navigationController?.popViewController(animated: true)
                }))

                // Отображаем алерт
                self.present(alert, animated: true, completion: nil)

                // end game
            }else{
                guessedWords.append(currentWord)
                currentWord = DataService.shared.getRandomWordUppercased()
                currentWordIndex += 1
                currentLetterIndex = 0
                tryCounter = 6
                clearKeyboard()
                buttonCheck?.setBackgroundImage(UIImage(named:"check_button_unactive"), for: .normal)
                buttonErase?.setBackgroundImage(UIImage(named:"erase_button_unactive"), for: .normal)
            }
        }else{
            tryCounter -= 1
            if(tryCounter == 0){
                let alert = UIAlertController(title: "Вы проиграли!", message: "К сожалению попытки закончились - загаданное слово было \(currentWord), но вы можете сыграть еще раз", preferredStyle: .alert)

                // Добавляем кнопку "Играть еще раз"
                alert.addAction(UIAlertAction(title: "Выйти из игры", style: .cancel, handler: {_ in
                    UserDefaults.standard.removeObject(forKey: "savedGameData")
                    self.gameData = nil
                    self.navigationController?.popViewController(animated: true)
                }))
                
                // Добавляем кнопку "Выйти их игры"
                alert.addAction(UIAlertAction(title: "Играть еще раз", style: .default, handler: {_ in
                    self.restartGame()
                }))

                // Отображаем алерт
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // Перезапуск игры
    private func restartGame(){
        UserDefaults.standard.removeObject(forKey: "savedGameData")
        gameData = nil
        currentWord = DataService.shared.getRandomWordUppercased()
        currentWordIndex = 0
        currentLetterIndex = 0
        tryCounter = 6
        clearKeyboard()
        for row in buttonArray{
            for button in row{
                button.setTitle("", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.setBackgroundImage(UIImage(named: "empty_rectangle"), for: .normal)
            }
        }
        buttonCheck?.setBackgroundImage(UIImage(named:"check_button_unactive"), for: .normal)
        buttonErase?.setBackgroundImage(UIImage(named:"erase_button_unactive"), for: .normal)
    }
    
    // Проверка соответствия ввода игрока для слова
    private func checkGameRules(){
        
        // Перебираем ввод пользователя
        buttonArray[currentWordIndex].forEach { button in
            // Получим клавишу на клавиатуре
            let sender = getKeyboardButton(letter: button.titleLabel?.text ?? " ") ?? UIButton()
            // Получим букву
            let letter = button.titleLabel?.text?.first ?? " "
            
            let index = buttonArray[currentWordIndex].firstIndex(of: button) ?? 0
            
            // Буква есть в слове
            if(currentWord.contains(letter)){
                // Буква стоит на своей позиции
                if let stringIndex = currentWord.index(currentWord.startIndex, offsetBy: index, limitedBy: currentWord.endIndex), (currentWord[stringIndex] == letter){
                    // Покрасим кнопку на клавиатуре и на игровом поле
                    sender.setBackgroundImage(UIImage(named: "letter_green"), for: .normal)
                    sender.setTitleColor(.white, for: .normal)
                    button.setBackgroundImage(UIImage(named: "green_rectangle"), for: .normal)
                    button.setTitleColor(.white, for: .normal)
                }else{
                    // Буква есть в слове, но она не на своей позиции
                    sender.setBackgroundImage(UIImage(named: "letter_white"), for: .normal)
                    sender.setTitleColor(.black, for: .normal)
                    button.setBackgroundImage(UIImage(named: "white_rectangle"), for: .normal)
                    button.setTitleColor(.black, for: .normal)
                }
                
            }else{
                // Буквы нет в слове
                sender.setBackgroundImage(UIImage(named: "letter_gray"), for: .normal)
                sender.setTitleColor(.white, for: .normal)
                button.setBackgroundImage(UIImage(named: "gray_rectangle"), for: .normal)
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    // Получить кнопку клавиатуры по ее символу
    private func getKeyboardButton(letter: String) -> UIButton?{
        for view in keyboardView!.subviews{
            if let button = view as? UIButton, button.titleLabel?.text == letter{
                return button
            }
        }
        
        return nil
    }
    
    // Сбор цветов кнопок клавиатуры
    private func clearKeyboard(){
        for view in keyboardView!.subviews{
            if let button = view as? UIButton, button.titleLabel?.text?.isEmpty == false{
                button.setTitleColor(.white, for: .normal)
                button.setBackgroundImage(UIImage(named: "letter_empty"), for: .normal)
            }
        }
    }
    
    // Кнопка клавиатуры нажата
    @objc
    private func keyboardButtonTapped(sender: UIButton){
        
        if(currentLetterIndex > 4){
            return
        }
        
        // Получим нажатую букву
        let letter = Character(sender.titleLabel?.text ?? "")
        let button = buttonArray[currentWordIndex][currentLetterIndex]
        
        // Выведем букву на игровое поле
        button.setTitle(String(letter), for: .normal)
        if(currentLetterIndex < 5){
            currentLetterIndex += 1
            buttonErase?.setBackgroundImage(UIImage(named:"erase_button_active"), for: .normal)
            if(currentLetterIndex == 5){
                buttonCheck?.setBackgroundImage(UIImage(named:"check_button_active"), for: .normal)
            }
        }
        
    }
    
    // Кнопка назад нажата
    @objc
    private func backButtonTapped(){
        saveGameData()
        navigationController?.popViewController(animated: true)
    }

    // Добавление игрового поля
    private func setupGrid() {
        
        // Кол-во строк
        let rows = 6
        // Кол-во столбцов
        let columns = 5
        // Размер ячейки
        let buttonSize: CGFloat = 60
        // Отступ между ячейками
        let spacing: CGFloat = 10
        
        // Вычисляем общую ширину сетки
        let totalWidth = CGFloat(columns) * buttonSize + CGFloat(columns - 1) * spacing
        let totalHeight = CGFloat(rows) * buttonSize + CGFloat(rows - 1) * spacing
        
        // Контейнер для таблицы
        let gridView = UIView()
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        
        NSLayoutConstraint.activate([
            
            gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridView.widthAnchor.constraint(equalToConstant: totalWidth),
            gridView.heightAnchor.constraint(equalToConstant: totalHeight),
            gridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
        ])
        
        self.gridView = gridView
        
        for row in 0..<rows {
            var rowButtons: [UIButton] = []
            for column in 0..<columns {
                // Создаем кнопку
                let button = UIButton(type: .custom)
                button.tintColor = .white
                button.setBackgroundImage(UIImage(named: "empty_rectangle"), for: .normal)
                button.setTitle(" ", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 42, weight: .black)
                button.setTitleColor(.white, for: .normal)
                button.contentHorizontalAlignment = .center
                
                // Устанавливаем размеры и положение кнопки с учетом отступов
                let xPosition = CGFloat(column) * (buttonSize + spacing)
                let yPosition = CGFloat(row) * (buttonSize + spacing)
                
                button.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
                button.isUserInteractionEnabled = false
                
                // Добавляем кнопку на главный вид
                gridView.addSubview(button)
                rowButtons.append(button)
            }
            buttonArray.append(rowButtons)
        }
    }
    
    // Настройка экрана
    private func configureView(){
        // Задать черный фон
        view.backgroundColor = .black
        
        // Установить параметры navigationBar для title
        title = "5-букв"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // Установить параметры navigationBar для back button
        let backButtonImage = UIImage(named: "back_button")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .done, target: self, action: #selector(backButtonTapped))
    }
}

