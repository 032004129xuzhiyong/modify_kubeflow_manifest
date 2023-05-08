def get_filename():
    with open("errimages.txt", "r") as f:
        lines = f.read().split('\n')
        #print(lines)
        return lines

#get_filename()
def change_name(oldname):
    if "gcr.io" in oldname:
        if ":" in oldname and '@sha256' not in oldname: #有标签
            tag = oldname.split(":")[-1]
            oldname = oldname.split(":")[0]
            return oldname[:3] + '.m.daocloud' + oldname[3:],tag
        else: #无标签
            if '@' in oldname:
                oldname = oldname.split("@")[0]
            return oldname[:3] + '.m.daocloud' + oldname[3:],''
    elif "quay.io" in oldname or 'ghcr.io' in oldname : #quay.io
        if ":" in oldname:#有标签
            tag = oldname.split(":")[-1]
            oldname = oldname.split(":")[0]
            return oldname[:4] + '.m.daocloud' + oldname[4:],tag
        else:#无标签
            return oldname[:4] + '.m.daocloud' + oldname[4:],''
    else: #docker.io
        if ":" in oldname and '@sha256' not in oldname: #有标签
            tag = oldname.split(":")[-1]
            oldname = oldname.split(":")[0]
            return oldname[:6] + '.m.daocloud' + oldname[6:],tag
        else: #无标签
            if '@' in oldname:
                oldname = oldname.split("@")[0]
            return oldname[:6] + '.m.daocloud' + oldname[6:],''

#修改配置文件
with open("./example/kustomization.yaml", "wt") as w:
    ori_lines = []
    with open("./ori_kustomization.yaml",'rt') as r:
        ori_lines = r.readlines()
    for ori_line in ori_lines:
        w.write(ori_line)
    w.write('\n')
    w.write('images: \n')
    images_lines = get_filename()[:-2]
    for oldname in images_lines:
        newName, newTag = change_name(oldname)
        w.write(' - name: '+oldname+'\n')
        w.write('   newName: '+newName+'\n')
        if newTag != '':
            w.write('   newTag: '+newTag+'\n')

#输出要拉取和加载的镜像列表文件
with open("pullimages.txt",'wt') as f:
    images_lines = get_filename()[:-2]
    for oldname in images_lines:
        newName, newTag = change_name(oldname)
        if newTag != '':
            f.write(newName+":"+newTag+'\n')
        else:
            f.write(newName+'\n')


