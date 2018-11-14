#include <stdarg.h>
#include <string>
#include "logger.h"
#include <cstring>



#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <errno.h>


#ifdef THREAD_SAFE111
 pthread_mutex_t	g_logLock;
 #define LOG_LOCK_INIT	pthread_mutex_init(&g_logLock, NULL)
 #define LOG_LOCK_DESTROY pthread_mutex_destroy(&g_logLock)
#else
 #define LOG_LOCK_INIT	
 #define LOG_LOCK_DESTROY
#endif



int gIsOpen = 0;
unsigned int gLogLevel = LOG_WARNING;
unsigned int bleLogLevel = LOG_WARNING;
unsigned int gBoxID;
va_list gVAList;
char gMsg[MAX_BUF];
const char* gLogLevels[8] = { "LOG_EMERG", "LOG_ALERT", "LOG_CRIT", "LOG_ERR", "LOG_WARNING", "LOG_NOTICE", 
		"LOG_INFO", "LOG_DEBUG" };

void logStart(char* fileName, unsigned int level, unsigned int boxId) {
	LOG_LOCK_INIT;
	if(gIsOpen) {
		LOG_UNLOCK;
		return;
	}

	gLogLevel = level;
	gBoxID = boxId;
	openlog(fileName, 0, LOG_USER);
	gIsOpen = 1;
	LOG_UNLOCK;
}

void logStop() {

	LOG_LOCK;
	if(!gIsOpen) {
		LOG_UNLOCK;
		return;
	}
	closelog();
	gIsOpen = 0;
	LOG_UNLOCK;
	LOG_LOCK_DESTROY;
}

void setLogLevel(unsigned int level) {
	LOG_LOCK;
	gLogLevel = level;
	LOG_UNLOCK;
}

void setBleLogLevel(unsigned int level) {
	LOG_LOCK;
	bleLogLevel = level;
	LOG_UNLOCK;
}

unsigned int getLogLevel() {
	return gLogLevel;
}

void setBoxID(unsigned int boxId) {
	LOG_LOCK;
	gBoxID = boxId;
	LOG_UNLOCK;
}

unsigned int getBoxID() { 
	return gBoxID;
}

void sendToUDPSocket(char* buf, int len)
{

	int sockfd;
	struct sockaddr_in	servaddr;

	// Creating socket file descriptor
	if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) {
		return;
	}
	memset(&servaddr, 0, sizeof(servaddr));

	// Filling server information
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(PORT_SYSLOG);
	servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");

	if(sendto(sockfd, buf, len,MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)) < 0){
		printf("could not send to socket!!  %s\n", strerror(errno));

	}
	close(sockfd);
}

void buildLogMsg(unsigned int level, int offset, const char* fmt, ...) {
	va_start(gVAList, fmt);
	int n=vsnprintf((char*) gMsg+offset,MAX_BUF-MAX_HEADERS, fmt, gVAList);
	va_end(gVAList);
	std::string str(gMsg);
	//printf("buildLogMsg %d msg_actual_size=%lu [%s]\n",n,str.size(),str.c_str());
	sendToUDPSocket(str.c_str(),str.size());
	//syslog(level, gMsg);
}
///
