//
//  RoomHandoffRevealView.swift
//  Room 0
//

import UIKit

final class RoomHandoffRevealView: UIView {
    private let opaqueLayer = CAShapeLayer()
    private let transitionBandLayer = CAShapeLayer()

    private let targetHoleRadius: CGFloat = 120
    private let targetBandWidth: CGFloat = 75
    private var revealCenter = CGPoint.zero
    private var hasScheduledReveal = false
    private var hasStartedReveal = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false

        opaqueLayer.fillColor = UIColor(
            red: 218 / 255,
            green: 215 / 255,
            blue: 206 / 255,
            alpha: 1
        ).cgColor
        opaqueLayer.fillRule = .evenOdd

        transitionBandLayer.fillColor = UIColor(
            red: 218 / 255,
            green: 215 / 255,
            blue: 206 / 255,
            alpha: 0.5
        ).cgColor
        transitionBandLayer.fillRule = .evenOdd

        layer.addSublayer(opaqueLayer)
        layer.addSublayer(transitionBandLayer)
        applyPaths(holeRadius: 0, bandWidth: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        opaqueLayer.frame = bounds
        transitionBandLayer.frame = bounds

        guard !hasStartedReveal else { return }
        applyPaths(holeRadius: 0, bandWidth: 0)
    }

    func configure(center: CGPoint) {
        revealCenter = center
        applyPaths(holeRadius: 0, bandWidth: 0)
    }

    func scheduleReveal(
        after delay: TimeInterval,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard !hasScheduledReveal else { return }
        hasScheduledReveal = true

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.reveal(duration: duration, completion: completion)
        }
    }

    private func reveal(
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard !hasStartedReveal else { return }
        hasStartedReveal = true
        layoutIfNeeded()

        let initialOpaquePath = makeOpaquePath(outerRadius: 0)
        let finalOpaquePath = makeOpaquePath(
            outerRadius: targetHoleRadius + targetBandWidth
        )
        let initialBandPath = makeBandPath(innerRadius: 0, outerRadius: 0)
        let finalBandPath = makeBandPath(
            innerRadius: targetHoleRadius,
            outerRadius: targetHoleRadius + targetBandWidth
        )

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        opaqueLayer.path = finalOpaquePath.cgPath
        transitionBandLayer.path = finalBandPath.cgPath
        CATransaction.commit()

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        let timing = CAMediaTimingFunction(name: .easeInEaseOut)
        addPathAnimation(
            to: opaqueLayer,
            from: initialOpaquePath.cgPath,
            to: finalOpaquePath.cgPath,
            duration: duration,
            timing: timing
        )
        addPathAnimation(
            to: transitionBandLayer,
            from: initialBandPath.cgPath,
            to: finalBandPath.cgPath,
            duration: duration,
            timing: timing
        )
        CATransaction.commit()
    }

    private func applyPaths(holeRadius: CGFloat, bandWidth: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        opaqueLayer.path = makeOpaquePath(
            outerRadius: holeRadius + bandWidth
        ).cgPath
        transitionBandLayer.path = makeBandPath(
            innerRadius: holeRadius,
            outerRadius: holeRadius + bandWidth
        ).cgPath
        CATransaction.commit()
    }

    private func makeOpaquePath(outerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(ovalIn: circleRect(radius: outerRadius)))
        path.usesEvenOddFillRule = true
        return path
    }

    private func makeBandPath(
        innerRadius: CGFloat,
        outerRadius: CGFloat
    ) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: circleRect(radius: outerRadius))
        path.append(UIBezierPath(ovalIn: circleRect(radius: innerRadius)))
        path.usesEvenOddFillRule = true
        return path
    }

    private func circleRect(radius: CGFloat) -> CGRect {
        CGRect(
            x: revealCenter.x - radius,
            y: revealCenter.y - radius,
            width: radius * 2,
            height: radius * 2
        )
    }

    private func addPathAnimation(
        to layer: CAShapeLayer,
        from initialPath: CGPath,
        to finalPath: CGPath,
        duration: TimeInterval,
        timing: CAMediaTimingFunction
    ) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = initialPath
        animation.toValue = finalPath
        animation.duration = duration
        animation.timingFunction = timing
        layer.add(animation, forKey: "roomReveal")
    }
}
