@echo off

setlocal enableDelayedExpansion

:input
REM 指定目录
set /p dir=dirs,dirs=

REM 将输入的目录路径按逗号分割成数组
set i=0
for %%d in ("%dir:,=" "%") do (
    set /a i+=1
    set "dir[!i!]=%%~d"
)

REM 遍历目录下所有png文件
for /l %%i in (1,1,!i!) do (
    for %%f in ("!dir[%%i]!\*.png") do (
        REM 使用ImageMagick将像素改为透明
        magick convert "%%f" -alpha transparent "%%f"
    )
)

echo 处理完成！

pause