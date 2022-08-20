## 💡项目介绍

对频繁集、关联规则的相关概念和方法进行了归纳整理,并采用`python 3.9.7`和`Matlab 2020b`设计实现了常见的关联规则算法`Apriori`算法,`FpGrowth`算法,`Eclat`算法.

## 📝目录结构描述


```c++
.
│  README.pdf					//即此文档
│  关联规则算法研究及其应用.pdf	//暑期实训论文pdf格式
│  思维导图.png					 //思维导图png格式
│  
└─实验程序与数据
    ├─源代码					  //项目源代码
    │  ├─Matlab代码			  //Matlab实现
    │  │      apriori.m
    │  │      ECLAT.m
    │  │      
    │  └─python代码			   //python实现
    │          Apriori.py
    │          Eclat.py
    │          FpGrowth.py
    │          pre.py			//数据预处理
    │          
    └─超市关联规则数据集
            apriori.xlsx		//存放apriori挖掘的关联规则
            dataset.xlsx		//存放处理后的数据,在Sheet3
            Eclat.xlsx			//存放Eclat挖掘的关联规则
            fpgrowth.xlsx		//存放Fpgrowth挖掘的关联规则
            Original data.xlsx	//存放原始数据集
            效率对比具体数据.xlsx  //存放三种算法在相同条件下运行时间
```
## 📖使用说明

算法原理阐述见`关联规则算法研究及其应用.pdf`

至于源代码下的算法文件,按照下文所述修改参数,直接运行即可.读入数据存放在`dataset.xlsx`,输出数据存放在对应的Excel文件下。

+ `Apriori.py`:修改第6行的path为[超市关联数据集]的目录，修改第120,121行的最小支持度和最小置信度参数.函数`load_data_set`作用为加载数据,测试新的数据时请在此函数更改.第124到134行为数据输出,输出格式为:关联规则左侧+关联规则右侧+置信度+支持度,详情可见`apriori.xlsx`

+ `Eclat.py`:第136行修改相关参数,修改第138行的path，第141到153行为加载数据.输出数据格式同上

+ `FpGrowth.py`:第210行修改相关参数,修改第212行的path，第215到第227行为加载数据.输出格式同上

+ `apriori.m`与`ECLAT.m`:只需修改第6行的目录地址即可