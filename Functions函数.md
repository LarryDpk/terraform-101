> 《Terraform 101 从入门到实践》这本书只将在[南瓜慢说官方网站](https://www.pkslow.com/tags/terraform101)和[GitHub](https://github.com/LarryDpk/terraform-101)两个地方同步更新，如果你在其它地方看到，那应该就是抄袭和未授权的转载。书中的示例代码也是放在GitHub上，方便大家参考查看。

---



# Terraform的函数

Terraform为了让大家在表达式上可以更加灵活方便地进行计算，提供了大量的内置函数（Function）。目前并不支持自定义函数，只能使用Terraform自带的。使用函数的格式也很简单，直接写函数名+参数即可。如下面的函数为取最大值：

```hcl
> max(34, 45, 232, 25)
232
```

这里把函数单独列成一章不是因为它很难理解，而因为它很常用，值得把这些函数梳理一下，以便查询使用吧。



# 数值计算函数

绝对值abs：

```hcl
> abs(5)
5
> abs(-3.1415926)
3.1415926
> abs(0)
0
```



返回大于等于该数值的最小整数：

```hcl
> ceil(3)
3
> ceil(3.1)
4
> ceil(2.9)
3
```



小于等于该数值的最大整数：

```hcl
> floor(6)
6
> floor(6.9)
6
> floor(5.34)
5
```



对数函数：

```hcl
> log(16, 2)
4
> log(9, 3)
2.0000000000000004
```



指数函数：

```hcl
> pow(6, 2)
36
> pow(6, 1)
6
> pow(6, 0)
1
```



最大值、最小值：

```hcl
> max(2, 98,  75, 4)
98
> min(2, 98,  75, 4)
2
```



字符串转换成整数，第二个参数为进制：

```hcl
> parseint("16", 10)
16
> parseint("16", 16)
22
> parseint("FF", 16)
255
> parseint("1010", 2)
10
```



信号量函数：

```hcl
> signum(6)
1
> signum(-6)
-1
> signum(0)
0
```



# 字符串函数

删去换行，在从文件中读取文本时非常有用：

```hcl
> chomp("www.pkslow.com")
"www.pkslow.com"
> chomp("www.pkslow.com\n")
"www.pkslow.com"
> chomp("www.pkslow.com\n\n")
"www.pkslow.com"
> chomp("www.pkslow.com\n\n\r")
"www.pkslow.com"
> chomp("www.pkslow.com\n\n\ra")
<<EOT
www.pkslow.com

a
EOT
```



格式化输出：

```hcl
> format("Hi, %s!", "Larry")
"Hi, Larry!"

> format("My name is %s, I'm %d", "Larry", 18)
"My name is Larry, I'm 18"

> format("The reuslt is %.2f", 3)
"The reuslt is 3.00"

> format("The reuslt is %.2f", 3.1415)
"The reuslt is 3.14"

> format("The reuslt is %8.2f", 3.1415)
"The reuslt is     3.14"
```



遍历格式化列表：

```hcl
> formatlist("My name is %s, I'm %d %s.", ["Larry", "Jeremy", "Tailor"], [18, 28, 33], "in 2022")
tolist([
  "My name is Larry, I'm 18 in 2022.",
  "My name is Jeremy, I'm 28 in 2022.",
  "My name is Tailor, I'm 33 in 2022.",
])
```

参数可以是List，还可以是单个变量。



字符串连接：

```hcl
> join(".", ["www", "pkslow", "com"])
"www.pkslow.com"
> join(", ", ["Larry", "Pkslow", "JJ"])
"Larry, Pkslow, JJ"
```



大小写字母转换：

```hcl
> lower("Larry Nanhua DENG")
"larry nanhua deng"
> upper("Larry Nanhua DENG")
"LARRY NANHUA DENG"
```



首字母大写：

```hcl
> title("larry")
"Larry"
```



替换：

```hcl
> replace("www.larrydpk.com", "larrydpk", "pkslow")
"www.pkslow.com"
> replace("hello larry", "/la.*y/", "pkslow")
"hello pkslow"
```





分割：

```hcl
> split(".", "www.pklow.com")
tolist([
  "www",
  "pklow",
  "com",
])
```



反转：

```hcl
> strrev("pkslow")
"wolskp"
```



截取：

```hcl
> substr("Larry Deng", 0, 5)
"Larry"
> substr("Larry Deng", -4, -1)
"Deng"
```



去除头尾某些特定字符，注意这里只要有对应字符就会删除：

```hcl
> trim("?!what?!!!!!", "?!")
"what"
> trim("abaaaaabbLarry Dengaab", "ab")
"Larry Deng"
```



去除头尾特定字符串，注意与上面的区别：

```hcl
> trimsuffix("?!what?!!!!!", "!!!")
"?!what?!!"
> trimprefix("?!what?!!!!!", "?!")
"what?!!!!!"
```



去除头尾的空格、换行等空串：

```hcl
> trimspace(" Larry Deng \n\r")
"Larry Deng"
```



正则匹配，下面的例子是匹配第一个和匹配所有：

```hcl
> regex("[a-z\\.]+", "2021www.pkslow.com2022larry deng 31415926")
"www.pkslow.com"
> regexall("[a-z\\.]+", "2021www.pkslow.com2022larry deng 31415926")
tolist([
  "www.pkslow.com",
  "larry",
  "deng",
])
```

更多正则匹配语法可参考：https://www.terraform.io/language/functions/regex



# 集合类函数

`alltrue`：判断列表是否全为真，空列表直接返回true。只能是bool类型或者对应的字符串。

```hcl
> alltrue([true, "true"])
true
> alltrue([true, "true", false])
false
> alltrue([])
true
> alltrue([1])
╷
│ Error: Invalid function argument
│ 
│   on <console-input> line 1:
│   (source code not available)
│ 
│ Invalid value for "list" parameter: element 0: bool required.
```



`anytrue`：判断列表是否有真，只要有一个为真就返回true。空列表为false。

```hcl
> anytrue([true])
true
> anytrue([true, false])
true
> anytrue([false, false])
false
> anytrue([])
false
```



`chunklist`分片：根据分片数来对列表进行切分。

```hcl
> chunklist(["www", "pkslow", "com", "Larry", "Deng"], 3)
tolist([
  tolist([
    "www",
    "pkslow",
    "com",
  ]),
  tolist([
    "Larry",
    "Deng",
  ]),
])
```



`coalesce`返回第一个非空元素：

```hcl
> coalesce("", "a", "b")
"a"
> coalesce("", "", "b")
"b"
```



`coalescelist`返回第一个非空列表：

```hcl
> coalescelist([], ["pkslow"])
[
  "pkslow",
]
```



从字符串列表里把空的去掉：

```hcl
> compact(["", "www", "", "pkslow", "com"])
tolist([
  "www",
  "pkslow",
  "com",
])
```



`concat`连接多个列表：

```hcl
> concat([1, 2, 3], [4, 5, 6])
[
  1,
  2,
  3,
  4,
  5,
  6,
]
```



`contains`判断是否存在某个元素：

```hcl
> contains(["www", "pkslow", "com"], "pkslow")
true
> contains(["www", "pkslow", "com"], "Larry")
false
```



`distinct`去除重复元素：

```hcl
> distinct([1, 2, 2, 1, 3, 8, 1, 10])
tolist([
  1,
  2,
  3,
  8,
  10,
])
```



`element`获取列表的某个元素：

```hcl
> element(["a", "b", "c"], 1)
"b"
> element(["a", "b", "c"], 2)
"c"
> element(["a", "b", "c"], 3)
"a"
> element(["a", "b", "c"], 4)
"b"
```



`flatten`把内嵌的列表都展开成一个列表：

```hcl
> flatten([1, 2, 3, [1], [[6]]])
[
  1,
  2,
  3,
  1,
  6,
]
```

