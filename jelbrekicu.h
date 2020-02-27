
@interface JelBrekICU : NSObject
@property BOOL logging;
- (NSString *)uploadUIImage:(UIImage *)image jelbrekKey:(NSString *)key siteURL:(NSURL *)url;
@end