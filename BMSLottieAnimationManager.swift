//
//  BMSLottieAnimationManager.swift
//  BookMyShow
//
//  Created by Debashish Dash on 18/04/23.
//  Copyright © 2023 BookMyShow. All rights reserved.
//

import Foundation
import Lottie

public enum LottieURLSource {
    case bms
    case json
}

public protocol BMSLottieAnimationManagerProtocol {
    var animationURLString: String { get }
    var lottieAnimationView: LOTAnimationView? { get set }
    func loadLottieAnimation(completion: @escaping (LOTAnimationView?) -> Void)
    func startAnimation(
        inLoop: Bool,
        completion: (() -> Void)?
    )
    func stopAnimation(completion: (() -> Void)?)
}

extension BMSLottieAnimationManagerProtocol {
    func startAnimation(
        inLoop: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        startAnimation(
            inLoop: inLoop,
            completion: completion
        )
    }
    func stopAnimation(completion: (() -> Void)? = nil) {
        stopAnimation(completion: completion)
    }
}

public class BMSLottieAnimationManager: BMSLottieAnimationManagerProtocol {

    private let lottieURLSource: LottieURLSource
    public var lottieAnimationView: LOTAnimationView?
    public var animationURLString: String
    
    init(
        animationURLString: String,
        lottieURLSource: LottieURLSource = .bms
    ) {
        self.animationURLString = animationURLString
        self.lottieURLSource = lottieURLSource
    }
    
    private func getLottieAnimation(completion: @escaping (LOTComposition?) -> ()) {
        guard let animationURL = URL(string: animationURLString) else { return }
        // If animation exists in cache, return it immediately
        if let existingAnimation: LOTComposition = LOTAnimationCache.shared().animation(forKey: animationURLString) {
            completion(existingAnimation)
        } else {
            // Download the animation from the remote URL
            URLSession.shared.dataTask(with: animationURL) { [weak self] (data, _, _) in
                var animation: LOTComposition?
                defer {
                    DispatchQueue.main.async {
                        if let animation = animation {
                            LOTAnimationCache.shared().addAnimation(
                                animation,
                                forKey: animationURL.absoluteString
                            )
                        }
                        completion(animation)
                    }
                }
                
                guard let jsonData = data,
                      let animationDataObj = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    return
                }
                if self?.lottieURLSource == .bms {
                    if let animationString: String = animationDataObj["Data"] as? String,
                       let animationJSON: [String: Any] = try? JSONSerialization.jsonObject(with: Data(animationString.utf8), options: []) as? [String: Any] {
                        
                        let lottieAnimation: LOTComposition = LOTComposition(json: animationJSON)
                        animation = lottieAnimation
                    }
                } else {
                    let lottieAnimation: LOTComposition = LOTComposition(json: animationDataObj)
                    animation = lottieAnimation
                }
            }.resume()
        }
    }
    
    public func loadLottieAnimation(completion: @escaping (LOTAnimationView?) -> Void) {
        getLottieAnimation { [weak self] lottieComposition in
            self?.lottieAnimationView = LOTAnimationView(
                model: lottieComposition,
                in: nil
            )
            self?.lottieAnimationView?.contentMode = .scaleAspectFit
            self?.lottieAnimationView?.isUserInteractionEnabled = false
            completion(self?.lottieAnimationView)
        }
    }
    
    public func startAnimation(
        inLoop: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        lottieAnimationView?.loopAnimation = inLoop
        lottieAnimationView?.play(completion: { _ in
            completion?()
        })
    }
    
    public func stopAnimation(completion: (() -> Void)? = nil) {
        lottieAnimationView?.stop()
        completion?()
    }
}
