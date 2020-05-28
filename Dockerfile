FROM ruby:2.7

RUN mkdir /build
WORKDIR /build

RUN wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip && wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip && wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip
RUN unzip instantclient-basic-linux.x64-19.6.0.0.0dbru.zip && unzip instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip && unzip instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip
RUN mkdir -p /opt/oracle && cp -a instantclient_19_6 /opt/oracle/

WORKDIR /
RUN rm -rf /build

RUN apt-get update && apt-get install -y libaio1
RUN echo "/opt/oracle/instantclient_19_6" > /etc/ld.so.conf.d/zzz_oci.conf && ldconfig

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && \
    apt-get -y install nodejs && \
    apt-get -y clean
RUN gem update --system
RUN gem install bundler smashing ruby-oci8

RUN mkdir /smashing && \
    smashing new smashing && \
    cd /smashing && \
    bundle && \
    ln -s /smashing/dashboards /dashboards && \
    ln -s /smashing/jobs /jobs && \
    ln -s /smashing/assets /assets && \
    ln -s /smashing/lib /lib-smashing && \
    ln -s /smashing/public /public && \
    ln -s /smashing/widgets /widgets && \
    mkdir /smashing/config && \
    mv /smashing/config.ru /smashing/config/config.ru && \
    ln -s /smashing/config/config.ru /smashing/config.ru && \
    ln -s /smashing/config /config

COPY run.sh /

VOLUME ["/dashboards", "/jobs", "/lib-smashing", "/config", "/public", "/widgets", "/assets"]

ENV PORT 3030
EXPOSE $PORT
WORKDIR /smashing

CMD ["/run.sh"]
