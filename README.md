# modify_kubeflow_manifest
这是Kubeflow Manifest "https://github.com/kubeflow/manifests" ,经过少量修改（只改了一个文件，添加了几个文件），可以在国内安装的笔记。
非常感谢public-image-mirror "https://github.com/DaoCloud/public-image-mirror" 提供的镜像加速，使得很多在国外的镜像，在国内也可以下载，只需要改变仓库名（添加'.m.daocloud'）。
这里也包括我安装时踩坑记录。


# 前置条件 
# 1#
#(kind下载地址) https://kind.sigs.k8s.io/docs/user/quick-start/#installation
#kind version
#kind v0.18.0 go1.20.2 linux/amd64

# 2#
#官网要求（最多1.25）https://github.com/DaoCloud/public-image-mirror
#(kubectl下载地址) 下载需要指定版本 https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/  
#kubectl version
#Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.0", GitCommit:"a866cbe2e5bbaa01cfd5e969aa3e033f3282a8a2", GitTreeState:"clean", BuildDate:"2022-08-23T17:44:59Z", GoVersion:"go1.19", Compiler:"gc", Platform:"linux/amd64"}
#Kustomize Version: v4.5.7
#Server Version: version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.3", GitCommit:"9e644106593f3f4aa98f8a84b23db5fa378900bd", GitTreeState:"clean", BuildDate:"2023-03-30T06:34:50Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linux/amd64"}

# 3#
#虽然kubectl中有kustomize，版本不对，要独立下载(根据官网要求至少5.0.0) https://github.com/DaoCloud/public-image-mirror 
#(kustomize下载地址) https://github.com/kubernetes-sigs/kustomize/releases
#kustomize version
#v5.0.0

# 4#
#docker version
#Client: Docker Engine - Community
#Version:           23.0.2
#API version:       1.42
#Go version:        go1.19.7
#Git commit:        569dd73
#Built:             Mon Mar 27 16:16:30 2023
#OS/Arch:           linux/amd64
#Context:           default
#Server: Docker Engine - Community
#Engine:
#Version:          23.0.2
#API version:      1.42 (minimum version 1.12)
#Go version:       go1.19.7
#Git commit:       219f21b
#Built:            Mon Mar 27 16:16:30 2023
#OS/Arch:          linux/amd64
#Experimental:     false
#containerd:
#Version:          1.6.20
#GitCommit:        2806fc1057397dbaeefbea0e4e17bddfbd388f38
#runc:
#Version:          1.1.5
#GitCommit:        v1.1.5-0-gf19387a
#docker-init:
#Version:          0.19.0
#GitCommit:        de40ad0

# 5#
#python3


# Warning1#
#如果没有auth（namespace），重新用这条命令加载,在打开另一个终端输入
#kustomize build common/dex/overlays/istio | kubectl apply -f -

# Warning2#
#记得如果kubeflow-user-example-com 或者 auth (两个都是namespace) 中的pod 镜像加载错误，就手动修改（添加".m.daocloud"）
#因为可能后面加载的pod，image还是拉取国外
#kubectl edit pod -n namespace podname

# Warning3#
#踩坑踩坑，注意是对ingressgateway服务(svc)进行端口映射，不是对pod.....
#临时端口映射，登录浏览器（127.0.0.1：8080）输入账号user@example.com  输入密码12341234
#kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80

# Warning4#
#kubectl create -f data-pv-hostpath.yaml  (其中持久卷挂载的源目录是/home，和上面kind-ingress-config.yaml中的containerPath: /home要一样)
#kubectl create -f data-pvc.yaml  (持久卷声明，使用了上面的持久卷，当要使用的时候就将它的name声明在volumns中)
#如下所示
#volumes: 
#  - name: data-pvc #自定义name
#    persistentVolumeClaim:
#      claimName: data-pvc  #data-pvc.yaml中的name，要一样
#      readOnly: false
