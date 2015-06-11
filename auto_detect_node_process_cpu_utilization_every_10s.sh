#!/bin/bash
####本脚本用来每10s监测一次node进程的cpu使用率，当cpu使用率超过70%，则reload当前进程，防止某个阻塞操作引起整个node服务不可用
####可以后台daemon运行本脚本，同时结合crontab定期监测本脚本是否正常运行
####coding by laijingli 
####20150611

node_process_detect_log=/var/log/node_process_detect.log
node_process_snap=/tmp/.current_node_process_snap.tmp

function_node_process_detect () {
	###获取node进程信息
	ps aux|grep node|grep -v grep|grep -v $0 > $node_process_snap
	#echo  "监测前node process info:"
	#cat $node_process_snap
	#echo -----------------------------------------------------------
 
	###根据获取的node进程信息快照进行阈值判断
	awk    '{ 
		if($3 > 70){
			###reload 对应node服务
			print "################"
			system("date")
			print $0
			print "Warning: "$NF " cpu utilization is "$3"% greater than 70%,it will reload"
			system("/etc/init.d/restart_node_recluster.sh reload "$NF)
			}
			else{
			#print "Normal"
			}
		}' $node_process_snap
	
	#echo -----------------------------------------------------------
	#ps aux|grep node|grep -v grep|grep -v $0 > $node_process_snap	
	#echo  "监测后node process info:"
	#cat $node_process_snap

}

###loop
while true ;do 
	function_node_process_detect  >> $node_process_detect_log
	#function_node_process_detect |tee -a $node_process_detect_log
	#echo
	#echo
	#echo sleep 10s...
	sleep 10
	#echo "###########################################################"
done

