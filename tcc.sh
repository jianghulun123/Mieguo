#!/bin/bash

# 从压缩文件恢复Docker镜像和挂载卷

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

# 提示用户输入压缩文件路径
read -p "Enter the path to the backup tar.gz file: " backup_file

# 检查文件是否存在
if [ ! -f "$backup_file" ]; then
    echo "Error: File '$backup_file' not found."
    exit 1
fi

# 定义恢复目录
restore_dir="/root/dcc"
volumes_restore_dir="$restore_dir/volumes"
images_restore_dir="$restore_dir/images"
metadata_file="$restore_dir/volumes_metadata.json"

# 确保恢复目录存在
mkdir -p "$restore_dir"

# 解压备份文件
tar -xzf "$backup_file" -C "$restore_dir"

# 恢复Docker镜像
cd "$images_restore_dir" || exit
for tar_file in *.tar; do
    echo "Importing image from $tar_file"
    docker load -i "$tar_file"
done

echo "All Docker images imported successfully."

# 恢复挂载卷
if [ -f "$metadata_file" ]; then
  jq -c '.[]' "$metadata_file" | while read -r entry; do
    src=$(echo "$entry" | jq -r '.source')
    tarball=$(echo "$entry" | jq -r '.tarball')
    if [ -f "$tarball" ]; then
      echo "Restoring volume: $tarball -> $src"
      mkdir -p "$src"  # 确保恢复路径存在
      tar -xzf "$tarball" -C "$src"
    else
      echo "Warning: Tarball $tarball not found."
    fi
  done
else
  echo "Error: Metadata file $metadata_file not found."
fi

echo "All Docker volumes restored successfully."
