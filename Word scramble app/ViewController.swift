//
//  ViewController.swift
//  Word scramble app
//
//  Created by DDDD on 08/02/2020.
//  Copyright © 2020 MeerkatWorks. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n") // separated by a line break
            }
        }
        if allWords.isEmpty {
            allWords = ["No words available"]
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement() //the view control title
        usedWords.removeAll(keepingCapacity: true)  //removes all the values that the user has already guess so far
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) { //creating the Submit button
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPOssible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0) // would always be inserted at zero row
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "Heh, this word does not actually exist in the dictionary :)"
                }
            } else {
                errorTitle = "The word was already used"
                errorMessage = "You have to figure another one :)"
            }
        } else {
            errorTitle = "Word is not possible"
            errorMessage = "Not sure that you can spell that word from \(title!.lowercased))"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    
    // checks if the Word is possible based on the original
    func isPOssible(word: String) -> Bool {
        guard var temporaryWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = temporaryWord.firstIndex(of: letter) {
                temporaryWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    // checks if the Word was not used before and stored in usedWords
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    // checks if the Word exists or simply random string
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
}

