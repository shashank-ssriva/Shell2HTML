#! /bin/bash
#Author : - Shashank Srivastava
#Date : - 18 September, 2017

#Checking if this script is being executed as ROOT. For maintaining proper directory structure, this script must be run from a root user.
if [ $EUID != 0 ]
then
  echo "Please run this script as root so as to see all details! Better run with sudo."
  exit 1
fi

#Declaring variables
#set -x
os_name=`uname -v | awk {'print$1'} | cut -f2 -d'-'`
upt=`uptime | awk {'print$3'} | cut -f1 -d','`
ip_add=`ifconfig | grep "inet addr" | head -2 | tail -1 | awk {'print$2'} | cut -f2 -d:`
num_proc=`ps -ef | wc -l`
root_fs_pc=`df -h /dev/sda1 | tail -1 | awk '{print$5}'`
root_fs_pc_numeric=`df -h /dev/sda1 | tail -1 | awk '{print$5}' | cut -f1 -d'%'`
total_root_size=`df -h /dev/sda1 | tail -1 | awk '{print$2}'`
#load_avg=`uptime | cut -f5 -d':'`
load_avg=`cat /proc/loadavg  | awk {'print$1,$2,$3'}`
ram_usage=`free -m | head -2 | tail -1 | awk {'print$3'}`
ram_total=`free -m | head -2 | tail -1 | awk {'print$2'}`
ram_pc=`echo "scale=2; $ram_usage / $ram_total * 100" | bc | cut -f1 -d '.'`
inode=`df -i / | head -2 | tail -1 | awk {'print$5'}`
inode_numeric=`df -i / | head -2 | tail -1 | awk {'print$5'} | cut -f1 -d '%'`
os_version=`uname -v | cut -f2 -d'~' | awk {'print$1'} | cut -f1 -d'-' | cut -c 1-5`
num_users=`who | wc -l`
cpu_free=`top b -n1 | head -5 | head -3 | tail -1 | awk '{print$8}' | cut -f1 -d ','`
last_reboot=`who -b | awk '{print$3, $4}'`

#Creating a directory if it doesn't exist to store reports first, for easy maintenance.
if [ ! -d ${HOME}/health_reports ]
then
  mkdir ${HOME}/health_reports
fi
html="${HOME}/health_reports/Server-Health-Report-`hostname`-`date +%y%m%d`-`date +%H%M`.html"
email_add="change this to yours"
for i in `ls /home`; do sudo du -sh /home/$i/* | sort -nr | grep G; done > /tmp/dir.txt
ps aux | awk '{print$2, $4, $6, $11}' | sort -k3rn | head -n 10 > /tmp/memstat.txt
top b -n1 | head -17 | tail -11 | awk '{print $1, $2, $9, $12}' | grep -v PID > /tmp/cpustat.txt
#Generating HTML file
echo "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">" >> $html
echo "<html>" >> $html
echo "<head>" >> $html
echo "<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">" >> $html
echo "<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">" >> $html
echo "<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>" >> $html
echo "<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>" >> $html
echo -e "<script type="text/javascript">
google.charts.load('current', {'packages':['gauge']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {

  var data = google.visualization.arrayToDataTable([
  ['Label', 'Value'],
  ['# of Processes', $num_proc],
  ['# of Users', $num_users]
  ]);

  var options = {
    width: 600, height: 175,
    redFrom: 90, redTo: 100,
    yellowFrom:75, yellowTo: 90,
    minorTicks: 5
  };

  var chart = new google.visualization.Gauge(document.getElementById('chart_div'));

  chart.draw(data, options);
}
</script>" >> $html
echo "<link rel="stylesheet" href="https://unpkg.com/purecss@0.6.2/build/pure-min.css">" >> $html
echo "<body>" >> $html
echo "<fieldset>" >> $html
echo "<center>" >> $html
echo "<h2><span class=\"label label-primary\">Linux Server Report : `hostname`</span></h2>" >> $html
echo "<h3><legend>Script authored by Shashank Srivastava</legend></h3>" >> $html
echo "</center>" >> $html
echo "</fieldset>" >> $html
echo "<br>" >> $html
echo "<center>" >> $html
echo "<h2><span class=\"label label-warning\">Last Rebooted :</span></h2>" >> $html
echo "<h3><span class=\"label label-danger\">$last_reboot</span></h3>" >> $html
echo "</center>" >> $html
echo "<br>" >> $html
echo "<center>" >> $html
echo "<h2><span class=\"label label-success\">OS Details : </span></h2>" >> $html
echo "<br>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>OS Name</th>" >> $html
echo "<th>OS Version</th>" >> $html
echo "<th>IP Address</th>" >> $html
echo "<th>Uptime</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$os_name</td>" >> $html
echo "<td>$os_version</td>" >> $html
echo "<td>$ip_add</td>" >> $html
echo "<td>$upt</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<h2><span class=\"label label-primary\">Resources Utilization : </span></h2>" >> $html
echo "<br>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th># of Processes</th>" >> $html
echo "<th>Root FS Usage</th>" >> $html
echo "<th>Total Size of Root FS</th>" >> $html
echo "<th>Load Average</th>" >> $html
echo "<th>Used RAM(in MB)</th>" >> $html
echo "<th>Total RAM(in MB)</th>" >> $html
echo "<th>iNode Status</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td><center>$num_proc</center></td>" >> $html
echo "<td><center>$root_fs_pc</center></td>" >> $html
echo "<td><center>$total_root_size</center></td>" >> $html
echo "<td><center>$load_avg</center></td>" >> $html
echo "<td><center>$ram_usage</center></td>" >> $html
echo "<td><center>$ram_total</center></td>" >> $html
echo "<td><center>$inode</center></td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<h2><span class=\"label label-danger\">Culprit Directories(Eating up disk space) : </span></h2>" >> $html
echo "<br>" >> $html
echo "<table class=\"pure-table pure-table-bordered\">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Size</th>" >> $html
echo "<th>Name</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
while read size name;
do
  echo "<td>$size</td>" >> $html
  echo "<td>$name</td>" >> $html
  echo "</tr>" >> $html
done < /tmp/dir.txt
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<br>" >> $html
echo "<h2><span class=\"label label-info\">Top Memory Consuming Processes : </span></h2>" >> $html
echo "<br>" >> $html
echo "<table class=\"pure-table pure-table-bordered\">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>PID</th>" >> $html
echo "<th>%RAM</th>" >> $html
echo "<th>Resident Memory (KB)</th>" >> $html
echo "<th>Command Name</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
while read pid ram resident pname;
do
  echo "<td>$pid</td>" >> $html
  echo "<td>$ram</td>" >> $html
  echo "<td>$resident</td>" >> $html
  echo "<td>$pname</td>" >> $html
  echo "</tr>" >> $html
done < /tmp/memstat.txt
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<br>" >> $html
echo "<h2><span class=\"label label-primary\">Top CPU Consuming Processes : </span></h2>" >> $html
echo "<br>" >> $html
echo "<table class=\"pure-table pure-table-bordered\">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>PID</th>" >> $html
echo "<th>User</th>" >> $html
echo "<th>%CPU</th>" >> $html
echo "<th>Command Name</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
while read pid_cpu user cpu_prc cpu_cmd_name;
do
  echo "<td>$pid_cpu</td>" >> $html
  echo "<td>$user</td>" >> $html
  echo "<td>$cpu_prc</td>" >> $html
  echo "<td>$cpu_cmd_name</td>" >> $html
  echo "</tr>" >> $html
done < /tmp/cpustat.txt
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<br>" >> $html
echo "<h2><span class=\"label label-primary\">Pictorial Data : </span></h2>" >> $html
echo "<center><div id="chart_div"></div></center>" >> $html
echo -e "<br>
<div class=\"panel panel-primary\" style=\"width: 40%;\">
<div class=\"panel-heading\">
<h3 class=\"panel-title\">Resources Overview</h3>
</div>
<div class=\"panel-body\">
<b>Root Filesystem</b>
<div class=\"progress\" style=\"width: 55%;\">" >> $html
#set -x
if [ $root_fs_pc_numeric -ge 85 ]
then
  echo "<div class=\"progress-bar progress-bar-danger progress-bar-striped\" role=\"progressbar\" aria-valuenow="60" aria-valuemin=\"0\" aria-valuemax="100" style=\"width: $root_fs_pc;\">" >> $html
else
  echo "<div class=\"progress-bar progress-bar-info progress-bar-striped\" role=\"progressbar\" aria-valuenow="60" aria-valuemin=\"0\" aria-valuemax="100" style=\"width: $root_fs_pc;\">" >> $html
fi
echo "$root_fs_pc" >> $html
echo -e "</div>
</div>
<b>Memory</b>
<div class="progress" style=\"width: 55%;\"> " >> $html
if [ $ram_pc -ge 90 ]
then
  echo "<div class=\"progress-bar progress-bar-danger progress-bar-striped\" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style=\"width: $ram_pc%;\">" >> $html
else
  echo "<div class=\"progress-bar progress-bar-info progress-bar-striped\" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style=\"width: $ram_pc%;\">" >> $html
fi
echo "$ram_pc%" >> $html
echo -e "</div>
</div>
<b>CPU Free</b>
<div class="progress" style=\"width: 55%;\"> " >> $html
if [ $cpu_free -le 50 ]
then
  echo "<div class=\"progress-bar progress-bar-danger progress-bar-striped\" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style=\"width: $cpu_free%;\"> " >> $html
else
  echo "<div class=\"progress-bar progress-bar-info progress-bar-striped\" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style=\"width: $cpu_free%;\"> " >> $html
fi
echo "$cpu_free%" >> $html
echo -e "</div>
</div>
<b>iNodes</b>
<div class="progress" style=\"width: 55%;\"> " >> $html
if [ $inode_numeric -gt 90 ]
then
echo "<div class=\"progress-bar progress-bar-danger progress-bar-striped\" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style=\"width: $inode;\"> " >> $html
else
  echo "<div class=\"progress-bar progress-bar-info progress-bar-striped\" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style=\"width: $inode;\"> " >> $html
fi
echo "$inode" >> $html
echo -e "</div>
</div>
</div>
</div>" >> $html
echo "</body>" >> $html
echo "</html>" >> $html
echo "Report has been generated in ${HOME}/health_reports with file-name = $html. Report has also been sent to $email_add."
#Sending Email to the user
cat $html | mail -s "`hostname` - Daily System Health Report" -a "MIME-Version: 1.0" -a "Content-Type: text/html" -a "From: Shashank Srivastava <root@shashank.com>" $email_add
