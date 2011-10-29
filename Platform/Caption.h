//
//  Caption.h
//  Platform
//
//  Created by Bobby Gill on 10/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface Caption : Resource {
    
}
@property (nonatomic,retain) NSString* caption;
@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSNumber* numberofvotes;
@end
