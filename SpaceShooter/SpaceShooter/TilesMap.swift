//
//  TilesMap.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit



class TilesMap : SKTileMapNode {

    var ships = Set<SpaceShip>()
    
    init(map: SKTileMapNode, ships: Set<SpaceShip>) {
        
        self.ships = ships
        var tileGroupList = [SKTileGroup]()
        for row in 0...map.numberOfRows-1 {
            for column in 0...map.numberOfColumns-1 {
                if (map.tileGroup(atColumn: column, row: row) != nil) {
                    tileGroupList.append(map.tileGroup(atColumn: column, row: row)!)
                }
            }
        }
        
        super.init(tileSet: map.tileSet, columns: map.numberOfColumns, rows: map.numberOfRows, tileSize: map.tileSize, tileGroupLayout: tileGroupList)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
