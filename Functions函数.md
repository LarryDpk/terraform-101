> 《Terraform 101 从入门到实践》这本小册在[南瓜慢说官方网站](https://www.pkslow.com/tags/terraform101)和[GitHub](https://github.com/LarryDpk/terraform-101)两个地方同步更新，书中的示例代码也是放在GitHub上，方便大家参考查看。

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



`index`获取列表中的元素的索引值：

```hcl
> index(["www", "pkslow", "com"], "pkslow")
1
```



`keys`获取map的所有key值：

```hcl
> keys({name="Larry", age=18, webSite="www.pkslow.com"})
[
  "age",
  "name",
  "webSite",
]
```



`values`获取map的value值：

```hcl
> values({name="Larry", age=18, webSite="www.pkslow.com"})
[
  18,
  "Larry",
  "www.pkslow.com",
]
```



`length`获取字符串、列表、Map等的长度：

```hcl
> length([])
0
> length(["pkslow"])
1
> length(["pkslow", "com"])
2
> length({pkslow = "com"})
1
> length("pkslow")
6
```



`lookup(map, key, default)`根据key值在map中找到对应的value值，如果没有则返回默认值：

```hcl
> lookup({name = "Larry", age = 18}, "age", 1)
18
> lookup({name = "Larry", age = 18}, "myAge", 1)
1
```



`matchkeys(valueslist, keyslist, searchset)`对key值进行匹配。匹配到key值后，返回对应的Value值。

```hcl
> matchkeys(["a", "b", "c", "d"], [1, 2, 3, 4], [2, 4])
tolist([
  "b",
  "d",
])
```



`merge`合并Map，key相同的会被最后的覆盖：

```hcl
> merge({name = "Larry", webSite = "pkslow.com"}, {age = 18})
{
  "age" = 18
  "name" = "Larry"
  "webSite" = "pkslow.com"
}
> merge({name = "Larry", webSite = "pkslow.com"}, {age = 18}, {age = 13})
{
  "age" = 13
  "name" = "Larry"
  "webSite" = "pkslow.com"
}
```



`one`取集合的一个元素，如果为空则返回null；如果只有一个元素，则返回该元素；如果多个元素，则报错：

```hcl
> one([])
null
> one(["pkslow"])
"pkslow"
> one(["pkslow", "com"])
╷
│ Error: Invalid function argument
│ 
│   on <console-input> line 1:
│   (source code not available)
│ 
│ Invalid value for "list" parameter: must be a list, set, or tuple value with either zero or one elements.
╵
```



`range`生成顺序列表：

```hcl
range(max)
range(start, limit)
range(start, limit, step)

> range(3)
tolist([
  0,
  1,
  2,
])
> range(1, 6)
tolist([
  1,
  2,
  3,
  4,
  5,
])
> range(1, 6, 2)
tolist([
  1,
  3,
  5,
])
```



`reverse`反转列表：

```hcl
> reverse([1, 2, 3, 4])
[
  4,
  3,
  2,
  1,
]
```



`setintersection`对set求交集：

```hcl
> setintersection([1, 2, 3], [2, 3, 4], [2, 3, 6])
toset([
  2,
  3,
])
```



`setproduct`列出所有组合可能：

```hcl
> setproduct(["Larry", "Harry"], ["Deng", "Potter"])
tolist([
  [
    "Larry",
    "Deng",
  ],
  [
    "Larry",
    "Potter",
  ],
  [
    "Harry",
    "Deng",
  ],
  [
    "Harry",
    "Potter",
  ],
])
```



`setsubtract`：set的减法

```hcl
> setsubtract([1, 2, 3], [3, 4])
toset([
  1,
  2,
])

# 求不同
> setunion(setsubtract(["a", "b", "c"], ["a", "c", "d"]), setsubtract(["a", "c", "d"], ["a", "b", "c"]))
[
  "b",
  "d",
]
```



`setunion`：set的加法

```hcl
> setunion([1, 2, 3], [3, 4])
toset([
  1,
  2,
  3,
  4,
])
```



`slice(list, startindex, endindex)`截取列表部分，包括startindex，但不包括endindex：

```hcl
> slice(["a", "b", "c", "d", "e"], 1, 4)
[
  "b",
  "c",
  "d",
]
```



`sort`对列表中的字符串进行排序，要注意如果输入的是数字，会先转化为字符串再排序：

```hcl
> sort(["larry", "pkslow", "com", "deng"])
tolist([
  "com",
  "deng",
  "larry",
  "pkslow",
])
> sort([3, 6, 1, 9, 12, 79, 22])
tolist([
  "1",
  "12",
  "22",
  "3",
  "6",
  "79",
  "9",
])
```



`sum`求和：

```hcl
> sum([3, 1.2, 9, 17.3, 2.2])
32.7
```



`transpose`对Map的key和value进行换位：

```hcl
> transpose({"a" = ["1", "2"], "b" = ["2", "3"]})
tomap({
  "1" = tolist([
    "a",
  ])
  "2" = tolist([
    "a",
    "b",
  ])
  "3" = tolist([
    "b",
  ])
})
```





`zipmap`根据key和value的列表按一对一关系生成Map：

```hcl
> zipmap(["age", "name"], [18, "Larry Deng"])
{
  "age" = 18
  "name" = "Larry Deng"
}
```



# 加密解密

Base64：

```hcl
> base64encode("pkslow")
"cGtzbG93"
> base64decode("cGtzbG93")
"pkslow"
> textencodebase64("pkslow", "UTF-8")
"cGtzbG93"
> textdecodebase64("cGtzbG93", "UTF-8")
"pkslow"
```



csv文本解析：

```hcl
> csvdecode("seq,name,age\n1,larry,18\n2,pkslow,3\n3,Jeremy,29")
tolist([
  {
    "age" = "18"
    "name" = "larry"
    "seq" = "1"
  },
  {
    "age" = "3"
    "name" = "pkslow"
    "seq" = "2"
  },
  {
    "age" = "29"
    "name" = "Jeremy"
    "seq" = "3"
  },
])
```



Json解析：

```hcl
> jsonencode({"name"="Larry", "age"=18})
"{\"age\":18,\"name\":\"Larry\"}"
> jsondecode("{\"age\":18,\"name\":\"Larry\"}")
{
  "age" = 18
  "name" = "Larry"
}
```



URL：

```hcl
> urlencode("Larry Deng/a/:/./@")
"Larry+Deng%2Fa%2F%3A%2F.%2F%40"
```



YAML：

```hcl
> yamlencode({"a":"b", "c":"d"})
"a": "b"
"c": "d"

> yamlencode({"foo":[1, 2, 3], "bar": "baz"})
"bar": "baz"
"foo":
- 1
- 2
- 3

> yamlencode({"foo":[1, {"a":"b","c":"d"}, 3], "bar": "baz"})
"bar": "baz"
"foo":
- 1
- "a": "b"
  "c": "d"
- 3
> yamldecode("hello: world")
{
  "hello" = "world"
}

> yamldecode("true")
true

> yamldecode("{a: &foo [1, 2, 3], b: *foo}")
{
  "a" = [
    1,
    2,
    3,
  ]
  "b" = [
    1,
    2,
    3,
  ]
}
```



文件处理：

获取绝对路径：

```hcl
> abspath(path.root)
"/Users/larry"
```



获取路径中的目录，或者是文件名：

```hcl
> dirname("/home/larry/soft/terraform")
"/home/larry/soft"
> dirname("/home/larry/soft/terraform/")
"/home/larry/soft/terraform"
> basename("/home/larry/soft/terraform")
"terraform"
> basename("/home/larry/soft/terraform/")
"terraform"
```



判断文件是否存在，并获取文件内容：

```hcl
> fileexists("/Users/larry/.bash_profile")
true
> file("/Users/larry/.bash_profile")
> filebase64("/Users/larry/.bash_profile")
```



根据模式匹配所有文件：

```hcl
> fileset("/Users/larry", "*.bash*")
toset([
  ".bash_history",
  ".bash_profile",
  ".bash_profile.backup",
])
```



[`templatefile(path, vars)`模板化文件](https://www.terraform.io/language/functions/templatefile)：指定文件和变量，把变量值替换掉模板中的变量。



# 时间函数

获取当前时间，并格式化显示，格式请参考：https://www.terraform.io/language/functions/formatdate

```hcl
> formatdate("YYYY-MM-DD hh:mm:ss / D MMMM YYYY", timestamp())
"2022-03-05 08:25:48 / 5 March 2022"
> formatdate("EEEE, DD-MMM-YY hh:mm:ss ZZZ", "2018-01-02T23:12:01Z")
"Tuesday, 02-Jan-18 23:12:01 UTC"
```



时间加减：

```hcl
> timeadd(timestamp(), "24h")
"2022-03-06T08:28:52Z"
> timeadd(timestamp(), "-24h10m")
"2022-03-04T08:19:08Z"
```

支持的单位有：`"ns"`, `"us"` (or `"µs"`), `"ms"`, `"s"`, `"m"`, and `"h"`.







# 其它

加密：

```hcl
> md5("www.pkslow.com")
"97e164b60faf4d7875c2a8a5bc3f2245"
```



UUID：

```hcl
> uuid()
"049bf418-15d1-e034-28db-92945067dcf6"
```



IP：

```hcl
> cidrsubnet("172.16.0.0/12", 4, 2)
"172.18.0.0/16"
```



更多请参考官网。
