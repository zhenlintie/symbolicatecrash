# symbolicatecrash
iOS crash 文件符号解析工具

## 前提

* 安装好 Xcode
* 将需要被解析的崩溃文件以 '.crash' 作为后缀进行保存
* 将同名的 dSYM 文件，放在同一文件夹下

如:

```
/path/to/
├── mycrash.crash
├── mycrash.dSYM
```
## 使用方法

`$ ./symbolicatecrash  path/to/mycrash.crash`

解析成功后，将在同一文件夹下生成 `mycrash-symbolicated.crash` 文件

## 提示

本工具使用了 Xcode 自带工具 `symbolicatecrash`，目录为：   

> /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash

若后续该工具路径发生变化，使用下方命令进行查找：

`$ find /Applications/Xcode.app -name symbolicatecrash -type f`

然后在源码中替换新的路径，重新编译即可