> 《Terraform 101 从入门到实践》这本书只将在[南瓜慢说官方网站](https://www.pkslow.com/tags/terraform101)和[GitHub](https://github.com/LarryDpk/terraform-101)两个地方同步更新，如果你在其它地方看到，那应该就是抄袭和未授权的转载。书中的示例代码也是放在GitHub上，方便大家参考查看。

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



创建一个工作区并切换：

```bash
$ terraform workspace new pkslow
```



切换到已存在的工作区：

```bash
$ terraform workspace select pkslow
```



输出变更计划到指定文件：

```bash
$ terraform plan -out=pkslow.plan
```

根据计划执行变更：

```bash
$ terraform apply pkslow.plan
```



输入变量：

```bash
$ terraform apply -var="env=uat"
$ terraform apply -var-file="prod.tfvars"
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

