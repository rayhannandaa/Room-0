//
//  BubbleDialogLine.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import Foundation

struct BubbleDialogLine: Identifiable {
    let id = UUID()
    let speakerName: String?
    let text: String
    
    init(speakerName: String? = nil, text: String) {
        self.speakerName = speakerName
        self.text = text
    }
}
