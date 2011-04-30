//
//  LvlMngr.h
//  labicos2d
//
//  Created by Krzysztof Wolski on 11-04-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface LvlMngr : NSObject {

}

#pragma mark -
#pragma mark properties

@property (nonatomic, readonly) NSInteger CurrentLevel;

#pragma mark -
#pragma mark singleton

+ (LvlMngr *)instance;

#pragma mark -
#pragma mark methods

- (void) loadLevel:(NSInteger)lvlNumber intoLayer:(CCLayer *)layer withBox2DBody:(b2World*)_World 
  withTileFromFile:(NSString *)tileFilename;

@end
