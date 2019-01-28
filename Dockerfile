# 生成镜像name：tomcat:8-alpine-cst-font
# 功能：
#      1. 镜像时间为中国时间
#      2. 添加字体
FROM tomcat:8-alpine
RUN apk add --no-cache tzdata ttf-dejavu \
     && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
	 && echo "Asia/Shanghai" > /etc/timezone
#拷贝宋体,如果不要自带字体，注释这句	 
COPY chinese /usr/share/fonts/chinese
#动态配置
COPY server.xml /usr/local/tomcat/conf/server.xml
