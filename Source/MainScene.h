#import "Grid.h"

@interface MainScene : CCNode
{
}
@property (nonatomic, weak) Grid *grid;
@property (nonatomic, weak) CCLabelTTF *scoreLabel;
@property (nonatomic, weak) CCLabelTTF *highscoreLabel;
@property (nonatomic, weak) CCNodeGradient *backgroundColor;
@property NSInteger highScore;

@end
