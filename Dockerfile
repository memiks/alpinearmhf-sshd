FROM container4armhf/armhf-alpine
MAINTAINER Frederic LESUR <contact@memiks.fr>
# Install openrc
RUN apk update &&\
    apk add openrc &&\
# Tell openrc its running inside a container, till now that has meant LXC
    sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab &&\
# can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
# can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh

# add openssh and clean
RUN apk add --update openssh &&\
    rm  -rf /tmp/* /var/cache/apk/*
# add entrypoint script
RUN rc-update add sshd default
RUN rc-update add crond default

ADD docker-entrypoint.sh /usr/sbin
#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

EXPOSE 22
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/sbin/init"]
