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





