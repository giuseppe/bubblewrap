#!/bin/sh

# Ensure to run these commands first:
#
# sudo docker create --name=fedora fedora /bin/sh
# (mkdir rootfs; cd rootfs; sudo docker export fedora | tar xv)
# sudo docker rm fedora

# A read only image should not need this, but...
# Run once to create the needed temporary files
uuidgen | tr -d - > /tmp/machine-id

bwrap --cap-add ALL --uid 0 --gid 0 --bind rootfs / --ro-bind /sys \
      /sys --proc /proc --dev /dev --ro-bind /sys/fs/cgroup /sys/fs/cgroup \
      --ro-bind /sys/fs/cgroup/systemd /sys/fs/cgroup/systemd --ro-bind \
      /sys/fs/cgroup/cpuset /sys/fs/cgroup/cpuset --ro-bind \
      /sys/fs/cgroup/hugetlb /sys/fs/cgroup/hugetlb --ro-bind  \
      /sys/fs/cgroup/devices /sys/fs/cgroup/devices --ro-bind  \
      /sys/fs/cgroup/cpu,cpuacct /sys/fs/cgroup/cpu,cpuacct --ro-bind \
      /sys/fs/cgroup/freezer /sys/fs/cgroup/freezer --ro-bind \
      /sys/fs/cgroup/pids /sys/fs/cgroup/pids --ro-bind /sys/fs/cgroup/blkio \
      /sys/fs/cgroup/blkio --ro-bind /sys/fs/cgroup/net_cls,net_prio \
      /sys/fs/cgroup/net_cls,net_prio --ro-bind /sys/fs/cgroup/perf_event \
      /sys/fs/cgroup/perf_event --ro-bind /sys/fs/cgroup/memory \
      /sys/fs/cgroup/memory --bind /sys/fs/cgroup/systemd \
      /sys/fs/cgroup/systemd --tmpfs /run --tmpfs /tmp --tmpfs /var/lib \
      --tmpfs /dev/shm --mqueue /dev/mqueue --dev-bind /dev/tty /dev/tty  \
      --chdir / --setenv PATH  \
      /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  \
      --setenv TERM xterm --setenv container docker  --tmpfs /var/log/  \
      --tmpfs /var/log/httpd --tmpfs /var/tmp  --hostname systemd  \
      --unshare-pid --unshare-net --unshare-ipc --unshare-user --unshare-uts \
      bash -c "systemd-tmpfiles --create && systemctl mask dev-hugepages.mount"

# All the temporary files are created, when can use / as read only
exec bwrap --cap-add ALL --uid 0 --gid 0 --bind rootfs / --bind / /root \
     --ro-bind /sys /sys --proc /proc --dev /dev --ro-bind /sys/fs/cgroup  \
     /sys/fs/cgroup --ro-bind /sys/fs/cgroup/systemd /sys/fs/cgroup/systemd \
     --ro-bind /sys/fs/cgroup/cpuset /sys/fs/cgroup/cpuset --ro-bind \
     /sys/fs/cgroup/hugetlb /sys/fs/cgroup/hugetlb --ro-bind \
     /sys/fs/cgroup/devices /sys/fs/cgroup/devices --ro-bind \
     /sys/fs/cgroup/cpu,cpuacct /sys/fs/cgroup/cpu,cpuacct --ro-bind \
     /sys/fs/cgroup/freezer /sys/fs/cgroup/freezer --ro-bind \
     /sys/fs/cgroup/pids /sys/fs/cgroup/pids --ro-bind /sys/fs/cgroup/blkio \
     /sys/fs/cgroup/blkio --ro-bind /sys/fs/cgroup/net_cls,net_prio \
     /sys/fs/cgroup/net_cls,net_prio --ro-bind /sys/fs/cgroup/perf_event \
     /sys/fs/cgroup/perf_event --ro-bind /sys/fs/cgroup/memory \
     /sys/fs/cgroup/memory --bind /sys/fs/cgroup/systemd \
     /sys/fs/cgroup/systemd --tmpfs /run --tmpfs /tmp --tmpfs /var/lib \
     --tmpfs /dev/shm --mqueue /dev/mqueue --bind /tmp/machine-id \
     /etc/machine-id --dev-bind /dev/tty /dev/tty --chdir / --setenv PATH \
     /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
     --setenv TERM xterm --setenv container docker --tmpfs /var/log/ \
     --tmpfs /var/log/httpd --tmpfs /var/tmp --hostname systemd \
     --unshare-pid --unshare-net --unshare-ipc --unshare-user --unshare-uts \
     --as-pid-1 --remount-ro / /usr/lib/systemd/systemd --system
