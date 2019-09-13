//
//  SRClientHelper.h
//  SRClientHelper
//
//  Created by NTT TechnoCross.
//  Copyright(C) 2017 NTT TechnoCross Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRClientHelperDelegate <NSObject>
@optional
- (void)srcDidReady;
- (void)srcDidRecognize:(NSData*)data;
- (void)srcDidTempPoint:(NSData*)data;
- (void)srcDidSentenceEnd;
- (void)srcDidComplete:(NSError*)error;
- (void)srcDidReceiveParameter:(NSDictionary*)parameterValue;
- (void)srcDidRecord:(NSData*)pcmData;
- (void)srcDidRecordNR:(NSData*)pcmData;
- (void)srcDidRecordSentence:(NSData*)pcmData;
- (void)srcDidPush:(NSData*)pcmData;
@end

@interface SRClientHelper : NSObject
@property (nonatomic, weak) id<SRClientHelperDelegate> delegate;
- (id)initWithDevice:(NSDictionary*)settings;
- (id)initWithURL:(NSDictionary*)settings url:(NSURL*)url;
- (instancetype)init __attribute__((unavailable("init is not available")));
- (void)start;
- (void)getParameter:(NSString*)paramName;
- (void)stop;
- (void)cancel;
- (void)startForGetParameter:(NSString*)paramName;
@end
