
@interface JelBrekICU : NSObject
@property BOOL logging;
- (void)uploadUIImage:(UIImage *)image jelbrekKey:(NSString *)key siteURL:(NSURL *)url completionHandler:(void(^)(NSString *))completionHandler;
@end