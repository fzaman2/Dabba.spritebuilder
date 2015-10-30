#import "MainScene.h"

@implementation MainScene
{
   
//   CGFloat elapsedTime;
   UITapGestureRecognizer *tapped;
   int newDirectionCounter;
   int prevDirectionCounter;
   BOOL once;
   BOOL readyToRotate;
   BOOL touchActivated;
   CGPoint direction;

}

- (void)didLoadFromCCB {
   once = false;
   touchActivated = false;
   readyToRotate = true;
   newDirectionCounter = 0;
   prevDirectionCounter = 0;
   // GestureRecognizer Code
   tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   tapped.numberOfTapsRequired = 1;
   tapped.numberOfTouchesRequired = 1;
   tapped.cancelsTouchesInView = NO;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:tapped];
   
   [self rotateCCW];

   [self performSelector:@selector(touchActivated) withObject:self afterDelay:1];

}

//- (void)update:(CCTime)delta {
////   elapsedTime += delta;
//
//}

# pragma mark Screen Tapped

-(void)screenTapped {
   CGPoint point = [tapped locationInView:[CCDirector sharedDirector].view];
   if(readyToRotate && touchActivated)
   {
     if(point.x < 160) //Left
     {
        [self rotateCCW];
     }
     else // Right
     {
        [self rotateCW];
     }
      readyToRotate = false;
      [self performSelector:@selector(readyToRotate) withObject:self afterDelay:1];
   }
}

-(void)rotateCCW {
   CCActionRotateBy *rot = [CCActionRotateBy actionWithDuration:0.5 angle:-90];
   [_grid runAction:rot];
   newDirectionCounter--;
   if (newDirectionCounter < 0) {
      newDirectionCounter = 3;
   }
   else if(newDirectionCounter > 3) {
      newDirectionCounter = 0;
   }
   [self performSelector:@selector(moveGrid) withObject:self afterDelay:1];
}

-(void)rotateCW {
   CCActionRotateBy *rot = [CCActionRotateBy actionWithDuration:0.5 angle:90];
   [_grid runAction:rot];
   newDirectionCounter++;
   if (newDirectionCounter < 0) {
      newDirectionCounter = 3;
   }
   else if(newDirectionCounter > 3) {
      newDirectionCounter = 0;
   }
   [self performSelector:@selector(moveGrid) withObject:self afterDelay:1];
}

-(void)readyToRotate {
   readyToRotate = true;
}

-(void)touchActivated {
   touchActivated = true;
}

-(void)moveGrid {
   
   if (newDirectionCounter == 3 && prevDirectionCounter == 0) {
      direction = CGPointMake(-1, 0);
   }
   else if (newDirectionCounter == 1 && prevDirectionCounter == 0) {
      direction = CGPointMake(1, 0);
   }
   else if (newDirectionCounter == 2 && prevDirectionCounter == 3) {
      direction = CGPointMake(0, 1);
   }
   else if (newDirectionCounter == 0 && prevDirectionCounter == 3) {
      direction = CGPointMake(0, -1);
   }
   else if (newDirectionCounter == 2 && prevDirectionCounter == 1) {
      direction = CGPointMake(0, 1);
   }
   else if (newDirectionCounter == 0 && prevDirectionCounter == 1) {
      direction = CGPointMake(0, -1);
   }
   else if (newDirectionCounter == 3 && prevDirectionCounter == 2) {
      direction = CGPointMake(-1, 0);
   }
   else if (newDirectionCounter == 1 && prevDirectionCounter == 2) {
      direction = CGPointMake(1, 0);
   }
   else
   {
      direction = CGPointMake(0, 0);
   }
//   NSLog(@"%s,%f","direction.x ", direction.x);
//   NSLog(@"%s,%f","direction.y ", direction.y);
   prevDirectionCounter = newDirectionCounter;
   
   [_grid move:direction];
   if (once) {
      [_grid spawnRandomTile];
      [_grid move:direction];
      [self performSelector:@selector(scanTiles) withObject:self afterDelay:1];
   }
   once = true;
}

-(void) scanTiles {
   [_grid scanTiles];   
}
@end
