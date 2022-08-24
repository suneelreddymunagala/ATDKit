//
//  Copyright (c) Dr. Michael Lauer Information Technology. All rights reserved.
//

#import "LTOBD2Protocol.h"

@implementation LTOBD2ProtocolResult
{
    NSMutableArray* _payload;
}

+(instancetype)protocolResultFailureType:(OBD2FailureType)failureType
{
    LTOBD2ProtocolResult* obj = [[self alloc] init];
    obj->_failureType = failureType;
    obj->_payload = [NSMutableArray array];
    return obj;
}

-(void)appendPayloadBytes:(NSArray<NSNumber*>*)bytes
{
    [_payload addObjectsFromArray:bytes];
}

@end



@implementation LTOBD2Protocol

+(instancetype)protocol
{
    LTOBD2Protocol* obj = [[self alloc] init];
    return obj;
}

-(instancetype)init
{
    if ( ! ( self = [super init] ) )
    {
        return nil;
    }
    
    return self;
}

-(NSDictionary<NSString*,LTOBD2ProtocolResult*>*)decode:(NSArray<NSString*>*)lines originatingCommand:(NSString*)command
{
    NSAssert( NO, @"please implement decode:originatingCommand: in your subclass" );
    return nil;
}

-(LTOBD2Command*)heartbeatCommand
{
    return nil;
}

-(BOOL)isMultiFrameWithPrefix:(NSString*)prefix lines:(NSArray<NSString*>*)lines
{
    __block NSUInteger n = 0;
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ( [line hasPrefix:prefix] )
        {
            n++;
        }
        if ( n > 1 )
        {
            *stop = YES;
        }
        
    }];
    
    return n > 1;
}

-(NSArray<NSNumber*>*)hexStringToArrayOfNumbers:(NSString*)string
{
    //TODO: Support strings without spaces as well?
    NSMutableArray<NSNumber*>* ma = [NSMutableArray array];
    NSArray<NSString*>* hexValues = [string componentsSeparatedByString:@" "];
    [hexValues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSScanner* scanner = [NSScanner scannerWithString:obj];
        unsigned int value = 0;
        if ( [scanner scanHexInt:&value] )
        {
            [ma addObject:@(value)];
        }
    }];
    return [NSArray arrayWithArray:ma];
}

-(LTOBD2ProtocolResult*)createProtocolResultForBytes:(NSArray<NSNumber*>*)bytes sidIndex:(NSUInteger)sidIndex
{
    uint sid = bytes[sidIndex].unsignedIntValue;
    if ( sid != OBD2FailureCode )
    {
        return [LTOBD2ProtocolResult protocolResultFailureType:OBD2FailureTypeInternalOK];
    }
    if ( sidIndex + 2 >= bytes.count )
    {
        return [LTOBD2ProtocolResult protocolResultFailureType:OBD2FailureTypeInternalUnknown];
    }
    __unused uint failedPid = bytes[sidIndex + 1].unsignedIntValue;
    uint failureType = bytes[sidIndex + 2].unsignedIntValue;
    
    return [LTOBD2ProtocolResult protocolResultFailureType:failureType];
}

@end
