//
//  SMTPMessage.h
//  smtp
//
//  Created by jasenhuang on 15/9/15.
//  Copyright (c) 2015年 jasenhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMTPMessage;
typedef void (^SMTPProgressCallback)(SMTPMessage* message, double now, double total);
typedef void (^SMTPSuccessCallback)(SMTPMessage* message);
typedef void (^SMTPFailureCallback)(SMTPMessage* message, NSError* error);

@interface SMTPAttachment : NSObject
@property(nonatomic,copy) NSString* name;
@property(nonatomic,copy) NSString* filePath;
@end

@interface SMTPMessage : NSObject

@property(nonatomic, copy) NSString* from;
@property(nonatomic, copy) NSString* to;
@property(nonatomic, copy) NSArray* ccs;
@property(nonatomic, copy) NSArray* bccs;
@property(nonatomic, copy) NSString* subject;
@property(nonatomic, copy) NSString* content;
@property(nonatomic, copy) NSString* contentType;
@property(nonatomic, copy) NSArray* attachments; //SMTPAttachment

@property(nonatomic, copy) NSString* account;
@property(nonatomic, copy) NSString* pwd;
@property(nonatomic, copy) NSString* host;
@property(nonatomic, copy) NSString* port;
@property(nonatomic, assign) BOOL ssl;
@property(nonatomic, assign) long timeout;
@property(nonatomic, assign) long connectTimeout;
@property(nonatomic, copy) SMTPProgressCallback progressCallback;
@property(nonatomic, copy) SMTPSuccessCallback successCallback;
@property(nonatomic, copy) SMTPFailureCallback failureCallback;
@property(nonatomic, assign) BOOL cancel;
@property(nonatomic, strong) NSMutableData* response;

- (void)send:(void (^)(SMTPMessage* message, double now, double total)) progressCallback
     success:(void (^)(SMTPMessage* message))successCallback
     failure:(void (^)(SMTPMessage* message, NSError* error))failureCallback;

@end
