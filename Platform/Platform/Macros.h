//
//  Macros.h
//  Platform
//
//  Created by Bobby Gill on 10/17/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#define kMessage    @"message"
#define kCustomView @"customview"
#define kMaximumTimeInSeconds @"maximumtimeinseconds"
#ifdef DEBUG
#define LOG_SECURITY(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"security",level,__VA_ARGS__)
#define LOG_REQUEST(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"request",level,__VA_ARGS__)
#define LOG_RESOURCE(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"resource",level,__VA_ARGS__)
#define LOG_RESOURCECONTEXT(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"resourcecontext",level,__VA_ARGS__)
#define LOG_HTTP(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"http",level,__VA_ARGS__)
#define LOG_CONFIGURATION(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"configuration",level,__VA_ARGS__)
#define LOG_ENUMERATION(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"enumeration",level,__VA_ARGS__)
#define LOG_FEED(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"feed",level,__VA_ARGS__)
#define LOG_IMAGE(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"image",level,__VA_ARGS__)
#define LOG_PAGEVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"pageviewcontroller",level,__VA_ARGS__)
#define LOG_BOOKLASTPAGEVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"pageviewcontroller",level,__VA_ARGS__)
#define LOG_BOOKVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"bookviewcontroller",level,__VA_ARGS__)
#define LOG_DRAFTVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"draftviewcontroller",level,__VA_ARGS__)
#define LOG_PRODUCTIONLOGVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"productionlogviewcontroller",level,__VA_ARGS__)
#define LOG_FULLSCREENPHOTOVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"fullscreenphotoviewcontroller",level,__VA_ARGS__)
#define LOG_CONTRIBUTEVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"contributeviewcontroller",level,__VA_ARGS__)
#define LOG_PERSONALLOGVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"personallogviewcontroller",level,__VA_ARGS__)
#define LOG_PEOPLELISTVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"peoplelistviewcontroller",level,__VA_ARGS__)
#define LOG_HOMEVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"homeviewcontroller",level,__VA_ARGS__)
#define LOG_NOTIFICATIONICON(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"notificationicon",level,__VA_ARGS__)
#define LOG_EVENTMANAGER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"eventmanager",level,__VA_ARGS__)
#define LOG_FEEDMANAGER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"feedmanager",level,__VA_ARGS__)

#define LOG_LOGINVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"loginviewcontroller",level,__VA_ARGS__)

#define LOG_OVERLAYVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"overlayviewcontroller",level,__VA_ARGS__)

#define LOG_UIDRAFTVIEW(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"uidraftview",level,__VA_ARGS__)
#define LOG_UIVOTEPAGEVIEW(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"uivotepageview",level,__VA_ARGS__)

#define LOG_BASEVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"baseviewcontroller",level,__VA_ARGS__)

#define LOG_NOTIFICATIONVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"notificationviewcontroller",level,__VA_ARGS__)

#define LOG_UIPRODUCTIONLOGTABLEVIEWCELL(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"uiproductionlogtableviewcell",level,__VA_ARGS__)

#define LOG_SOCIALSHARINGMANAGER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"socialsharingmanager",level,__VA_ARGS__)
#define LOG_RESPONSE(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"response",level,__VA_ARGS__) 

#define LOG_EDITORVOTEVIEWCONTROLLER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"editorvotingviewcontroller",level,__VA_ARGS__)

#define LOG_APPLICATIONSETTINGSMANAGER(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"applicationsettingsmanager",level,__VA_ARGS__)

#define LOG_PROGRESSVIEW(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"progressview",level,__VA_ARGS__)
#else
#define LOG_NETWORK(...)    do{}while(0)
#define LOG_GENERAL(...)    do{}while(0)
#define LOG_SECURITY(...)    do{}while(0)
#define LOG_GRAPHICS(...)   do{}while(0)
#define LOG_REQUEST(...)   do{}while(0)
#define LOG_RESOURCE(...)   do{}while(0)
#define LOG_RESOURCECONTEXT(...)   do{}while(0)
#define LOG_HTTP(...)   do{}while(0)
#define LOG_CONFIGURATION(...)   do{}while(0)
#define LOG_ENUMERATION(...)   do{}while(0)
#define LOG_FEED(...)   do{}while(0)
#define LOG_IMAGE(...)   do{}while(0)
#define LOG_PAGEVIEWCONTROLLER(...)   do{}while(0)
#define LOG_BOOKVIEWCONTROLLER(...)   do{}while(0)
#define LOG_DRAFTVIEWCONTROLLER(...)   do{}while(0)
#define LOG_PRODUCTIONLOGVIEWCONTROLLER(...)   do{}while(0)
#define LOG_FULLSCREENPHOTOVIEWCONTROLLER(...)   do{}while(0)
#define LOG_CONTRIBUTEVIEWCONTROLLER(...)   do{}while(0)
#define LOG_PERSONALLOGVIEWCONTROLLER(...)   do{}while(0)
#define LOG_HOMEVIEWCONTROLLER(...)   do{}while(0)
#define LOG_NOTIFICATIONICON(...)   do{}while(0)
#define LOG_EVENTMANAGER(...)   do{}while(0)
#define LOG_FEEDMANAGER(...)   do{}while(0)
#define LOG_LOGINVIEWCONTROLLER(...)   do{}while(0)
#define LOG_PROGRESSVIEW(...)   do{}while(0)

#define LOG_OVERLAYVIEWCONTROLLER(...)   do{}while(0)
#define LOG_UIDRAFTVIEW(...)   do{}while(0)
#define LOG_DRAFTVIEWCONTROLLER(...)   do{}while(0)
#define LOG_UIVOTEPAGEVIEW(...)   do{}while(0)
#define LOG_BASEVIEWCONTROLLER(...)   do{}while(0)
#define LOG_NOTIFICATIONVIEWCONTROLLER(...)   do{}while(0)
#define LOG_UIPRODUCTIONLOGTABLEVIEWCELL(...)   do{}while(0)
#define LOG_SOCIALSHARINGMANAGER(...)   do{}while(0)
#define LOG_RESPONSE(...)   do{}while(0)
#define LOG_EDITORVOTEVIEWCONTROLLER(...)   do{}while(0)
#define LOG_APPLICATIONSETTINGSMANAGER(...)   do{}while(0)
#define LOG_BOOKLASTPAGEVIEWCONTROLLER (...)    do{}while(0)
#define LOG_PEOPLELISTVIEWCONTROLLER(level, ...)   do{}while(0)





#endif