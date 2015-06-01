FROM centos:centos6
MAINTAINER Darin London <darin.london@duke.edu>

RUN ["/usr/bin/yum", "clean", "all"]
RUN ["/usr/bin/yum", "distro-sync", "-q", "-y", "--nogpgcheck"]
RUN ["/usr/bin/yum", "update", "-q", "-y","--nogpgcheck"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "gcc","gcc-c++", "glibc-static", "which", "zlib-devel", "readline-devel", "libcurl-devel", "tar", "patch"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "openssl", "openssl-devel"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "unzip", "bzip2", "wget"]

#shellshocked!
RUN ["/usr/bin/yum", "update", "-y", "--nogpgcheck", "bash"]
WORKDIR /root
RUN ["wget", "http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"]
RUN ["rpm", "-ivh", "/root/epel-release-6-8.noarch.rpm"]
RUN ["rm", "/root/epel-release-6-8.noarch.rpm"]

#ruby
ADD install_ruby.sh /root/install_ruby.sh
RUN ["chmod", "u+x", "/root/install_ruby.sh"]
RUN ["/root/install_ruby.sh"]
RUN ["/usr/local/bin/gem", "install", "--no-rdoc", "--no-ri", "bundler"]
RUN ["/usr/local/bin/gem", "install", "--no-rdoc", "--no-ri", "rails"]

#sqlite
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "sqlite", "sqlite-devel"]

#javascript runtime
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "nodejs"]

# self-signed cert
ADD cert_config /root/installs/cert_config
RUN ["mkdir", "/etc/app"]
RUN ["/usr/bin/openssl", "req", "-nodes", "-newkey", "rsa:2048", "-keyout", "/etc/app/reg.key", "-config", "/root/installs/cert_config", "-out", "/etc/app/reg.csr"]
RUN ["/usr/bin/openssl", "x509", "-req", "-days", "36500", "-in", "/etc/app/reg.csr", "-signkey", "/etc/app/reg.key", "-out", "/etc/app/reg.crt"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "libxml2", "libxml2-devel", "libxslt", "libxslt-devel"]

RUN ["mkdir", "-p", "/var/www/app"]
ADD test /var/www/app/test
ADD public /var/www/app/public
ADD Gemfile /var/www/app/Gemfile
ADD Gemfile.lock /var/www/app/Gemfile.lock
ADD README.rdoc /var/www/app/README.rdoc
ADD Rakefile /var/www/app/Rakefile
ADD app /var/www/app/app
ADD bin /var/www/app/bin
ADD config /var/www/app/config
ADD config.ru /var/www/app/config.ru
ADD db /var/www/app/db
ADD lib /var/www/app/lib
ADD log /var/www/app/log
ADD tmp /var/www/app/tmp
ADD vendor /var/www/app/vendor

WORKDIR /var/www/app
RUN ["bundle", "config", "build.nokogiri", "--use-system-libraries"]
RUN ["bundle", "install"]
CMD ["thin", "start", "--ssl", "--ssl-disable-verify", "--ssl-key-file", "/etc/app/reg.key", "--ssl-cert-file", "/etc/app/reg.crt"]
