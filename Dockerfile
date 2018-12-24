# 生成镜像name:tomcat:8-alpine-ffmpeg
FROM tomcat:8-alpine

# rtmp接流服务
COPY nginx.conf /etc/nginx/nginx.conf
# 多服务管理
COPY supervisord.conf /conf/supervisord.conf
# 海康威视sdk lib
COPY lib/* /usr/lib/

RUN  apk add --no-cache tzdata nginx-mod-rtmp ffmpeg supervisor \
	&& ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p /var/run/nginx 
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/conf/supervisord.conf"] 
