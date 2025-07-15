//
//  NSData+VZZip.m
//  VeryZhun
//
//  Created by chunxi on 15/11/24.
//  Copyright © 2015年 listener~. All rights reserved.



#import "NSData+VZZip.h"
#import <zconf.h>
#import <zlib.h>

#define ChunkSize  20480

@implementation NSData (VZZip)

- (NSData *)vz_unzip {
    
    if (self.length == 0) {
        return 0;
    }
    
    Bytef *inData = (Bytef *)self.bytes;
    
    bool done = false;
    int status = 0;
    z_stream d_strm;
    d_strm.next_in = inData;
    d_strm.avail_in = (uInt)self.length;
    d_strm.total_out = 0;
    d_strm.opaque = 0;
    d_strm.zalloc = Z_NULL;
    d_strm.zfree = Z_NULL;
    if(inflateInit2(&d_strm, -MAX_WBITS) != Z_OK)
    {
        return nil;
    }
    
    Bytef buffer[ChunkSize];
    NSMutableData *retData = [NSMutableData data];
    
    uLong totalLen = 0;
    while(!done)
    {
        bzero(buffer, ChunkSize);
        
        d_strm.avail_out = ChunkSize;
        d_strm.next_out = buffer;
        status = inflate(&d_strm, Z_NO_FLUSH);  //解压缩数据
        
        if(status == Z_STREAM_END || d_strm.avail_in == 0)
        {
            done = true;
        }
        else if(status != Z_OK)
        {
            break;
        }
        
        [retData appendBytes:(char *)buffer length:d_strm.total_out - totalLen];
        totalLen = d_strm.total_out;
    }
    
    inflateEnd(&d_strm);
    
    if(done)
    {
        return retData;
    }
    else
    {
        return nil;
    }
}


- (NSData *)vz_zip {
    
    if (self.length == 0) {
        return nil;
    }
    
    z_stream c_stream;
    
    c_stream.zalloc = Z_NULL;
    c_stream.zfree = Z_NULL;
    c_stream.opaque = Z_NULL;
    c_stream.total_out = 0;
    
    
    if(deflateInit2(&c_stream,
                    Z_DEFAULT_COMPRESSION,
                    Z_DEFLATED,
                    -MAX_WBITS,
                    8,
                    Z_DEFAULT_STRATEGY) != Z_OK)
    {
        return nil;
    }
    
    c_stream.next_in = (Bytef *)self.bytes;
    c_stream.avail_in = (uInt)(self.length);
    
    NSMutableData *data = [NSMutableData dataWithLength:ChunkSize];
    
    while (c_stream.avail_in != 0)
    {
        if (c_stream.total_out >= [data length])
        {
            [data increaseLengthBy:ChunkSize];
        }
        
        c_stream.next_out = data.mutableBytes + c_stream.total_out;
        c_stream.avail_out = (uInt)(data.length - c_stream.total_out);
        
        int status = deflate(&c_stream, Z_NO_FLUSH);
        
        if (status < 0)
        {
            NSLog(@"deflate out error :%@", @(status));
            break;
        }
        else if (status == Z_STREAM_END)
        {
            break;
        }
    }
    
    for(; ;)
    {
        
        if (c_stream.total_out >= [data length])
        {
            [data increaseLengthBy:ChunkSize];
        }
        
        int status = deflate(&c_stream, Z_FINISH);
        
        c_stream.next_out = data.mutableBytes + c_stream.total_out;
        c_stream.avail_out = (uInt)(data.length - c_stream.total_out);
        
        if(status == Z_STREAM_END)
        {
            break;
        }
    }
    
    deflateEnd(&c_stream);
    
    [data setLength:c_stream.total_out];
    
    return data;
}

@end
