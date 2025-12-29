# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com
#
# SPDX-License-Identifier: GPL-3.0-or-later

cloud-init devel net-convert \
  --network-data=/run/cloud-init/network-config.json --kind=yaml --output-kind=networkd --distro=ubuntu --directory=target
