#!/bin/bash
#############################
# 使用说明
# 添加可执行权限
# chmod +x mergeCsv.sh
# 将mergeCsv.sh 放到需要处理的文件夹中
# 执行mergeCsv.sh脚本
# ./mergeCsv.sh
#############################
# count: 记录处理文件的数量
count=0
# output: 输出文件名
output=merged.csv
# mergedFile: 输出文件全路径，当前路径(`pwd`)/输出文件名(output)
mergedFile=`pwd`/$output
echo 工作目录 `pwd`, 输出文件$mergedFile
# 定义mergeRecurse方法，用于递归合并当前目录下所有的csv文件
function mergeRecurse() {
    # $1: mergeRecurse方法第一个参数, flist: 列出$1 目录下所有文件
    flist=`ls $1`
    echo 进入目录 $1
    echo 目录内容 $flist
    cd $1
    # 循环遍历 $1 目录下的所有文件
    for f in $flist
    do
        if test -d $f
        then
            # $f 为目录时，递归调用mergeRecurse $f
            mergeRecurse $f
        elif [ $f = $output ]
        then
            # 跳过输出文件
            echo 忽略文件 $f
        elif [ "${f##*.}"x = "csv"x ]&&[ $count -eq 0 ]
        then
            # ${f##*.}: 取文件后缀，加x防空；${f%.*}: 取文件名(去掉文件后缀)
            # $f 为csv文件，且为第一个csv文件，当前场景每个csv为三行
            # 第一行前加一个空白单元格，并保存内容到line
            line=,`sed -n '1p' $f`
            # 打印第一行内容，并将结果重定向到输出文件，使用>强制覆盖输出文件
            echo $line > $mergedFile
            # 第二行前加一个单元格，内容为tissue
            line=tissue,`sed -n '2p' $f`
            # 打印第二行内容，并将结果重定向到输出文件，使用>>追加到输出文件
            echo $line >> $mergedFile
            # 第三行内容前加一个单元格，内容为当前文件名(去掉文件后缀)
            line="${f%.*}",`sed -n 3p $f`
            # 打印第三行内容，并将结果重定向到输出文件，使用>>追加到输出文件
            echo $line >> $mergedFile
            # 处理文件数加一
            let count++
            echo 合并文件 $f
        elif [ "${f##*.}"x = "csv"x ]
        then
            # $f 为csv文件，上面的elif [ "${f##*.}"x = "csv"x ]&&[ $count -eq 0 ]，处理了第一个csv。所以这里需要去掉每个csv中重复的内容
            # 当前场景每个csv为三行，且前两行为重复内容
            # 第三行内容前加一个单元格，内容为当前文件名(去掉文件后缀)
            line="${f%.*}",`sed -n 3p $f`
            # 打印第三行内容，并将结果重定向到输出文件，使用>>追加到输出文件
            echo ${line} >> $mergedFile
            # 处理文件数加一
            let count++
            echo 合并文件 $f
        else
            echo 忽略文件 $f
        fi
    done
    cd ..
}
# 调用mergeRecurse `pwd`，处理当前目录
mergeRecurse `pwd`
echo
echo 总共合并了 $count 个文件...
