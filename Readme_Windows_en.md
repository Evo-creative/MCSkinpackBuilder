## How to Use

1. **Prepare Files**  
   - Put skin PNGs (e.g. `*.tga`, `*.png`,`*.jpg`) and script in same folder

2. **Run Script**  
   ```Powershell
   powershell -ExecutionPolicy Bypass -File .\build_zh.ps1
   ```

3. **Follow Prompts**  
   - Skin pack name  
   - Each skin's display name  
   - Model type (1=slim, 2=classic)

4. **Get Result**  
   `.mcpack` file will be generated after completion

> - Notes:  
> - For Minecraft Bedrock Edition ONLY  
> - Not work for NetEase Edition  
> - Requires `uuidgen` and `zip` tools(If you do not,the script will install it automatically)
