//
//  SRClientDataClasses.h
//  SRClient
//
//  Created by NTT TechnoCross.
//  Copyright(C) 2017 NTT TechnoCross Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRModelGroup : NSObject <NSCoding>
@property (readonly, nonatomic, retain) NSMutableArray* nbestArray;
- (id)initWithData:(NSArray*)nbestArray;
- (instancetype)init __attribute__((unavailable("init is not available")));
- (NSString*)serialize;
@end

@interface SRNbest : NSObject <NSCoding>
@property (readonly, nonatomic, retain) NSString* recognitionId;
@property (readonly, nonatomic, retain) NSMutableArray* sentenceArray;
@property (readonly, nonatomic, retain) NSString* modelGroup;
- (id)initWithData:(NSArray*)sentenceArray modelGroup:(NSString*)modelGroup recognitionId:(NSString*)recognitionId;
- (instancetype)init __attribute__((unavailable("init is not available")));
- (NSArray*)getNbestStringArray:(BOOL)signageOnly;
- (NSString*)serialize;
@end

@interface SRSentence : NSObject <NSCoding>
@property (readonly, nonatomic, retain) NSMutableArray* wordArray;
@property (readonly, nonatomic, retain) NSNumber* score;
- (id)initWithData:(NSArray*)wordArray score:(NSNumber*)score;
- (instancetype)init __attribute__((unavailable("init is not available")));
- (NSString*)getSentenceString:(BOOL)signageOnly;
- (NSString*)serialize;
@end

@interface SRWord : NSObject <NSCoding>
@property (readonly, nonatomic, retain) NSString* phoneme;
@property (readonly, nonatomic, retain) NSString* label;
@property (readonly, nonatomic, retain) NSString* preLabel;
@property (readonly, nonatomic, retain) NSNumber* startPoint;
@property (readonly, nonatomic, retain) NSNumber* endPoint;
@property (readonly, nonatomic, retain) NSNumber* score;
- (id)initWithData:(NSString*)phoneme label:(NSString*)label preLabel:(NSString*)preLabel startPoint:(NSNumber*)startPoint endPoint:(NSNumber*)endPoint score:(NSNumber*)score;
- (instancetype)init __attribute__((unavailable("init is not available")));
- (NSString*)serialize;
@end
