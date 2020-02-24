#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "jelbrekicu.h"

@implementation JelBrekICU

- (NSString *)uploadUIImage:(UIImage *)image jelbrekKey:(NSString *)key siteURL:(NSURL *)url
{
    __block NSString *uploadURL = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), 
	^{
        NSData *imageData = UIImagePNGRepresentation(image);
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
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

        BOUND();
        CONTENT(@"\"method\"");
        APPEND([@"json" dataUsingEncoding:NSUTF8StringEncoding]);
        END();
        BOUND();
        CONTENT(@"\"key\"");
        APPEND([key dataUsingEncoding:NSUTF8StringEncoding]);
        END();
        BOUND();
        CONTENT1(@"\"file\"; filename=\"jelbrek_icu.png\"");
        CONTENT_TYPE();
        APPEND(imageData);
        END();
        BOUND_END();

        [request setHTTPBody:body];

        NSLog(@"JelbrekICU: NSMutableURLRequest: request: %@", [request allHTTPHeaderFields]);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *responseDict = [httpResponse allHeaderFields];
            if(httpResponse.statusCode == 200)
            {
                NSError *jsonError = nil;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (jsonError)
                {
                    NSLog(@"JelbrekICU: NSURLSessionDataTask: jsonError: %@ data: %@", jsonError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                }
                uploadURL = [jsonArray valueForKey:@"filename"];
                NSLog(@"JelbrekICU: NSURLSessionDataTask: data: %@ error: %@", uploadURL, error);
                dispatch_semaphore_signal(semaphore);
            }
            else
                NSLog(@"JelbrekICU: NSURLSessionDataTask: failed: statusCode: %ld data: %@ error: %@", (long)httpResponse.statusCode, responseDict, error);
        }];
        [dataTask resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    return uploadURL;
}

@end
