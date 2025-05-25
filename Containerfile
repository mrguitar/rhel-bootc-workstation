FROM registry.redhat.io/rhel10/rhel-bootc:10.0

COPY etc etc
COPY usr usr

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
	wireguard-tools 

RUN systemctl set-default graphical.target

RUN systemctl enable fstrim.timer podman-auto-update.timer cockpit.socket

#add NVIDIA drivers and a few other packages from negativo17 & epel repositories
RUN dnf config-manager --add-repo=https://negativo17.org/repos/epel-nvidia.repo --add-repo=https://negativo17.org/repos/epel-multimedia.repo &&\
        dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm &&\
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo -o /etc/yum.repos.d/nvidia-container-toolkit.repo && \
        mkdir -p /etc/nvidia &&\
        echo "MODULE_VARIANT=kernel" > etc/nvidia/kernel.conf &&\
        dnf install -y \
	dkms-nvidia \
	dkms-xpadneo \
	ffmpeg \
	gdb \
	gcc-c++ \
	java-headless \
	kernel-devel \
	kernel-headers \
	libguestfs \
	libva-nvidia-driver \
	libva-utils \
	nvidia-container-toolkit \
	nvidia-driver \
	nvidia-settings \
	nvidia-vaapi-driver \
	vulkan-tools &&\
        dnf clean all

COPY kmod.sh /tmp
RUN /tmp/kmod.sh

#Add steam-devices udev rules
RUN curl -s -L https://raw.githubusercontent.com/ValveSoftware/steam-devices/master/60-steam-input.rules -o /usr/lib/udev/rules.d/60-steam-input.rules &&\
	curl -s -L https://raw.githubusercontent.com/ValveSoftware/steam-devices/master/60-steam-vr.rules -o /usr/lib/udev/rules.d/60-steam-vr.rules

#let's set the timezone
RUN ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime

#clean up after rpms using legacy paths:
RUN rm -rf /var/run

# Final lint step to prevent easy-to-catch issues at build time
RUN bootc container lint

