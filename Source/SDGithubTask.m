//
//  SDGithubTask.m
//  CocoaREST
//
//  Created by Clint Shryock on 3/6/10.
//  Copyright 2010. All rights reserved.
//

#import "SDGithubTask.h"

#import "SDGithubTaskManager.h"

#import "SDNetTask+Subclassing.h"

@implementation SDGithubTask

@synthesize user;
@synthesize repo;

@synthesize name;
@synthesize email;
@synthesize blog;
@synthesize company;
@synthesize location;
@synthesize state;
@synthesize number;


- (id) initWithManager:(SDGithubTaskManager*)newManager {
	if (self = [super initWithManager:newManager]) {
		githubManager = newManager;
		
		type = SDGithubTaskDoNothing;
		errorCode = SDNetTaskErrorNone;
	}
	return self;
}

// MARK: -
// MARK: Before-response Methods

- (BOOL) validateType {
	return (type > SDGithubTaskDoNothing && type < SDGithubTaskMAX);
}

//  Using each user's API Token in place of a password
- (BOOL) shouldUseBasicHTTPAuthentication {
	return NO;
}

- (BOOL) isMultiPartDataBasedOnTaskType {
	BOOL multiPartData = NO;
	
	return multiPartData;
}

- (SDHTTPMethod) methodBasedOnTaskType {
	SDHTTPMethod method = SDHTTPMethodGet;
	switch (type) {
        case SDGithubTaskUserUpdate:
			method = SDHTTPMethodPost;
			break;
    }
    return method;
}

- (NSString*) URLStringBasedOnTaskType 
{
    switch (type) {
		case SDGithubTaskGetRepos:
			return [NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@", user];
			break;
        case SDGithubTaskGetRepoNetwork:
            return [NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@/%@/network", user, repo];
            break;
        case SDGithubTaskUserShow:
            return [NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@", user];
            break;
        case SDGithubTaskUserUpdate:    //  update by adding updating fields in addParametersToDictionary:
            return [NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@", githubManager.username];
            break;     
        case SDGithubTaskIssuesList:    
            return [NSString stringWithFormat:@"https://github.com/api/v2/json/issues/list/%@/%@/%@", user, repo, state];
            break;
        case SDGithubTaskIssuesShow:    
            return [NSString stringWithFormat:@"https://github.com/api/v2/json/issues/show/%@/%@/%@", user, repo, number];
            break;     
        case SDGithubTaskIssuesComments:    
            return [NSString stringWithFormat:@"https://github.com/api/v2/json/issues/comments/%@/%@/%@", user, repo, number];
        case SDGithubTaskNetworkMeta:
            return [NSString stringWithFormat:@"https://github.com/%@/%@/network_meta", user, repo];
        case SDGithubTaskNetworkData:
            return [NSString stringWithFormat:@"https://github.com/%@/%@/network_data_chunk", user, repo];            
            break;
    }
    return nil;
}

- (void) addParametersToDictionary:(NSMutableDictionary*)parameters 
{
    if(name && [name isNotEqualTo:@""])
		[parameters setObject:name forKey:@"values[name]"];
	
	if(email && [email isNotEqualTo:@""])
		[parameters setObject:email forKey:@"values[email]"];
    
    if(blog && [blog isNotEqualTo:@""])
		[parameters setObject:name forKey:@"values[blog]"];
	
	if(company && [company isNotEqualTo:@""])
		[parameters setObject:email forKey:@"values[company]"];
    
	if(location && [location isNotEqualTo:@""])
		[parameters setObject:location forKey:@"values[location]"];
    
    if(nethash && [nethash isNotEqualTo:@""])
		[parameters setObject:nethash forKey:@"nethash"];
    
    
	if(([githubManager.username isNotEqualTo:@""]) && ([githubManager.password isNotEqualTo:@""])) {
		[parameters setObject:githubManager.username forKey:@"login"];
		[parameters setObject:githubManager.password forKey:@"token"];
    }
}

- (SDParseFormat) parseFormatBasedOnTaskType {
	// there may be some calls which return just a single string, without JSON formatting
	// if so, then we need to make this method conditional
	return SDParseFormatJSON;
}

- (void) sendResultsToDelegate {
	if ([results isKindOfClass:[NSDictionary class]] && [[results allKeys] containsObject:@"error"]) {
		error = [NSError errorWithDomain:@"SDNetDomain" code:SDNetTaskErrorServiceDefinedError userInfo:nil];
		[self sendErrorToDelegate];
	}
	else
		[super sendResultsToDelegate];
}

- (void) dealloc {
	[user release], user = nil;
	[repo release], repo = nil;

    [super dealloc];
}
@end
