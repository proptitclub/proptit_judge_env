FROM ubuntu:18.04
LABEL AUTHOR=nghiatd.proptit@gmail.com
LABEL OWNER=PROPTIT_CLUB_HN-https://www.facebook.com/clubproptit/
WORKDIR /opt/
ENV PYTHONUNBUFFERED=1 C_FORCE_ROOT=true
ENV VNC_PASSWORD=proptit HTTP_PASSWORD=proptit USER=nghiatd PASSWORD=proptit
ENV RABBITMQ_HOST=localhost RABBITMQ_PORT=5672 RABBITMQ_USER=guest RABBITMQ_PWD=guest
ENV POSTGRESQL_HOST=localhost POSTGRESQL_PORT=5432 POSTGRESQL_USER=root POSTGRESQL_PWD=root POSTGRESQL_SCHEMA=proptit_judge
ENV REDIS_HOST=localhost REDIS_PORT=6379
RUN apt-get update -y && apt-get upgrade -y

RUN mkdir /storage && chmod -R 755 /storage

# Install g++, gcc, download tool, and isolate's dependence
RUN apt-get install build-essential wget libcap-dev vim libpq-dev -y

ENV GCC_PATH /usr/bin/x86_64-linux-gnu-gcc-7
ENV GPP_PATH /usr/bin/x86_64-linux-gnu-g++-7

# Install Isolate Sandbox
RUN mkdir isolate
COPY ./isolate /opt/isolate
RUN cd isolate && make isolate && make install
ENV ISOLATE /opt/isolate/isolate

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

ADD ./sys_requirements.txt /opt/sys_requirements.txt
RUN pip3 install --default-timeout 9999 -r sys_requirements.txt
# RUN mkdir /opt/proptit_pcm
# COPY ./proptit_pcm /opt/proptit_pcm


# RUN echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
# RUN echo 0 > /proc/sys/kernel/randomize_va_space
# RUN echo never > /sys/kernel/mm/transparent_hugepage/enabled
# RUN echo never > /sys/kernel/mm/transparent_hugepage/defrag
# RUN echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
