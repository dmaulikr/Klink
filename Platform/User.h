//
//  User.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : Resource {
    
}
@property (nonatomic,retain) NSString* email;
@property (nonatomic,retain) NSString* displayname;
@property (nonatomic,retain) NSNumber* numberofvotes;
@property (nonatomic,retain) NSString* thumbnailurl;
@property (nonatomic,retain) NSNumber* sharinglevel;
@property (nonatomic,retain) NSNumber* iseditor;
@property (nonatomic,retain) NSNumber* numberofcaptionslw;
@property (nonatomic,retain) NSNumber* numberofdraftscreatedlw;
@property (nonatomic,retain) NSNumber* numberofdraftsparticipated;
@property (nonatomic,retain) NSNumber* numberofpagespublished;
@property (nonatomic,retain) NSNumber* numberofphotoslw;
@property (nonatomic,retain) NSNumber* datebecameeditor;
@property (nonatomic,retain) NSNumber* numberofdraftscreated;
@property (nonatomic,retain) NSNumber* numberofcaptions;
@property (nonatomic,retain) NSNumber* numberofphotos;
@property (nonatomic,retain) NSNumber* maxweeklyparticipation;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSString* username;


+ (int) unopenedNotificationsFor:(NSNumber*)objectid;
@end
