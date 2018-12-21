# 生成镜像name：tomcat:8-alpine-cst-font
# 功能：
#      1. 镜像时间为中国时间
#      2. 添加字体
FROM tomcat:8-alpine
RUN apk add --no-cache tzdata ttf-dejavu \
     && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
	 && echo "Asia/Shanghai" > /etc/timezone