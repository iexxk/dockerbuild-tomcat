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

#### 使用

`Dockerfile`

```dockerfile
#基础镜像选择alpine 小巧安全流行方便
FROM exxk/tomcat:8-alpine-cst
#复制固定路径下打包好的jar包(target/*.jar)并重命名到容器跟目录(/app.jar)，或ADD
#COPY target/app.war /usr/local/tomcat/webapps/
#防止重复启动，清除webapps下所有自带应用，然后server.xml 里面的dobase指向了新的/data/app ，为了防止重复启动
COPY target/app.war /data/app/
#修改tomcat默认端口
#RUN sed -i 's|port="8080"|port="80"|g' /usr/local/tomcat/conf/server.xml
#健康检查 -s 静默模式，不下载文件
#HEALTHCHECK CMD wget -s http://127.0.0.1:14030/actuator/health || exit 1
#启动命令
CMD ["catalina.sh", "run"]
```

`Dockercompose.yml`

```yaml
version: '3.2'

services:
  app:
    restart: always
    #新编译的镜像名
    image: extentTomcat:latest
   # volumes:
   #   - /logs/ygl-app:/app/log
    environment:
    # 远程debug
      CATALINA_OPTS: "-Xdebug -Xrunjdwp:transport=dt_socket,address=5005,suspend=n,server=y"
    # 启动参数  
      JAVA_OPTS: "-Xms512m -Xmx1024m -Xss1024K -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m"
#      MYSQL_URL: mysql
    ports:
      - 14083:8080
      - 14082:5005
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      placement:
        constraints: [node.hostname == ?]
```

### 详细说明

[Docker-Alpine-Timezone-Encoding](http://blog.iexxk.com/2018/07/16/Docker-Alpine-Timezone-Encoding/)
