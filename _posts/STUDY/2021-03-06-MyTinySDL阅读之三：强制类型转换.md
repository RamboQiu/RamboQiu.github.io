---
title:  "MyTinySDL阅读之三：强制类型转换"
date:   2021-03-06
desc: "static_cast、dynamic_cast、const_cast和reinterpret_cast"
keywords: "c"
categories: [Tech, Study]
tags: [c++,SDL]
---

allocator.h中，有段代码用到了static_cast，如下

```c++
template <class T>
T* allocator<T>::allocate()
{
  return static_cast<T*>(::operator new(sizeof(T)));
}
```

