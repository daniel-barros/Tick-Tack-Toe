//
//  Game.swift
//  Tick Tack Toe
//
//  Created by Daniel Barros on 10/26/14.
//  Copyright (c) 2014 Daniel Barros. All rights reserved.
//

import Foundation


enum Value: Int {
    case free = 0
    case X = 1
    case O = -1
}

enum Weight: Int {
    case min = 0
    case low = 1
    case medium = 2
    case high = 3
    case max = 40
    case win = 1000
}

enum Line {
    case row(Int)
    case column(Int)
    case diagonal(Int) //diagonal 1 is the one which contains (0,0), diagonal 2 contains (2,0)
}

enum GameState {
    case lost, win, draw, playing
}

struct Board {
    var array: [Value]
    let size: Int;
    
    init(size: Int = 3) {
        self.size = size
        array = Array(count:size*size, repeatedValue:.free)
    }
    
    subscript(row: Int, column: Int) -> Value {
        get {
            return array[row*size + column]
        }
        set(newValue) {
            array[row*size + column] = newValue
        }
    }
    
    var isFull: Bool {
        for value in array {
            if value == .free {
                return false
            }
        }
        return true
    }
}

class Game {
    var board = Board(size: 3) //0 if free, 1
    let size = 3    //Implemented only for size 3
    
    func reset() {
        board = Board(size: size)
    }
    
    var state: GameState {
        var sum = 0
        
        func gameStateForSum() -> GameState? {
            if sum == Value.O.rawValue * size {
                return .lost
            }
            else if sum == Value.X.rawValue * size {
                return .win
            }
            return nil
        }
        
        //Check rows
        for row in 0..<size {
            sum = 0
            for column in 0..<size {
                sum += board[row,column].rawValue
            }
            if let state = gameStateForSum() {
                return state
            }
        }
        
        //Check columns
        for column in 0..<size {
            sum = 0
            for row in 0..<size {
                sum += board[row,column].rawValue
            }
            if let state = gameStateForSum() {
                return state
            }
        }
        
        //Check diagonals
        sum = board[0,0].rawValue + board[1,1].rawValue + board[2,2].rawValue
        if let state = gameStateForSum() {
            return state
        }
        sum = board[0,2].rawValue + board[1,1].rawValue + board[2,0].rawValue
        if let state = gameStateForSum() {
            return state
        }
        
        
        if board.isFull {
            return .draw
        }
        
        return .playing
    }
    
    ///Human player puts a X
    func putXIn(#row: Int, column: Int) -> Bool {
        if board[row, column] == .free {
            board[row,column] = .X
            return true
        }
        return false
    }
    
    ///AI makes a move
    func putO() {
        
        ///Returns the best box where the AI oponent can put an O
        func nextMove() -> (row: Int, column: Int) {
            var moves = [(Int,Int)]()
            var weight = 0
            var bestWeight = 0
            var row, col: Int
            
            ///Computes the overall weight for a row
            func weightForRow(row: Int) -> Weight {
                var sum = 0
                for i in 0..<size {
                    sum += board[row,i].rawValue
                }
                return weightForSum(sum, rowOrColumnOrDiagonal: .row(row))
            }
            
            ///Computes the overall weight for a column
            func weightForColumn(column: Int) -> Weight {
                var sum = 0
                for i in 0..<size {
                    sum += board[i,column].rawValue
                }
                return weightForSum(sum, rowOrColumnOrDiagonal: .column(column))
            }
            
            ///Computes the overall weight for a diagonal
            func weightForDiagonal(diagonal: Int) -> Weight {
                var sum = 0
                
                if (diagonal == 1) {
                    for i in 0..<size {
                        sum += board[i,i].rawValue
                    }
                }
                else {
                    for i in 0..<size {
                        sum += board[i,size-1-i].rawValue
                    }
                }
                return weightForSum(sum, rowOrColumnOrDiagonal: .diagonal(diagonal))
            }
            
            
            
            for row in 0..<size {
                for col in 0..<size {
                    if (board[row,col] == .free) {
                        weight = weightForRow(row).rawValue + weightForColumn(col).rawValue
                        
                        switch (row,col) {
                        case (0,0), (1,1), (2,2):
                            weight += weightForDiagonal(1).rawValue
                        case (0,2),(1,1),(2,0):
                            weight += weightForDiagonal(2).rawValue
                        default:
                            break
                        }
                        
                        if weight > bestWeight {
                            moves.removeAll(keepCapacity: false)
                            moves += [(row,col)]
                            bestWeight = weight
                        }
                        else if weight == bestWeight {
                            moves += [(row,col)]
                        }
                    }
                }
            }
            
            return moves[random()%moves.count]
            
        }
        
        
        let box = nextMove()
        board[box.row, box.column] = .O
    }
    
    ///Returns the weight for a given row, column or diagonal taking into account the sum of the raw values of each box
    private func weightForSum(sum: Int, rowOrColumnOrDiagonal line: Line) -> Weight{
        switch sum {
        case 2:
            return .max
        case -2:
            return .win
        case 1:
            return .high
        case -1:
            return .low
        default:
            
            switch line {
            case .column(let num):
                if board[0,num] == .free &&
                    board[1,num] == .free &&
                    board[2,num] == .free {
                        return .medium
                }
            case .row(let num):
                if board[num,0] == .free &&
                    board[num,1] == .free &&
                    board[num,2] == .free {
                        return .medium
                }
            case .diagonal(let num):
                switch num {
                case 1:
                    if board[0,0] == .free &&
                        board[1,1] == .free &&
                        board[2,2] == .free {
                            return .medium
                    }
                case 2:
                    if board[0,2] == .free &&
                        board[1,1] == .free &&
                        board[2,0] == .free {
                            return .medium
                    }
                default:
                    println("Error: diagonals must be 1 or 2")
                    return .min
                }
            default:
                return .min
            }
            
        }
        return .min
    }
    
    
    
}