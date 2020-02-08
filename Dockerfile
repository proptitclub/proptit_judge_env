FROM dorowu/ubuntu-desktop-lxde-vnc:bionic
LABEL AUTHOR=nghiatd.proptit@gmail.com
LABEL OWNER=PROPTIT_CLUB_HN-https://www.facebook.com/clubproptit/
WORKDIR /opt/
ENV PYTHONUNBUFFERED=1 C_FORCE_ROOT=true
ENV VNC_PASSWORD=proptit HTTP_PASSWORD=proptit USER=nghiatd PASSWORD=proptit
ENV RABBITMQ_HOST=127.0.0.1 RABBITMQ_PORT=5672 RABBITMQ_USER=guest RABBITMQ_PWD=guest
ENV MYSQL_HOST=localhost MYSQL_PORT=3306 MYSQL_USER=root MYSQL_PWD=root MYSQL_SCHEMA=proptit_js
RUN apt-get update -y && apt-get upgrade -y

# Install g++, gcc, download tool, and isolate's dependence
RUN apt-get install build-essential wget libcap-dev vim default-libmysqlclient-dev -y

ENV GCC_PATH /usr/bin/x86_64-linux-gnu-gcc-7
ENV GPP_PATH /usr/bin/x86_64-linux-gnu-g++-7

# Install Java
RUN apt-get install openjdk-11-jdk-headless -y
ENV JAVA_PATH /usr/lib/jvm/java-11-openjdk-amd64/bin/java
ENV JAVAC_PATH /usr/lib/jvm/java-11-openjdk-amd64/bin/javac

# Install python environment
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN /bin/bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

RUN /opt/conda/bin/conda create -n py3 python=3.7 -y

ENV PY3_PATH /opt/conda/envs/py3/bin/python

RUN apt-get install python3 python3-dev python3-pip -y

# Install Isolate Sandbox
RUN mkdir isolate
COPY ./isolate /opt/isolate
RUN cd isolate && make isolate && make install
ENV ISOLATE /opt/isolate/isolate

ADD ./sys_requirements.txt /opt/sys_requirements.txt
RUN pip3 install --default-timeout 9999 -r sys_requirements.txt
# RUN mkdir /opt/proptit_pcm
# COPY ./proptit_pcm /opt/proptit_pcm


# RUN echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
# RUN echo 0 > /proc/sys/kernel/randomize_va_space
# RUN echo never > /sys/kernel/mm/transparent_hugepage/enabled
# RUN echo never > /sys/kernel/mm/transparent_hugepage/defrag
# RUN echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
