/usr/sbin/sshd -D &


ServerArray=${SERVERS:=$1}

tee /haproxy/haproxy.cfg <<EOF > /dev/null
# this config needs haproxy-1.1.28 or haproxy-1.2.1

global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  #log loghost  local0 info
  maxconn 500
  #chroot /usr/share/haproxy
  user haproxy
  group haproxy
  daemon
  #debug
  #quiet

listen webfarm 0.0.0.0:80
       mode http
       balance roundrobin
       cookie SERVERID insert indirect
       option httpchk HEAD /index.php HTTP/1.0
EOF

IFS=","
COUNT=1
for i in ${ServerArray[@]}
do
  echo "   " server SERVER_$COUNT $i cookie A check >> /haproxy/haproxy.cfg
  let "COUNT += 1"
done

cat /haproxy/haproxy.cfg

haproxy -db -f /haproxy/haproxy.cfg
