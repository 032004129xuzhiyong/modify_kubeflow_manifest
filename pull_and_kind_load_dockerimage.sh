#!/bin/bash


#前置条件 
#1#
# (kind下载地址) https://kind.sigs.k8s.io/docs/user/quick-start/#installation
# kind version
#kind v0.18.0 go1.20.2 linux/amd64

#2#
#官网要求（最多1.25）https://github.com/DaoCloud/public-image-mirror
# (kubectl下载地址) 下载需要指定版本 https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/  
# kubectl version
#Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.0", GitCommit:"a866cbe2e5bbaa01cfd5e969aa3e033f3282a8a2", GitTreeState:"clean", BuildDate:"2022-08-23T17:44:59Z", GoVersion:"go1.19", Compiler:"gc", Platform:"linux/amd64"}
#Kustomize Version: v4.5.7
#Server Version: version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.3", GitCommit:"9e644106593f3f4aa98f8a84b23db5fa378900bd", GitTreeState:"clean", BuildDate:"2023-03-30T06:34:50Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linux/amd64"}

#3#
#虽然kubectl中有kustomize，版本不对，要独立下载(根据官网要求至少5.0.0) https://github.com/DaoCloud/public-image-mirror 
# (kustomize下载地址) https://github.com/kubernetes-sigs/kustomize/releases
# kustomize version
# v5.0.0

#4#
# docker version
#Client: Docker Engine - Community
# Version:           23.0.2
# API version:       1.42
# Go version:        go1.19.7
# Git commit:        569dd73
# Built:             Mon Mar 27 16:16:30 2023
# OS/Arch:           linux/amd64
# Context:           default
#Server: Docker Engine - Community
# Engine:
#  Version:          23.0.2
#  API version:      1.42 (minimum version 1.12)
#  Go version:       go1.19.7
#  Git commit:       219f21b
#  Built:            Mon Mar 27 16:16:30 2023
#  OS/Arch:          linux/amd64
#  Experimental:     false
# containerd:
#  Version:          1.6.20
#  GitCommit:        2806fc1057397dbaeefbea0e4e17bddfbd388f38
# runc:
#  Version:          1.1.5
#  GitCommit:        v1.1.5-0-gf19387a
# docker-init:
#  Version:          0.19.0
#  GitCommit:        de40ad0

#5#
# python3




pullImagesName=pullimages.txt
grepStr=.m.daocloud
kindClusterName=kind

while getopts p:g:k: keyName
do
 case "${keyName}" in
 p) pullImagesName=${OPTARG};;
 g) grepStr=${OPTARG};;
 k) kindClusterName=${OPTARG};;
 ?)
         echo "未知参数"
         exit 1;;
 esac
done



#没有修改可能使 ml-pipeline-7XXXXXXX 和 profiles-deployment-XXXXXX 两个pod CrashLoopBackOff
echo '修改宿主机打开文件个数限制'
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512


echo '导出镜像列表，更改配置文件'
python3 ./erim.py


#echo '开始拉取镜像!!!!!'
#cat ${pullImagesName} | xargs -r -l docker pull | grep 'Error'
#echo '拉取完毕!!!!!!!!!'
#sleep 2


#注意 里面包含本地要挂载的目录（自行修改）
#这个通过挂载到所在节点（hostpath）   本地--》节点（node）
#要挂载到kubeflow中转最后 #Warning4#
echo '建立集群'
kind create cluster --config ./kind-ingress-config.yaml -n ${kindClusterName}

#echo '开始载入镜像!!!!!'
#docker images|grep ${grepStr} |awk '{print $3}'|xargs -r -l  kind load docker-image -n ${kindClusterName}
#echo '载入完毕!!!!!!!!!'


echo '启动(初始化)kubeflow!!!!!'
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

#Warning1#
#如果没有auth（namespace），重新用这条命令加载,在打开另一个终端输入
#kustomize build common/dex/overlays/istio | kubectl apply -f -

#Warning2#
#记得如果kubeflow-user-example-com 或者 auth (两个都是namespace) 中的pod 镜像加载错误，就手动修改（添加".m.daocloud"）
#因为可能后面加载的pod，image还是拉取国外
#kubectl edit pod -n namespace podname

#Warning3#
#踩坑踩坑，注意是对ingressgateway服务(svc)进行端口映射，不是对pod.....
#临时端口映射，登录浏览器（127.0.0.1：8080）输入账号user@example.com  输入密码12341234
#kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80

#Warning4#
#kubectl create -f data-pv-hostpath.yaml  (其中持久卷挂载的源目录是/home，和上面kind-ingress-config.yaml中的containerPath: /home要一样)
#kubectl create -f data-pvc.yaml  (持久卷声明，使用了上面的持久卷，当要使用的时候就将它的name声明在volumns中)
#如下所示
#volumes: 
#  - name: data-pvc #自定义name
#    persistentVolumeClaim:
#      claimName: data-pvc  #data-pvc.yaml中的name，要一样
#      readOnly: false


