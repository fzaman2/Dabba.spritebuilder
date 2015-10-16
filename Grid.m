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
   
   Tile *tiled;
   Tile *gridArray[gridSize][gridSize];
   Tile *noTile;
   UITapGestureRecognizer *tapped;
   CGFloat elapsedTime;

   
}
- (void)didLoadFromCCB {
   noTile = nil;
   
   // GestureRecognizer Code
   tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   tapped.numberOfTapsRequired = 1;
   tapped.numberOfTouchesRequired = 1;
   tapped.cancelsTouchesInView = NO;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:tapped];

   [self setupBackground];
   
   for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
         gridArray[i][j] = noTile;
      }
   }
   
   [self spawnStartTiles];
}

- (void)update:(CCTime)delta {
   elapsedTime += delta;
   if(elapsedTime > 1.f)
   {
      [self dropDown];
   }
}

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
//      int randomRow = (CCRANDOM_0_1() * gridSize);
//      int randomColumn = (CCRANDOM_0_1() * gridSize);
      NSLog(@"%s,%d","random row: ", randomRow);
      NSLog(@"%s,%d","random column: ", randomColumn);
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

# pragma mark Screen Tapped

-(void)screenTapped {
   CGPoint point = [tapped locationInView:[CCDirector sharedDirector].view];
   CGPoint point2;
   if(point.x < 160) //Left
   {
      NSLog(@"Tapping on the left side of the screen is for communists!");
      point2 = CGPointMake(-1, 0);
      [self move:point2];
   }
   else // Right
   {
      NSLog(@"User tapped on the right side! Ohh Yeah!");
      point2 = CGPointMake(1, 0);
      [self move:point2];
   }
}

-(void)dropDown {
   
   CGPoint point = CGPointMake(0, -1);
   [self move:point];
   
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
         if (tile2 != nil) {///////////??????????????
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
            }
         }
         // move further in this column
         currentY += yChange;
      }
      currentX += xChange;
      currentY = initialY;
   }
}
   

@end
