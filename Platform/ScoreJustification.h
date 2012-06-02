//
//  ScoreJustification.h
//  Platform
//
//  Created by Jasjeet Gill on 6/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"
@interface ScoreJustification : NSObject <IJSONSerializable>
{
    NSString* m_justification;
    NSNumber* m_points;
}

@property (nonatomic,retain) NSString* justification;
@property (nonatomic,retain) NSNumber* points;
@end
