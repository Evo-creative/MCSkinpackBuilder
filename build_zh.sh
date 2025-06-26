#!/bin/bash

TEMP_DIR="skinpack_tmp" 
SCRIPT_NAME=$(basename "$0")

check_deps() {
    missing=()
    for cmd in uuidgen zip; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "缺少依赖: ${missing[*]}"
        
        # 自动安装逻辑
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            echo -e "\n尝试自动安装..."
            case $ID in
                debian|ubuntu|linuxmint) sudo apt update && sudo apt install -y util-linux zip ;;
                fedora|centos|rhel) sudo dnf install -y util-linux zip ;;
                arch|manjaro) sudo pacman -Sy --noconfirm util-linux zip ;;
                *) echo "无法自动安装，请手动安装: util-linux zip"; exit 1 ;;
            esac
        else
            echo "请手动安装: util-linux zip"
            exit 1
        fi
    fi
}


check_deps
mkdir -p "$TEMP_DIR/texts"


skin_files=($(ls {*.png,*.tga,*.jpg} 2>/dev/null | grep -v -e "$SCRIPT_NAME" -e "$TEMP_DIR"))
if [ ${#skin_files[@]} -eq 0 ]; then
    echo "错误: 未找到皮肤文件（支持.png/.tga/.jpg）"
    rm -rf "$TEMP_DIR"
    exit 1
fi
echo "检测到皮肤文件: ${skin_files[*]}"

read -p "输入皮肤包显示名称: " pack_name
output_file="${pack_name// /_}.mcpack"


cat > "$TEMP_DIR/skins.json" <<EOF
{
    "serialize_name": "pack_$(uuidgen -r | cut -d'-' -f1)",
    "localization_name": "pack_${pack_name// /_}",
    "skins": [
EOF


for i in "${!skin_files[@]}"; do
    skin_num=$(printf "%02d" $((i+1)))
    texture="${skin_files[$i]}"
    
    read -p "输入【$texture】的显示名称: " skin_display_name
    read -p "模型类型 (1=纤细(Alex) 2=粗壮(Steve)): " model_type
    
    geometry=$([ "$model_type" = "2" ] && echo "geometry.humanoid.custom" || echo "geometry.humanoid.customSlim")

    cat >> "$TEMP_DIR/skins.json" <<EOF
        {
            "localization_name": "$skin_num",
            "geometry": "$geometry",
            "texture": "$texture",
            "type": "free"
        }$([ $((i+1)) -ne ${#skin_files[@]} ] && echo ",")
EOF

    echo "skin.pack_${pack_name// /_}.$skin_num=$skin_display_name" >> "$TEMP_DIR/texts/zh_CN.lang"
    cp "$texture" "$TEMP_DIR/"
done

cat >> "$TEMP_DIR/skins.json" <<EOF
    ]
}
EOF

cat > "$TEMP_DIR/manifest.json" <<EOF
{
    "format_version": 1,
    "header": {
        "name": "$pack_name",
        "version": [1, 0, 0],
        "uuid": "$(uuidgen -r)"
    },
    "modules": [
        {
            "version": [1, 0, 0],
            "type": "skin_pack",
            "uuid": "$(uuidgen -r)"
        }
    ]
}
EOF


(cd "$TEMP_DIR" && zip -qr "../$output_file" ./*)
rm -rf "$TEMP_DIR"

echo -e "\n 生成完成!"
