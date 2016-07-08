# smtp
1.tiny object-c smtp library

2.base on libcurl-7.44

pod 'SMTPLite', '~> 0.0.3'

```
	SMTPMessage *message = [[SMTPMessage alloc] init];
    message.from = @"from@domain.com";
    message.to = @"to@domain.com";
    message.host = @"smtp.domain.com";
    message.account = @"accout@domain.com";
    message.pwd = @"***";
    
    message.subject = @"from jasenhuang";
    message.content = @"this is a html!<br/>not plain text<br/>";
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
```
