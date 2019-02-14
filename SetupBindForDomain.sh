sudo apt-get update
sudo apt-get install bind9 -y
echo "Enter the domain to use for DNS configuration"
read domainName
echo "Enter the IP address to use for DNS configuration"
read IPAddress
sudo bash -c 'echo "
zone \"$domainName\" {
        type master;
        file \"/etc/bind/zones/db.$domainName\";
};
" >> /etc/bind/named.conf.local'
sudo mkdir -p /etc/bind/zones
sudo bash -c 'echo "
$TTL 1d
$ORIGIN $domainName.  

@       IN      SOA     ns1     root    (
                20180904        ;Serial
                12h             ;Refresh
                15m             ;Retry
                3w              ;Expire
                2h              ;Minumum
        )

@       IN      A       $IPAddress       

@       IN      NS      ns1
ns1     IN      A       $IPAddress

*       IN      CNAME   $domainName." >> /etc/bind/zones/db.$domainName'

sudo bash -c 'echo "include \"/etc/bind/named.conf.log\";" >> /etc/bind/named.conf'
sudo sed -i -e '/listen-on-v6 { any; };/a\\tallow-transfer { none;};\n\tversion "[null]";' /etc/bind/named.conf.options

sudo bash -c 'echo "logging {
  channel bind_log {
    file \"/var/log/named/bind.log\" versions 3 size 5m;
    severity info;
    print-category yes;
    print-severity yes;
    print-time yes;
  };
  category default { bind_log; };
  category update { bind_log; };
  category update-security { bind_log; };
  category security { bind_log; };
  category queries { bind_log; };
  category lame-servers { null; };
};" >> /etc/bind/named.conf.log'

sudo mkdir /var/log/named
sudo chown bind:bind /var/log/named
sudo systemctl restart bind9