# 生成镜像name：tomcat:8-alpine-cst
# 功能：镜像时间为中国时间
FROM tomcat:8-alpine
RUN apk add --no-cache tzdata \
     && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
	 && echo "Asia/Shanghai" > /etc/timezone