#!/bin/bash
#
# 备份所有Docker镜像和挂载卷，并打包成一个压缩文件
#

# 检测 jq 是否已安装，如果未安装则自动安装
install_jq() {
  if ! command -v jq &> /dev/null; then
    echo "jq 未安装，正在自动安装..."
    if [ -x "$(command -v apt-get)" ]; then
      sudo apt-get update
      sudo apt-get install -y jq
    elif [ -x "$(command -v yum)" ]; then
      sudo yum install -y epel-release
      sudo yum install -y jq
    elif [ -x "$(command -v dnf)" ]; then
      sudo dnf install -y jq
    else
      echo "无法检测到包管理器，请手动安装 jq。"
      exit 1
    fi
  fi
}

# 调用函数安装 jq
install_jq

# 定义备份目录
backup_dir="/root/dcc"
volumes_backup_dir="$backup_dir/volumes"
images_backup_dir="$backup_dir/images"
metadata_file="$backup_dir/volumes_metadata.json"
final_backup_file="/root/docker_backup_$(date +%F_%T).tar.gz"

# 确保备份目录存在
mkdir -p "$volumes_backup_dir"
mkdir -p "$images_backup_dir"

# 备份所有Docker镜像
images=$(docker images --format "{{.Repository}}:{{.Tag}}")
for image in $images; do
    tar_filename=$(echo "$image" | tr '/:' '_').tar
    echo "Saving $image as $tar_filename"
    docker save -o "$images_backup_dir/$tar_filename" "$image"
done

echo "All Docker images saved to $images_backup_dir"

# 初始化元数据文件
echo "[]" > "$metadata_file"

# 备份所有挂载卷
container_ids=$(docker ps -q)
for container_id in $container_ids; do
  mounts=$(docker inspect --format '{{json .Mounts}}' "$container_id")
  if [ "$mounts" != "[]" ]; then
    echo "$mounts" | jq -r '.[] | .Source' | while read -r host_dir; do
      if [ -d "$host_dir" ]; then
        tarball_name=$(basename "$host_dir")
        tarball_path="$volumes_backup_dir/${tarball_name}_$(date +%F_%T).tar.gz"
        echo "Backing up volume: $host_dir -> $tarball_path"
        tar -czf "$tarball_path" -C "$host_dir" .
        
        # 记录元数据
        jq --arg src "$host_dir" --arg tarball "$tarball_path" '. += [{"source": $src, "tarball": $tarball}]' "$metadata_file" > tmp.$$.json && mv tmp.$$.json "$metadata_file"
      else
        echo "Warning: Host directory $host_dir does not exist or is not a directory."
      fi
    done
  fi
done

echo "All Docker volumes saved to $volumes_backup_dir"

# 打包整个备份目录
tar -czf "$final_backup_file" -C "$backup_dir" .

echo "Backup completed and saved to $final_backup_file"
