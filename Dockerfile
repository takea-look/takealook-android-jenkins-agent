# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:latest

# 환경변수 설정
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    curl unzip git openjdk-17-jdk wget sudo \
    lib32stdc++6 lib32z1 \
    && rm -rf /var/lib/apt/lists/*

# Java 환경변수 설정
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Android SDK 설치
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && rm cmdline-tools.zip && \
    mv cmdline-tools latest

# SDK 필수 구성 요소 설치
RUN yes | sdkmanager --licenses

# Gradle 설치
RUN wget https://services.gradle.org/distributions/gradle-8.6-bin.zip -O /tmp/gradle.zip && \
    unzip /tmp/gradle.zip -d /opt/ && \
    ln -s /opt/gradle-8.6/bin/gradle /usr/bin/gradle && \
    rm /tmp/gradle.zip

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
