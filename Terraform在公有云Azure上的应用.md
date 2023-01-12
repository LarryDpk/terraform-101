> 《Terraform 101 从入门到实践》这本书只将在[南瓜慢说官方网站](https://www.pkslow.com/tags/terraform101)和[GitHub](https://github.com/LarryDpk/terraform-101)两个地方同步更新，如果你在其它地方看到，那应该就是抄袭和未授权的转载。书中的示例代码也是放在GitHub上，方便大家参考查看。

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
