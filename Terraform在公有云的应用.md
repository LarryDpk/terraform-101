
# Terraform与云开发
Terraform支持的公有云有很多，如AWS、Azure、Google、Alibaba等。将Terraform应用于公有云，才最能发挥其强大的功能。

# Terraform在GCP上的应用



## 创建一个新项目
首先我们需要初始化一个GCP项目。GCP给开发者提供了免费试用的服务，我们可以在不花钱的情况下学习GCP的功能。

要使用GCP，我们需要创建一个项目，它所有的资源都是在项目之下管理的：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/init-gcp-sdk.new-project.png)



## 创建Service Account

在实际开发中，我们不能使用自己的账号在做操作，最好的方式是创建一个服务账号（Service Account），这应该也是所有云平台都推荐的方式。创建位置如下：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/init-gcp-sdk.new-service-account.png)



输入账号名字：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/init-gcp-sdk.new-sa-name.png)



选择角色，为了方便，我直接选择Owner，会拥有所有权限，但实际应用肯定不能这样，要做好隔离：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/init-gcp-sdk.new-sa-role.png)





## 创建密钥文件

对于Service Account，不是通过用户名密码来授权的，而是通过密钥文件，创建如下：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/init-gcp-sdk.new-sa-key.png)



选择新建一个密钥，并格式为json。创建后，会自动下载key文件。



## 设置gcloud SDK

Key文件拿到后，我们可以设置环境变量：**GOOGLE_APPLICATION_CREDENTIALS**：

```bash
$ export GOOGLE_APPLICATION_CREDENTIALS=/Users/larry/Software/google-cloud-sdk/pkslow-admin-for-all.json
```



激活Service Account：

```bash
$ gcloud auth activate-service-account admin-for-all@pkslow.iam.gserviceaccount.com --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
```



设置SDK的项目ID：

```bash
$ gcloud config set project pkslow
```



检查一下设置是否正确：

```bash
$ gcloud auth list
               Credentialed Accounts
ACTIVE  ACCOUNT
*       admin-for-all@pkslow.iam.gserviceaccount.com

To set the active account, run:
    $ gcloud config set account `ACCOUNT`


$ gcloud config list
[core]
account = admin-for-all@pkslow.iam.gserviceaccount.com
disable_usage_reporting = True
project = pkslow

Your active configuration is: [default]
```



## 使用gcloud创建Pub/Sub

SDK设置好后，就可以使用了，我们使用它来创建Pub/Sub试试。创建主题和订阅：

```bash
$ gcloud pubsub topics create pkslow-test
Created topic [projects/pkslow/topics/pkslow-test].

$ gcloud pubsub subscriptions create pkslow-sub --topic=pkslow-test
Created subscription [projects/pkslow/subscriptions/pkslow-sub].
```



检查是否创建成功：

```bash
$ gcloud pubsub topics list
---
name: projects/pkslow/topics/pkslow-test


$ gcloud pubsub subscriptions list
---
ackDeadlineSeconds: 10
expirationPolicy:
  ttl: 2678400s
messageRetentionDuration: 604800s
name: projects/pkslow/subscriptions/pkslow-sub
pushConfig: {}
topic: projects/pkslow/topics/pkslow-test
```



在浏览器查看，发现已经成功创建了：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/init-gcp-sdk.pubsub.png)




