
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

---

# Terraform创建Pub/Sub

## 下载Terraform插件

我们需要安装GCP的Terraform插件来管理GCP资源：

```bash
# 设置插件目录
$ export TERRAFORM_PLUGIN=/Users/larry/Software/terraform/plugins
# 创建目录
$ mkdir -p ${TERRAFORM_PLUGIN}/registry.terraform.io/hashicorp/google/4.0.0/darwin_amd64
$ cd ${TERRAFORM_PLUGIN}/registry.terraform.io/hashicorp/google/4.0.0/darwin_amd64
# 下载
$ wget https://releases.hashicorp.com/terraform-provider-google/4.0.0/terraform-provider-google_4.0.0_darwin_amd64.zip
# 解压
$ unzip terraform-provider-google_4.0.0_darwin_amd64.zip
```



## 准备Terraform代码

需要提供Terraform代码理管理Pub/Sub，更多细节请参考： [Terrafrom GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription).



版本文件version.tf:

```json
terraform {
  required_version = "= 1.0.11"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = "= 4.0.0"
    }
  }
}
```



主文件main.tf:

```json
provider "google" {
  project     = "pkslow"
}

resource "google_pubsub_topic" "pkslow-poc" {
  name = "pkslow-poc"
}

resource "google_pubsub_subscription" "pkslow-poc" {
  name  = "pkslow-poc"
  topic = google_pubsub_topic.pkslow-poc.name

  labels = {
    foo = "bar"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = true
}
```



## 初始化和变更

指定插件目录初始化：

```bash
$ terraform init -plugin-dir=${TERRAFORM_PLUGIN}
```



使变更生效，就会在GCP上创建对应的资源：

```bash
$ terraform apply -auto-approve
```



如果没有发生错误，则意味着创建成功，我们检查一下：

```bash
$ gcloud pubsub topics list
---
name: projects/pkslow/topics/pkslow-poc

$ gcloud pubsub subscriptions list
---
ackDeadlineSeconds: 20
enableMessageOrdering: true
expirationPolicy:
  ttl: 300000.500s
labels:
  foo: bar
messageRetentionDuration: 1200s
name: projects/pkslow/subscriptions/pkslow-poc
pushConfig: {}
retainAckedMessages: true
retryPolicy:
  maximumBackoff: 600s
  minimumBackoff: 10s
topic: projects/pkslow/topics/pkslow-poc
```



注意：我们并没有提供任何密码或密钥，那Terraform怎么可以直接操作我的GCP资源呢？因为它会根据环境变量**GOOGLE_APPLICATION_CREDENTIALS**来获取。



# 发送和接收消息

我们通过gcloud来发送消息到Pub/Sub上：

```bash
$ gcloud pubsub topics publish pkslow-poc --message="www.pkslow.com"
messageIds:
- '3491736520339885'

$ gcloud pubsub topics publish pkslow-poc --message="Larry Deng"
messageIds:
- '3491738650256958'

$ gcloud pubsub topics publish pkslow-poc --message="Hi, pkslower"
messageIds:
- '3491739306095970'
```



从Pub/Sub拉取消息：

```bash
$ gcloud pubsub subscriptions pull pkslow-poc --auto-ack
```



![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/terraform-gcp-pubsub.pull.png)



我们还能在GCP界面上监控对应的队列，十分方便：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/2021/11/terraform-gcp-pubsub.console-pub.png)


