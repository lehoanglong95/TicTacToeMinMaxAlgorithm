//
//  ViewController.swift
//  TicTacToeMinMaxAlgorithm
//
//  Created by LongLH on 1/7/18.
//  Copyright © 2018 LongLH. All rights reserved.
//

import UIKit

enum Player: String {
    case human = "X"
    case bot = "O"
}

enum ResultMode {
    case win
    case draw
}

struct Move {
    var index: Int
    var score: Int
}

class ViewController: UIViewController {

    @IBOutlet weak var tictacButton: UIButton!
    @IBOutlet weak var tictacButton1: UIButton!
    @IBOutlet weak var tictacButton2: UIButton!
    @IBOutlet weak var tictacButton3: UIButton!
    @IBOutlet weak var tictacButton4: UIButton!
    @IBOutlet weak var tictacButton5: UIButton!
    @IBOutlet weak var tictacButton6: UIButton!
    @IBOutlet weak var tictacButton7: UIButton!
    @IBOutlet weak var tictacButton8: UIButton!
    
    private var groupButton = [UIButton]()
    private var player: Player = .human
    private let tictacCombos: [[Int]] = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]]
    
    private var boardGame = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupButton = [tictacButton, tictacButton1, tictacButton2, tictacButton3, tictacButton4, tictacButton5, tictacButton6, tictacButton7, tictacButton8]
        setupUserInterface()
        playNewGame()
    }
    
    private func setupUserInterface() {
        for button in groupButton {
            setup(button)
        }
    }
    
    private func setup(_ button: UIButton) {
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1.0
    }
    
    private func playNewGame() {
        for button in groupButton {
            button.setTitle("", for: .normal)
        }
        player = .human
        boardGame = Array.init(repeating: "", count: 9)
        tictacButton.setTitle("", for: .normal)
    }
    
    private func showWinner(with name: String, mode: ResultMode) {
        var alert = UIAlertController()
        if mode == .win {
            alert = UIAlertController(title: "Congratulation", message: name + " win", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "End Game", message: "Draw", preferredStyle: .alert)
        }
        let action = UIAlertAction(title: "New Game", style: .default) { (_) in
            self.playNewGame()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func checkWinner(with player: Player, board: [String]) -> Bool {
        for combo in tictacCombos {
            var winnerCondition: [Bool] = Array(repeating: false, count: 3)
            var checkCount = 0
            for index in combo {
                if board[index] == player.rawValue {
                    winnerCondition[checkCount] = true
                    checkCount += 1
                }
                if winnerCondition[0] && winnerCondition[1] && winnerCondition[2] {
                    return true
                }
            }
        }
        return false
    }
    
    private func checkDraw(with board: [String]) -> Bool {
        for square in board {
            if square == "" {
                return false
            }
        }
        return true
    }
    
    private func endGame(with winner: Player, mode: ResultMode) {
        showWinner(with: (winner == Player.human) ? "Human" : "Bot", mode: mode)
    }
    
    private func emptySquare(with board: [String]) -> [Int] {
        var emptySquare = [Int]()
        for (index, square) in board.enumerated() {
            if square == "" {
                emptySquare.append(index)
            }
        }
        return emptySquare
    }
    
    private func minMaxAlgorithm(player: Player, previousBoard: [String], deep: Int) -> Int {
        let newDeep = deep + 1
        var points = [Int]()
        var bestPoint = 0
        if checkWinner(with: .human, board: previousBoard) {
            return -10 + deep
        } else if checkWinner(with: .bot, board: previousBoard) {
            return 10 - deep
        } else if checkDraw(with: previousBoard) {
            return 0
        }
        let availBoard = emptySquare(with: previousBoard)
        var newBoard = previousBoard
        for index in availBoard {
            var point = 0
            newBoard[index] = player.rawValue
            if player == .human {
                point = minMaxAlgorithm(player: .bot, previousBoard: newBoard, deep: newDeep)
            } else {
                point = minMaxAlgorithm(player: .human, previousBoard: newBoard, deep: newDeep)
            }
            points.append(point)
            newBoard[index] = ""
        }
        
        if player == .bot {
            var bestScore = -100
            for point in points {
                if point > bestScore {
                    bestScore = point
                    bestPoint = point
                }
            }
        } else {
            var bestScore = 100
            for point in points {
                if point < bestScore {
                    bestScore = point
                    bestPoint = point
                }
            }
        }
        return bestPoint
    }
    
    private func bestMove(previousBoard: [String]) -> Int {
        let availBoard = emptySquare(with: previousBoard)
        var newBoard = previousBoard
        var moves = [Move]()
        var bestMove = Move(index: 0, score: 0)
        var bestScore = -100
        for index in availBoard {
            var move = Move(index: 0, score: 0)
            newBoard[index] = Player.bot.rawValue
            move.score = minMaxAlgorithm(player: .human, previousBoard: newBoard, deep: 1)
            move.index = index
            moves.append(move)
            newBoard[index] = ""
        }
        for move in moves {
            if move.score > bestScore {
                bestScore = move.score
                bestMove = move
            }
        }
        return bestMove.index
    }
    
    private func botPlay(previousBoard: [String]) {
        boardGame[bestMove(previousBoard: previousBoard)] = Player.bot.rawValue
        groupButton[bestMove(previousBoard: previousBoard)].setTitle(Player.bot.rawValue, for: .normal)
        player = .human
    }
    
//    private func calculateMinxMaxPoint(player: Player, previousBoard: [String], nextMove: Int) -> Move {
//        var newBoard = previousBoard
//        newBoard[nextMove] = player.rawValue
//        print(newBoard)
//        var bestMove: Int = 0
//        var moves: [Move] = [Move]()
//        let availSquare = emptySquare(with: newBoard)
//
//        if checkWinner(with: .human, board: newBoard) {
//            return Move(index: nextMove, score: -10)
//        } else if checkWinner(with: .bot, board: newBoard) {
//            return Move(index: nextMove, score: 10)
//        } else if checkDraw(with: newBoard) {
//            return Move(index: nextMove, score: 0)
//        }
//        for index in availSquare {
//            if player == .human {
//                let move = calculateMinxMaxPoint(player: .bot, previousBoard: newBoard, nextMove: index)
//                moves.append(move)
//            } else {
//                let move = calculateMinxMaxPoint(player: .human, previousBoard: newBoard, nextMove: index)
//                moves.append(move)
//            }
//        }
//        if player == .bot {
//            var bestScore = -20
//            for (index, move) in moves.enumerated() {
//                if move.score > bestScore {
//                    bestScore = move.score
//                    bestMove = index
//                }
//            }
//        } else {
//            var bestScore = 20
//            for (index, move) in moves.enumerated() {
//                if move.score < bestScore {
//                    bestScore = move.score
//                    bestMove = index
//                }
//            }
//        }
//        return moves[bestMove]
//    }
    
//    private func botPlay(with board: [String]) {
//        var moves = [Move]()
//        var bestMove = Move(index: 0, score: -20)
//        for index in emptySquare(with: boardGame) {
//            let move = self.calculateMinxMaxPoint(player: .bot, previousBoard: board, nextMove: index)
//            moves.append(move)
//        }
//        for move in moves {
//            if move.score > bestMove.score {
//                bestMove = move
//            }
//        }
//        groupButton[bestMove.index].setTitle(Player.bot.rawValue, for: .normal)
//        boardGame[bestMove.index] = Player.bot.rawValue
//        player = .human
//    }
    
    @IBAction func playNewGame(_ sender: Any) {
        playNewGame()
    }
    
    @IBAction func tichSquare(_ sender: Any) {
        if let tichButton = sender as? UIButton {
            guard boardGame[tichButton.tag] == "" else {
                return
            }
            tichButton.setTitle(player.rawValue, for: .normal)
            boardGame[tichButton.tag] = player.rawValue
            if checkWinner(with: player, board: boardGame) {
                endGame(with: player, mode: .win)
                return
            }
            if checkDraw(with: boardGame) {
                endGame(with: player, mode: .draw)
                return
            }
            player = (player == Player.human) ? Player.bot : Player.human
            botPlay(previousBoard: boardGame)
        }
    }
}

