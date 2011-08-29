//
//  WS_TransferManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/24/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "WS_TransferManager.h"


@implementation WS_TransferManager
@synthesize putQueue;
static  WS_TransferManager* sharedManager;  

+ (WS_TransferManager*) getInstance {
    NSString* activityName = @"WS_TransferManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        } 
        [BLLog v:activityName withMessage:@"completed initialization"];
        return sharedManager;
    }
}

- (id)init {
    self = [super init];
    self.putQueue = [[NSOperationQueue alloc] init];
    return self;

}

- (void) shareCaptionViaCloud:(NSNumber *)captionid {
    NSString* activityName = @"WS_TransferManager.shareCaption:";
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    AuthenticationContext* authnContext = [authnManager getAuthenticationContext];
    
    if (authnContext != nil &&
        [authnContext hasWordpress]) {
        
        NSURL* url = [UrlManager getShareCaptionURL:captionid withAuthenticationContext:authnContext];
    
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:@"a" forKey:@""];
        [request setDelegate:self];
        [request setTimeOutSeconds:130];
        [request setDidFinishSelector:@selector(onShareCaptionComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"shared caption %@ at url: %@",captionid,url];
        [BLLog v:activityName withMessage:message];
        [message release];
       

        
        
    }

    
    
}


- (void) uploadAttachmentToCloud:(Attachment*)attachment onFinishNotify:(NSString*)notificationID {
    [self uploadAttachementToCloud:attachment.objectid withObjectType:attachment.objecttype forAttributeName:attachment.attributename atFileLocation:attachment.filelocation onFinishNotify:notificationID];
}

- (void) uploadAttachementToCloud:
    (NSNumber*)objectid 
    withObjectType:(NSString*)objectType 
    forAttributeName:(NSString*)attributeName 
    atFileLocation:(NSString*)path 
    onFinishNotify:(NSString *)notificationID{
    
    NSString* activityName = @"WS_TransferManager.uploadAttachementToCloud:";
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getUploadAttachmentURL:objectid withObjectType:objectType forAttributeName:attributeName withAuthenticationContext:authenticationContext];
      
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init ];
        [userInfo setValue:objectid forKey:an_OBJECTID];
        [userInfo setValue:objectType forKey:an_OBJECTTYPE];
        [userInfo setValue:attributeName forKey:an_ATTRIBUTENAME];
        [userInfo setValue:path forKey:an_FILELOCATION];
        [userInfo setValue:notificationID forKey:an_ONFINISHNOTIFY];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setFile:path forKey:@"attachment"];
        request.userInfo = userInfo;
        [request setDelegate:self];
        [request setTimeOutSeconds:130];
        [request setDidFinishSelector:@selector(onUploadAttachmentComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
        [userInfo release];
    }

}

- (void) createObjectInCloud:(NSNumber *)objectid withObjectType:(NSString *)objecttype onFinishNotify:(NSString *)notificationID{
    NSString* activityName = @"WS_TransferManager.createObjectInCloud:";
    ServerManagedResource* object = [DataLayer getObjectByID:objectid withObjectType:objecttype];
    NSDictionary* jsonObject = [object toJSON];
    NSString* jsonRepresentation = [jsonObject JSONString];
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    NSArray* objectids = [NSArray arrayWithObject:objectid];
    NSArray* objectTypes = [NSArray arrayWithObject:objecttype];
    NSArray* objectsToCreate = [NSArray arrayWithObject:jsonRepresentation];
    
    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getCreateObjectsURL:objectids withObjectTypes:objectTypes withAuthenticationContext:authenticationContext];

        NSError* error = nil;        
        NSString* json = [objectsToCreate JSONStringWithOptions:JKSerializeOptionNone error:&error];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:notificationID forKey:an_ONFINISHNOTIFY];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:json forKey:@""];
        request.userInfo = userInfo;
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(onCreateSingleObjectComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
        
    }
}

- (void) createObjectInCloud:(NSNumber*) objectid withObjectType:(NSString*)objecttype withAttachmentFor:(NSString*)attributeName atFileLocation:(NSString*)path {
    NSString* activityName = @"WS_TransferManager.createObjectInCloud:";
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    NSArray* objectids = [NSArray arrayWithObject:objectid];
    NSArray* objectTypes = [NSArray arrayWithObject:objecttype];
    
    ServerManagedResource* object = [DataLayer getObjectByID:objectid withObjectType:objecttype];
    NSDictionary* jsonObject = [object toJSON];
    NSString* jsonRepresentation = [jsonObject JSONString];
    
    NSArray* objectsToCreate = [NSArray arrayWithObject:jsonRepresentation];
    
    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getCreateObjectsURL:objectids withObjectTypes:objectTypes withAuthenticationContext:authenticationContext];
        
        Attachment* attachment = [[Attachment alloc]init];
        attachment.objectid = objectid;
        attachment.objecttype = objecttype;
        attachment.attributename = attributeName;
        attachment.filelocation = path;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:attachment forKey:tn_ATTACHMENT];
                                          
        NSError* error = nil;
        
        NSString* json = [objectsToCreate JSONStringWithOptions:JKSerializeOptionNone error:&error];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:json forKey:@""];
        request.userInfo = userInfo;
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(onCreateSingleObjectComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
        
    }

}

- (void) createObjectsInCloud:
              (NSArray*)objectids 
              withObjectTypes:(NSArray*)objectTypes 
              withAttachments:(NSArray*)attachments
              onFinishNotify:(NSString *)notificationID{
  
    [self createObjectsInCloud:objectids withObjectTypes:objectTypes withAttachments:attachments useProgressView:nil onFinishNotify:notificationID];
}

- (void) createObjectsInCloud:(NSArray*)objectids 
              withObjectTypes:(NSArray*)objectTypes 
              withAttachments:(NSArray *)attachments
              useProgressView:(UIProgressView *)progressView
              onFinishNotify:(NSString *)notificationID{
    
    
    NSString* activityName = @"WS_TransferManager.createObjectsInCloud:";


    NSMutableArray *objectsToCreate = [[NSMutableArray alloc]initWithCapacity:[objectids count]];
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    for (int i = 0; i < [objectids count];i++) {
       ServerManagedResource* resource =  [DataLayer getObjectByID:[objectids objectAtIndex:i] withObjectType:[objectTypes objectAtIndex:i]];
        
        NSError* error = nil;
        NSDictionary* jsonDictionary = [resource toJSON];
        NSString* jsonRepresentation = [jsonDictionary JSONStringWithOptions:flags error:&error];
        [objectsToCreate insertObject:jsonRepresentation atIndex:i];
        
    }
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
   

    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getCreateObjectsURL:objectids withObjectTypes:objectTypes withAuthenticationContext:authenticationContext];
        
        NSString* json = [objectsToCreate JSONString];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:json forKey:@""];    
        
        NSMutableDictionary* dictionary = nil;
        if (attachments != nil && [attachments count]>0) {
             dictionary = [NSMutableDictionary dictionaryWithObject:attachments forKey:tn_ATTACHMENT];
            
            
        }
        
        if (notificationID != nil) {
            if (dictionary == nil) {
                dictionary = [NSMutableDictionary dictionaryWithObject:notificationID forKey:an_ONFINISHNOTIFY];
            }
            else {
                [dictionary setObject:notificationID forKey:an_ONFINISHNOTIFY];
            }
        }
        
        if (dictionary != nil) {
            request.userInfo = dictionary;
        }
        [request setUploadProgressDelegate:progressView];    
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(onCreateComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
    }
        
      
    

    
}

- (void) deleteObjectInCloud:(NSNumber*)objectid withObjectType:(NSString*)objectType {
//    NSString* activityName = @"WS_TransferManager.deleteObjectInCloud";
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    if (authenticationContext != nil) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setObject:objectid forKey:an_OBJECTID];
        [userInfo setObject:objectType forKey:an_OBJECTTYPE];
        
        NSURL* url = [UrlManager getDeleteURL:objectid withObjectType:objectType withAuthenticationContext:authenticationContext];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
        request.delegate = self;
        request.userInfo = userInfo;
        [request setPostValue:@"dicks" forKey:@""];
        [request setDidFinishSelector:@selector(onDeleteComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        [userInfo release];
        
    }
    
    
}


- (void) updateObjectInCloud:(NSNumber*)objectid withObjectType:(NSString*)objectType{
    NSString* activityName = @"WS_TransferManager.updateObjectInCloud:";
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
        
    NSEntityDescription *description = [NSEntityDescription entityForName:objectType inManagedObjectContext:appContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",an_OBJECTID,objectid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:description];
    
    NSError* error = nil;
    
    NSArray* results = [[appContext executeFetchRequest:fetchRequest error:&error]retain];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"unable to retrieve object id: %@ of type %@",objectid,objectType];
        [BLLog e:activityName withMessage:message];
        
    }
    else if ([results count] != 1) {
        NSString* message = [NSString stringWithFormat:@"unable to uniquely locate object id: %@ of type: %@",objectid,objectType];
        [BLLog e:activityName withMessage:message];

    } else {
        ServerManagedResource *resource  = [results objectAtIndex:0];
        
        NSError* error = nil;
        JKSerializeOptionFlags flags = JKSerializeOptionNone;
        NSDictionary* jsonDictionary = (NSDictionary*)[resource toJSON];
        NSString* jsonRepresentation = [jsonDictionary JSONStringWithOptions:flags error:&error];
        
        AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
       
        
        if (authenticationContext != nil) {
            NSURL *url = [UrlManager getUpdateObjectURL:objectid withObjectType:objectType withAuthenticationContext:authenticationContext];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setPostValue:jsonRepresentation forKey:@""];
                   
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(onPutComplete:)];
            [request setDidFailSelector:@selector(requestWentWrong:)];
            [self.putQueue addOperation:request];
            
            NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
            [BLLog v:activityName withMessage:message];
            [message release];
            
        }
    }
    
   
    
}


- (void) updateAttributeInCloud:
                                (NSNumber*)objectid 
                 withObjectType:(NSString*)objectType 
                   forAttribute:(NSString*)attributeName 
                        byValue:(NSString*)value
                 onFinishNotify:(NSString*)notificationID {
    
    NSString* activityName = @"WS_TransferManager.updateAttributeInCloud";
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getUpdateAttributeURL:objectid withObjectType:objectType forAttribute:attributeName withOperationCode:0 byValue:value withAuthenticationContext:authenticationContext];

        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setObject:objectid forKey:an_OBJECTID];
        [userInfo setObject:objectType forKey:an_OBJECTTYPE];
        [userInfo setObject:attributeName forKey:an_ATTRIBUTENAME];
        [userInfo setObject:notificationID forKey:an_ONFINISHNOTIFY];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.requestMethod = @"POST";
        request.delegate = self;
        request.userInfo = userInfo;
        request.didFinishSelector=@selector(onPutAttributeComplete:);
        request.didFailSelector = @selector(requestWentWrong:);
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted put attribute operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
        [userInfo release];
    }
}

#pragma mark - Asynchronous Response Handlers

- (void) onShareCaptionComplete:(ASIHTTPRequest*) request {
    NSString* activityName = @"WS_TransferManager.onPutAttributeComplete";
    NSString* message = [NSString stringWithFormat:@"Caption shared successfully"];
    [BLLog v:activityName withMessage:message];
    
}
//Generic put response handling method that can be used on both cases
- (void) onPutAttributeComplete:(ASIHTTPRequest*) request {
    NSString* activityName = @"WS_TransferManager.onPutAttributeComplete";
    NSString* response = [request responseString];
    
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    PutResponse* putResponse = [[PutResponse alloc]initFromDictionary:jsonDictionary];
    
    ServerManagedResource* returnedObject = nil;
    NSArray* secondaryObjects = nil;
    
    if (putResponse.didSucceed == [NSNumber numberWithBool:YES]) {
        returnedObject = [putResponse.modifiedResource retain];
        secondaryObjects = [putResponse.secondaryResults retain];
        
        NSDictionary *userInfo = request.userInfo;
        NSString* objectid = [userInfo objectForKey:an_OBJECTID];
        NSString* objectType = [userInfo objectForKey:an_OBJECTTYPE];
        NSString* attributeName = [userInfo objectForKey:an_ATTRIBUTENAME];
            
        [ServerManagedResource refreshWithServerVersion:returnedObject];
        
        for (int i = 0; i < [secondaryObjects count];i++) {
            ServerManagedResource* secondaryObject = [secondaryObjects objectAtIndex:i];
            [ServerManagedResource refreshWithServerVersion:secondaryObject];
        }
        
        
        NSString* message = [NSString stringWithFormat:@"Attribute: %@ on %@ with id %@", objectid,objectType,attributeName];
        [BLLog v:activityName withMessage:message];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        NSString* notificationID = [userInfo objectForKey:an_ONFINISHNOTIFY];
        [notificationCenter postNotificationName:notificationID object:self userInfo:userInfo];
        
        [returnedObject release];
        [secondaryObjects release];
    }
    else {
        NSString* errorMessage = @"Put Attribute operation failed";
        [BLLog e:activityName withMessage:errorMessage];
    }
}

-(void) onUploadAttachmentComplete:(ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onUploadComplete:";
    NSString* response = [request responseString];
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    PutResponse *putResponse = [[PutResponse alloc]initFromDictionary:jsonDictionary];
    
    if (putResponse.didSucceed == [NSNumber numberWithBool:YES]) {
        
        NSDictionary* userInfo = request.userInfo;
        
        NSString* objectType = [userInfo valueForKey:an_OBJECTTYPE];
        NSNumber* objectID = [userInfo valueForKey:an_OBJECTID];
        NSString* attributeName = [userInfo valueForKey:an_ATTRIBUTENAME];
        NSString* notificationID = [userInfo valueForKey:an_ONFINISHNOTIFY];
        
        ServerManagedResource* returnedObject = putResponse.modifiedResource;
        NSString* newAttachmentAttributeValue = [returnedObject valueForKey:attributeName];
        ServerManagedResource* resource = [DataLayer getObjectByID:objectID withObjectType:objectType];
        
        
        
        [BLLog v:activityName withMessage:@"successfully completed for objectID:%@, objectType:%@, attributeName:%@ with new value %@",
         objectID,objectType,attributeName,newAttachmentAttributeValue];
        
        //now we update the attribute that was set to reflect the new attribute value;
        [resource setValue:newAttachmentAttributeValue forKey:attributeName];
        [resource commitChangesToDatabase:NO withPendingFlag:NO];
        
        //notify all interested parties that this attachment has been uploaded
        if (notificationID != nil) {
            NSMutableDictionary* notificationUserInfoDictionary = [[[NSMutableDictionary alloc]init]autorelease];
            [notificationUserInfoDictionary setObject:objectType forKey:an_OBJECTTYPE];
            [notificationUserInfoDictionary setObject:objectID forKey:an_OBJECTID];
            [notificationUserInfoDictionary setObject:attributeName forKey:an_ATTRIBUTENAME];
            
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:notificationID object:self userInfo:notificationUserInfoDictionary];
        }
    }
    else {
        [BLLog e:activityName withMessage:@"failed to upload attachment"];
    }
    
    
    
    
}

- (void) onPutComplete:(ASIFormDataRequest*)request{
    NSString* activityName = @"WS_TransferManager.onPutComplete:";
    NSString* response = [request responseString];
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    PutResponse* putResponse = [[PutResponse alloc]initFromDictionary:jsonDictionary];
    
    NSString* message2 = [NSString stringWithFormat:@"put operation compeleted with success:%@",putResponse.didSucceed];
    [BLLog v:activityName withMessage:message2];
       
    ServerManagedResource* downloadedResource = putResponse.modifiedResource;
    
    if (downloadedResource != nil) {
        [ServerManagedResource refreshWithServerVersion:downloadedResource];

    }
}



- (void) onDeleteComplete:(ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onDeleteComplete:";
    NSDictionary* jsonResponse = [[request responseString] objectFromJSONString];
    Response* response = [[Response alloc]initFromDictionary:jsonResponse];
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* message = nil;
    if ([response.didSucceed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        message = [NSString stringWithFormat:@"deletion succeeded"];
        [BLLog v:activityName withMessage:message];
        
        NSDictionary* userInfo = [request userInfo];
        NSNumber* objectID =(NSNumber*) [userInfo valueForKey:an_OBJECTID];
        NSString* objectType = [userInfo valueForKey:an_OBJECTTYPE];
        
        //need to remove the deleted object record from the system table
        
        NSManagedObjectContext *appContext = appDelegate.systemObjectContext;
        NSEntityDescription *description = [NSEntityDescription entityForName:tn_DELETEDOBJECT inManagedObjectContext:appContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        [fetchRequest setEntity:description];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@",an_OBJECTID,objectID,an_OBJECTTYPE,objectType];
        
        [fetchRequest setPredicate:predicate];
        
        NSError* error = nil;
        NSArray* returnedResults = [appContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil) {
            message = [NSString stringWithFormat:@"Failed to retrieve deleted object record for %@ with type %@",objectID,objectType];
            [BLLog e:activityName withMessage:message];
        }
        else {
            NSManagedObject* deletedObjectRecord = [returnedResults objectAtIndex:0];
            [appContext deleteObject:deletedObjectRecord];
            error = nil;
            
            [appContext save:&error];
            
            if (error != nil) {
                message = [NSString stringWithFormat:@"could not delete deleted object record for %@ with type %@",objectID,objectType];
                [BLLog e:activityName withMessage:message];
            }
            
        }
        
        [fetchRequest release];
        
    }
    else {
        message = [NSString stringWithFormat:@"deletion failed"];
        [BLLog e:activityName withMessage:message];
    }
    
    
}

-(void) onCreateSingleObjectComplete : (ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onCreateWithAttachementComplete:";
    
    NSString* response = [request responseString];
    NSDictionary* jsonDictionary = [response objectFromJSONString];
    CreateResponse *createResponse = [[CreateResponse alloc]initFromDictionary:jsonDictionary];
    
    if (createResponse.didSucceed) {
        //now we need to process any attachments that are to be uploaded apres the creation of the object
        NSDictionary* userInfo = request.userInfo;
        NSString* notificationID = nil;
        
        if ([userInfo objectForKey:an_ONFINISHNOTIFY] != nil) {
            notificationID = [userInfo objectForKey:an_ONFINISHNOTIFY];
        }
        
        if ([userInfo objectForKey:tn_ATTACHMENT] != nil) {
            //we have a file attachment to upload
            Attachment *attachment = [userInfo valueForKey:tn_ATTACHMENT];
            
            NSString* message = [NSString stringWithFormat:@"Processing attachment for objectid:%@, objecttype:%@,attributename:%@,filelocation:%@",attachment.objectid,attachment.objecttype,attachment.attributename,attachment.filelocation];
            [BLLog v:activityName withMessage:message];
            [self uploadAttachmentToCloud:attachment onFinishNotify:notificationID];
        }
        
        //send notification to all interested parties
        if (notificationID != nil) {
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            NSMutableDictionary* notificationUserInfo = [[[NSMutableDictionary alloc]init]autorelease];
            [notificationCenter postNotificationName:notificationID object:self userInfo:notificationUserInfo];
        }
        
    }
    else {
        NSString* message = [NSString stringWithFormat:@"Create operation failed"];
        [BLLog e:activityName withMessage:message];
    }
    
    [createResponse release];
    
}

- (void) onCreateComplete:(ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onCreateComplete:";
    NSString* response = [request responseString];
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    CreateResponse *createResponse = [[CreateResponse alloc] initFromDictionary:jsonDictionary];
    
    NSString* message2 = [NSString stringWithFormat:@"create operation compeleted with success:%@",createResponse.didSucceed];
    [BLLog v:activityName withMessage:message2];
    
    
    //need to grab the instance from the core data model
    ServerManagedResource* createdResource = nil;
    if (createResponse.createdResources != nil){
        for (int i = 0; i < [createResponse.createdResources count]; i++) {
            createdResource = [createResponse.createdResources objectAtIndex:i];
            [ServerManagedResource refreshWithServerVersion:createdResource];
            

        }
    }
    
    //process any attachments to the original create request
    NSDictionary* userInfo = request.userInfo;
    NSString* notificationID = nil;
    
    if ([userInfo objectForKey:an_ONFINISHNOTIFY] != nil) {
        notificationID = [userInfo objectForKey:an_ONFINISHNOTIFY];
    }
    
    if ([userInfo valueForKey:tn_ATTACHMENT] != [NSNull null]) {
        NSArray* attachments = [userInfo valueForKey:tn_ATTACHMENT];
        for (int i = 0; i < [attachments count] ; i++) {
            Attachment* attachment = [attachments objectAtIndex:i];
            NSString* message = [NSString stringWithFormat:@"Processing attachment for objectid:%@, objecttype:%@,attributename:%@,filelocation:%@",attachment.objectid,attachment.objecttype,attachment.attributename,attachment.filelocation];
            [BLLog v:activityName withMessage:message];
            
            [self uploadAttachmentToCloud:attachment onFinishNotify:notificationID];
        }
    }
    
    //now we launch a notification if subscribed for the creation of the original object
    if (notificationID != nil && createdResource != nil) {
        NSMutableDictionary* notificationUserInfoDictionary = [[[NSMutableDictionary alloc]init]autorelease];
        [notificationUserInfoDictionary setObject:createdResource.objecttype forKey:an_OBJECTTYPE];
        [notificationUserInfoDictionary setObject:createdResource.objectid forKey:an_OBJECTID];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:notificationID object:self userInfo:notificationUserInfoDictionary];
        
    }
    
    [createResponse release];
}

- (void) requestWentWrong:(ASIFormDataRequest*) request {
      NSString* activityName = @"WS_TransferManager.requestWentWrong:";
    [BLLog e:activityName withMessage:@" submit operation failed"];
}

@end
