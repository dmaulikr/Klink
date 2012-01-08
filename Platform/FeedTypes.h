//
//  FeedTypes.h
//  Klink V2
//
//  Created by Bobby Gill on 7/24/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kCAPTION_VOTE,
    kPHOTO_VOTE,
    kCAPTION_ADDED,
    kDRAFT_SUBMITTED_TO_EDITORS,
    kEDITORIAL_BOARD_VOTE_STARTED,
    kDRAFT_PUBLISHED,
    kDRAFT_EXPIRED,
    kPHOTO_ADDED_TO_DRAFT,
    kPROMOTION_TO_EDITOR,
    kDEMOTION_FROM_EDITOR,
    kEDITORIAL_BOARD_VOTE_ENDED,
    kDRAFT_NOT_PUBLISHED,
    kEDITORIAL_BOARD_NO_RESULT,
    kDRAFT_LEADER_CHANGED,
    kEDITORIAL_BOARD_VOTE_CAST,    
    kPHOTO_UNAUTHENTICATED_VOTE,
    kCAPTION_UNAUTHENTICATED_VOTE
} FeedEvent;

typedef enum {
  
    //the following are generic notification types specified for future expansion
    kGENERIC_EDITORIAL_POST_VOTE,
    kGENERIC_FULLSCREEN,
    kGENERIC_DRAFT,
    kGENERIC_USER,
    kGENERIC_MESSAGE,
    kGENERIC_BOOK,
    kGENERIC_EDITORIAL
} FeedRenderType;