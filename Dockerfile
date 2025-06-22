# syntax=docker/dockerfile:1
# --platform 플래그 제거, Docker가 자동으로 arm64용 이미지를 가져옴
FROM ubuntu:22.04

# 환경변수 설정
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    curl unzip git wget sudo \
    ca-certificates \
    # AAPT2 실행에 필요한 공유 라이브러리 추가
    libc++1 \
    zlib1g \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install necessary dependencies
RUN apt-get update && apt-get install -y libc6

# Temurin JDK 17 설치 (aarch64 용으로 URL 변경)
RUN mkdir -p /opt/java && \
    curl -L -o /tmp/temurin.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.11+9/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.11_9.tar.gz && \
    tar -xzf /tmp/temurin.tar.gz -C /opt/java --strip-components=1 && \
    rm /tmp/temurin.tar.gz

# Java 환경변수 설정
ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Android SDK 설치
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && rm cmdline-tools.zip && \
    mv cmdline-tools latest

# SDK 필수 구성 요소 설치
RUN yes | sdkmanager --licenses

# Jenkins 에이전트용 디렉토리 생성
RUN useradd -m -d /home/jenkins jenkins && echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
WORKDIR /home/jenkins

# JNLP 에이전트 jar 받을 위치
RUN mkdir -p /home/jenkins/agent

# ENTRYPOINT는 Jenkins가 제어할 것이므로 이 단계에서는 생략

# android-sdk 접근 권한 부여 (android build시 필요함)
USER root
RUN chmod -R a+rwX /opt/android-sdk
USER jenkins
