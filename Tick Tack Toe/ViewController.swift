//
//  ViewController.swift
//  Tick Tack Toe
//
//  Created by Daniel Barros on 10/26/14.
//  Copyright (c) 2014 Daniel Barros. All rights reserved.
//

import Appkit

class ViewController: NSViewController {
    
    var boxes: [NSButton]!
    var game: Game!
    var turn: Int!
    
    func putX(sender: NSButton) {
        let row = sender.tag / 3
        let column = sender.tag % 3
        
        if game.putXIn(row: row, column: column) {
            if game.state != .playing {
                gameOver()
            }
            else {
                putO()
            }
        }
    }
    
    func updateUI() {
        for i in 0..<boxes.count {
            var mark: String!
            switch game.board.array[i] {
            case .O:
                mark = "◯"
            case .X:
                mark = "✕"
            case .free:
                mark = ""
            }
            boxes[i].title = mark
        }
    }
    
    func putO() {
        game.putO()
        updateUI()
        
        if game.state != .playing {
            gameOver()
        }
    }
    
    func gameOver() {
        var message = ""
        
        switch game.state {
        case .win:
            message = "You win"
        case .lost:
            message = "You lost"
        case .draw:
            message = "Draw"
        default:
            break
        }
        
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = "Do you want to play again?"
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Quit")
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        
        let selection = alert.runModal()
        if selection == NSAlertFirstButtonReturn {
            game.reset()
            turn = (turn + 1) % 2
            updateUI()
            if turn == 0 {
                putO()
            }
        }
        else {
            NSApplication.sharedApplication().terminate(self)
        }
    }
    
    func initGame() {
        game = Game()
        turn = Int(arc4random()%2)
        updateUI()
        if turn == 0 {
            putO()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        boxes = [NSButton]()

        for (tag,subView) in enumerate(view.subviews) {
            if let button = subView as? NSButton {
                button.tag = tag - 1
                boxes.append(button)
                button.action = "putX:"
                button.target = self
            }
        }
                
        initGame()
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

