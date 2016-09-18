//
//  GFSImageCarouselView.m
//  GFSImageCarousel(图片无限轮播)
//
//  Created by 管复生 on 16/3/11.
//  Copyright © 2016年 GFS. All rights reserved.
//

#import "GFSImageCarouselView.h"
#import "GFSCarouselCell.h"

#define CarsouselTimeInterval 3
#define CarsouselSectionNumber 100
@interface GFSImageCarouselView()<UICollectionViewDataSource,UICollectionViewDelegate>
/**
 *  轮播view
 */
@property(nonatomic,weak)UICollectionView *carsouselView;
/**
 *  定时器
 */
@property(nonatomic,strong)NSTimer *timer;
/**
 *  翻页
 */
@property(nonatomic,weak)UIPageControl *pageControl;
/**
 *  flowOut
 */
@property(nonatomic,strong)UICollectionViewFlowLayout * layout;
@end
@implementation GFSImageCarouselView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 初始化设置
        [self setUp];
    }
    return self;
}
- (void)setImageArray:(NSMutableArray *)imageArray
{
    _imageArray = [imageArray copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pageControl.numberOfPages = _imageArray.count;
        // 解决每次刷新数组造成定时器卡顿问题
//        //  移除之前的定时器
//        [self stopTimer];
//        //  添加定时器
//        [self startTimer];
        [self.carsouselView reloadData];
    });
}
#pragma mark- 私有方法

- (void)setUp
{
    // 1 添加轮播view
    UICollectionViewFlowLayout *flowOut = [[UICollectionViewFlowLayout alloc]init];
    // 1.1轮播器cell的尺寸
    flowOut.itemSize = self.bounds.size;
    flowOut.minimumLineSpacing = 0;
    flowOut.minimumInteritemSpacing = 0;
    flowOut.sectionInset = UIEdgeInsetsZero;
    flowOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout = flowOut;
    UICollectionView *carousel = [[UICollectionView alloc]initWithFrame:self.frame collectionViewLayout:self.layout];
    carousel.backgroundColor = [UIColor whiteColor];
    
    self.carsouselView = carousel;
    [self addSubview:carousel];
    
    [self.carsouselView registerNib:[UINib nibWithNibName:@"GFSCarouselCell" bundle:nil] forCellWithReuseIdentifier:@"carouselCell"];
    
    self.carsouselView.dataSource = self;
    self.carsouselView.delegate = self;
    self.carsouselView.showsHorizontalScrollIndicator = NO;
    self.carsouselView.pagingEnabled = YES;
    self.carsouselView.bounces = NO;
    
    // 2 添加分页
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width * 0.5 - 25, self.frame.size.height - 20, 50, 20)];
    
    pageControl.pageIndicatorTintColor   = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.hidesForSinglePage = YES;
 
    self.pageControl = pageControl;
    [self addSubview:self.pageControl];
    
    // 3 添加定时器
    [self startTimer];

}
/**
 *  开始计时器
 */
- (void)startTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:CarsouselTimeInterval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    self.timer = timer ;
    
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];

}
/**
 *  关闭计时器
 */
- (void)stopTimer
{
    [self.timer invalidate];
    
    self.timer = nil;
}
- (void)nextImage
{
    // 防止网络特别差 加载数据未加载到奔溃
    if (self.imageArray.count == 0){
        [self stopTimer];
        return;
    }
    NSIndexPath *indexPath = [[self.carsouselView indexPathsForVisibleItems]firstObject];
    NSInteger nextSection = indexPath.section ;
    NSInteger row = indexPath.item ;
    if (self.imageArray.count == indexPath.item + 1) {
        nextSection += 1;
        row = 0;
    }else{
        row += 1;
    }
    [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:nextSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    if (nextSection > CarsouselSectionNumber - 8) {
        // 再回到中间位置
        [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:CarsouselSectionNumber *0.5] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
   
    self.pageControl.currentPage = row;
}

#pragma mark- collection代理和数据源方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return CarsouselSectionNumber;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.imageArray.count) {
        return self.imageArray.count ;
    }else{
        return 1;
    }

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GFSCarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"carouselCell" forIndexPath:indexPath];
    if (self.imageArray.count > 0) {
        cell.imageUrl = self.imageArray[indexPath.row];
    }else{
        cell.imageUrl = nil;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出选中的位置
    int page = (int)indexPath.row;
    if ([self.delegate respondsToSelector:@selector(GFSImageCarouselDidClicked:)]) {
        [self.delegate GFSImageCarouselDidClicked:page];
    }
}
#pragma mark- scrollview的代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 偏移量 计算第几页
    int page = scrollView.contentOffset.x / self.frame.size.width + 0.5;
    if ((page < 10)||(page > (self.imageArray.count *CarsouselSectionNumber - 10))) {
        [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page%self.imageArray.count inSection:CarsouselSectionNumber *0.5] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
//    self.currentPage = page;
    self.pageControl.currentPage = page % self.imageArray.count;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 偏移量 计算第几页
    int page = scrollView.contentOffset.x / self.frame.size.width + 0.5;
    if ((page < 10)||(page > (self.imageArray.count *CarsouselSectionNumber - 10))) {
        [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page%self.imageArray.count inSection:CarsouselSectionNumber *0.5] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    //    self.currentPage = page;
    self.pageControl.currentPage = page % self.imageArray.count;
    [self startTimer];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 偏移量 计算第几页
    int page = scrollView.contentOffset.x / self.frame.size.width + 0.5;
    if ((page < 10)||(page > (self.imageArray.count *CarsouselSectionNumber - 10))) {
        [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page%self.imageArray.count inSection:CarsouselSectionNumber *0.5] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    //    self.currentPage = page;
    self.pageControl.currentPage = page % self.imageArray.count;
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
//    [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:CarsouselSectionNumber * 0.5] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

    self.layout.itemSize = self.frame.size;
    self.carsouselView.frame = self.bounds;
    
    CGFloat itemW = self.frame.size.width;
    CGFloat itemH = self.frame.size.height;
    self.pageControl.frame = CGRectMake(itemW * 0.5 - 25, itemH - 20, 50, 20);
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self.carsouselView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:CarsouselSectionNumber * 0.5] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
@end
