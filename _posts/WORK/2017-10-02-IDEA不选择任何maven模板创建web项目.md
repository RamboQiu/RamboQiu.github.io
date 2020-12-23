---
layout: post
title:  "IDEA不选择任何maven模板创建web项目"
date:   2017-10-02
desc: "IDEA不选择任何maven模板创建web项目"
keywords: "Maven,IDEA,webapp"
categories: [Tech, java]
tags: [IDEA, Maven, webapp]
icon: icon-html
---

转载至[这里](https://my.oschina.net/947/blog/769729)
 1. Create New Project或者File->New->Project，如图
 ![这里写图片描述](/assets/img/work/20171002/20171003160326021.png)
 2. 点击maven,(不用选择Create from archetype)，点击next，如图：
 ![这里写图片描述](/assets/img/work/20171002/20171003160428175.png)
 3. 填写GroupId和ArtifactId,点击next，如图:
 ![这里写图片描述](/assets/img/work/20171002/20171003160459047.png)
 4. 填写项目名称，点击Finish，如图：
 ![这里写图片描述](/assets/img/work/20171002/20171003160528302.png)
 5. 此时的目录结构如图所示：可以看到这里只创建了java的文件目录，没有创建web的文件目录
 ![这里写图片描述](/assets/img/work/20171002/20171003160559494.png)
 6. idea会有一个提示，自动引入，点击它：
 ![这里写图片描述](/assets/img/work/20171002/20171003160623514.png)
 7. 部署项目，File->Project Structure或点击如图所示的图标：
 ![这里写图片描述](/assets/img/work/20171002/20171003160645465.png)
 8. 设置SDK，选择自己电脑上安装的SDK版本。设置Project compiler output,通常选择默认，这里是编译后的文件目录，如图：
 ![这里写图片描述](/assets/img/work/20171002/20171003160726773.png)
 9. 点击Modules,可以看到这里没有任何模板服务，在这里创建一个web服务，点击+，选择web
 ![这里写图片描述](/assets/img/work/20171002/20171003160750898.png)
 10. 设置好后点击应用（Deployment Descriptors/Path以及Web Resource Dicrectories/Web Resource Dicrectory取默认的即可）：
 ![这里写图片描述](/assets/img/work/20171002/20171003161210216.png)
 11. 添加tomcat依赖，如图所示：
 ![这里写图片描述](/assets/img/work/20171002/20171003161502642.png)
 12. 在弹出的窗口中选择tomcat,点击添加，如图所示：
 ![这里写图片描述](/assets/img/work/20171002/20171003161535511.png)
 13. 点击Artifacts,这里设置当前项目发布信息。点击+，选择From Modules...在弹出的窗口中点击ok
 ![这里写图片描述](/assets/img/work/20171002/20171003161328775.png)
 14. 如图所示，点击应用
 ![这里写图片描述](/assets/img/work/20171002/20171003161631527.png)
 15. 设置tomcat：点击如图所示图标：
 ![这里写图片描述](/assets/img/work/20171002/20171003161703240.png)
 16. 选中Defaults->Tomcat Server->Local->Server和Deployment如下图设置
 ![这里写图片描述](/assets/img/work/20171002/20171003161813941.png)
 ![这里写图片描述](/assets/img/work/20171002/20171003161827300.png)
 ![这里写图片描述](/assets/img/work/20171002/20171003161841074.png)
 17. 如图所示，第一次进入会隐藏热部署设置，需要下次进来设置。
 ![这里写图片描述](/assets/img/work/20171002/113008_EHeO_2445566.png)
 18. 选择Deployment->+->Artifact.如图：
 ![这里写图片描述](/assets/img/work/20171002/113156_L1iR_2445566.png)
 19. 现在反回Server，如图在On frame deactivation中选择Update classes and resources;设置热部署
 ![这里写图片描述](/assets/img/work/20171002/113648_UWLV_2445566.png)
 20. 点击应用或，ok。在webapp下面新建index.jsp页面，如图：
 ![这里写图片描述](/assets/img/work/20171002/113905_35yG_2445566.png)
 21. 在web.xml中添加欢迎节点，如图:
 ![这里写图片描述](/assets/img/work/20171002/114143_s67v_2445566.png)
 22. 启动程序
 ![这里写图片描述](/assets/img/work/20171002/115646_546u_2445566.png)![这里写图片描述](/assets/img/work/20171002/115722_5toP_2445566.png)
 23. ok，到这里，web项目设置完成。最终目录结构如图：
 ![这里写图片描述](/assets/img/work/20171002/115900_ZJB3_2445566.png)