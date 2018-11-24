#ifndef SECBOX_LOG
#define SECBOX_LOG
#include <syslog.h>
#include <pthread.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>       /* time_t, struct tm, time, localtime, asctime */

#ifdef __cplusplus
extern "C" {
#endif

#define testmax(x,y)	(x>y) ? x : y;
#define testmin(x,y)	(x<y) ? x : y;


//#define THREAD_SAFE

#ifdef THREAD_SAFE111
 extern pthread_mutex_t	g_logLock;
 #define LOG_LOCK		pthread_mutex_lock(&g_logLock)
 #define LOG_UNLOCK	pthread_mutex_unlock(&g_logLock)
#else
 #define LOG_LOCK
 #define LOG_UNLOCK
#endif


#define MAX_BUF 1000			//whole message, including headers
#define MAX_HEADERS 300         //headers only
#define SIZE_OF_PRORAM_NAME (124)

extern unsigned int gLogLevel;
extern unsigned int bleLogLevel;
extern unsigned int gBoxID;
extern char gMsg[MAX_BUF];
extern const char* gLogLevels[8];

void setLogLevel(unsigned int level);
void setBleLogLevel(unsigned int level);
unsigned int getLogLevel();
void setBoxID(unsigned int boxId);
unsigned int getBoxID();
void logStart(char* fileName, unsigned int level, unsigned int boxId);
void logStop();
void buildLogMsg(unsigned int level, int offset, const char *fmt,  ...);

#define msgInfo(transaction, ...) {  \
	LOG_LOCK; \
	if(gLogLevel >= LOG_INFO) { \
		time_t log_now = time(NULL); \
		struct tm log_now_time = *localtime(&log_now); \
		int offset = snprintf(gMsg,MAX_HEADERS, "%d-%.2d-%.2d %.2d:%.2d:%.2d [%u] [%u] [%s] [%lu] [%d] [%s:%d] ", \
			log_now_time.tm_year + 1900, log_now_time.tm_mon + 1, log_now_time.tm_mday, \
			log_now_time.tm_hour, log_now_time.tm_min, log_now_time.tm_sec, \
			gBoxID, transaction,  gLogLevels[LOG_INFO], \
			pthread_self(), getpid(), __PRETTY_FUNCTION__, __LINE__ ); \
			offset = testmax(0,offset); \
			offset = testmin(MAX_HEADERS,offset); \
			buildLogMsg(LOG_INFO, offset, __VA_ARGS__); \
	} \
	LOG_UNLOCK; \
 }

#define msgErr(transaction, ...) { \
	LOG_LOCK; \
	if(gLogLevel >= LOG_ERR) { \
		time_t log_now = time(NULL); \
		struct tm log_now_time = *localtime(&log_now); \
		int offset = snprintf(gMsg,MAX_HEADERS, "%d-%.2d-%.2d %.2d:%.2d:%.2d [%u] [%u] [%s] [%lu] [%d] [%s:%d] ", \
			log_now_time.tm_year + 1900, log_now_time.tm_mon + 1, log_now_time.tm_mday, \
			log_now_time.tm_hour, log_now_time.tm_min, log_now_time.tm_sec, \
			gBoxID, transaction, gLogLevels[LOG_ERR], \
			(unsigned long) pthread_self(), getpid(),  __PRETTY_FUNCTION__, __LINE__ ); \
			offset = testmax(0,offset); \
			offset = testmin(MAX_HEADERS,offset); \
			buildLogMsg(LOG_ERR, offset, __VA_ARGS__); \
	} \
	LOG_UNLOCK; \
 }

#define msgDbg(transaction, ...) { \
	LOG_LOCK; \
	if(gLogLevel >= LOG_DEBUG) { \
		 time_t log_now = time(NULL); \
		 struct tm log_now_time = *localtime(&log_now); \
		int offset = snprintf(gMsg,MAX_HEADERS, "%d-%.2d-%.2d %.2d:%.2d:%.2d [%u] [%u] [%s] [%lu] [%d] [%s:%d] ", \
			log_now_time.tm_year + 1900, log_now_time.tm_mon + 1, log_now_time.tm_mday, \
			log_now_time.tm_hour, log_now_time.tm_min, log_now_time.tm_sec, \
			gBoxID, transaction, gLogLevels[LOG_DEBUG], \
			(unsigned long) pthread_self(), getpid(), __PRETTY_FUNCTION__, __LINE__ ); \
			offset = testmax(0,offset); \
			offset = testmin(MAX_HEADERS,offset); \
			buildLogMsg(LOG_DEBUG, offset, __VA_ARGS__); \
	} \
	LOG_UNLOCK; \
 }

#define bleMsgDbg(transaction, ...) { \
	LOG_LOCK; \
	if(bleLogLevel >= LOG_DEBUG) { \
		int offset = snprintf(gMsg,MAX_HEADERS, "[%u] [%u] [%s] [%lu] [%d] [%s:%d] ", \
			gBoxID, transaction, gLogLevels[LOG_DEBUG], \
			(unsigned long) pthread_self(), getpid(), __PRETTY_FUNCTION__, __LINE__ ); \
			offset = testmax(0,offset); \
			offset = testmin(MAX_HEADERS,offset); \
			buildLogMsg(LOG_DEBUG, offset, __VA_ARGS__); \
	} \
	LOG_UNLOCK; \
 }

#define msgWarn(transaction, ...) { \
	LOG_LOCK; \
	if(gLogLevel >= LOG_WARNING) {\
		time_t log_now = time(NULL); \
		struct tm log_now_time = *localtime(&log_now); \
		int offset = snprintf(gMsg,MAX_HEADERS, "%d-%.2d-%.2d %.2d:%.2d:%.2d [%u] [%u] [%s] [%lu] [%d] [%s:%d] ", \
			log_now_time.tm_year + 1900, log_now_time.tm_mon + 1, log_now_time.tm_mday, \
			log_now_time.tm_hour, log_now_time.tm_min, log_now_time.tm_sec, \
			gBoxID, transaction, gLogLevels[LOG_WARNING], \
			(unsigned long) pthread_self(), getpid(), __PRETTY_FUNCTION__, __LINE__ ); \
			offset = testmax(0,offset); \
			offset = testmin(MAX_HEADERS,offset); \
			buildLogMsg(LOG_WARNING, offset, __VA_ARGS__);\
	} \
	LOG_UNLOCK; \
 }

#ifdef __cplusplus
}
#endif

#endif
