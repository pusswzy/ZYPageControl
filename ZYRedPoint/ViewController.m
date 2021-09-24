//
//  ViewController.m
//  ZYRedPoint
//
//  Created by lihaoze on 2021/9/23.
//

#import "ViewController.h"
#import "ZYPageControlVIew.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIStepper *bbb;
@property (nonatomic, strong) ZYPageControlVIew *pageControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    [self.view addSubview:self.pageControl];
    self.pageControl.frame = CGRectMake(20, 50, 300, 300);
    self.pageControl.backgroundColor = [UIColor yellowColor];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.pageControl.currentPage = arc4random() % self.pageControl.numberOfPages;
    [self __log];
    
}

- (IBAction)action:(UIStepper *)sender {
    self.pageControl.numberOfPages = sender.value;
    [self __log];
}

- (IBAction)changeCurrentPageAction:(UIStepper *)sender {
    self.pageControl.currentPage = sender.value;
    [self __log];
}

#pragma mark -
- (void)__log {
    self.label.text = [NSString stringWithFormat:@"当前下标为:%zd 当前pages总数为:%zd", self.pageControl.currentPage, self.pageControl.numberOfPages];
    [self.label sizeToFit];
}

#pragma mark
- (ZYPageControlVIew *)pageControl {
    if (!_pageControl) {
        _pageControl = [[ZYPageControlVIew alloc] init];
        _pageControl.numberOfPages = 0;
        _pageControl.currentPage = 0;
        _pageControl.maximumVisablePages = 5;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    }
    return _pageControl;
}

@end
