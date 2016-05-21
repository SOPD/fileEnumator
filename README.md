#fileEnumator(1.0)

##文件路径枚举器 
####枚举指定文件夹内所有要搜索的文件并输出其路径 方便用于网络访问
####配合apacheFileReader使用 让手机可以便捷访问电脑上的图片 

##使用方法
##填入文件路径分别如下
![pciture1](http://ww2.sinaimg.cn/mw690/be3cd04ajw1f438kt1iwmj21kw1274ad.jpg)
###软件使用说明 

* 填入apache根路径 作用为生成文件在apache根目录下的相对路径用于网络访问
* 只会检索有制定字段的文件 
* 对于图片文件会自动生成一张大约80KB的预览图片
* 若未关闭软件可以分多次添加不同文件夹下的文件 列表将会扩充 重启软件后再添加会覆盖原文件
* 组标签作用为为预览图分组如果分多次添加不同目录下的文件区分预览图所用若未添加分组标签则每次生成预览图会覆盖之前的预览图
* 列表输出文件路径不需要加.json

###已完成
* 基本的文件枚举与输出列表功能
* 生成预览图


###待完善
* 便捷化文件输出规则
###待实现
* 生成视频截图作为预览图
* 启动软件定时扫描制定文件夹以更新文件列表


#可重用代码资源
*OSX下的图片尺寸重置


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
    
# 注意!
####该方法执行时只要整个程序不结束无法释放已经加载过的图片内容所占用的内存(也就是使用这个方法重设a b两张图片即使 a已经输出完毕重新调用重设b图片时 a的所占用的内存会重新被加载)!!!


####若加载图片较多会占用非常多的内存空间(超过内存大小会占用磁盘空间)200张中高质量图片内存占用量越1.5G(差值等级若设置为low会超过15G),因此如果电脑不够给力的话 建议使用分组一组一组执行实在不行可以每次都重启软件执行,分别输出给不同的json文件 手工打开将所有文件中的[]内的条目合并到files.json即可
