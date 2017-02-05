//
//  ViewController.swift
//  KoreanStudy
//
//  Created by bsmith on 2017-01-28.
//  Copyright © 2017 sbrian. All rights reserved.
//

import UIKit
import Foundation

class RootViewController: UIViewController, UITextFieldDelegate, WordViewControllerDelegate {
    
    var words: KoreanStudyWordList?
    
    var nextPass : [KoreanStudyWord]?
    
    @IBOutlet weak var type: UISegmentedControl!
    
    @IBOutlet weak var count: UITextField!
    
    @IBOutlet weak var groups: UITextField!
    
    @IBOutlet weak var allowRepeats: UISwitch!
    
    @IBOutlet weak var countStepper: UIStepper!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count.delegate = self
        groups.delegate = self
        countStepper.value = Double(count.text!)!
        
        let defaults = UserDefaults.standard
        var countValue = defaults.integer(forKey: "count")
        if ( countValue == 0 ) {
            countValue = 100
        }
        count.text = String(countValue)
        countStepper.value = Double(countValue)
        if let g=defaults.string(forKey: "groups") {
            groups.text = g
        }
        allowRepeats.isOn = defaults.bool(forKey: "allowRepeats")
        type.selectedSegmentIndex = defaults.integer(forKey: "type")
        
        let c=defaults.integer(forKey: "lastWordCount")
        if (c>0) {
            showResult(wordCount: c, correctCount: defaults.integer(forKey: "lastCorrectCount"))
        }
        
        do {
            words = try KoreanStudyWordList.loadFromFile(path: Bundle.main.path(forResource: "dict", ofType: "txt")!)
        } catch {
            NSLog("Failed to open dict file")
            exit(EXIT_FAILURE)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowWordControllerSegue" {
            let k : [KoreanStudyWord] = words!.selectWords(count: Int(countStepper.value), allowRepeats: allowRepeats.isOn, groups: parseGroups())
            if (k.count==0) {
                return false
            } else {
                nextPass = k
                return true
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWordControllerSegue" {
            if let destinationVC = segue.destination as? WordViewController {
                destinationVC.delegate = self
                destinationVC.studyPass = KoreanStudyPass(words: nextPass!, type: parseKoreanStudyPassType())
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        groups.resignFirstResponder()
        count.resignFirstResponder()
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func countStepperValueChanged(_ sender: UIStepper) {
        let intVal : Int = Int(sender.value)
        count.text = String(intVal)
        UserDefaults.standard.set(intVal, forKey:"count")
    }
    
    @IBAction func countEditingDidEnd(_ sender: UITextField) {
        countStepper.value = Double(sender.text!)!
        UserDefaults.standard.set(Int(sender.text!)!, forKey:"count")
    }
    
    @IBAction func allowRepeatsValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"allowRepeats")
    }
    
    @IBAction func typeValueChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey:"type")
    }
    
    @IBAction func groupsEditingDidEnd(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey:"groups")
    }

    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField==count) {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return characterSet.isSubset(of: allowedCharacters)
        } else {
            if (string==",") {
                
                if (range.location==0) {
                    // Prevent leading comma
                    return false
                } else {
                    let t : String = textField.text!
                    let i1 = t.index(t.startIndex, offsetBy: range.location-1)
                    let i2 = t.index(t.startIndex, offsetBy: range.location)
                    if t.substring(with: i1..<i2)=="," {
                        // Prevent ",,"
                        return false
                    }
                }
            }
            let allowedCharacters : CharacterSet = CharacterSet(charactersIn: "0123456789,")
            let characterSet = CharacterSet(charactersIn: string)
            return characterSet.isSubset(of: allowedCharacters)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func wordViewControllerResult(wordCount: Int, correctCount: Int) {
        showResult(wordCount: wordCount, correctCount: correctCount)
        UserDefaults.standard.set(wordCount, forKey: "lastWordCount")
        UserDefaults.standard.set(correctCount, forKey: "lastCorrectCount")
    }
    
    func showResult(wordCount: Int, correctCount: Int) {
        self.result.isHidden=false
        self.resultLabel.isHidden=false
        let percent : Int = Int(Float(100) * ( Float(correctCount) / Float(wordCount) ))
        self.result.text = "\(correctCount) / \(wordCount) = \(percent)%"
    }
    
    func parseGroups() -> Set<Int> {
        let startingText = groups.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (startingText=="") {
            return Set<Int>()
        }
        let splitString : [String] =  startingText.components(separatedBy: ",")
        var parsedGroups : Set<Int> = Set<Int>()
        for s in splitString {
            let trimmed = s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (trimmed=="") {
                continue
            }
            parsedGroups.insert(Int(trimmed)!)
        }
        return parsedGroups
    }
    
    func parseKoreanStudyPassType() -> KoreanStudyPassType {
        if (type.selectedSegmentIndex==0) {
            return KoreanStudyPassType.KoreanToEnglish
        } else {
            return KoreanStudyPassType.EnglishToKorean
        }
    }
}

