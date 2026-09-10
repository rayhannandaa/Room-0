//
//  BubbleDialogViewModel.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import Foundation
import Combine

@MainActor
class BubbleDialogViewModel: ObservableObject {
    
    @Published private(set) var isVisible: Bool = false
    @Published private(set) var displayedText: String = ""
    @Published private(set) var isTyping: Bool = false
    
    private var lines: [BubbleDialogLine] = []
    private var currentIndex: Int = 0
    private var typingTask: Task<Void, Never>?
    private var completion: (() -> Void)?
    
    private let typingCharacterInterval: TimeInterval = 0.03
    
    func present(_ sequence: BubbleDialogSequence, completion: (() -> Void)? = nil) {
        typingTask?.cancel()
        lines = sequence.lines
        currentIndex = 0
        self.completion = completion
        isVisible = true
        startTypingCurrentLine()
    }
    
    func handleTap() {
        if isTyping {
            completeCurrentLine()
        } else if currentIndex < lines.count - 1 {
            currentIndex += 1
            startTypingCurrentLine()
        } else {
            finishSequence()
        }
    }
    
    func dismiss() {
        typingTask?.cancel()
        completion = nil
        isVisible = false
    }

    private func finishSequence() {
        typingTask?.cancel()
        isVisible = false

        let completion = completion
        self.completion = nil
        completion?()
    }
    
    private func startTypingCurrentLine() {
        guard lines.indices.contains(currentIndex) else { return }
        
        typingTask?.cancel()
        displayedText = ""
        isTyping = true
        
        let fullText = lines[currentIndex].text
        let interval = typingCharacterInterval
        
        typingTask = Task { [weak self] in
            for character in fullText {
                if Task.isCancelled { return }
                
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                
                guard let self = self else { return }
                self.displayedText.append(character)
            }
            
            guard let self = self else { return }
            self.isTyping = false
        }
    }
    
    private func completeCurrentLine() {
        typingTask?.cancel()
        guard lines.indices.contains(currentIndex) else { return }
        displayedText = lines[currentIndex].text
        isTyping = false
    }
}
