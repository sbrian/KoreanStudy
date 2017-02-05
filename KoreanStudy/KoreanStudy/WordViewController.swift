//
//  WordViewController.swift
//  KoreanStudy
//
//  Created by bsmith on 2017-01-28.
//  Copyright © 2017 sbrian. All rights reserved.
//

import UIKit

protocol WordViewControllerDelegate
{
     func wordViewControllerResult(wordCount: Int, correctCount: Int)
}

class WordViewController: UIViewController {

    enum Status {
        case onQuery
        case onResponse
    }
    
    var delegate: WordViewControllerDelegate?

    var studyPass: KoreanStudyPass?
    
    var status : Status = Status.onQuery
    
    var correctCount : Int = 0
    
    @IBOutlet weak var queryTextView: UITextView!
    
    @IBOutlet weak var responseTextView: UITextView!
    
    @IBOutlet weak var incorrectButton: UIButton!
    
    @IBOutlet weak var correctButton: UIButton!
    
    @IBOutlet weak var showButton: UIButton!
    
    override func viewDidLoad() {
        responseTextView.text = ""
        queryTextView.text = studyPass?.nextQuery()
        status = Status.onResponse
        incorrectButton.isHidden = true
        correctButton.isHidden = true
        correctCount = 0
    }
    
    @IBAction func showButtonClick(_ sender: UIButton) {
        UIView.transition(with:self.view, duration: 0.6, options: .transitionCrossDissolve, animations: {
            self.incorrectButton.isHidden = false
            self.correctButton.isHidden = false
            self.showButton.isHidden = true
            self.goToNext()
        })
    }
    
    @IBAction func incorrectButtonClick(_ sender: UIButton) {
        if (!studyPass!.hasMore()) {
            showResult()
            return;
        }
        UIView.transition(with:self.view, duration: 0.6, options: .transitionCurlUp, animations: {
            self.showShowButton()
            self.goToNext()
        })
    }
    
    @IBAction func correctButtonClick(_ sender: UIButton) {
        correctCount=correctCount+1
        if (!studyPass!.hasMore()) {
            showResult()
            return;
        }
        UIView.transition(with:self.view, duration: 0.6, options: .transitionCurlUp, animations: {
            self.showShowButton()
            self.goToNext()
        })
    }
    
    func goToNext() {
        if (status==Status.onQuery) {
            queryTextView.text = studyPass?.nextQuery()
            responseTextView.text = ""
            status = Status.onResponse
        } else {
            responseTextView.text = studyPass?.nextResponse()
            status = Status.onQuery
        }
    }
    
    func showShowButton() {
        self.incorrectButton.isHidden = true
        self.correctButton.isHidden = true
        self.showButton.isHidden = false
    }
    
    func showResult() {
        self.navigationController!.popViewController(animated: true)
        delegate!.wordViewControllerResult(wordCount: studyPass!.wordCount(), correctCount: correctCount)
    }
}
