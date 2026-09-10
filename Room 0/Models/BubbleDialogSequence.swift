//
//  BubbleDialogSequence.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import Foundation

struct BubbleDialogSequence: Identifiable {
    let id = UUID()
    let lines: [BubbleDialogLine]
    
    init(lines: [BubbleDialogLine]) {
        self.lines = lines
    }
}
