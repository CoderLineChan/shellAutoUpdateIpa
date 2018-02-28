

# 使用方法:
# 下载项目, 把项目中的三个文件 放入与工程相同目录下
# 再修改当前文件 三个#号开头的配置参数   ###
# 最后执行这个.sh文件






# IPA 打包存放路径
if [ ! -d ./IPA ];then
mkdir -p IPA;
fi

#工程绝对路径(当前工程)
project_path=$(cd `dirname $0`; pwd)


####工程名 将ExampleOC替换成自己的工程名
project_name=ExampleOC

####scheme名 将ExampleOC替换成自己的sheme名(一般scheme名与工程名相同)
scheme_name=ExampleOC

#打包模式 Debug/Release(默认Release)
development_mode=Release

#build文件夹路径
build_path=${project_path}/build

#plist文件所在路径(plist文件名称要与实际文件名称相同)
exportOptionsPlistPath=${project_path}/exportTest.plist

#导出.ipa文件所在路径
exportIpaPath=${project_path}/IPA


echo " Place enter the number you want to export ? [ 1:app-store  2:debug-ad-hoc  3:release-ad-hoc ] "
## 选择模式: 1:appStore上架, 2:Debug测试, 3:Release测试
read number
while([ $number != 1 ] && [ $number != 2 ] && [ $number != 3 ])
do
echo "Error! Should enter 1 or 2 or 3"
echo "Place enter the number you want to export ? [ 1:app-store  2:debug-ad-hoc  3:release-ad-hoc ] "
read number
done

####(plist文件名称要与实际文件名与路径称相同)
if [ $number == 1 ];then
development_mode=Release
exportOptionsPlistPath=${project_path}/exportConfig/exportAppstore.plist
elif [ $number == 2 ];then
development_mode=Debug
exportOptionsPlistPath=${project_path}/exportConfig/exportTest.plist
else
development_mode=Release
exportOptionsPlistPath=${project_path}/exportConfig/exportTest.plist
fi

echo '*** --------- ***'
echo '***  正在清理  ***'
echo '*** --------- ***'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit

echo '*** --------- ***'
echo '***  清理完成  ***'
echo '***  开始编译  ***'
echo '*** --------- ***'
echo ''
xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit

echo '*** --------- ***'
echo '***  编译完成  ***'
echo '***  开始打包  ***'
echo '*** --------- ***'
echo ''


xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ]; then
echo '*** --------- ***'
echo '***  ipa已导出 ***'
echo '*** --------- ***'
open $exportIpaPath
else
echo '*** ---------- ***'
echo '*** ipa导出失败 ***'
echo '*** 按任意键退出 ***'
echo '*** ---------- ***'
read end
exit 0
fi
echo '*** ---------- ***'
echo '*** ipa导出完成 ***'
echo '*** 开始发布ipa ***'
echo '*** ---------- ***'
echo ''

# 导出完成ipa包, 删除.xcarchive编译文件 
rm -rf $build_path


if [ $number == 1 ];then

#验证并上传到App Store
###  将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
"$altoolPath" --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -u XXX -p XXX -t ios --output-format xml
"$altoolPath" --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -u  XXX -p XXX -t ios --output-format xml

echo ''
echo '			ｂ（￣▽￣）ｄ			'
echo '                		'
echo '*****	 发布ipa包AppStore完成  *****'
echo '                   	'	
echo '			ｂ（￣▽￣）ｄ			'
echo ''

else

# 这里上传蒲公英,  如果是其他平台, 就配置对应的参数
### 蒲公英上的User Key
uKey="889dd905*************"
### 蒲公英上的API Key
apiKey="f059e26d***************"
#要上传的ipa文件路径
IPA_PATH=${exportIpaPath}/${scheme_name}.ipa
# 开始上传蒲公英
curl -F "file=@${IPA_PATH}" -F "uKey=${uKey}" -F "_api_key=${apiKey}" http://www.pgyer.com/apiv1/app/upload

echo ''
echo '			ｂ（￣▽￣）ｄ			'
echo '                		'
echo '*****	 发布ipa包到蒲公英完成  *****'
echo '                   	'	
echo '			ｂ（￣▽￣）ｄ			'
echo ''

fi

read end
exit 0


