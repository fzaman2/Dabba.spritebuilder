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
   NSInteger _points;
   CGPoint defaultPosition;

}

- (void)didLoadFromCCB {
//   _backgroundColor.startColor = [CCColor colorWithRed: 20.0/255 green: 20.0/255 blue: 200.0/255];
//   _backgroundColor.endColor = [CCColor colorWithRed: 20.0/255 green: 20.0/255 blue: 250.0/255];
//   _backgroundColor.startColor = [CCColor colorWithRed:20.0/255 green:60.0/255 blue:220.0/255];
//   _backgroundColor.endColor = [CCColor colorWithRed:20.0/255 green:120.0/255 blue:120.0/255];
//   _backgroundColor.startColor = [CCColor colorWithRed:20.0/255 green:160.0/255 blue:120.0/255];
//   _backgroundColor.endColor = [CCColor colorWithRed:20.0/255 green:160.0/255 blue:60.0/255];
   _backgroundColor.startColor = [CCColor colorWithRed:0.0/255 green:128.0/255 blue:128.0/255];
   _backgroundColor.endColor = [CCColor colorWithRed:0.0/255 green:130.0/255 blue:139.0/255];
//   _backgroundColor.startColor = [CCColor colorWithRed:220.0/255 green:30.0/255 blue:30.0/255];

   once = false;
   touchActivated = false;
   readyToRotate = true;
   newDirectionCounter = 0;
   prevDirectionCounter = 0;
   _tenPoints.visible = false;
   // GestureRecognizer Code
   tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   tapped.numberOfTapsRequired = 1;
   tapped.numberOfTouchesRequired = 1;
   tapped.cancelsTouchesInView = NO;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:tapped];
   
   [self rotateCCW];

   [self performSelector:@selector(touchActivated) withObject:self afterDelay:1.5];

   _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"] ;
   _highscoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_highScore];

   defaultPosition = CGPointMake(_tenPoints.position.x, _tenPoints.position.y);
   _gameOverBox.visible = false;
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
      if([_grid checkCounter] <= 2) {
         [self performSelector:@selector(readyToRotate) withObject:self afterDelay:2];
      }
      else {
         [self performSelector:@selector(readyToRotate) withObject:self afterDelay:1];
      }
   }
}

-(void)rotateCCW {
   _points ++;
   _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
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
   _points ++;
   _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
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

-(void)setDefaultPosition {
   _tenPoints.visible = false;
   CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.1 position:defaultPosition];
   CCActionFadeIn *fade = [CCActionFadeIn actionWithDuration:0.1];
   CCActionSequence *sequence = [CCActionSequence actionWithArray:@[moveTo,fade]];
   [_tenPoints runAction:sequence];

   _points += 10;
   _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];

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
   if([_grid checkGameOver])
   {
      [_grid removeFromParentAndCleanup:true];
      if(_points > _highScore)
      {
         
         [[NSUserDefaults standardUserDefaults] setInteger: _points forKey: @"highScore"];
         
      }
      _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"] ;
      _highscoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_highScore];
      _gameOverBox.visible = true;
      
   }
   if([_grid checkMatch])
   {
      _tenPoints.visible = true;
      CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.5 position:_scoreLabel.position];
      CCActionFadeOut *fade = [CCActionFadeOut actionWithDuration:0.5];
      CCActionSequence *sequence = [CCActionSequence actionWithArray:@[moveTo,fade]];
      [_tenPoints runAction:sequence];
      [self performSelector:@selector(setDefaultPosition) withObject:self afterDelay:1];
      


//      [_grid spawnRandomTile];
      [_grid move:direction];
      [self performSelector:@selector(scanTiles) withObject:self afterDelay:1];
   }
}

-(void) restart {
   CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
   [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.5]];
   
}
@end
