# Shell2HTML
A Bash shell script that creates a beautiful, colorful HTML report which contains vital Linux server stats & information.

## Introduction
As a Linux SysAdmin, one of the tasks that you have to do on a regular basis is sending server health-check reports to your Manager(s). While it is not a daunting task, wouldn't it be better if you can spice up the reports to make them more pleasing to your Manager & to you? Reading a boring text file that contains some stats can be really unsatisfying :wink:

So, I created a Bash shell script to generate a rich, vibrant, vividly colored HTML report that has interactive 3D charts & other colorful visual elements that are sure to please you. Nice way to impress your Manager :wink:
You can customise it to include/exclude any of the stats :blush: Put inside a Cron job & configure the destination e-mail address :blush:

## Usage
As with any Shell script, make it executable after cloning/downloading & run as : - 

```bash
shashank@shashank-dbserver:~$ sudo ./shell2html.sh
Report has been generated in /home/shashank/health_reports with file-name = /home/shashank/health_reports/Server-Health-Report-shashank-dbserver-170918-0432.html. Report has also been sent to $email_add.
shashank@shashank-dbserver:~$ 
```
Change ``$email_add`` to your email-address in script.

## Screenshots

Below are the screenshots :

<img src="https://github.com/shashank-ssriva/Shell2HTML/blob/master/shell2html.png" height="400" width="500">

<img src="https://github.com/shashank-ssriva/Shell2HTML/blob/master/shell2html2.png" height="400" width="450">

<img src="https://github.com/shashank-ssriva/Shell2HTML/blob/master/shell2html3.png" height="400" width="500">

## YouTube Demo Video

Click below thumbnail to watch the demo video  

<a href="http://www.youtube.com/watch?feature=player_embedded&v=https://youtu.be/jgG5UN6geUE
" target="_blank"><img src="http://img.youtube.com/vi/jgG5UN6geUE/0.jpg" 
alt="lognotify YourTube demo video" width="480" height="360" border="10" /></a>
