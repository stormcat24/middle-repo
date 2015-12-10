FROM ubuntu:trusty

RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" > /etc/apt/sources.list.d/nginx-stable.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN apt-get update -y
RUN apt-get install -y nginx-extras
RUN apt-get install -y openssl

EXPOSE 80

ENTRYPOINT /usr/sbin/nginx -g 'daemon off;'
