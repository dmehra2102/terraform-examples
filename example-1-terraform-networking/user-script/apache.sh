#!/bin/bash

apt update -y
apt install -y apache2

systemctl start apache2
systemctl enable apache2

HOSTNAME=$(hostname)

cat <<EOF > /var/www/html/index.html
<html>
<body>
<h1>EC2 Instance Running</h1>
<p>Hostname: $HOSTNAME</p>
</body>
</html>
EOF