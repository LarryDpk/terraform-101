> 《Terraform 101 从入门到实践》这本书只将在[南瓜慢说官方网站](https://www.pkslow.com/tags/terraform101)和[GitHub](https://github.com/LarryDpk/terraform-101)两个地方同步更新，如果你在其它地方看到，那应该就是抄袭和未授权的转载。书中的示例代码也是放在GitHub上，方便大家参考查看。

**博客目录**：

- [《Terraform 101 从入门到实践》 前言](https://www.pkslow.com/archives/terraform-101-preface)
- [《Terraform 101 从入门到实践》 第一章 Terraform初相识](https://www.pkslow.com/archives/terraform-101-introduction)
- [《Terraform 101 从入门到实践》 第二章 Providers插件管理](https://www.pkslow.com/archives/terraform-101-providers)
- [《Terraform 101 从入门到实践》 第三章 Modules模块化](https://www.pkslow.com/archives/terraform-101-modules)
- [《Terraform 101 从入门到实践》 第四章 States状态管理](https://www.pkslow.com/archives/terraform-101-states)
- [《Terraform 101 从入门到实践》 第五章 HCL语法](https://www.pkslow.com/archives/terraform-101-hcl)
- [《Terraform 101 从入门到实践》 Terraform常用命令](https://www.pkslow.com/archives/terraform-101-commands)



**GitHub目录**：

- [前言](https://github.com/LarryDpk/terraform-101/blob/main/README.md)
- [第一章 Terraform初相识](https://github.com/LarryDpk/terraform-101/blob/main/01.Terraform初相识.md)
- [第二章 Providers插件管理](https://github.com/LarryDpk/terraform-101/blob/main/02.Providers插件管理.md)
- [第三章 Modules模块化](https://github.com/LarryDpk/terraform-101/blob/main/03.Modules模块化.md)
- [第四章 States状态管理](https://github.com/LarryDpk/terraform-101/blob/main/04.States状态管理.md)
- [第五章 HCL语法](https://github.com/LarryDpk/terraform-101/blob/main/05.HCL语法.md)
- [Terraform常用命令](https://github.com/LarryDpk/terraform-101/blob/main/Terraform常用命令.md)

---

指定插件目录初始化：

```bash
$ terraform init -plugin-dir=/Users/larry/Software/terraform/plugins
$ terraform init -plugin-dir=${TERRAFORM_PLUGIN}
```



将目录下所有Terraform文件格式化，包含子目录：

```bash
$ terraform fmt -recursive
```



非交互式apply和destroy：

```bash
$ terraform apply -auto-approve
$ terraform destroy -auto-approve
```



其它：

```bash
$ terraform output
$ terraform console
$ terraform get
```



有用的别名：

```bash
alias tfmt='terraform fmt -recursive'
alias tinit='terraform init -plugin-dir=${TERRAFORM_PLUGIN}'
alias tapply='terraform apply -auto-approve'
alias tdestroy='terraform destroy -auto-approve'
alias tplan='terraform plan'
```

