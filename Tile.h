//
//  Tile.h
//  Dabba
//
//  Created by Faisal on 10/6/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Tile : CCNode

@property (nonatomic, weak) CCNodeColor *backgroundNode;
@property (nonatomic, assign) NSString* Color;
@property (nonatomic, assign) int value;

@end
