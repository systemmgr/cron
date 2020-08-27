## cron  
  
crontab - schedule periodic background work  
  
Automatic install/update:
```
bash -c "$(curl -LSs https://github.com/systemmgr/cron/raw/master/install.sh)"
```
Manual install:
requires:    
```
apt install cron cowsay fortune-mod fortunes-off
```  
```
yum install cronie-noanacron cowsay fortune-mod
```  
```
pacman -S cronie cowsay fortune-mod
```  
  
```
sudo git clone https://github.com/systemmgr/cron /usr/local/etc/cron
sudo cp -Rfv /usr/local/etc/cron/cron* /etc/
```
  
  
<p align=center>
  <a href="https://wiki.archlinux.org/index.php/cron" target="_blank">cron wiki</a>  |  
  <a href="https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html" target="_blank">cron site</a>  |  
  <a href="https://crontab.guru" target="_blank">crontab time</a>
</p>  
    
    
