# modify_kubeflow_manifest
> **这是Kubeflow Manifest "https://github.com/kubeflow/manifests" ,经过少量修改（只改了一个文件，添加了几个文件），可以在国内安装的笔记。**<br/>
> **非常感谢public-image-mirror "https://github.com/DaoCloud/public-image-mirror" 提供的镜像加速，使得很多在国外的镜像，在国内也可以下载，只需要改变仓库名（添加'.m.daocloud'）。**<br/>
> **这里也包括我安装时踩坑记录**

# 版本
![](https://github.com/032004129xuzhiyong/modify_kubeflow_manifest/blob/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202023-05-10%20090424.png)



# 前置条件 
### kind
> (kind下载地址) https://kind.sigs.k8s.io/docs/user/quick-start/#installation <br/>
> kind version <br/>
> kind v0.18.0 go1.20.2 linux/amd64 <br/>

### kubectl
> 官网要求（最多1.25）https://github.com/DaoCloud/public-image-mirror  <br/>
> (kubectl下载地址) 下载需要指定版本 https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/   <br/> <br/>
> kubectl version <br/>
> Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.0", GitCommit:"a866cbe2e5bbaa01cfd5e969aa3e033f3282a8a2", GitTreeState:"clean", BuildDate:"2022-08-23T17:44:59Z", GoVersion:"go1.19", Compiler:"gc", Platform:"linux/amd64"} <br/> <br/>
> Kustomize Version: v4.5.7 <br/> <br/>
> Server Version: version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.3", GitCommit:"9e644106593f3f4aa98f8a84b23db5fa378900bd", GitTreeState:"clean", BuildDate:"2023-03-30T06:34:50Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linux/amd64"} <br/>

### kustomize
> 虽然kubectl中有kustomize，版本不对，要独立下载(根据官网要求至少5.0.0) https://github.com/DaoCloud/public-image-mirror <br/>
> (kustomize下载地址) https://github.com/kubernetes-sigs/kustomize/releases <br/>
> kustomize version <br/>
> v5.0.0 <br/>

### docker
> docker version <br/>
> Client: Docker Engine - Community <br/>
> Version:           23.0.2 <br/>
> API version:       1.42 <br/>
> Go version:        go1.19.7 <br/>
> Git commit:        569dd73 <br/>
> Built:             Mon Mar 27 16:16:30 2023 <br/>
> OS/Arch:           linux/amd64 <br/>
> Context:           default <br/> <br/>
> Server: Docker Engine - Community <br/>
> Engine: <br/>
> Version:          23.0.2 <br/>
> API version:      1.42 (minimum version 1.12) <br/>
> Go version:       go1.19.7 <br/>
> Git commit:       219f21b <br/>
> Built:            Mon Mar 27 16:16:30 2023 <br/>
> OS/Arch:          linux/amd64 <br/>
> Experimental:     false <br/>
> containerd: <br/>
> Version:          1.6.20 <br/>
> GitCommit:        2806fc1057397dbaeefbea0e4e17bddfbd388f38 <br/>
> runc: <br/>
> Version:          1.1.5 <br/>
> GitCommit:        v1.1.5-0-gf19387a <br/>
> docker-init: <br/>
> Version:          0.19.0 <br/>
> GitCommit:        de40ad0 <br/>

### python
> python3

# 步骤
### 第一步
> 只要填写errimages.txt,也就是将不能拉取的gcr.io、quay.io、ghcr.io开头的镜像复制进去 <br/>
> 原本是笔者不能拉取的镜像列表 <br/>
### 第二步
> 将这里的除README.md和.git的文件复制到官网manifests-master目录下 <br/>
### 第三歩
> 注意：在运行前，如果对挂载、节点等有要求，先修改kind-ingress-config.yaml(里面笔者挂载了本地的jupyterlab的目录) <br/>
> 这步包括：修改宿主机打开文件个数限制--导出镜像列表，更改配置文件(example/*)--建立集群--启动(初始化)kubeflow(无限循环，不会结束，可以手动结束) <br/>
> 在官网manifests-master目录下运行pull_and_kind_load_dockerimage.sh <br/>
### 第四步
> 根据下面的Warning进行补充操作 <br/>



# Warning
### warning1
> 如果没有auth（namespace），重新用这条命令加载,在打开另一个终端输入 <br/>
> kustomize build common/dex/overlays/istio | kubectl apply -f - <br/>

### warning2
> 记得如果kubeflow-user-example-com 或者 auth (两个都是namespace) 中的pod 镜像加载错误，就手动修改（添加".m.daocloud"） <br/>
> 因为可能后面加载的pod，image还是拉取国外 <br/>
> kubectl edit pod -n namespace podname <br/>

### warning3
> 踩坑踩坑，注意是对ingressgateway服务(svc)进行端口映射，不是对pod..... <br/>
> 临时端口映射，登录浏览器（127.0.0.1：8080）输入账号user@example.com  输入密码12341234 <br/>
> kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 <br/>

### warning4
> 补充 <br/>
> 从本地（宿主机）将目录挂载到集群中，笔者要用到本地的jupyterlab目录的代码和数据，所以声明到pvc中，使用时引用pvc的name。 <br/>
> kubectl create -f data-pv-hostpath.yaml  (其中持久卷挂载的源目录是/home，和上面kind-ingress-config.yaml中的containerPath: /home要一样) <br/>
> kubectl create -f data-pvc.yaml  (持久卷声明，使用了上面的持久卷，当要使用的时候就将它的name声明在volumns中) <br/>

# 安装成功
### 所有运行的pod
![运行的pod](https://github.com/032004129xuzhiyong/modify_kubeflow_manifest/blob/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202023-05-09%20174108.png)

### kubeflow界面
**使用`kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80`进行临时端口映射，访问本地浏览器127.0.0.1:8080，出现界面。**
![界面](https://github.com/032004129xuzhiyong/modify_kubeflow_manifest/blob/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202023-05-09%20174217.png)


