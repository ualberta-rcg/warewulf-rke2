FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SYSTEMD_IGNORE_ERRORS=1

# --- 0. Set root user ---
USER root

# --- 1. Install Core Tools, Debugging, Kubernetes Dependencies, and Kernel ---
RUN apt-get update && apt-get install -y \
    sudo \
    openssh-server \
    net-tools \
    iproute2 \
    pciutils \
    lvm2 \
    nfs-common \
    multipath-tools \
    ifupdown \
    rsync \
    curl \
    wget \
    vim \
    tmux \
    less \
    htop \
    sysstat \
    cron \
    ipmitool \
    smartmontools \
    lm-sensors \
    python3 \
    python3-pip \
    unzip \
    gnupg \
    ansible \
    systemd \
    systemd-sysv \
    dbus \
    initramfs-tools \
    linux-image-generic \
    linux-headers-generic \
    openscap-scanner \
    libopenscap25t64 \
    openscap-common \
    socat \
    conntrack \
    ebtables \
    ethtool \
    ipset \
    iptables \
    chrony \
    tcpdump \
    strace \
    lsof \
    jq \
    bash-completion \
    ceph-common \
    open-iscsi \
    bpfcc-tools \
    cgroup-tools \
    auditd \
    apt-transport-https \
    software-properties-common \
    gnupg-agent \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Set root password ---
RUN echo "root:changeme" | chpasswd

# --- 3. Fetch and Apply SCAP Security Guide Remediation ---
RUN export SSG_VERSION=$(curl -s https://api.github.com/repos/ComplianceAsCode/content/releases/latest | grep -oP '"tag_name": "\K[^"]+' || echo "0.1.66") && \
    echo "🔄 Using SCAP Security Guide version: $SSG_VERSION" && \
    SSG_VERSION_NO_V=$(echo "$SSG_VERSION" | sed 's/^v//') && \
    wget -O /ssg.zip "https://github.com/ComplianceAsCode/content/releases/download/${SSG_VERSION}/scap-security-guide-${SSG_VERSION_NO_V}.zip" && \
    mkdir -p /usr/share/xml/scap/ssg/content && \
    unzip -jo /ssg.zip "scap-security-guide-${SSG_VERSION_NO_V}/*" -d /usr/share/xml/scap/ssg/content/ && \
    rm -f /ssg.zip && \
    SCAP_GUIDE=$(find /usr/share/xml/scap/ssg/content -name "ssg-ubuntu*-ds.xml" | sort | tail -n1) && \
    echo "📘 Found SCAP guide: $SCAP_GUIDE" && \
    oscap xccdf eval \
        --remediate \
        --profile xccdf_org.ssgproject.content_profile_cis_level2_server \
        --results /root/oscap-results.xml \
        --report /root/oscap-report.html \
        "$SCAP_GUIDE" || true && \
    echo "✅ SCAP remediation done."

# --- 4. Clean up SCAP content and scanner ---
RUN rm -rf /usr/share/xml/scap/ssg/content && \
    apt remove -y openscap-scanner libopenscap8 && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# --- 5. Install RKE2 (server mode) ---
RUN curl -sfL https://get.rke2.io | sh && \
    systemctl enable rke2-server.service

# --- 6. Create RKE2 config directory ---
RUN mkdir -p /etc/rancher/rke2/

# --- 7. Create sysctl config for K8s networking ---
RUN echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.d/k8s.conf && \
    echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.d/k8s.conf && \
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.d/k8s.conf && \
    sysctl --system || true

# --- 8. Rebuild initramfs (for PXE or WW images) ---
RUN update-initramfs -u

# --- 9. Systemd-compatible boot (Warewulf) ---
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
