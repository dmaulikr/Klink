//
//  SocialSharingManager.m
//  Klink V2
//
//  Created by Bobby Gill on 8/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SocialSharingManager.h"
#import "BLLog.h"
#import "Caption.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "Photo.h"
#import "SocialPost.h"
#import "Facebook.h"
#import "Theme.h"
#import "ImageManager.h"
@implementation SocialSharingManager
@synthesize facebook = __facebook;

#pragma mark - Properties
- (Facebook*) facebook {
    if (__facebook != nil) {
        return __facebook;
    }
    Klink_V2AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    __facebook = appDelegate.facebook;
    return __facebook;
}
#pragma mark - Instance Management

static  SocialSharingManager* sharedManager;

+ (id) getInstance {
    NSString* activityName=@"SocialSharingManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
            [BLLog v:activityName withMessage:@"completed initialization"];
        }        
        return sharedManager;
    }
}

#pragma mark - Initializer
- (id) init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Post Formatters
- (NSString*) postTitleFor:(Caption*)caption {
    return caption.title;
}

- (NSString*) postMessageFor:(Caption*)caption {
    return caption.title;
}

#pragma mark - WordPress Communication
- (NSArray*) argsForWordpressPost:(SocialPost*)post 
                     withUsername:(NSString*)username 
                     withPassword:(NSString*)password 
                           atBlog:(NSString*) blogURL 
                       forCaption:(Caption*)caption {
    
    int size = 4; 
    
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:size];
    [result addObject:[NSNumber numberWithInt:0]];
    [result addObject:username];
    [result addObject:password];
    
    NSMutableDictionary* parameterDictionary = [[NSMutableDictionary alloc]init];
    [parameterDictionary setObject:post.title forKey:@"title"];
    [parameterDictionary setObject:post.message forKey:@"description"];
    NSMutableArray* categoriesArray = [[NSMutableArray alloc]init];
    [categoriesArray insertObject:category_WORDPRESS atIndex:0];
    
    if (post.hashtags != nil) {
        [parameterDictionary setObject:post.hashtags forKey:@"mt_keywords"];
    }
    
    [parameterDictionary setObject:categoriesArray forKey:@"categories"];
    [parameterDictionary setObject:@"publish" forKey:@"post_status"];

    
    [result addObject:parameterDictionary];
    [parameterDictionary autorelease];
    return result;

}

- (NSError *)errorWithResponse:(XMLRPCResponse *)res {
    NSError *err = nil;
	
    if ([res isKindOfClass:[NSError class]]) {
        err = (NSError *)res;
    } else {
        if ([res isFault]) {
            NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[res fault], NSLocalizedDescriptionKey, nil];
            err = [NSError errorWithDomain:@"org.wordpress.iphone" code:[[res code] intValue] userInfo:usrInfo];
        }
		
        if ([res isParseError]) {
            err = [res object];
        }
    }
    
	
	return err;
}


- (id)executeXMLRPCRequest:(XMLRPCRequest *)req shouldRetryOnTimeout:(BOOL)retryOnTimeout {
	
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[req host]];
	[request setRequestMethod:@"POST"];
	[request setShouldPresentCredentialsBeforeChallenge:YES];
	[request setShouldPresentAuthenticationDialog:YES];
	[request setUseKeychainPersistence:YES];
    [request setValidatesSecureCertificate:NO];
	[request setTimeOutSeconds:30];
	NSString *version  = [[[NSBundle mainBundle] infoDictionary] valueForKey:[NSString stringWithFormat:@"CFBundleVersion"]];
	[request addRequestHeader:@"User-Agent" value:[NSString stringWithFormat:@"wp-iphone/%@",version]];
    
    NSString *quickPostType = [[req request] valueForHTTPHeaderField:@"WP-Quick-Post"];
    if (quickPostType != nil) {
        [request addRequestHeader:@"WP-Quick-Post" value:quickPostType];
    }
    
    if (retryOnTimeout) {
        [request setNumberOfTimesToRetryOnTimeout:2];
    } else {
        [request setNumberOfTimesToRetryOnTimeout:0];
    }
	if(getenv("WPDebugXMLRPC"))
		NSLog(@"executeXMLRPCRequest request: %@",[req source]);
    [request appendPostData:[[req source] dataUsingEncoding:NSUTF8StringEncoding]];
	[request startSynchronous];
	
	//generic error
	NSError *err = [request error];
    if (err) {
        
        NSLog(@"executeXMLRPCRequest error: %@", err);
		[request release];
        return err;
    }
    
    
    int statusCode = [request responseStatusCode];
    if (statusCode >= 404) {
        NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[request responseStatusMessage], NSLocalizedDescriptionKey, nil];

        return [NSError errorWithDomain:@"org.wordpress.iphone" code:statusCode userInfo:usrInfo];
    }
	if(getenv("WPDebugXMLRPC"))
		NSLog(@"executeXMLRPCRequest response: %@", [request responseString]);
	
    NSString* responseString = [request responseData];
	XMLRPCResponse *userInfoResponse = [[[XMLRPCResponse alloc] initWithData:[request responseData]] autorelease];

    
    [request release];
    
    err = [self errorWithResponse:userInfoResponse];
	
    if (err) {
    
        return err;
	} else 	{
    
    }
		    
    return [userInfoResponse object];
}



- (NSURL*) submitPostToWordpress:(SocialPost*)post 
                    withUsername:(NSString*)username 
                    withPassword:(NSString*)password 
                          atBlog:(NSString*)blogURL  
                      forCaption:(Caption*)caption {
    NSString* activityName = @"SocialSharingManager.submitPostToWordpress:";
    //need to construct the rpc request and submit it to wordpress
    NSString* modifiedURL = [NSString stringWithFormat:@"%@/xmlrpc.php",blogURL];
    XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc]initWithHost:[NSURL URLWithString:modifiedURL]];
    NSArray* postArgs = [self argsForWordpressPost:post withUsername:username withPassword:password atBlog:blogURL forCaption:caption];
    
    [xmlrpcRequest setMethod:@"metaWeblog.newPost" withObjects:postArgs];
    
    id result = [self executeXMLRPCRequest:xmlrpcRequest shouldRetryOnTimeout:NO];
    
    if ([result isKindOfClass:[NSError class]]) {
        NSString* message = [NSString stringWithFormat:@"Error posting to wordpress"];
        [BLLog e:activityName withMessage:message];
        return nil;
    }
    else {
        //it was a success, the result should be a number
        int postID = [result intValue];
        
        //now we need to create the url of the post
        NSString* postURL = [NSString stringWithFormat:@"%@/?p=%d",blogURL, postID];
        return [NSURL URLWithString:postURL];
        
    }

    
}

 
- (NSString*) postHTMLFor:(Caption*)caption withPhoto:(Photo*)photo{
//    NSString* retVal = [NSString stringWithFormat:@"<div><p class=\"post-image \"><a href=\"%@\">_</a></p><p>%@</p></div>",photo.imageurl,caption.caption1];

    ImageManager* imageManager = [ImageManager getInstance];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:nil];
    
    int width = 0;
    int height = 0;
    if (image != nil) {
        CGSize size = image.size;
        width = size.width;
        height = size.height;
        double ratio = 0;
        if (width > max_width_WORDPRESSIMAGE) {
            //need to scale the size appropriately
            ratio = (double)width / (double)height;
            width = max_width_WORDPRESSIMAGE;
            height = width / ratio;
            
        }
        else {
            width = size.width;
            height = size.height;
        }
    }
    else {
        width = default_width_WORDPRESSIMAGE;
        height = default_height_WORDPRESSIMAGE;
    }
    NSString* retVal = [NSString stringWithFormat:@"<div><p class=\"post-image \"><img src=\"%@\" width=%d height=%d/></p><p>%@</p></div>",photo.imageurl,width,height, caption.caption1];
    return retVal;
}

#pragma mark - Sharing Methods
- (void) shareCaption:(NSNumber*)captionID {
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    [transferManager shareCaptionViaCloud:captionID];
}

//- (void) shareCaption:(NSNumber *)captionID {
//    NSString* activityName = @"SocialSharingManager.shareCaption:";
//    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
//    AuthenticationContext* authnContext = [authnManager getAuthenticationContext];
//    
//    if (authnContext != nil &&
//        [authnContext hasWordpress]) {
//        //user has to be logged in in order to share and have a wordpress account
//        Caption* caption = [DataLayer getObjectByType:CAPTION withId:captionID];
//        Photo* photo = [DataLayer getObjectByID:caption.photoid withObjectType:PHOTO];
//        Theme* theme = [DataLayer getObjectByID:photo.themeid withObjectType:tn_THEME];
//        //need to first post the caption as a post to the wordpress
//        NSString* postTitle = [self postTitleFor:caption];
//        NSString* postMessage = [self postHTMLFor:caption withPhoto:photo];
//        NSArray* postHashTags = [theme arrayForHashtags];
//        
//        SocialPost* newPost = [SocialPost postFor:postMessage withTitle:postTitle withHashtags:postHashTags];
//        NSURL* postURL = [self submitPostToWordpress:newPost withUsername:authnContext.wpUsername withPassword:authnContext.wpPassword atBlog:authnContext.wordpressURL forCaption:caption];
//        
//        if (postURL != nil) {
//            NSString* message = [NSString stringWithFormat:@"Published caption: %@ to url: %@",captionID,postURL];
//            [BLLog e:activityName withMessage:message];
//            
//            newPost.url = postURL;
//            //now we share this url with twitter and facebook angles
//            [self shareCaptionOnFacebook:caption withPost:newPost];
//        }
//        else {
//            //there was an error
//            NSString* message = [NSString stringWithFormat:@"Could not publish caption: %@",captionID];
//            [BLLog e:activityName withMessage:message];
//        }
//    }
//    else {
//        NSString* message = @"Must be logged in and have a registered wordpress blog to share";
//        [BLLog e:activityName withMessage:message];
//    }
//}



- (void) shareCaptionOnFacebook:(Caption*)caption withPost:(SocialPost*)post {
    //takes a preformed post and translates it to facebook world
    NSString* activityName = @"SocialSharingManager.shareCaptionOnFacebook:";
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    AuthenticationContext* authnContext = [authnManager getAuthenticationContext];
    Photo* photo = [DataLayer getObjectByType:PHOTO withId:caption.photoid];
    Theme* theme = [DataLayer getObjectByType:tn_THEME withId:photo.themeid];
    
    if (authnContext != nil &&
        [authnContext hasFacebook] &&
        [self.facebook isSessionValid]) {
        //user has facebook, so let us now publish to it
        NSMutableDictionary* wallPost = [[NSMutableDictionary alloc]init];
        [wallPost setObject:caption.caption1 forKey:@"message"];
        [wallPost setObject:[post.url absoluteString] forKey:@"link"];
        [wallPost setObject:theme.displayname forKey:@"name"];
        [wallPost setObject:photo.imageurl forKey:@"picture"];
        [wallPost setObject:theme.hashtags forKey:@"description"];
        
        [self.facebook requestWithGraphPath:@"me/feed" andParams:wallPost andHttpMethod:@"POST" andDelegate:self];
    }
    else {
        NSString* message = @"Must be logged in and have a registered wordpress blog to share";
        [BLLog e:activityName withMessage:message];
    }
    
}

#pragma mark - Facebook Request Delegate
- (void) request:(FBRequest *)request didLoad:(id)result {
       
}
- (void) shareCaptionOnTwitter:(SocialPost*)post {
    
}

- (void) shareCaptionOnWordpress:(NSNumber *)captionID {
    
}

@end
