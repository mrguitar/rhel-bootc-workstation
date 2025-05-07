#FROM registry.stage.redhat.io/rhel10/rhel-bootc:10.0
FROM quay.io/mrguitar/el10-base:latest

COPY etc etc
# Make sure that the rootfiles package can be installed
RUN mkdir -p /var/roothome 

#remove after the repos hit the CDN
#RUN dnf repolist && sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/subscription-manager.conf

RUN dnf --disablerepo=rhel-10-for-x86_64-appstream-rpms --disablerepo=rhel-10-for-x86_64-baseos-rpms groupinstall -y \
	"Container Management" \
	gnome-desktop \
	hardware-support \
	multimedia \
	networkmanager-submodules \
	"Workstation" \
	"Virtualization Host" && \
	\
	dnf --disablerepo=rhel-10-for-x86_64-appstream-rpms --disablerepo=rhel-10-for-x86_64-baseos-rpms install -y \
	cockpit-machines \
	cockpit-podman \
	lm_sensors \
	pcp \
	pcp-selinux \
	powertop \
	wireguard-tools &&\
	dnf clean all

RUN systemctl set-default graphical.target

RUN systemctl enable fstrim.timer podman-auto-update.timer cockpit.socket

#let's set the timezone
RUN ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime

#clean up after rpms using legacy paths:
RUN rm -rf /var/run

# Final lint step to prevent easy-to-catch issues at build time
RUN bootc container lint

