@REM 写一个.bat,把指定目录下的所有文件名含有关键字的文件名添加指定后缀

@echo off
setlocal enabledelayedexpansion

rem 指定要搜索的目录
set "directory=D:\Downloads\ZP010004016005.logcat"

rem 指定关键字
set "keyword=logcat"

rem 指定要添加的后缀
set "suffix=.log"

rem 切换到指定目录
cd /d "%directory%"

rem 遍历目录中的所有文件
for %%f in (*%keyword%*) do (
    rem 获取文件的扩展名
    set "filename=%%~nf"
    set "extension=%%~xf"

    rem 重命名文件，添加后缀
    ren "%%f" "!filename!!extension!!suffix!"
)

endlocal
