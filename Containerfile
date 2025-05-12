#FROM registry.redhat.io/rhel10/rhel-bootc:10.0
FROM quay.io/mrguitar/el10-base:latest

COPY etc etc
# Make sure that the rootfiles package can be installed
RUN mkdir -p /var/roothome 

RUN dnf groupinstall -y \
	"Container Management" \
	gnome-desktop \
	hardware-support \
	multimedia \
	networkmanager-submodules \
	"Workstation" \
	"Virtualization Host" && \
	\
	dnf install -y \
	cockpit-machines \
	cockpit-podman \
	command-line-assistant \
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

