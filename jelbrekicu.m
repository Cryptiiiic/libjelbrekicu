#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "jelbrekicu.h"


@implementation JelBrekICU

- (void)uploadUIImage:(UIImage *)image jelbrekKey:(NSString *)key siteURL:(NSURL *)url completionHandler:(void(^)(NSString *))completionHandler
{
    __block NSString *uploadURL = nil;
    JelBrekICU *jbicu = [JelBrekICU new];
    [jbicu login:key siteURL:url completionHandler:^(BOOL success) 
    {
        if([jbicu logging])
            NSLog(@"JelbrekICU: login: success: %@", success ? @"YES" : @"NO");
        if(!success)
            return;
    }];
    dispatch_queue_t current_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(current_queue, 
	^{

        NSData *imageData = UIImageJPEGRepresentation(image, 3);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *boundaryString = [NSString stringWithFormat:@"JelBrekICU-%@", [[NSUUID UUID] UUIDString]];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryString];
        NSMutableData *body = [NSMutableData data];
        #define APPEND(data) do { [body appendData:data]; } while(false)
        #define BOUND() do { NSData *boundary = [[NSString stringWithFormat:@"--%@\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]; APPEND(boundary); } while(false)
        #define END() do { NSData *end = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]; APPEND(end); } while(false)
        #define CONTENT(data) do { NSData *content = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", data] dataUsingEncoding:NSUTF8StringEncoding]; APPEND(content); } while(false)
        #define CONTENT1(data) do { NSData *content = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n", data] dataUsingEncoding:NSUTF8StringEncoding]; APPEND(content); } while(false)
        #define CONTENT_TYPE() do { NSData *dContentType = [@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]; APPEND(dContentType); } while(false)
        #define BOUND_END() do { NSData *boundaryEnd = [[NSString stringWithFormat:@"--%@--\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]; APPEND(boundaryEnd); } while(false)

        [request setHTTPMethod:@"POST"];
        [request addValue:@"jelbrekicu-tweak/1.0.0" forHTTPHeaderField:@"User-Agent"];
        [request addValue:key forHTTPHeaderField:@"authorization"];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

        BOUND();
        CONTENT1(@"\"x\"; filename=\"jelbrek_icu.jpg\"");
        CONTENT_TYPE();
        APPEND(imageData);
        END();
        BOUND_END();

        [request setHTTPBody:body];

        if([jbicu logging])
            NSLog(@"JelbrekICU: NSMutableURLRequest: request: %@", [request allHTTPHeaderFields]);
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *responseDict = [httpResponse allHeaderFields];
            if(httpResponse.statusCode == 200 || httpResponse.statusCode == 201)
            {
                NSError *jsonError = nil;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (jsonError)
                {
                    if([jbicu logging])
                        NSLog(@"JelbrekICU: NSURLSessionDataTask: jsonError: %@ data: %@", jsonError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                }
                uploadURL = [jsonArray valueForKey:@"url"];
                if([jbicu logging])
                    NSLog(@"JelbrekICU: NSURLSessionDataTask: data: %@ error: %@", uploadURL, error);
                    dispatch_async(current_queue, 
                    ^{
                        completionHandler(uploadURL);
                    });
            }
            else
            {
                if([jbicu logging])
                    NSLog(@"JelbrekICU: NSURLSessionDataTask: failed: statusCode: %ld data: %@ error: %@", (long)httpResponse.statusCode, responseDict, error);
            }
        }];
        [dataTask resume];
    });
}

- (void)login:(NSString *)key siteURL:(NSURL *)url completionHandler:(void(^)(BOOL))completionHandler
{
    __block BOOL success = NO;
    JelBrekICU *jbicu = [JelBrekICU new];
    dispatch_queue_t current_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(current_queue, 
	^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        [request setHTTPMethod:@"POST"];
        [request addValue:@"jelbrekicu-tweak/1.0.0" forHTTPHeaderField:@"User-Agent"];
        [request addValue:key forHTTPHeaderField:@"authorization"];

        if([jbicu logging])
            NSLog(@"JelbrekICU: NSMutableURLRequest: request: %@", [request allHTTPHeaderFields]);
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *responseDict = [httpResponse allHeaderFields];
            if(httpResponse.statusCode == 200 || httpResponse.statusCode == 201)
            {
                NSError *jsonError = nil;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (jsonError)
                {
                    if([jbicu logging])
                        NSLog(@"JelbrekICU: NSURLSessionDataTask: jsonError: %@ data: %@", jsonError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                }
                success = [[jsonArray valueForKey:@"success"] boolValue];
                if([jbicu logging])
                    NSLog(@"JelbrekICU: NSURLSessionDataTask: success: %@ error: %@", success ? @"YES" : @"NO", error);
                dispatch_async(current_queue, 
                ^{
                    completionHandler(success);
                });
            }
            else
            {
                if([jbicu logging])
                    NSLog(@"JelbrekICU: NSURLSessionDataTask: failed: statusCode: %ld data: %@ error: %@", (long)httpResponse.statusCode, responseDict, error);
            }
        }];
        [dataTask resume];
    });
}

@end
