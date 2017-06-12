//
//  Extension.swift
//  VisionTest
//
//  Created by Aaron on 12/06/2017.
//  Copyright © 2017 Aaron. All rights reserved.
//

import UIKit
import Vision

// MARK: - CGRect Extension

extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}

// MARK: - VNFaceLandmarks2D

class LandMarks2DArray {
    var landmarks: VNFaceLandmarks2D
    
    struct scale_float2 {
        var scaleX = [Float]()
        var scaleY = [Float]()
    }
    
    enum MarkType {
        case faceCoutour
        case leftEye
        case leftEyebrow
        case leftPupil
        case rightEye
        case rightEyebrow
        case rightPupil
        case innerLips
        case medianLine
        case nose
        case noseCrest
        case outerLips
        case allPoints
        
        func pointsCount() -> Int {
            switch self {
            case .faceCoutour:      return 10
            case .innerLips:        return 6
            case .leftEye:          return 7
            case .leftEyebrow:      return 3
            case .leftPupil:        return 1
            case .rightEye:         return 7
            case .rightEyebrow:     return 3
            case .rightPupil:       return 1
            case .medianLine:       return 8
            case .nose:             return 8
            case .noseCrest:        return 2
            case .outerLips:        return 9
            case .allPoints:        return 30
            }
        }
    }
    
    init(landmarks: VNFaceLandmarks2D) {
        self.landmarks = landmarks
    }
    
    func getArray(markType: MarkType) -> [vector_float2] {
        var arr = [vector_float2]()
        
        switch markType {
        case .faceCoutour:      arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.faceContour?.points)!)
        case .innerLips:        arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.innerLips?.points)!)
        case .leftEye:          arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.leftEye?.points)!)
        case .leftEyebrow:      arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.leftEyebrow?.points)!)
        case .leftPupil:        arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.leftPupil?.points)!)
        case .rightEye:         arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.rightEye?.points)!)
        case .rightEyebrow:     arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.rightEyebrow?.points)!)
        case .rightPupil:       arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.rightPupil?.points)!)
        case .medianLine:       arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.medianLine?.points)!)
        case .nose:             arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.nose?.points)!)
        case .noseCrest:        arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.noseCrest?.points)!)
        case .outerLips:        arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.outerLips?.points)!)
        case .allPoints:        arr = generalArray(count: markType.pointsCount(),
                                                   points: (self.landmarks.allPoints?.points)!)
        }
        
        return arr
    }
    
    private func generalArray(count: Int, points: UnsafePointer<vector_float2>) -> [vector_float2] {
        var arr = [vector_float2]()
        for i in 0...count {
            arr.append(points[i])
        }
        return arr
    }
    
    func scaleX(markType: MarkType, scaled scale: Float) -> [Float] {
        let arr = getArray(markType: markType)
        return arr.map { $0.x*scale }
    }
    
    func scaleY(markType: MarkType, scaled scale: Float) -> [Float] {
        let arr = getArray(markType: markType)
        return arr.map { $0.y*scale }
    }
    
    func scaleFloat2(markType: MarkType, scaled scale: Float) -> scale_float2 {
        var scaleT = scale_float2()
        scaleT.scaleX = scaleX(markType: markType, scaled: scale)
        scaleT.scaleY = scaleY(markType: markType, scaled: scale)
        return scaleT
    }
}


