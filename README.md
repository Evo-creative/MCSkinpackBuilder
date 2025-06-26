## 使用说明How to Use

1. **准备文件Prepare Files**  
   - 将皮肤 PNG 文件（如 `*.png`, `*.tga`,`*.jpg` ）和脚本放在同一文件夹
   - Put skin PNGs (e.g. `*.tga`, `*.png`,`*.jpg`) and script in same folder
   - 注意文件格式，仅限png,tga,jpg
   - Mind the format

2. **运行脚本Run Script**  
   Windows
   ```Powershell
   pwsh build_zh.ps1
   ```
   Linux
   ```bash
   chmod +x cuild_zh.sh
   ./build_zh.sh
   ```

4. **根据脚本指引填写Follow Prompts**  
   - 皮肤包名称  
   - 每个皮肤的名称  
   - 选择模型类型（1=纤细(Alex)，2=粗壮(Steve)）
   - Skin pack name
   - Each skin's display name  
   - Model type (1=slim, 2=classic)

5. **获取结果Get Result**  
   生成完成后会得到 `.mcpack` 文件
   `.mcpack` file will be generated after completion

> 注意：  
> - 仅支持 Minecraft 基岩版  
> - 网易版不可用  
> - 需要提前安装 `uuidgen` 和 `zip` 工具(不安装也没事，脚本会自己装的)
> - Notes:  
> - For Minecraft Bedrock Edition ONLY  
> - Not work for NetEase Edition  
> - Requires `uuidgen` and `zip` tools(If you do not,the script will install it automatically)
