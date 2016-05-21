//
//  ViewController.m
//  fileEnumator
//
//  Created by mac on 16/5/6.
//  Copyright © 2016年 zhaoxin. All rights reserved.
//

#import "ViewController.h"
#import <AppKit/AppKit.h>
 typedef void(^Finish)();
@interface ViewController()
//组标签
@property (weak) IBOutlet NSTextField *tagName;
//阿帕奇路径
@property (weak) IBOutlet NSTextField *apachePath;
//要搜索的文件名
@property (nonatomic,weak) IBOutlet NSTextField *fileName;
//要存储的文件路径
@property (nonatomic,weak) IBOutlet NSTextField *jsonName;

//要搜索的文件夹路径
@property (nonatomic,weak) IBOutlet NSTextField *filePath;
@property(nonatomic,copy)Finish finish;
//生成的大图路径列表
@property(nonatomic,strong)NSMutableArray *filesJson;
//要压缩的图片列表
@property(nonatomic,strong)NSMutableArray *tempPath;


@end
@implementation ViewController
-(NSMutableArray *)tempPath{

    if (_tempPath==nil) {
        _tempPath=[NSMutableArray array];
    }
    return _tempPath;
}
-(NSMutableArray *)filesJson{

    //懒加载
    if (_filesJson==nil) {
        _filesJson=[NSMutableArray array];
    }
    return _filesJson;
}
- (IBAction)didSetButtonClick:(id)sender {
    self.filesJson=[NSMutableArray array];
    self.tempPath=[NSMutableArray array];
    //文件夹路径
    NSString *path=self.filePath.stringValue;
    
    int index=1;
    //获取文件管理器
    NSFileManager *manager=[NSFileManager defaultManager];
    //获取文件枚举器
    NSDirectoryEnumerator *myDirectoryEnumerator;
    //枚举文件
    myDirectoryEnumerator=[manager enumeratorAtPath:self.filePath.stringValue];
    
    NSMutableString *Mstr=[NSMutableString string];
    
    //获取要搜索的文件
    NSString *str=[NSString stringWithFormat:@"%@,",self.fileName.stringValue];
    
    NSMutableArray *keyWords=[NSMutableArray array];
    
    //获取搜索的文件名列表
    for (int i=0; i<(int)[str length]; i++) {
        
       //枚举文件名字符
       if ([str characterAtIndex:i]==',') {
           //字符为","的时候将前面的字符串添加进数组
            [keyWords addObject:Mstr];
            Mstr=[NSMutableString string];
            index++;
        }
        if([str characterAtIndex:i]!=',') {
            //拼接字符串
            [Mstr appendString:[NSString stringWithFormat:@"%c",[str characterAtIndex:i]]];
        }
 
        
    }
    
    
       NSImage *img1=[[NSImage alloc]init];
         //枚举路径
   int i=0;
    while((path=[myDirectoryEnumerator nextObject])!=nil){
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        //枚举关键字数组
        for (NSString *key in keyWords) {
         //   NSLog(@"%@",keyWords);
            //判断如果路径中是否包含该数组
            if ([path containsString:key]) {
                
                //计算路径裁切
                NSInteger len=self.apachePath.stringValue.length;
                NSRange rang=NSMakeRange(0, len+1);
                NSMutableString *filePathMstr=[NSMutableString stringWithString:self.filePath.stringValue];
                [filePathMstr deleteCharactersInRange:rang];
                
                //将路径添加进数组
                [dic setValue:[NSString stringWithFormat:@"%@/%@",filePathMstr,path] forKey:@"filePath"];
                [self.tempPath addObject:path];
                
               
                 [self.filesJson addObject:dic];
                //判断是否是图片 是图片则生成略缩图
                
                if ([path containsString:@"png"]||[path containsString:@"jpg"]||[path containsString:@"jpeg"]||[path containsString:@"JPG"]||[path containsString:@"JPEG"]) {
                    [dic setValue:@"image" forKey:@"fileType"];
                    //获取图片绝对路径
                    NSString *filePath= [NSString stringWithFormat:@"%@/%@",self.filePath.stringValue,path];
                    //获取图片
                    
                    img1=[[NSImage alloc]initWithContentsOfFile:filePath];
 
                    NSSize size;
                    size.width=400;
                    size.height=400/img1.size.width*img1.size.height;
                    //重绘图片改变大小
                    NSImage *img=[[NSImage alloc]init];
                    
                    img=[self resizeImage:img1 size:size];
                    
                    //
                    //                //图片序列化为data
                    NSData *imageData = [img TIFFRepresentation];
                    //
                    //                //获取上下文
                    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                    //
                    NSDictionary *imageProps = nil;
                    //                //设置图片质量
                    NSNumber *quality = [NSNumber numberWithFloat:0.5];
                    imageProps = [NSDictionary dictionaryWithObject:quality forKey:NSImageCompressionFactor];
                    //
                    //
                    //                //将上下文中的信息写入到文件中
                    NSData *writeData= [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
                    //            
                    [ writeData writeToFile:[NSString stringWithFormat:@"/Users/mac/webDoc/Preview/%@%09d.jpg",self.tagName.stringValue,i] atomically:YES];
                    
                    //将略缩图路径添加进字典
                    [dic setValue:[NSString stringWithFormat:@"Preview/%@%09d.jpg",self.tagName.stringValue,i] forKey:@"previewPath"];
                    //         
                    i++;
                
                }else{
                  
                    [dic setValue:@"file" forKey:@"fileType"];}
  
        }
            NSString *pathExtension = [[path lastPathComponent] stringByDeletingPathExtension];
            
            [dic setValue:pathExtension forKey:@"fileName"];
   
    }
     
   
    
   
   
   
  NSData *data=[NSJSONSerialization dataWithJSONObject:self.filesJson options:0 error:nil];
     //NSLog(@"%@",data);
    NSMutableString *mStr=[NSMutableString stringWithString:self.jsonName.stringValue];
    NSString *str1=@".json";
    [mStr appendString:str1];
    [data writeToFile:mStr atomically:YES];
    
    
    }}


- (void)viewDidLoad {
    [super viewDidLoad];


    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


//重设图片大小
- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size{
    
    //计算缩放比例
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    
    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
    
    NSSize sourceSize = [sourceImage size];
    
    float ratioH = size.height/ sourceSize.height;
    
    float ratioW = size.width / sourceSize.width;
    
    NSRect cropRect = NSZeroRect;
    if (ratioH >= ratioW) {
        cropRect.size.width = floor (size.width / ratioH);
        cropRect.size.height = sourceSize.height;
    } else {
        cropRect.size.width = sourceSize.width;
        cropRect.size.height = floor(size.height / ratioW);
    }
    cropRect.origin.x = floor( (sourceSize.width - cropRect.size.width)/2 );
    cropRect.origin.y = floor( (sourceSize.height - cropRect.size.height)/2 );
    
    
    //开始绘图
    [targetImage lockFocus];
    [sourceImage drawInRect:targetFrame fromRect:cropRect
     //portion of source image to draw
                  operation:NSCompositeCopy
     //compositing operation
                   fraction:1.0
     //alpha (transparency) value
             respectFlipped:YES
     //coordinate system
                      hints:@{NSImageHintInterpolation: [NSNumber numberWithInt:NSImageInterpolationHigh]}];
    //NSImageInterpolationHigh 差值运算参数   差值等级越低越消耗资源
    [targetImage unlockFocus];
  
    
    return targetImage;}

@end
