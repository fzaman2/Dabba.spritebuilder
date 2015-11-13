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
   _value = arc4random()%3;

   switch (_value) {
   case 0:
         backgroundColor = [CCColor colorWithRed:220.0/255 green:20.0/255 blue:60.0/255];
         break;
   case 1:
         backgroundColor = [CCColor colorWithRed:0.0/255 green:128.0/255 blue:0.0/255];
         break;
   case 2:
         backgroundColor = [CCColor colorWithRed:72.0/255 green:61.0/255 blue:139.0/255];
         break;
//   case 3:
//         backgroundColor = [CCColor yellowColor];
//         break;
   default:
         break;
   }
   _backgroundNode.color = backgroundColor;
}

@end
