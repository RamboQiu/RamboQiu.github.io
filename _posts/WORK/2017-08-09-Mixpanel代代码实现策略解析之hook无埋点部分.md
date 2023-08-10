---
layout: post
title:  "Mixpanel代代码实现策略解析之hook无埋点部分"
date:   2017-08-09
desc: "Mixpanel代代码实现策略解析之hook无埋点部分"
keywords: "OC,Mixpanel,无埋点"
categories: [Tech, iOS]
tags: [OC, Mixpanel, 无埋点]
icon: icon-html
---

# 写在前面
[Mixpanel](https://mixpanel.com)是非常好用的移动数据统计分析工具。开发者通过调用相关接口，就可以访问MixPanel收集的目标APP的各种即时分析数据。该平台可以跟踪用户的评论数、订阅者数、like 次数、分享次数、页面浏览数量等。
>Mixpanel is the most advanced analytics platform for mobile & web. Instead of measuring pageviews, it helps you analyze the actions people take in your application. An action can be anything - someone uploading a picture, playing a video, or sharing a post, for example.

本章内容主要讲解，Mixpanel的无埋点实现策略。
>去[Mixpanel](https://mixpanel.com)注册一个免费用户，获取到token，自己通过pod建立一个demo。具体教程参考[这里](https://mixpanel.com/help/reference/ios#automatically-sending-events)

---

# 第一章 无埋点相关实现技术点介绍
最近项目组正在重写埋点整个逻辑，以完成老板的流量查看需求，所以原先老的埋点技术已经不能满足逐渐越来越复杂的业务逻辑，作者是负责iOS埋点版本实现。<br />
无埋点技术主要是在埋点技术上的衍生，往外的衍生还有可视化埋点技术。<br />
无埋点技术简单点来说就是：hook住iOS中的所有需要的事件访问，并获取相关业务和当前出发的view的层级结构。所以，涉及的技术点主要包含：<br />

1. hook <br />
2. 路径树的定义和解析 <br />

# 第二章 无埋点后台配置请求逻辑
Mixpanel当程序进入前台的时候会请求服务器配置信息
~~~ json
{
    "automatic_events":1,
    "event_bindings":[
        {
            "control_event":64,
            "control_target":null,
            "event_name":"button3Click:",
            "event_type":"ui_control",
            "path":"/ViewController/UIView/UIButton[(mp_fingerprintVersion >= 1 AND mp_varE == "a3639cd95a6f348487f768ac6431deb4710d37bc")]",
            "table_delegate":null
        },
        {
            "control_event":null,
            "control_target":null,
            "event_name":"didSelectCell",
            "event_type":"ui_table_view",
            "path":"/TableViewController/UITableView",
            "table_delegate":"TableViewController"
        }
    ],
    "notifications":[

    ],
    "variants":[
        {
            "actions":[
                {
                    "args":[
                        [
                            "rgba(0, 0, 255, 1.00)",
                            "UIColor"
                        ]
                    ],
                    "cacheOriginal":1,
                    "name":"c1109",
                    "original":[
                        [
                            null,
                            "UIColor"
                        ]
                    ],
                    "path":"/UITableViewController/UITableView/UITableViewWrapperView/UITableViewCell/UITableViewCellContentView/UILabel[(mp_fingerprintVersion >= 1 AND mp_varE == "d84f9db25ecb1133d9b0edb2e9c27b3eb1f627c9")]",
                    "prop":"backgroundColor",
                    "selector":"setBackgroundColor:"
                },
                {
                    "args":[
                        [
                            "\U6211\U662f",
                            "NSString"
                        ],
                        [
                            0,
                            "UIControlState"
                        ]
                    ],
                    "cacheOriginal":1,
                    "name":"c4202",
                    "original":[
                        [
                            "Button1",
                            "NSString"
                        ],
                        [
                            0,
                            "UIControlState"
                        ]
                    ],
                    "path":"/ViewController/UIView/UIButton[(mp_fingerprintVersion >= 1 AND mp_varE == "1b71222ea3803c44e99d47e688945c8152938a0f")]",
                    "prop":"titleForState",
                    "selector":"setTitle:forState:"
                }
            ],
            "experiment_id":43190,
            "id":89728,
            "tweaks":[

            ]
        }
    ]
}
~~~