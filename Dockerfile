FROM centos
MAINTAINER sea-bird.org

ENV USERNAME __your_id__

RUN yum -y update
RUN yum -y install sudo openssh-server httpd nmap python-setuptools ntp
RUN yum clean all
RUN easy_install supervisor

# create user
RUN /usr/sbin/useradd $USERNAME
RUN /usr/bin/passwd -f -u $USERNAME

# create ssh user
RUN mkdir -p /home/$USERNAME/.ssh; /bin/chown $USERNAME:$USERNAME /home/$USERNAME/.ssh; /bin/chmod 700 /home/$USERNAME/.ssh
ADD ./authorized_keys /home/$USERNAME/.ssh/authorized_keys
RUN /bin/chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys; /bin/chmod 600 /home/$USERNAME/.ssh/authorized_keys

# setup sshd
ADD ./sshd_config /etc/ssh/sshd_config
RUN /etc/init.d/sshd start && /etc/init.d/sshd stop

# setup sudoers
RUN echo "$USERNAME   ALL=(ALL)   ALL" > /etc/sudoers.d/$USERNAME

# setup apache
RUN echo "ServerName 127.0.0.1" >> /etc/httpd/conf/httpd.conf

# setup supervisor
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisord.conf

# setup timezone
ADD ./clock /etc/sysconfig/clock
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# setup ntpd
ADD ./ntp.conf /etc/ntp.conf

EXPOSE 22 80

CMD ["/usr/bin/supervisord"]
