//
//  PlaygroundLayer.h
//  labicos2d
//
//  Created by Krzysztof Wolski on 11-04-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"



@interface PlaygroundLayer : CCLayer {
	b2World* _World;
    
	CCSprite *_MetalBallSprite;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) setupWorld:(CGSize)winSize;
- (void) setupSprites;

@end
