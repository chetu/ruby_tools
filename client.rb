# cat /opt/client.rb 
require 'rubygems'
require 'mail'
require "socket"
require "openssl"
require "base64"
include OpenSSL
require "base64"
PORT = 5534

def smtp_options
  { :address  => "mailer.example.com",
    :port  => 6610,
    :domain  => "mailer.example.com",
    :user_name  => "user_name",
    :password  => "password",
    :authentication  => :login
  }
end



def send_email(subject,email,body)
  Mail.defaults do
   delivery_method :smtp,
   smtp_options
 end
 mail = Mail.new do
   from "xyzADMIN@example.com"
   to email
   subject "#{subject}"
   body " \n #{body}"
 end
 mail.cc ["cc@xyz.com"]
 mail.deliver
end




def load_check
  load_check = `cat /proc/loadavg |cut -d " " -f 3 `
  load ="#{load_check}".split(" ")
  if load[0].to_i > 20
   load_status = "Load Alert #{load}"
   send_email("xyz LOAD ALERT","chetan.muneshwar@example.com",load_status)
 end		
end
def disk_check
  array=`df -Ph | grep -r '/' | awk '{ printf "%s-%s-%s-%s ",$3,$4,$5,$6  }'`
  bulk_data="#{array}".split(" ")
  bulk_data.each do
    |check|
    $disk = ""
    data="#{check}".split("-")
    max =  data[2]
    if  max.to_i > 90
      $disk = $disk + "Urgent:" + data[3] + ":" + data[2] + ":" +  data[0]  + ":" + data[1] + "," 
      disk_status = "Disk Alert #{$disk}"
      send_email("xyz DISK ALERT","chetan.muneshwar@example.com",disk_status)

    elsif max.to_i < 60 && max.to_i > 75
     p "bang"    
   else
     p "bang"
   end
 end
end

def disk_icheck
  array=`df -Pih | grep -r '/' | awk '{ printf "%s-%s-%s-%s ",$3,$4,$5,$6  }'`
  bulk_data="#{array}".split(" ")
  bulk_data.each do
    |check|
    data="#{check}".split("-")
    max =  data[2]
    if  max.to_i > 75

      $inode = $inode + "Inode-Urgent:" + data[3] + ":" + data[2] + ":" +  data[0]  + ":" + data[1]  
      inode_status = "Disk Inodes Alert #{$inode}"
      send_email("xyz DISK-INODE ALERT","chetan.muneshwar@example.com",inode_status)

    elsif max.to_i < 75 && max.to_i > 50
      p "bang"
    else
     p "bang"
   end
 end
end
def apache_check
  apache_pid = `ps -efa | grep httpd | grep -v grep | awk '{ print $2 }'| xargs |wc -w`
#puts apache_pid.to_i
if  apache_pid.to_i > 1
  p "bang"
else 
  apache_status = "Apache Server Not Running "                 
  send_email("xyz APACHE DOWN","chetan.muneshwar@example.com",apache_status)		
end
end

def mysql_check
  mysql_pid = `ps -efa | grep mysql | grep -v grep | awk '{ print $2 }'| xargs |wc -w` 
  if  mysql_pid.to_i > 1
    p "bang"
  else
    mysql_status = "Mysql Server Not Running "                 
    send_email("xyz MYSQL DOWN","chetan.muneshwar@example.com",mysql_status)
  end
end

def pgsql_check
  pgsql_pid = `ps -efa | grep postgres | grep -v grep | awk '{ print $2 }'| xargs |wc -w` 
  if  pgsql_pid.to_i > 1
    p "bang"
  else
    psql_status = "Postgres Server Not Running "                 
    send_email("xyz POSTGRES DOWN","chetan.muneshwar@example.com",psql_status)
  end
end





def ram_check
	m_array = `free -tom |xargs |cut -d ":" -f 2 |cut -d " " -f 1-7 |xargs`
	mem_array="#{m_array}".split(" ")
  threshold = ( ( mem_array[1].to_i - mem_array[5].to_i - mem_array[4].to_i ) * 100 ) / mem_array[0].to_i 
  if  threshold.to_i > 90
   ram_status = "RAM High Usage #{threshold.to_i}% "                 
   send_email("xyz RAM ALERT","chetan.muneshwar@example.com",ram_status)	
 else
  p "bang"   
end
end
def process_check
  hallow = []
  p_array = `ps -eo pid,comm,%cpu,%mem | awk '{OFS="!"; print $1,$2,$3,$4}' | grep -v 'PID!COMMAND!%CPU!%MEM' |xargs `
  proc_list = "#{p_array}".split(" ")
  proc_list.each do |l|
    k = "#{l}".split("!")
    k.each do |lt|
      if  k[2] != "0.0" or k[3] != "0.0"
       if k[2].to_i > 50 or k[3].to_i > 20 
         hallow << l + "," 
       end
     end
   end
 end
 if hallow.length < 1
  p "bang"
else
 process_status = "Process High Usage To 10 : #{hallow} "                 
 send_email("xyz PROCESSES ALERT","chetan.muneshwar@example.com",process_status)	


end
end
def mail_server_check
  res = `pii postfix |wc -w`
  if res == 0
   mail_server_status = "Mail Server: Not Running "                 
   send_email("xyz MAIL_SERVER DOWN","chetan.muneshwar@example.com",mail_server_status)	
   p "Mail Gone"
 end
end

# simple function ON/OFF will give you sutable choice what to monitor .
# add simple cronjobs 
# crontab -e 
# * * * * * ruby path_to/client.rb
# this is the quick ersonal monitor for server running your important application .

# System defaults

load_check 
ram_check
process_check

# Disk check start here

disk_check
disk_icheck

# Services Start Here

apache_check
mysql_check
pgsql_check
mail_server_check

