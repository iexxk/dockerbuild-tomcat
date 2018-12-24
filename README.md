# dockerbuild-tomcat
tomcat的dockerfile bulid项目

Tags:

[8-alpine-cst](https://github.com/xuanfong1/dockerbuild-tomcat)

[8-alpine-cst-font](https://github.com/xuanfong1/dockerbuild-tomcat/tree/font)

[8-alpine-ffmpeg](https://github.com/xuanfong1/dockerbuild-tomcat/tree/ffmpeg)

[github issues](https://github.com/xuanfong1/dockerbuild-tomcat/issues)

### 基础镜像

[tomcat:8-alpine](https://hub.docker.com/_/tomcat/)

#### 功能
1. 添加中国时区
2. 多服务supervisord管理器
3. nginx-rtmp
4. nginx-文件服务
5. 海康sdk
6. ffmpeg转流

#### 使用

`Dockerfile`

```dockerfile
#基础镜像选择alpine 小巧安全流行方便
FROM www.3sreform.com:14005/tomcat:8-alpine-ffmpeg
# 覆写nginx配置,需要打开注释
#COPY nginx.conf /etc/nginx/nginx.conf
#复制固定路径下打包好的jar包(target/*.jar)并重命名到容器跟目录(/app.jar)，或ADD
COPY target/hikvision.war /usr/local/tomcat/webapps/
# 覆写多服务配置
COPY supervisord.conf /conf/supervisord.conf
```

`Dockercompose.yml`

```yaml
version: '3.2'

services:
  hikvision:
    restart: always
    image: manage/test/ygl/hikvision:latest
    volumes:
      - /logs/ygl-hikvision:/app/log
    ports:
     # 系统tomcat业务接口
      - 14085:8080
     # 视频ffmpeg转流服务 
      - 14086:1935
     # 回放文件访问端口 
      - 14087:8888
     # supervisord服务管理端口 
      - 14081:9001
```

eg: 如果要覆写一下配置，在该文件修改即可

`supervisord.conf`

```properties
[supervisord]
; 启动到前端, 用于docker
nodaemon=true
; 设置pid文件路径
pidfile=/var/run/supervisord.pid

[inet_http_server]          ; inet (TCP) server disabled by default
port=*:9001         ; (ip_address:port specifier, *:port for all iface)

; 配置nginx
[program:nginx]
; 配置日志输出到控制台, 用于docker收集日志
stdout_logfile=/dev/stdout
; 去掉日志rotation
stdout_logfile_maxbytes=0
autorestart=true
; 启动优先级越大越重要越先启动
priority=900
command= nginx -g "daemon off;"

; 配置ffmpeg1
[program:ffmpeg1]
; 配置日志输出到控制台, 用于docker收集日志
stdout_logfile=/dev/stdout
; 去掉日志rotation
stdout_logfile_maxbytes=0
autorestart=true
priority=800
command=ffmpeg -rtsp_transport tcp -i rtsp://admin:12345@192.0.0.58:554  -vcodec copy -acodec aac -ar 44100 -strict -2 -ac 1 -f flv -s 1280x720 -q 10 -f flv rtmp://127.0.0.1:1935/hls/video1

; 配置tomcat
[program:tomcat]
; 配置日志输出到控制台, 用于docker收集日志
stdout_logfile=/dev/stdout
; 去掉日志rotation
stdout_logfile_maxbytes=0
autorestart=true
priority=700
command=catalina.sh run
```

`nginx.conf`

```nginx
# /etc/nginx/nginx.conf
user root;
worker_processes 1;
#error_log /var/log/nginx/error.log warn;
# 包含插件rtmp
include /etc/nginx/modules/*.conf;
events {
	worker_connections 1024;
}
rtmp {
        server {
            listen 1935;
            application myapp {
                live on;
            }
            application hls {
                live on;
                hls on;
                hls_path /tmp/hls;
        				hls_fragment 1s;
       	        hls_playlist_length 3s;
	 				 }
        }
}
# 回放临时文件访问的nginx的设置
http {
    include       mime.types;
    default_type  application/octet-stream;
    #access_log  logs/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    #gzip  on;
    server {
        listen       8888;
        server_name  localhost;
        location /video {
            root   /tmp/hikvision;
        }
    }
}
```





### 详细说明

[Docker-make-ffmpeg-nginx](https://blog.iexxk.com/2018/08/22/Docker-make-ffmpeg-nginx/)