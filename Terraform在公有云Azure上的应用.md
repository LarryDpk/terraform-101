> 《Terraform 101 从入门到实践》这本小册在[南瓜慢说官方网站](https://www.pkslow.com/tags/terraform101)和[GitHub](https://github.com/LarryDpk/terraform-101)两个地方同步更新，书中的示例代码也是放在GitHub上，方便大家参考查看。

---





# 简介

`Azure`是微软的公有云，它提供了一些免费的资源，具体可以查看： https://azure.microsoft.com/en-us/free/

本章将介绍如何通过`Terraform`来使用`Azure`的云资源。



# 注册Azure账号

首先要注册一个Azure账号，我选择用GitHub账号登陆，免得又记多一个密码。

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-azure-account.png)





跳到GitHub，同意即可：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-azure-account.with-github.png)



创建账号时，有一些信息要填，特别是邮箱和手机号比较关键：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-azure-account.profile.png)





同时还需要一张Visa或Master卡，我是有一张Visa的卡，填好后会有一个0元的扣费，不要担心。下面Cardholder Name我填的中文名字，注册成功了。

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-azure-account.visa-card.png)



0元扣费成功后，表示卡是正常的，就可以成功注册了，注册后就可以到[Portal](https://portal.azure.com/?quickstart=true#view/Microsoft_Azure_Resources/QuickstartCenterBlade)查看了。

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-azure-account.portal.png)



# 手动部署虚拟机

为了体验一下Azure，我们先手动创建一个虚拟机，操作入口如下：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-vm.add-vm.png)





需要填写一些配置信息，如主机名、区域、镜像、网络端口等，按需要我打开了22/80/443端口。

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-vm.config.png)





完成配置后，点击创建，提示要下载密钥对，必须要在创建的时候下载：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-vm.download-ssh-key.png)



创建完资源后，可以在虚拟机列表查看：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-vm.vm-list.png)

根据用户名和公网IP，我们可以ssh连接到服务器。需要给密钥文件修改权限，太大是不行的，会报错。

```bash
$ chmod 400 ~/Downloads/pksow-azure.pem
```



然后通过下面命令连接：

```bash
$ ssh azureuser@20.2.85.137 -i ~/Downloads/pksow-azure.pem 
Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.15.0-1030-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System load:  0.01513671875     Processes:             109
  Usage of /:   4.9% of 28.89GB   Users logged in:       0
  Memory usage: 31%               IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%

0 updates can be applied immediately.



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

azureuser@pkslow:~$ free
               total        used        free      shared  buff/cache   available
Mem:          928460      261816      288932        4140      377712      533872
Swap:              0           0           0
azureuser@pkslow:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G  1.5G   28G   5% /
tmpfs           454M     0  454M   0% /dev/shm
tmpfs           182M  1.1M  181M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda15      105M  5.3M  100M   5% /boot/efi
/dev/sdb1       3.9G   28K  3.7G   1% /mnt
tmpfs            91M  4.0K   91M   1% /run/user/1000
```





# 通过azure-cli创建虚拟机



## 安装azure-cli

我的电脑是MacOS，安装如下：

```bash
$ brew update-reset

$ brew install azure-cli

$ which az
/usr/local/bin/az

$ az version
{
  "azure-cli": "2.44.1",
  "azure-cli-core": "2.44.1",
  "azure-cli-telemetry": "1.0.8",
  "extensions": {}
}
```



其它系统请参考： https://learn.microsoft.com/en-us/cli/azure/install-azure-cli



## 权限

通过命令行操作Azure的资源，必然是需要权限的，我们可以通过密码，还可以通过Service Principal等方式来登陆。我们主要使用Service Principal的方式来授权。因此我们先在Portal上创建。

在左侧菜单选择`Azure Active Directory`，选择`应用注册`，点击`新注册`：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-service-principal.app-reg.png)



注册应用程序：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-service-principal.app-reg2.png)



添加密码：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-service-principal.add-client-password.png)





设置说明和时长：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-service-principal.config-password.png)





创建完后要马上记下密码，后面无法再获取密码值：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/create-service-principal.markdown-password.png)



## 查看租户

需要查看租户ID，或创建租户：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/tenant-info.png)







## 分配角色

到订阅管理界面： [Subscriptions page in Azure portal](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)，查看订阅列表：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/subscription-list.png)

点进去后，可以管理访问控制：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/subscription-access.png)



把之前创建的Service Principal加进来，分配特定角色：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/subscription-add-role.png)





选择对应的Service Principal：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/subscription-add-sp.png)





## 命令行登陆

完成以上操作后，就可以通过命令行来登陆Azure了：

```bash
$ az login --service-principal -u f01d69bf-8ff3-4043-9275-3e0c4de54884 -p B0N8Q~PQu6hTJkBTS5xxxxxxxx******** --tenant 2951528a-e359-4846-9817-ec3ebc2664d4
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "2951528a-e359-4846-9817-ec3ebc2664d4",
    "id": "cd7921d5-9ba9-45db-bfba-1c397fcaaba3",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Free Trial",
    "state": "Enabled",
    "tenantId": "2951528a-e359-4846-9817-ec3ebc2664d4",
    "user": {
      "name": "f01d69bf-8ff3-4043-9275-3e0c4de54884",
      "type": "servicePrincipal"
    }
  }
]
```

`-u`是注册应用的ID；

`-p`就是之前要记下的密码；

`--tenant`就是租户ID；



查询之前创建的VM，成功：

```bash
$ az vm list -g test --output table
Name    ResourceGroup    Location    Zones
------  ---------------  ----------  -------
pkslow  test             eastasia    1
```



## 创建vm

通过命令行创建vm如下：

```bash
$ az vm create --resource-group 'test' --name 'pkslow2' --image 'canonical:0001-com-ubuntu-server-jammy:22_04-lts:22.04.202301100' --admin-username 'larry' --admin-password 'Pa!!!ss123' --location 'eastasia'

{
  "fqdns": "",
  "id": "/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/test/providers/Microsoft.Compute/virtualMachines/pkslow2",
  "location": "eastasia",
  "macAddress": "60-45-BD-57-30-C1",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.5",
  "publicIpAddress": "20.187.85.53",
  "resourceGroup": "test",
  "zones": ""
}

```

查询后成功创建，已经有2台虚拟机在运行：

```bash
$ az vm list -g test --output table
Name     ResourceGroup    Location    Zones
-------  ---------------  ----------  -------
pkslow   test             eastasia    1
pkslow2  test             eastasia
```



# 用Terraform创建vm

## 权限环境变量设置

当我们使用Terraform来操作Azure时，同样也是需要权限的，配置以下环境变量即可。这些值在前面的内容已经讲过了。

```bash
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```



## 插件和版本

配置Terraform和插件的版本：

```hcl
terraform {
  required_version = ">= 1.1.3"
  required_providers {

    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.38.0"
    }
  }
}
```



## 创建vm

通过`azurerm_virtual_machine`来创建VM资源：

```hcl
provider "azurerm" {
  features {}
}

variable "prefix" {
  default = "pkslow-azure"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "22.04.202301100"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "larry"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
```



然后我们执行初始化，会下载Azure的Terraform插件：

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "3.38.0"...
- Installing hashicorp/azurerm v3.38.0...
- Installed hashicorp/azurerm v3.38.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```



查看plan，看看会生成什么资源：

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_network_interface.main will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "westeurope"
      + mac_address                   = (known after apply)
      + name                          = "pkslow-azure-nic"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "pkslow-azure-resources"
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "testconfiguration1"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_resource_group.example will be created
  + resource "azurerm_resource_group" "example" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "pkslow-azure-resources"
    }

  # azurerm_subnet.internal will be created
  + resource "azurerm_subnet" "internal" {
      + address_prefixes                               = [
          + "10.0.2.0/24",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "internal"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "pkslow-azure-resources"
      + virtual_network_name                           = "pkslow-azure-network"
    }

  # azurerm_virtual_machine.main will be created
  + resource "azurerm_virtual_machine" "main" {
      + availability_set_id              = (known after apply)
      + delete_data_disks_on_termination = false
      + delete_os_disk_on_termination    = false
      + id                               = (known after apply)
      + license_type                     = (known after apply)
      + location                         = "westeurope"
      + name                             = "pkslow-azure-vm"
      + network_interface_ids            = (known after apply)
      + resource_group_name              = "pkslow-azure-resources"
      + tags                             = {
          + "environment" = "staging"
        }
      + vm_size                          = "Standard_DS1_v2"

      + identity {
          + identity_ids = (known after apply)
          + principal_id = (known after apply)
          + type         = (known after apply)
        }

      + os_profile {
          + admin_password = (sensitive value)
          + admin_username = "larry"
          + computer_name  = "hostname"
          + custom_data    = (known after apply)
        }

      + os_profile_linux_config {
          + disable_password_authentication = false
        }

      + storage_data_disk {
          + caching                   = (known after apply)
          + create_option             = (known after apply)
          + disk_size_gb              = (known after apply)
          + lun                       = (known after apply)
          + managed_disk_id           = (known after apply)
          + managed_disk_type         = (known after apply)
          + name                      = (known after apply)
          + vhd_uri                   = (known after apply)
          + write_accelerator_enabled = (known after apply)
        }

      + storage_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts"
          + version   = "22.04.202301100"
        }

      + storage_os_disk {
          + caching                   = "ReadWrite"
          + create_option             = "FromImage"
          + disk_size_gb              = (known after apply)
          + managed_disk_id           = (known after apply)
          + managed_disk_type         = "Standard_LRS"
          + name                      = "myosdisk1"
          + os_type                   = (known after apply)
          + write_accelerator_enabled = false
        }
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = [
          + "10.0.0.0/16",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "westeurope"
      + name                = "pkslow-azure-network"
      + resource_group_name = "pkslow-azure-resources"
      + subnet              = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```



直接apply，创建对应的资源：

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_network_interface.main will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "westeurope"
      + mac_address                   = (known after apply)
      + name                          = "pkslow-azure-nic"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "pkslow-azure-resources"
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "testconfiguration1"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_resource_group.example will be created
  + resource "azurerm_resource_group" "example" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "pkslow-azure-resources"
    }

  # azurerm_subnet.internal will be created
  + resource "azurerm_subnet" "internal" {
      + address_prefixes                               = [
          + "10.0.2.0/24",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "internal"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "pkslow-azure-resources"
      + virtual_network_name                           = "pkslow-azure-network"
    }

  # azurerm_virtual_machine.main will be created
  + resource "azurerm_virtual_machine" "main" {
      + availability_set_id              = (known after apply)
      + delete_data_disks_on_termination = false
      + delete_os_disk_on_termination    = false
      + id                               = (known after apply)
      + license_type                     = (known after apply)
      + location                         = "westeurope"
      + name                             = "pkslow-azure-vm"
      + network_interface_ids            = (known after apply)
      + resource_group_name              = "pkslow-azure-resources"
      + tags                             = {
          + "environment" = "staging"
        }
      + vm_size                          = "Standard_DS1_v2"

      + identity {
          + identity_ids = (known after apply)
          + principal_id = (known after apply)
          + type         = (known after apply)
        }

      + os_profile {
          + admin_password = (sensitive value)
          + admin_username = "larry"
          + computer_name  = "hostname"
          + custom_data    = (known after apply)
        }

      + os_profile_linux_config {
          + disable_password_authentication = false
        }

      + storage_data_disk {
          + caching                   = (known after apply)
          + create_option             = (known after apply)
          + disk_size_gb              = (known after apply)
          + lun                       = (known after apply)
          + managed_disk_id           = (known after apply)
          + managed_disk_type         = (known after apply)
          + name                      = (known after apply)
          + vhd_uri                   = (known after apply)
          + write_accelerator_enabled = (known after apply)
        }

      + storage_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts"
          + version   = "22.04.202301100"
        }

      + storage_os_disk {
          + caching                   = "ReadWrite"
          + create_option             = "FromImage"
          + disk_size_gb              = (known after apply)
          + managed_disk_id           = (known after apply)
          + managed_disk_type         = "Standard_LRS"
          + name                      = "myosdisk1"
          + os_type                   = (known after apply)
          + write_accelerator_enabled = false
        }
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = [
          + "10.0.0.0/16",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "westeurope"
      + name                = "pkslow-azure-network"
      + resource_group_name = "pkslow-azure-resources"
      + subnet              = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.example: Creating...
azurerm_resource_group.example: Creation complete after 9s [id=/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-azure-resources]
azurerm_virtual_network.main: Creating...
azurerm_virtual_network.main: Still creating... [10s elapsed]
azurerm_virtual_network.main: Creation complete after 17s [id=/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-azure-resources/providers/Microsoft.Network/virtualNetworks/pkslow-azure-network]
azurerm_subnet.internal: Creating...
azurerm_subnet.internal: Still creating... [10s elapsed]
azurerm_subnet.internal: Creation complete after 11s [id=/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-azure-resources/providers/Microsoft.Network/virtualNetworks/pkslow-azure-network/subnets/internal]
azurerm_network_interface.main: Creating...
azurerm_network_interface.main: Still creating... [10s elapsed]
azurerm_network_interface.main: Creation complete after 10s [id=/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-azure-resources/providers/Microsoft.Network/networkInterfaces/pkslow-azure-nic]
azurerm_virtual_machine.main: Creating...
azurerm_virtual_machine.main: Still creating... [10s elapsed]
azurerm_virtual_machine.main: Still creating... [20s elapsed]
azurerm_virtual_machine.main: Still creating... [30s elapsed]
azurerm_virtual_machine.main: Still creating... [40s elapsed]
azurerm_virtual_machine.main: Still creating... [50s elapsed]
azurerm_virtual_machine.main: Still creating... [1m0s elapsed]
azurerm_virtual_machine.main: Creation complete after 1m0s [id=/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-azure-resources/providers/Microsoft.Compute/virtualMachines/pkslow-azure-vm]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```



查看所有资源，选择资源组`pkslow-azure-resources`下面的，已经成功创建：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/terraform-create-resources.png)



使用完成后，通过下面命令删除：

```bash
terraform destroy
```



# 部署Azure Kubernetes集群

## 通过Auzre CLI部署

### 创建资源组

Azure资源组是用于部署和管理Azure资源的逻辑组。创建资源时，系统会提示你指定一个位置。该位置主要用于：

（1）资源组元数据的存储位置；

（2）在创建资源期间未指定另一个区域时，资源在Azure中的运行位置。



我们通过以下命令来创建资源组：

```bash
$ az group create --name pkslow-aks --location eastasia
{
  "id": "/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-aks",
  "location": "eastasia",
  "managedBy": null,
  "name": "pkslow-aks",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```



### 创建AKS

通过下面的命令创建AKS：

```bash
az aks create -g pkslow-aks -n pkslow --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys
```



创建完成后会输出很大的Json日志，我们直接来查看一下是否正确生成：

```bash
$ az aks list --output table
Name    Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion    ProvisioningState    Fqdn
------  ----------  ---------------  -------------------  --------------------------  -------------------  --------------------------------------------------------
pkslow  eastasia    pkslow-aks       1.24.6               1.24.6                      Succeeded            pkslow-pkslow-aks-cd7921-725c7247.hcp.eastasia.azmk8s.io
```



### 连接到AKS

需要有`kubectl`命令，没有的就安装一下：

```bash
az aks install-cli
```



连接集群需要认证，要获取一下验证配置：

```bash
$ az aks get-credentials --resource-group pkslow-aks --name pkslow
Merged "pkslow" as current context in /Users/larry/.kube/config
```



成功后就可以连接并操作了：

```bash
$ kubectl get node
NAME                                STATUS   ROLES   AGE     VERSION
aks-nodepool1-29201873-vmss000000   Ready    agent   8m45s   v1.24.6


$ kubectl get ns
NAME              STATUS   AGE
default           Active   9m33s
kube-node-lease   Active   9m35s
kube-public       Active   9m35s
kube-system       Active   9m35s


$ kubectl get pod -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE
ama-logs-lhlkb                        3/3     Running   0          9m8s
ama-logs-rs-6cf9546595-rdmh9          2/2     Running   0          9m26s
azure-ip-masq-agent-nppvd             1/1     Running   0          9m8s
cloud-node-manager-bd4c2              1/1     Running   0          9m8s
coredns-59b6bf8b4f-lrzpp              1/1     Running   0          9m26s
coredns-59b6bf8b4f-zbbkm              1/1     Running   0          7m56s
coredns-autoscaler-5655d66f64-5946c   1/1     Running   0          9m26s
csi-azuredisk-node-9rpvd              3/3     Running   0          9m8s
csi-azurefile-node-hvxhc              3/3     Running   0          9m8s
konnectivity-agent-95ff8bbd-fwkds     1/1     Running   0          9m26s
konnectivity-agent-95ff8bbd-qg9vx     1/1     Running   0          9m26s
kube-proxy-c5crz                      1/1     Running   0          9m8s
metrics-server-7dd74d8758-ms8h9       2/2     Running   0          7m50s
metrics-server-7dd74d8758-nxq9t       2/2     Running   0          7m50s
```



### 部署测试应用

为了方便，我们直接使用官网的示例来测试一下。创建文件`azure-vote.yaml`，内容如下：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
        - name: azure-vote-back
          image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
          env:
            - name: ALLOW_EMPTY_PASSWORD
              value: "yes"
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
          ports:
            - containerPort: 6379
              name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
    - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
        - name: azure-vote-front
          image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
          ports:
            - containerPort: 80
          env:
            - name: REDIS
              value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
    app: azure-vote-front
```





然后执行以下命令：

```bash
$ kubectl apply -f azure-vote.yaml
deployment.apps/azure-vote-back created
service/azure-vote-back created
deployment.apps/azure-vote-front created
service/azure-vote-front created
```



成功后查看对应资源：

```bash
$ kubectl get svc
NAME               TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
azure-vote-back    ClusterIP      10.0.156.161   <none>         6379/TCP       112s
azure-vote-front   LoadBalancer   10.0.29.217    20.239.124.1   80:30289/TCP   112s
kubernetes         ClusterIP      10.0.0.1       <none>         443/TCP        21m

$ kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
azure-vote-back    1/1     1            1           2m1s
azure-vote-front   1/1     1            1           2m1s

$ kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
azure-vote-back-7cd69cc96f-gqm7r    1/1     Running   0          2m7s
azure-vote-front-7c95676c68-jtkqz   1/1     Running   0          2m7s
```

已经成功创建。

看front那有external IP，通过它直接在浏览器访问如下：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/aks-cli.front-page.png)



应用已经成功部署并访问了。



### 删除资源组

如果完成测试，不再使用，可以整个资源组一起删除：

```bash
az group delete --name pkslow-aks --yes --no-wait
```



## 通过Terraform部署

### 配置插件和版本

```hcl
terraform {
  required_version = ">= 1.1.3"
  required_providers {

    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.38.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
  }
}
```



### 变量设置

给`Terraform`设置一些要用到的变量：

```hcl
variable "agent_count" {
  default = 1
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  default = ""
}

variable "aks_service_principal_client_secret" {
  default = ""
}

variable "cluster_name" {
  default = "pkslow-k8s"
}

variable "dns_prefix" {
  default = "pkslow"
}

# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
variable "log_analytics_workspace_location" {
  default = "eastus"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
```



`agent_count`应该设置合理，这里设成1是因为我的账号是免费的，有限制。



### 输出结果

当Terraform执行完，会有一些结果，我们可以把一些值输出以便使用：

```hcl
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
```



### main.tf创建AKS

通过`azurerm_kubernetes_cluster`创建AKS：

```hcl
provider "azurerm" {
  features {}
}

# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
  location            = var.log_analytics_workspace_location
  # The WorkSpace name has to be unique across the whole of azure;
  # not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
  location              = azurerm_log_analytics_workspace.test.location
  resource_group_name   = azurerm_resource_group.rg.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  tags                = {
    Environment = "Development"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.agent_count
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }
}
```



### 执行

准备好文件后，先初始化，下载插件：

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/random versions matching "3.1.0"...
- Finding hashicorp/azurerm versions matching "3.38.0"...
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (unauthenticated)
- Installing hashicorp/azurerm v3.38.0...
- Installed hashicorp/azurerm v3.38.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```



查看Terraform计划，知道将要生成多少资源：

```bash
$ terraform plan -out main.tfplan -var="aks_service_principal_app_id=$ARM_CLIENT_ID" -var="aks_service_principal_client_secret=$ARM_CLIENT_SECRET"
```



没有问题则执行变更：

```bash
$ terraform apply main.tfplan
Outputs:

client_certificate = <sensitive>
client_key = <sensitive>
cluster_ca_certificate = <sensitive>
cluster_password = <sensitive>
cluster_username = <sensitive>
host = <sensitive>
kube_config = <sensitive>
resource_group_name = "rg-harmless-tomcat"
```



### 连接AKS

把kube_config输出，然后设置环境变量就可以通过kubectl连接了：

```bash
$ echo "$(terraform output kube_config)" > ./azurek8s

$ export KUBECONFIG=./azurek8s

$ kubectl get nodes
NAME                                STATUS   ROLES   AGE     VERSION
aks-agentpool-45159290-vmss000000   Ready    agent   9m20s   v1.24.6
```

如果有问题，可以查看azurek8s文件是否正常。



# 创建PostgreSQL



### 通过Azure CLI创建Single Server

### 创建资源组和数据库

先创建资源组：

```bash
az group create --name pkslow-sql --location eastasia --tag create-postgresql-server-and-firewall-rule
```



然后创建数据库：

```bash
$ az postgres server create \
> --name pkslow-pg \
> --resource-group pkslow-sql \
> --location eastasia \
> --admin-user pguser \
> --admin-password 'Pa$$word' \
> --sku-name GP_Gen5_2


Checking the existence of the resource group 'pkslow-sql'...
Resource group 'pkslow-sql' exists ? : True 
Creating postgres Server 'pkslow-pg' in group 'pkslow-sql'...
Your server 'pkslow-pg' is using sku 'GP_Gen5_2' (Paid Tier). Please refer to https://aka.ms/postgres-pricing  for pricing details
Make a note of your password. If you forget, you would have to reset your password with 'az postgres server update -n pkslow-pg -g pkslow-sql -p <new-password>'.
{
  "additionalProperties": {},
  "administratorLogin": "pguser",
  "byokEnforcement": "Disabled",
  "connectionString": "postgres://pguser%40pkslow-pg:Pa$$word@pkslow-pg.postgres.database.azure.com/postgres?sslmode=require",
  "earliestRestoreDate": "2023-01-15T03:24:18.440000+00:00",
  "fullyQualifiedDomainName": "pkslow-pg.postgres.database.azure.com",
  "id": "/subscriptions/cd7921d5-9ba9-45db-bfba-1c397fcaaba3/resourceGroups/pkslow-sql/providers/Microsoft.DBforPostgreSQL/servers/pkslow-pg",
  "identity": null,
  "infrastructureEncryption": "Disabled",
  "location": "eastasia",
  "masterServerId": "",
  "minimalTlsVersion": "TLSEnforcementDisabled",
  "name": "pkslow-pg",
  "password": "Pa$$word",
  "privateEndpointConnections": [],
  "publicNetworkAccess": "Enabled",
  "replicaCapacity": 5,
  "replicationRole": "None",
  "resourceGroup": "pkslow-sql",
  "sku": {
    "additionalProperties": {},
    "capacity": 2,
    "family": "Gen5",
    "name": "GP_Gen5_2",
    "size": null,
    "tier": "GeneralPurpose"
  },
  "sslEnforcement": "Enabled",
  "storageProfile": {
    "additionalProperties": {},
    "backupRetentionDays": 7,
    "geoRedundantBackup": "Disabled",
    "storageAutogrow": "Enabled",
    "storageMb": 5120
  },
  "tags": null,
  "type": "Microsoft.DBforPostgreSQL/servers",
  "userVisibleState": "Ready",
  "version": "11"
}
```

创建成功后，会打印很多有用的信息，如连接信息。



也可以在以后查看：

```bash
az postgres server show --resource-group pkslow-sql --name pkslow-pg
```



### 禁用SSL

创建完成后还可以更新一些配置，如我们禁用SSL：

```bash
az postgres server update --resource-group pkslow-sql --name pkslow-pg --ssl-enforcement Disabled
```

> 生产环境不要禁用SSL。



### 添加防火墙

需要把客户端IP添加到Firewall，不然会连接失败。

```bash
az postgres server firewall-rule create \
--resource-group pkslow-sql \
--server pkslow-pg \
--name AllowIps \
--start-ip-address '0.0.0.0' \
--end-ip-address '255.255.255.255'
```



### 测试连接

配置连接如下，注意用户名不只是`pguser`：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/postgresql.cli.connected.png)



### 删除资源

如果不需要再使用，就删除资源：

```bash
az group delete --name pkslow-sql
```



## 通过Terraform创建Flexible Server



### 插件与版本

```hcl
terraform {
  required_version = ">= 1.1.3"
  required_providers {

    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.38.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```



### 变量设置

```hcl
variable "name_prefix" {
  default     = "pkslow-pg-fs"
  description = "Prefix of the resource name."
}

variable "location" {
  default     = "eastus"
  description = "Location of the resource."
}
```



### main.tf创建

```hcl
resource "random_pet" "rg-name" {
  prefix = var.name_prefix
}

resource "azurerm_resource_group" "default" {
  name     = random_pet.rg-name.id
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "default" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "default" {
  name                 = "${var.name_prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.default.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_private_dns_zone" "default" {
  name                = "${var.name_prefix}-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${var.name_prefix}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.default.name
}

resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "${var.name_prefix}-server"
  resource_group_name    = azurerm_resource_group.default.name
  location               = azurerm_resource_group.default.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.default.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = "pguser"
  administrator_password = "QAZwsx123"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}
```



准备文件：pg-fs-db.tf

```hcl
resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "${var.name_prefix}-db"
  server_id = azurerm_postgresql_flexible_server.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}
```



### 输出结果

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_flexible_server.default.name
}

output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_flexible_server_database.default.name
}
```



### 执行

准备好hcl文件后，执行如下：

```bash
$ terraform init

$ terraform plan -out main.tfplan

$ terraform apply main.tfplan
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:
azurerm_postgresql_flexible_server = "pkslow-pg-fs-server"
postgresql_flexible_server_database_name = "pkslow-pg-fs-db"
resource_group_name = "pkslow-pg-fs-delicate-honeybee"
```



创建成功后，可以查看：

```bash
$ az postgres flexible-server list --output table
Name                 Resource Group                  Location    Version    Storage Size(GiB)    Tier            SKU              State    HA State    Availability zone
-------------------  ------------------------------  ----------  ---------  -------------------  --------------  ---------------  -------  ----------  -------------------
pkslow-pg-fs-server  pkslow-pg-fs-delicate-honeybee  East US     13         32                   GeneralPurpose  Standard_D2s_v3  Ready    NotEnabled  1
```



当然，在Portal上看也是可以的：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/postgresql.terraform.portal.png)



### 删除

不需要了可以执行删除：

```bash
 terraform destroy
```



# 在Azure云存储上管理Terraform状态

默认Terraform的状态是保存在本地的，为了安全和协作，在生产环境中一般要保存在云上。



## 创建Azure Storage

我们创建Storage来存储Terraform状态。按下面一步步执行即可：

```bash
RESOURCE_GROUP_NAME=pkslow-tstate-rg
STORAGE_ACCOUNT_NAME=pkslowtfstate
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location "West Europe"

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
```



## Terraform backend

创建完Storage后，我们需要在Terraform中配置使用：

```hcl
terraform {
  required_version = ">= 1.1.3"
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.38.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "pkslow-tstate-rg"
    storage_account_name = "pkslowtfstate"
    container_name       = "tfstate"
    key                  = "pkslow.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "local_file" "test-file" {
  content  = "https://www.pkslow.com"
  filename = "${path.root}/terraform-guides-by-pkslow.txt"
}
```



主要代码是这块：

```hcl
backend "azurerm" {
resource_group_name  = "pkslow-tstate-rg"
storage_account_name = "pkslowtfstate"
container_name       = "tfstate"
key                  = "pkslow.tfstate"
}
```

这里前三个变量的值都是前面创建Storage的时候指定的。



## 执行Terraform

初始化：

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/local versions matching "2.1.0"...
- Finding hashicorp/azurerm versions matching "3.38.0"...
- Installing hashicorp/local v2.1.0...
- Installed hashicorp/local v2.1.0 (unauthenticated)
- Installing hashicorp/azurerm v3.38.0...
- Installed hashicorp/azurerm v3.38.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

看日志就会初始化backend。



执行apply：

```bash
$ terraform apply -auto-approve
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.test-file will be created
  + resource "local_file" "test-file" {
      + content              = "https://www.pkslow.com"
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./terraform-guides-by-pkslow.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
local_file.test-file: Creating...
local_file.test-file: Creation complete after 0s [id=6db7ad1bbf57df0c859cd5fc62ff5408515b5fc1]
Releasing state lock. This may take a few moments...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```



然后我们去查看Azure Storage，就可以发现已经生成一个Terraform状态文件：

![](https://pkslow.oss-cn-shenzhen.aliyuncs.com/images/other/terraform-101/pictures/public-cloud/azure/state.azure-storage.png)





如果不再使用，记得删除资源。



---

[Creating a service principal](https://learn.microsoft.com/en-us/azure/purview/create-service-principal-azure)

[Use the portal to create an Azure AD application and service principal that can access resources](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)

[Sign in with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

[az vm命令](https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-list)

[azure-cli输出格式](https://learn.microsoft.com/en-us/cli/azure/format-output-azure-cli)

[Azure关联订阅](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory)

[azurerm_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine)

[Create an Azure VM cluster with Terraform and HCL](https://learn.microsoft.com/en-us/azure/developer/terraform/create-vm-cluster-with-infrastructure)

[Install Terraform on Windows with Bash](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash?tabs=bash)

[快速入门：使用Azure CLI部署Azure Kubernetes服务集群](https://learn.microsoft.com/zh-cn/azure/aks/learn/quick-kubernetes-deploy-cli)

[Quickstart: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)

[Quickstart: Create an Azure Database for PostgreSQL server by using the Azure CLI](https://learn.microsoft.com/en-us/azure/postgresql/single-server/quickstart-create-server-database-azure-cli)

[Deploy a PostgreSQL Flexible Server Database using Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/deploy-postgresql-flexible-server-database?tabs=azure-cli)

[PostgreSQL Flexible Server error: Operations on a server group in dropping state are not allowed](https://github.com/hashicorp/terraform-provider-azurerm/issues/16622)

[How to Create an Azure Remote Backend for Terraform](https://gmusumeci.medium.com/how-to-create-an-azure-remote-backend-for-terraform-67cce5da1520)

