//
//  Grid.h
//  Dabba
//
//  Created by Faisal on 10/6/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Grid : CCNode <UIGestureRecognizerDelegate>
{
}
@property (nonatomic, weak) CCNodeColor *grid;

-(void) move:(CGPoint)direction;
-(void) spawnRandomTile;
-(void)scanTiles;

@end
