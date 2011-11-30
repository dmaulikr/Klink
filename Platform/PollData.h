//
//  PollData.h
//  Platform
//
//  Created by Jasjeet Gill on 11/21/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"
@interface PollData : NSObject <IJSONSerializable>
{
    NSNumber* m_pollid;
    NSNumber* m_targetid;
    NSString* m_targetobjecttype;
    NSNumber* m_numberofvotes;
}

@property (nonatomic,retain) NSNumber* pollid;
@property (nonatomic,retain) NSNumber* targetid;
@property (nonatomic,retain) NSString* targetobjecttype;
@property (nonatomic,retain) NSNumber* numberofvotes;


@end
