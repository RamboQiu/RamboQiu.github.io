---
title:  "使用python遍历iOS工程中未使用的多个字符串"
date:   2020-11-23
desc: "扫描工程，全局遍历排查废弃代码"
keywords: "python,iOS"
categories: [Tech, iOS]
tags: [iOS, python]
---

## 起因

在项目中，埋点数据采集在本地有一个埋点配置plist，管理项目中的所有的业务打点key，如下：
![图片](/assets/img/work/20201123/20201123145306868.png){: .left}
随着业务的迭代，埋点越来越多，但是业务层面并没有埋点下线功能，也就是某个模块已经重构或是被删除，代码中已经没有相关打点逻辑，这个涉及到的埋点并没有被删除掉，导致plist文件里面的项越来越多，希望开发去手动下线删除其实也挺恶心的，所以有了下面的动作。

> 全局搜索项目中没有使用的埋点，并把它从plist中删除

## 环境
本人是mac os，所以自带python，IDE使用的是PyCharm，可自行网上下载

[pycharm安装第三方module](https://blog.csdn.net/qiannianguji01/article/details/50397046)

plist的解析和写入用的是biplist [python .plist 文件读写](https://www.cnblogs.com/kaisne/archive/2012/12/24/biplist.html)

Setting-Project Interpreter-+-biplist
![图片](/assets/img/work/20201123/20201123160338473.png){: .left}

## 结果
共检索5836个文件，是否包含1047个字符串key，查出99个key是没有地方使用的
如果是复杂不规则字符串，使用正则匹配计算共耗时1小时37分钟
如果是规则字符串，直接使用字符串包含即可，4s就能完成
之后再检索修改plist即可

> 如果你是复杂不规则字符串的话使用正则用xcode去跑的话，晚上下班之后再跑吧，不然最好还是领出来改下文件对应的地址，用python单独去跑![图片](/assets/img/work/20201123/20201123173542997.png){: .left}


## 原理介绍

不多说，直接上源码，解释都是在代码注释里面
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import re
from biplist import *
import datetime


def alleventname(funarr):
    """
    :param funarr: 数组字典，这里解析出key值，根据具体数据进行改造即可
    :return:
    """
    elist = []
    for itemtmp in funarr:
        event_name = itemtmp['key'].upper()
        elist.append(event_name)
    return elist


class Find(object):
    def __init__(self, root, input_list):
        """
             --初始化
        """
        self.root = root  # 文件树的根
        self.files = []  # 待匹配的文件集合
        self.current = 0  # 正在匹配的文件集合的位置
        self.input_files = input_list  # 将待匹配字符串保存在数组中
        self.output_eventname = []

    @staticmethod
    def find_file(self):
        """
        --查找文件，即遍历文件树将查找到的文件放在文件集合中
        :return:
        """
        self.find_dirfile(self, self.root)

    @staticmethod
    def find_dirfile(self, dirpath1):
        for root, dirs, files in os.walk(dirpath1, topdown=True):
            for name in files:
                if name.endswith('.m'):
                    if name == 'NEStatisticsHeader.m':
                        continue
                    # 这里可以对包含埋点的文件进行特定检索，这样可以略过很多不必要检查的文件
                    f = file(root + '/' + name, "r")
                    file_content = f.read()
                    f.close()
                    # searchObj = re.search(r'(.*)' + 'NEStatistics' + '.*', file_content, re.M | re.I)
                    # if searchObj:
                    if 'NEStatistics' in file_content:
                        self.files.append(os.path.join(root, name))
            for dirname in dirs:
                self.find_dirfile(self, root + '/' + dirname)

    @staticmethod
    def walk(self):
        """
        --逐一查找
        :param self:
        :return:
        """
        self.current = 1
        for item1 in self.files:
            print '当前检索到第', self.current, '个文件：', item1
            Find.traverse_file(self, item1)
            self.current = self.current + 1

    @staticmethod
    def traverse_file(self, file_path):
        """
        --遍历文件，匹配字符串
        :return:
        """
        f = file(file_path, "r")
        file_content = f.read()
        f.close()
        input_files = []
        for item2 in self.input_files:
            if item2:
                # searchObj = re.search(r'(.*)' + item2 + '.*', file_content, re.M | re.I)
                # if searchObj:
                if item2 in file_content:
                    continue
                else:
                    input_files.append(item2)
        self.input_files = input_files


if __name__ == "__main__":
    # 在Debug.xcconfig文件中配置一项 CHECK_NOUSE = YES
    if os.environ['CHECK_NOUSE'] == 'YES':
        print datetime.datetime.now()
        # 项目根目录
        srcRoot = os.environ['SRCROOT']
        # 获取项目名，进入类目录
        projectName = os.environ['PROJECT_NAME']
        plist_root = srcRoot + '/' + projectName
        # 这里就是plist的地址
        filepath = plist_root + '/test.plist'
        try:
            plist = readPlist(filepath)
        except InvalidPlistException, e:
            print "Not a Plist or Plist Invalid:", e
        # 获取到需要去检索的所有key
        alist = alleventname(plist)
        print '共有', len(alist), '个key'
        # 文件夹根目录
        dirpath = plist_root
        findObj = Find(dirpath, alist)
        # 查找到所有需要遍历的文件
        findObj.find_file(findObj)
        print '一共需要检索', len(findObj.files), '个文件'
        # 开始检索
        findObj.walk(findObj)
        # 将待匹配字符串保存在数组中
        events = findObj.input_files
        print '检索出', len(events), '个没有使用的key'
        if len(events) > 0:
	        print '开始修改plist'
	        # 查找匹配key，修改plist
	        index = 0
	        for event in events:
	            for item in plist:
	                varstr = item['event_name'].upper()
	                if varstr == event:
	                    del plist[index]
	                    index = 0
	                    break
	                index = index + 1
	
	        try:
	            # binary不填写，中文会乱码
	            writePlist(plist, filepath, binary=False)
	        except (InvalidPlistException, NotBinaryPlistException), e:
	            print "Something bad happened:", e
	        print '完成plist的修改'
	    else:
	    	print '无需修改plist'
        print datetime.datetime.now()
```

## 编译执行
在xcode的build phases 添加自定义的脚本即可
![图片](/assets/img/work/20201123/20201123211600601.png){: .left}

## 其他
该脚本不需要打包上线，所以在Build Settings->Build Options->Excluded Source File Names->AppStore
![图片](/assets/img/work/20201123/20201123212410206.png){: .left}

## 参考文章
[python 文件查找及内容匹配](https://blog.csdn.net/changhuzhao/article/details/58585448)

[使用biplist编辑plist文件时遇到中文乱码问题](https://www.jianshu.com/p/24e5d53b21aa)
