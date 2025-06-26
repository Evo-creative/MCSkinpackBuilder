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
        echo "Missing dependencies: ${missing[*]}"
        
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            echo -e "\nAttempting installation..."
            case $ID in
                debian|ubuntu|linuxmint) sudo apt update && sudo apt install -y util-linux zip ;;
                fedora|centos|rhel) sudo dnf install -y util-linux zip ;;
                arch|manjaro) sudo pacman -Sy --noconfirm util-linux zip ;;
                *) echo "Unsupported OS. Install manually: util-linux zip"; exit 1 ;;
            esac
        else
            echo "Install manually: util-linux zip"
            exit 1
        fi
    fi
}

check_deps
mkdir -p "$TEMP_DIR/texts"

skin_files=($(ls {*.png,*.tga,*.jpg} 2>/dev/null | grep -v -e "$SCRIPT_NAME" -e "$TEMP_DIR"))
if [ ${#skin_files[@]} -eq 0 ]; then
    echo "Error: No skin files found (supported: .png/.tga/.jpg)"
    rm -rf "$TEMP_DIR"
    exit 1
fi
echo "Detected skin files: ${skin_files[*]}"

read -p "Enter pack display name: " pack_name
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
    
    read -p "Name for $texture: " skin_display_name
    read -p "Model type (1=slim 2=classic): " model_type
    
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

echo -e "\n✅ Done! Skin pack: $(realpath "$output_file")"
