//
//  GameLoginRequest.m
//  duoleIosSDK
//
//  Created by cxh on 16/7/27.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "GameLoginRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation GameLoginRequest


//hmacSha1加密
- (NSString*)hmacSha1:(NSString *)key data:(NSString *)data
{

//    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
//    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
//    //Sha256:
//    // unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
//    //CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//    //sha1
//    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
//    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//    //将加密结果进行一次BASE64编码。
//    NSString *hash = [HMAC base64EncodedStringWithOptions:0];
//    return [hash lowercaseString];


    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash;
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    
    return [hash lowercaseString];
    
}

//md5加密
- (NSString *)md5:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

//sha1加密
- (NSString*)sha1:(NSString *)str
{
    
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output lowercaseString];
}

//请求合成
-(NSMutableURLRequest*)getRequestWithURL:(NSString*)url{
    
//    NSRange range = [url rangeOfString:@"?"];
//    NSString* uslStr = [url substringToIndex:range.location];
//    NSString* argsStr = [url substringFromIndex:range.location+range.length];
//    NSLog(@"%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";//请求方法
    //request.timeoutInterval=5.0;//设置请求超时为5秒
   // request.HTTPBody = [argsStr dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}
@end
