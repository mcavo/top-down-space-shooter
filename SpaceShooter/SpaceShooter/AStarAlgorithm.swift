//
//  AStar.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation

class AStarAlgorithm: NSObject {
    
    var map: TilesMap!
    var openSet = Set<CGPoint>()
    var closedSet = Set<CGPoint>()
    var gScore = [CGPoint: CGFloat]()
    var fScore = [CGPoint: CGFloat]()
    var pathMap = [CGPoint: CGPoint]()
    
    init(map: TilesMap) {
        self.map = map
    }
    
    func getPath(fromPoint: CGPoint, toPoint: CGPoint) -> [CGPoint] {
        reset()
        let from = fromPoint.toMapCoords(map: map)
        let to = toPoint.toMapCoords(map: map)
        openSet.insert(from)
        gScore[from] = 0
        fScore[from] = hScore(from: from, to: to)
        
        while !openSet.isEmpty {
            let current = getCurrentPoint()
            if ((current?.distance(point: to))! == 0) {
                return  mapToPath(current!)
            }
            
            openSet.remove(current!)
            closedSet.insert(current!)
            
            for neighbour in getNeighbours(of: current!) {
                
                if closedSet.contains(neighbour) {
                    continue
                }
                
                let gScoreFromCurrentToNeighbour = gScore[current!]! + (current?.distance(point: neighbour))!
                
                if !openSet.contains(neighbour) {
                    openSet.insert(neighbour)
                } else if gScoreFromCurrentToNeighbour >= gScore[neighbour]! {
                    continue
                }
                
                pathMap[neighbour] = current
                gScore[neighbour] = gScoreFromCurrentToNeighbour
                fScore[neighbour] = gScoreFromCurrentToNeighbour + hScore(from: neighbour, to: to)
            }
        }
        
        return [CGPoint]()
    }
    
    func reset() {
        openSet.removeAll()
        closedSet.removeAll()
        gScore.removeAll()
        fScore.removeAll()
        pathMap.removeAll()
    }
        
    func hScore(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
    
    func getCurrentPoint() -> CGPoint? {
        return openSet.min(by: { (a : CGPoint, b : CGPoint) -> Bool in
            return fScore[a]! < fScore[b]!
        })
    }
    
    func getNeighbours(of: CGPoint) -> [CGPoint] {
        
        var neighbours = [CGPoint]()
        
        for i in -1...1 {
            for j in -1...1 {
                let point = CGPoint(x: of.x + CGFloat(i),y: of.y + CGFloat(j))
                
                if map.contains(point) {
                    if !isAsteroid(point: point) && !isSpaceShip(point: point) && (CGFloat(i) != 0 || CGFloat(j) != 0) {
                        neighbours.append(point)
                    }
                }
            }
        }
        
        return neighbours
    }
    
    func mapToPath(_ current: CGPoint) -> [CGPoint] {
        var path = [current]
        var point = current
        
        while pathMap.keys.contains(point) {
            point = pathMap[point]!
            path.insert(point.toScreenCoords(map: map), at: 0)
        }
        path.removeLast()
        return path
        
    }
    
    func isAsteroid(point: CGPoint) -> Bool {
        let tile = map.tileDefinition(atColumn: Int(point.y), row: Int(point.x))
        return tile != nil
    }
    
    func isSpaceShip(point: CGPoint) -> Bool {
        for ship in map.ships {
            let shipColumn = map.tileColumnIndex(fromPosition: ship.position)
            let shipRow = map.tileRowIndex(fromPosition: ship.position)
            if (Int(point.x) == shipRow && Int(point.y) == shipColumn) {
                return true
            }
        }
        return false
    }

}
