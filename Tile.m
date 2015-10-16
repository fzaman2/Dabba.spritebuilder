//
//  Tile.m
//  Dabba
//
//  Created by Faisal on 10/6/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "Tile.h"

@implementation Tile

- (void)didLoadFromCCB {
   CCColor *backgroundColor;
   _value = arc4random()%4;

   switch (_value) {
   case 0:
         backgroundColor = [CCColor redColor];
         break;
   case 1:
         backgroundColor = [CCColor greenColor];
         break;
   case 2:
         backgroundColor = [CCColor blueColor];
         break;
   case 3:
         backgroundColor = [CCColor yellowColor];
         break;
   default:
         break;
   }
   _backgroundNode.color = backgroundColor;
}

@end
