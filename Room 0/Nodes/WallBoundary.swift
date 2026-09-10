//
//  WallBoundary.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import CoreGraphics

struct WallBoundary {
    static let points: [CGPoint] = [
        CGPoint(x: -373.3, y: 248.5),
        CGPoint(x: -232.5, y: 252.4),
        CGPoint(x: -223.9, y: 268.7),
        CGPoint(x: -223.9, y: 348.4),
        CGPoint(x: 74.4, y: 348.4),
        CGPoint(x: 74.4, y: 268.0),
        CGPoint(x: 82.0, y: 253.1),
        CGPoint(x: 223.2, y: 249.1),
        CGPoint(x: 224.5, y: -106.2),
        CGPoint(x: 245.7, y: -124.1),
        CGPoint(x: 373.0, y: -124.4),
        CGPoint(x: 368.4, y: -287.8),
        CGPoint(x: 350.5, y: -298.4),
        CGPoint(x: -56.9, y: -298.4),
        CGPoint(x: -73.7, y: -312.0),
        CGPoint(x: -74.7, y: -381.1),
        CGPoint(x: -88.3, y: -397.0),
        CGPoint(x: -364.7, y: -394.4),
        CGPoint(x: -373.3, y: -379.2)
    ]
    
    static func makePath() -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}
