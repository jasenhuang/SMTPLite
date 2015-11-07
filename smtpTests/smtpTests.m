//
//  smtpTests.m
//  smtpTests
//
//  Created by jasenhuang on 15/9/15.
//  Copyright (c) 2015年 jasenhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SMTPMessage.h"

@interface smtpTests : XCTestCase

@end

@implementation smtpTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    SMTPMessage *message = [[SMTPMessage alloc] init];
    message.from = @"from@domain.com";
    message.to = @"to@domain.com";
    message.host = @"smtp.domain.com";
    message.account = @"accout@domain.com";
    message.pwd = @"***";
    
    message.subject = @"from jasenhuang";
    message.content  =@"this is a html!<br/>not plain text<br/>";
    message.contentType = @"text/html";
    SMTPAttachment* attach = [[SMTPAttachment alloc] init];
    attach.name = @"image.png";
    attach.filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"image" ofType:@"png"];
    message.attachments = @[attach];
    
    [message send:^(SMTPMessage * message, double now, double total) {
        
    } success:^(SMTPMessage * message) {
        NSLog(@"response = %@", [[NSString alloc] initWithData:message.response encoding:NSUTF8StringEncoding]);
    } failure:^(SMTPMessage * message, NSError * error) {
        NSLog(@"error = %@", error);
    }];
    
    sleep(30);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
