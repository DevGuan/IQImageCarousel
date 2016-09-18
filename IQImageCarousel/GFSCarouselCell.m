//
//  GFSCarouselCell.m
//  GFSImageCarousel(图片无限轮播)
//
//  Created by 管复生 on 16/3/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import "GFSCarouselCell.h"
//#import "UIImageView+WebCache.h"
@interface GFSCarouselCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
@implementation GFSCarouselCell


- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    // 加载网络图片
    if (imageUrl.length > 0 ) {
//        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"pic_NULL"]];
    }else{
        self.imageView.image = [UIImage imageNamed:@"pic_NULL"];
    }
}
- (void)awakeFromNib {
    // Initialization code
}

@end
