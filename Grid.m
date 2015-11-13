//
//  Grid.m
//  Dabba
//
//  Created by Faisal on 10/6/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Tile.h"

static const int gridSize = 4;
static int startTiles = 2;
static CGFloat columnWidth = 0;
static CGFloat columnHeight = 0;
static CGFloat tileMarginVertical = 0;
static CGFloat tileMarginHorizontal = 0;

@implementation Grid
{
   Tile *gridArray[gridSize][gridSize];
   Tile *noTile;
//   CGFloat elapsedTime;
   int counter;
   BOOL matched;

}

- (void)didLoadFromCCB {
   noTile = nil;
   counter = 0;
   matched = false;
   [self setupBackground];
   
   for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
         gridArray[i][j] = noTile;
      }
   }
   
   [self spawnStartTiles];
}

//- (void)update:(CCTime)delta {
//
//}

- (void)setupBackground {
   Tile *tile = (Tile *)[CCBReader load:@"Tile"];
   columnWidth = tile.contentSize.width;
   columnHeight = tile.contentSize.height;

   tileMarginHorizontal = (self.contentSize.width - (gridSize * columnWidth)) / (gridSize + 1);
   tileMarginVertical = (self.contentSize.height - (gridSize * columnHeight)) / (gridSize + 1);
   
   CGFloat x = tileMarginHorizontal;
   CGFloat y = tileMarginVertical;
   
   for (int i = 0; i < gridSize; i++) {
      x = tileMarginHorizontal;
      for (int j = 0; j<gridSize; j++) {
         CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor grayColor]];
         backgroundTile.contentSize = CGSizeMake(columnWidth, columnHeight);
         backgroundTile.position = CGPointMake(x, y);
         [self addChild:backgroundTile];
         x += columnWidth + tileMarginHorizontal;
      }
      y += columnHeight + tileMarginVertical;
   }
}

-(CGPoint) positionForColumn:(int)column row:(int)row{
   CGFloat x = tileMarginHorizontal + column * (tileMarginHorizontal + columnWidth);
   CGFloat y = tileMarginVertical + row * (tileMarginVertical + columnHeight);
   return CGPointMake(x, y);
}

-(void) addTileAtColumn:(int)column :(int)row{
   Tile *tile = (Tile *)[CCBReader load:@"Tile"];
   gridArray[column][row] = tile;
   tile.scale = 0;
   [self addChild:tile];
   tile.position = [self positionForColumn:column row:row];
   CCActionDelay *delay = [CCActionDelay actionWithDuration:0.3];
   CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.2 scale:1];
   CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, scaleUp]];
   [tile runAction:sequence];
}

-(void) spawnRandomTile {
   BOOL spawned = false;
   while (!spawned) {
      int randomRow = arc4random()%gridSize;
      int randomColumn = arc4random()%gridSize;
      BOOL positionFree = gridArray[randomColumn][randomRow] == noTile;
      if (positionFree) {
         [self addTileAtColumn:randomColumn :randomRow];
         spawned = true;
      }
   }
}

-(void)spawnStartTiles {
   for (int i = 0; i < startTiles; i++) {
      [self spawnRandomTile];
   }
}

# pragma mark Move

-(BOOL)indexValid:(int)x y:(int)y{
   BOOL indexValid = true;
   indexValid = (x>=0) && (y>=0);
   if(indexValid)
   {
      indexValid = x < gridSize;
      if (indexValid)
      {
         indexValid = y < gridSize;
      }
   }
   return indexValid;
}

-(BOOL)indexValidAndUnoccupied:(int)x y:(int)y{
   BOOL indexValid = [self indexValid:x y:y];
   if (!indexValid) {
      return false;
   }
   // unoccupied?
   return gridArray[x][y] == noTile;
}

-(void) moveTile:(Tile*)tile fromX:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
   gridArray[toX][toY] = gridArray[fromX][fromY];
   gridArray[fromX][fromY] = noTile;
   CGPoint newPosition = [self positionForColumn:toX row:toY ];
   CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2 position:newPosition];
   [tile runAction:moveTo];

}

-(void) move:(CGPoint)direction{
   BOOL movedTilesThisRound = false;
   // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
   // bottom left corner
   int currentX = 0;
   int currentY = 0;
   // Move to relevant edge by applying direction until reaching border
   while ([self indexValid:currentX y:currentY]) {
      int newX = currentX + direction.x;
      int newY = currentY + direction.y;
      if ([self indexValid:newX y:newY]){
         currentX = newX;
         currentY = newY;
      } else {
         break;
      }
   }
   // store initial row value to reset after completing each column
   int initialY = currentY;
   // define changing of x and y value (moving left, up, down or right?)
   int xChange = -direction.x;
   int yChange = -direction.y;
   if (xChange == 0) {
      xChange = 1;
   }
   if (yChange == 0) {
      yChange = 1;
   }
   // visit column for column
   while ([self indexValid:currentX y:currentY]) {
      while ([self indexValid:currentX y:currentY]) {
         // get tile at current index
         Tile *tile2 = gridArray[currentX][currentY];
         if (tile2 != nil) {
            // if tile exists at index
            int newX = currentX;
            int newY = currentY;
            // find the farthest position by iterating in direction of the vector until reaching boarding of
            // grid or occupied cell
            while ([self indexValidAndUnoccupied:newX+direction.x y:newY+direction.y]) {
               newX += direction.x;
               newY += direction.y;
            }
            if (newX != currentX || newY != currentY) {
               [self moveTile:tile2 fromX:currentX fromY:currentY toX:newX toY:newY];
               movedTilesThisRound = true;
            }
         }
         // move further in this column
         currentY += yChange;
      }
      currentX += xChange;
      currentY = initialY;
   }
}

-(void)scanTiles {
   counter = 0;
   matched = false;
   Tile *tile[gridSize][gridSize];
   CCActionRemove *remove = [CCActionRemove action];
   for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j<gridSize; j++) {
         tile[i][j] = gridArray[i][j];
         
         // check if there is empty space in grid
         if (tile [i][j] == noTile) {
            counter++;
         }
      }
   }

   for (int i = 0; i < 3; i++) {
   // Check Rows
      if(tile[0][0] != noTile && tile[0][1] != noTile && tile[0][2] != noTile && tile[0][3] != noTile )
      {
      if(tile[0][0].value == i && tile[0][1].value == i && tile[0][2].value == i && tile[0][3].value == i)
      {
         gridArray[0][0] = noTile;
         gridArray[0][1] = noTile;
         gridArray[0][2] = noTile;
         gridArray[0][3] = noTile;
         [tile[0][0] runAction:remove];
         [tile[0][1] runAction:remove];
         [tile[0][2] runAction:remove];
         [tile[0][3] runAction:remove];
         [self removeChild:tile[0][0]];
         [self removeChild:tile[0][1]];
         [self removeChild:tile[0][2]];
         [self removeChild:tile[0][3]];
         matched = true;
      }
      }
      if(tile[1][0] != noTile && tile[1][1] != noTile && tile[1][2] != noTile && tile[1][3] != noTile )
      {
      if(tile[1][0].value == i && tile[1][1].value == i && tile[1][2].value == i && tile[1][3].value == i)
      {
         gridArray[1][0] = noTile;
         gridArray[1][1] = noTile;
         gridArray[1][2] = noTile;
         gridArray[1][3] = noTile;
         [tile[1][0] runAction:remove];
         [tile[1][1] runAction:remove];
         [tile[1][2] runAction:remove];
         [tile[1][3] runAction:remove];
         [self removeChild:tile[1][0]];
         [self removeChild:tile[1][1]];
         [self removeChild:tile[1][2]];
         [self removeChild:tile[1][3]];
         matched = true;
      }
      }
      if(tile[2][0] != noTile && tile[2][1] != noTile && tile[2][2] != noTile && tile[2][3] != noTile )
      {
      if(tile[2][0].value == i && tile[2][1].value == i && tile[2][2].value == i && tile[2][3].value == i)
      {
         gridArray[2][0] = noTile;
         gridArray[2][1] = noTile;
         gridArray[2][2] = noTile;
         gridArray[2][3] = noTile;
         [tile[2][0] runAction:remove];
         [tile[2][1] runAction:remove];
         [tile[2][2] runAction:remove];
         [tile[2][3] runAction:remove];
         [self removeChild:tile[2][0]];
         [self removeChild:tile[2][1]];
         [self removeChild:tile[2][2]];
         [self removeChild:tile[2][3]];
         matched = true;
      }
      }
      if(tile[3][0] != noTile && tile[3][1] != noTile && tile[3][2] != noTile && tile[3][3] != noTile )
      {
      if(tile[3][0].value == i && tile[3][1].value == i && tile[3][2].value == i && tile[3][3].value == i)
      {
         gridArray[3][0] = noTile;
         gridArray[3][1] = noTile;
         gridArray[3][2] = noTile;
         gridArray[3][3] = noTile;
         [tile[3][0] runAction:remove];
         [tile[3][1] runAction:remove];
         [tile[3][2] runAction:remove];
         [tile[3][3] runAction:remove];
         [self removeChild:tile[3][0]];
         [self removeChild:tile[3][1]];
         [self removeChild:tile[3][2]];
         [self removeChild:tile[3][3]];
         matched = true;
      }
      }
      // Check Columns
      if(tile[0][0] != noTile && tile[1][0] != noTile && tile[2][0] != noTile && tile[3][0] != noTile )
      {
      if(tile[0][0].value == i && tile[1][0].value == i && tile[2][0].value == i && tile[3][0].value == i)
      {
         gridArray[0][0] = noTile;
         gridArray[1][0] = noTile;
         gridArray[2][0] = noTile;
         gridArray[3][0] = noTile;
         [tile[0][0] runAction:remove];
         [tile[1][0] runAction:remove];
         [tile[2][0] runAction:remove];
         [tile[3][0] runAction:remove];
         [self removeChild:tile[0][0]];
         [self removeChild:tile[1][0]];
         [self removeChild:tile[2][0]];
         [self removeChild:tile[3][0]];
         matched = true;
      }
      }
      if(tile[0][1] != noTile && tile[1][1] != noTile && tile[2][1] != noTile && tile[3][1] != noTile )
      {
      if(tile[0][1].value == i && tile[1][1].value == i && tile[2][1].value == i && tile[3][1].value == i)
      {
         gridArray[0][1] = noTile;
         gridArray[1][1] = noTile;
         gridArray[2][1] = noTile;
         gridArray[3][1] = noTile;
         [tile[0][1] runAction:remove];
         [tile[1][1] runAction:remove];
         [tile[2][1] runAction:remove];
         [tile[3][1] runAction:remove];
         [self removeChild:tile[0][1]];
         [self removeChild:tile[1][1]];
         [self removeChild:tile[2][1]];
         [self removeChild:tile[3][1]];
         matched = true;
      }
      }
      if(tile[0][2] != noTile && tile[1][2] != noTile && tile[2][2] != noTile && tile[3][2] != noTile )
      {
      if(tile[0][2].value == i && tile[1][2].value == i && tile[2][2].value == i && tile[3][2].value == i)
      {
         gridArray[0][2] = noTile;
         gridArray[1][2] = noTile;
         gridArray[2][2] = noTile;
         gridArray[3][2] = noTile;
         [tile[0][2] runAction:remove];
         [tile[1][2] runAction:remove];
         [tile[2][2] runAction:remove];
         [tile[3][2] runAction:remove];
         [self removeChild:tile[0][2]];
         [self removeChild:tile[1][2]];
         [self removeChild:tile[2][2]];
         [self removeChild:tile[3][2]];
         matched = true;
      }
      }
      if(tile[0][3] != noTile && tile[1][3] != noTile && tile[2][3] != noTile && tile[3][3] != noTile )
      {
      if(tile[0][3].value == i && tile[1][3].value == i && tile[2][3].value == i && tile[3][3].value == i)
      {
         gridArray[0][3] = noTile;
         gridArray[1][3] = noTile;
         gridArray[2][3] = noTile;
         gridArray[3][3] = noTile;
         [tile[0][3] runAction:remove];
         [tile[1][3] runAction:remove];
         [tile[2][3] runAction:remove];
         [tile[3][3] runAction:remove];
         [self removeChild:tile[0][3]];
         [self removeChild:tile[1][3]];
         [self removeChild:tile[2][3]];
         [self removeChild:tile[3][3]];
         matched = true;
      }
      }
      // Check Diagnols
      if(tile[0][0] != noTile && tile[1][1] != noTile && tile[2][2] != noTile && tile[3][3] != noTile )
      {
         if(tile[0][0].value == i && tile[1][1].value == i && tile[2][2].value == i && tile[3][3].value == i)
         {
            gridArray[0][0] = noTile;
            gridArray[1][1] = noTile;
            gridArray[2][2] = noTile;
            gridArray[3][3] = noTile;
            [tile[0][0] runAction:remove];
            [tile[1][1] runAction:remove];
            [tile[2][2] runAction:remove];
            [tile[3][3] runAction:remove];
            [self removeChild:tile[0][0]];
            [self removeChild:tile[1][1]];
            [self removeChild:tile[2][2]];
            [self removeChild:tile[3][3]];
            matched = true;
         }
      }
      if(tile[0][3] != noTile && tile[1][2] != noTile && tile[2][1] != noTile && tile[3][0] != noTile )
      {
         if(tile[0][3].value == i && tile[1][2].value == i && tile[2][1].value == i && tile[3][0].value == i)
         {
            gridArray[0][3] = noTile;
            gridArray[1][2] = noTile;
            gridArray[2][1] = noTile;
            gridArray[3][0] = noTile;
            [tile[0][3] runAction:remove];
            [tile[1][2] runAction:remove];
            [tile[2][1] runAction:remove];
            [tile[3][0] runAction:remove];
            [self removeChild:tile[0][3]];
            [self removeChild:tile[1][2]];
            [self removeChild:tile[2][1]];
            [self removeChild:tile[3][0]];
            matched = true;
         }
      }
   }
   // no more empty space? call gameover method
   if (counter == 0 && matched == false) {
      [self gameOver];
      return;
   }

}

-(BOOL)checkMatch {
   
   return matched;
}

# pragma mark Move

-(void) setupGestures {

   UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
   [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];

   UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
   [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
   
   
   UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp)];
   [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
   
   UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown)];
   [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];
   
}

-(void) swipeLeft {
  [self move:CGPointMake(-1, 0)];
}

-(void) swipeRight {
   [self move:CGPointMake(1, 0)];
}

-(void) swipeUp{
   [self move:CGPointMake(0, 1)];
}

-(void) swipeDown {
   [self move:CGPointMake(0, -1)];
}

-(void)removeGridArray {
   gridArray[0][2] =  noTile;
}

-(void)removeGridArray2 {
   gridArray[0][1] =  noTile;
}

# pragma mark gameover

-(void)gameOver {
   CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
   [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:1.0]];

}

@end
