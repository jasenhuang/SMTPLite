//
//  SMTPMessage.m
//  smtp
//
//  Created by jasenhuang on 15/9/15.
//  Copyright (c) 2015年 jasenhuang. All rights reserved.
//

#import "SMTPMessage.h"
#include "curl.h"

size_t write_callback(void* ptr, size_t size, size_t nmemb, void* context)
{
    size_t ret = size * nmemb ;
    if (ret < 1)
        return ret ;
    SMTPMessage* message = (__bridge SMTPMessage*)context ;
    if (!message.response.length){
        message.response = [NSMutableData data];
    }
    [message.response appendBytes:ptr length:size * nmemb];
    return 0 ;
}
size_t header_callback(char *buffer, size_t size, size_t nitems,void *context)
{
    if(size * nitems < 1) return 0;
    SMTPMessage* message = (__bridge SMTPMessage*)context ;
    NSString* command = [[NSString alloc] initWithBytes:buffer length:nitems * size encoding:NSUTF8StringEncoding];
    if ([command rangeOfString:@"Error"].location != NSNotFound) {
        if (!message.response.length){
            message.response = [NSMutableData data];
        }
        [message.response appendBytes:buffer length:size * nitems];
    }
    return size * nitems;
}
size_t progress_callback( void *context , double dltotal , double dlnow , double ultotal, double ulnow)
{
    SMTPMessage* message = (__bridge SMTPMessage*)context;
    if (message.progressCallback && ulnow){
        message.progressCallback(message, ulnow, ultotal);
    }
    return message.cancel?1:0;
}

@interface SMTPMessage()
{
    FILE* _fd;
    NSString* _filePath;
    CURL* _handler;
    struct curl_slist * _recipients;
    
    NSString* _boundary;
}
@end

@implementation SMTPAttachment
@end

@implementation SMTPMessage
- (instancetype)init
{
    self = [super init];
    if (self) {
        _host = @"smtp.qq.com";
        _port = @"465";
        _ssl = YES;
        _cancel = NO;
        _connectTimeout = 20000L;
        _timeout = 60000L;
        _recipients = NULL;
        _fd = NULL;
        _contentType = @"text/html";
        _handler = curl_easy_init();
        _boundary = [NSString stringWithFormat:@"----=_NextPart_%@", @(time(0))];
        
    }
    return self;
}
- (void)dealloc
{
    curl_slist_free_all(_recipients);
    _recipients = NULL;
    
    curl_easy_cleanup(_handler);
    _handler = NULL;
    
    if (_fd) fclose(_fd),_fd = NULL;
}

- (void)send:(void (^)(SMTPMessage*, double, double)) progressCallback
     success:(void (^)(SMTPMessage*))successCallback
     failure:(void (^)(SMTPMessage*, NSError *))failureCallback
{
    _progressCallback = progressCallback;
    _successCallback = successCallback;
    _failureCallback = failureCallback;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CURLcode code = [self send];
        if (code != CURLE_OK) {
            if (_successCallback) _successCallback(self);
        }else{
            NSError* error = [NSError errorWithDomain:@"com.nextfun.SMTPMessage" code:code
                                             userInfo:@{@"msg":[NSString stringWithUTF8String:curl_easy_strerror(code)]}];
            NSLog(@"SMTPMessage send error:%@", error);
            if (_failureCallback) _failureCallback(self, error);
        }
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    });
}
- (CURLcode)send
{
    NSAssert(_host.length, @"host is nil");
    NSAssert(_account.length, @"accout is nil");
    NSAssert(_pwd.length, @"password is nil");
    
    if (!_handler) return CURLE_FAILED_INIT;
    
    NSString* host = nil;
    if (_ssl) {
        host = [NSString stringWithFormat:@"smtps://%@:%@", _host, _port];
    }else{
        host = [NSString stringWithFormat:@"smtp://%@:%@", _host, _port];
    }
    curl_easy_setopt(_handler, CURLOPT_URL, [host UTF8String]);
    curl_easy_setopt(_handler, CURLOPT_CONNECTTIMEOUT_MS, _connectTimeout);
    curl_easy_setopt(_handler, CURLOPT_TIMEOUT_MS, _timeout);
    
    curl_easy_setopt(_handler, CURLOPT_USERNAME, [_account UTF8String]);
    curl_easy_setopt(_handler, CURLOPT_PASSWORD, [_pwd UTF8String]);
    
    NSString* from = [NSString stringWithFormat:@"<%@>", _from];
    curl_easy_setopt(_handler, CURLOPT_MAIL_FROM, [from UTF8String]);
    
    NSString* to = [NSString stringWithFormat:@"<%@>", _to];
    _recipients = curl_slist_append(_recipients, [to UTF8String]);
    for (NSString* cc in _ccs) {
        _recipients = curl_slist_append(_recipients, [cc UTF8String]);
    }
    for (NSString* bcc in _bccs) {
        _recipients = curl_slist_append(_recipients, [bcc UTF8String]);
    }
    curl_easy_setopt(_handler, CURLOPT_MAIL_RCPT, _recipients);
    curl_easy_setopt(_handler, CURLOPT_WRITEDATA, self);
    curl_easy_setopt(_handler, CURLOPT_WRITEFUNCTION, &write_callback);
    curl_easy_setopt(_handler, CURLOPT_HEADERDATA, self);
    curl_easy_setopt(_handler, CURLOPT_HEADERFUNCTION, &header_callback);
    curl_easy_setopt(_handler, CURLOPT_PROGRESSDATA, self);
    curl_easy_setopt(_handler, CURLOPT_PROGRESSFUNCTION, &progress_callback);
    curl_easy_setopt(_handler, CURLOPT_UPLOAD, 1L);
    
    //build mime data
    _fd = fopen([[self buildMIME] UTF8String], "rb");
    curl_easy_setopt(_handler, CURLOPT_READDATA, _fd);
    
    curl_easy_setopt(_handler, CURLOPT_VERBOSE, 1L);
    
    return curl_easy_perform(_handler);
    
}
- (NSString*)buildMIME
{
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    _filePath = [NSString stringWithFormat:@"%@/smtpdata", cache];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]){
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
    }
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    [fileHandle seekToFileOffset:0];
    [fileHandle truncateFileAtOffset:0];
    
    NSMutableString* mime = [NSMutableString string];
    
    [mime appendFormat:@"Date: %@\r\n", @"Date: Wed, 16 Sep 2015 15:57:09 +0800"];
    
    [mime appendFormat:@"From: <%@>\r\n", _from];
    [mime appendFormat:@"To: <%@>\r\n", _to];
    
    NSMutableString* ccs = [NSMutableString string];
    for (NSString* cc in _ccs) {
        if (ccs.length){
            [ccs appendFormat:@", <%@>", cc];
        }else{
            [ccs appendFormat:@"<%@>", cc];
        }
    }
    if (ccs.length) [mime appendFormat:@"Cc: %@\r\n", ccs];
    
    NSMutableString* bccs = [NSMutableString string];
    for (NSString* bcc in _bccs) {
        if (bccs.length){
            [bccs appendFormat:@", <%@>", bcc];
        }else{
            [bccs appendFormat:@"<%@>", bcc];
        }
    }
    if (bccs.length) [mime appendFormat:@"Bcc: %@\r\n", bccs];
    
    [mime appendFormat:@"Mime-Version: 1.0\r\n"];
    if (_attachments.count) {
        [mime appendFormat:@"Content-Type: multipart/mixed;\r\n"];
        [mime appendFormat:@"\tboundary=\"%@\"\r\n", _boundary];
        [mime appendFormat:@"Content-Transfer-Encoding: 8Bit\r\n"];
    }else{
        [mime appendFormat:@"Content-Type: %@;\r\n", _contentType];
        [mime appendFormat:@"\tcharset=\"utf-8\"\r\n"];
        [mime appendFormat:@"Content-Transfer-Encoding: base64\r\n"];
    }

    [mime appendFormat:@"Message-ID: <SMTPMessage_%@>\r\n", @(time(0))];
    [mime appendFormat:@"Subject: %@\r\n", _subject];
    [mime appendString:@"\r\n"];
    
    [fileHandle writeData:[mime dataUsingEncoding:NSUTF8StringEncoding]];
    mime = [NSMutableString string];
    
    if (_attachments.count) {
        [mime appendFormat:@"This is a multi-part message in MIME format.\r\n"];
        [mime appendString:@"\r\n"];
        
        //content
        [mime appendFormat:@"--%@\r\n", _boundary];
        [mime appendFormat:@"Content-Type: %@;\r\n", _contentType];
        [mime appendFormat:@"\tcharset=\"utf-8\"\r\n"];
        [mime appendFormat:@"Content-Transfer-Encoding: base64\r\n"];
        
        [mime appendString:@"\r\n"];
        [mime appendFormat:@"%@\r\n", [self base64Encode:[_content dataUsingEncoding:NSUTF8StringEncoding]]];//base64
        [mime appendString:@"\r\n"];
        
        [fileHandle writeData:[mime dataUsingEncoding:NSUTF8StringEncoding]];
        mime = [NSMutableString string];
        
        //attach
        NSData* data = nil;
        for (SMTPAttachment* item in _attachments) {
            [mime appendFormat:@"--%@\r\n", _boundary];
            [mime appendFormat:@"Content-Type: application/octet-stream;\r\n"];
            [mime appendFormat:@"\tcharset=\"utf-8\"\r\n"];
            [mime appendFormat:@"\tname=\"%@\"\r\n", item.name];
            [mime appendFormat:@"Content-Disposition: attachment; filename=\"%@\"\r\n", item.name];
            [mime appendFormat:@"Content-Transfer-Encoding: base64\r\n"];
            
            [mime appendString:@"\r\n"];
            data = [NSData dataWithContentsOfFile:item.filePath];
            [mime appendString:[self base64Encode:data]];
            [mime appendString:@"\r\n"];
            
            [fileHandle writeData:[mime dataUsingEncoding:NSUTF8StringEncoding]];
            mime = [NSMutableString string];
        }
        
        //end
        [mime appendFormat:@"--%@--\r\n", _boundary];
    }else{
        [mime appendFormat:@"%@\r\n", [self base64Encode:[_content dataUsingEncoding:NSUTF8StringEncoding]]];//base64
    }
    
    [fileHandle writeData:[mime dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    
    return _filePath;
}
-(NSString *)base64Encode:(NSData*)data
{
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
@end
