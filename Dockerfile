FROM ubuntu:24.04

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    vim \
    htop \
    net-tools \
    tcpdump \
    wireshark-common \
    tshark \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    nodejs \
    npm \
    openssl \
    libssl-dev \
    pkg-config \
    libxml2-dev \
    libffi-dev \
    libc6-dev \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# .NET SDK 설치
RUN wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0 \
    && rm packages-microsoft-prod.deb

# 작업 디렉토리 설정
WORKDIR /root/opcua-research

# 환경 설정 스크립트 복사
COPY setup_environment.sh .

# 실행 권한 부여
RUN chmod +x setup_environment.sh

# 포트 노출
EXPOSE 4840 4841 4842 4843 4844

# 기본 명령어
CMD ["./setup_environment.sh"]



