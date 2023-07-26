# 首阶段：设置编译环境并编译应用程序
FROM golang:1.17-alpine as builder

# 将工作目录设置为应用程序源代码的目录
WORKDIR /app

# 将源代码复制到容器中
COPY . .

# 在 Alpine Linux 中构建应用程序
RUN export GOPROXY=https://goproxy.cn && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app .

# 第二阶段：构建最终镜像
FROM alpine

WORKDIR /home

# 修改alpine源为阿里云
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
  apk update && \
  apk upgrade && \
  apk add ca-certificates && update-ca-certificates && \
  apk add --update tzdata && \
  rm -rf /var/cache/apk/*

# 从编译阶段中复制编译好的二进制文件到最终镜像中
COPY --from=builder /app/app .

ENV TZ=Asia/Shanghai

EXPOSE 8080

ENTRYPOINT ./app

