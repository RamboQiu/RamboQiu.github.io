---
title:  "ScrollView的ContentSize自适应小技巧"
date:   2024-03-21
desc: "ContentSize我再大多数情况下都是自己去计算出来然后再赋值，让页面可以滚动，这里学习下可以使用autolayout的布局方式实现自适应滚动高度"
categories: [Tech, Study]
tags: [Swift, ScrollView]

---

大致意思就是布局要撑开ScrollView，也就是布局到最下面一个元素之后，最下面的元素要触底，将view撑开

```swift

addSubview(scrollView)

scrollView.snp.makeConstraints { make in
    make.top.equalTo(self.snp.top).offset(18)
    make.bottom.equalTo(self.snp.bottom).offset(0)
    make.horizontalEdges.equalTo(self).offset(0)
}

scrollView.addSubView(exampleView)
exampleView.snp.makeConstraints { make in
    make.width.equalTo(265)
    make.height.equalTo(117)
    make.centerX.equalTo(contentView)
    make.top.equalTo(self).inset(500)
}

scrollView.addSubView(button)
button.snp.makeConstraints { make in
    make.centerX.equalToSuperview()
    make.width.equalTo(UIScreen.main.bounds.width - 56)
    make.height.equalTo(300)
                     
    // 要先设置宽高，再设置top bottom，才会让父scrollView的contentSize自适应
    make.top.equalTo(exampleView.snp.bottom).offset(40)
    make.bottom.equalTo(contentView.snp.bottom).offset(-30)
}
```

