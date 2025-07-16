//
//  UIDefine.h
//  FYGOMS
//
//  Created by wangkun on 15/5/13.
//  Copyright (c) 2015年 feeyo. All rights reserved.
//

#ifndef FYGOMS_UIDefine_h
#define FYGOMS_UIDefine_h

 

 
#define FG_MULTILINE_TEXTSIZE(text, font, maxSize) ([text length] > 0 ? \
[text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : \
CGSizeZero);

#define FG_MULTILINE_ATEXTSIZE(attributedText, maxSize) ([attributedText length] > 0 ? [attributedText boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size : CGSizeZero);

#define FG_SINGLELINE_TEXTSIZE(text, font) ([text length] > 0 ? [text sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero);
#endif
