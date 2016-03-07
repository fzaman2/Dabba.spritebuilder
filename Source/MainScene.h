#import "Grid.h"

@interface MainScene : CCNode
{
}
@property (nonatomic, weak) Grid *grid;
@property (nonatomic, weak) CCLabelTTF *scoreLabel;
@property (nonatomic, weak) CCLabelTTF *highscoreLabel;
@property (nonatomic, weak) CCLabelTTF *tenPoints;
@property (nonatomic, weak) CCNodeGradient *backgroundColor;
@property (nonatomic, weak) CCNodeColor *gameOverBox;
@property NSInteger highScore;

@end
