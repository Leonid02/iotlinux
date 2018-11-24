#include <stdio.h>
#include "logger.h"
#include <string>

class TestLogClass {
public:
	TestLogClass() {}
	~TestLogClass() {}
	void printInfo(const char* str);
	void printErr();
	void printDebug(int var);
	void printWarn(float var);
};

void TestLogClass::printInfo(const char* str) {
	msgInfo(1, "This is INFO msg with val:%s", str);
}

void TestLogClass::printErr() {
	msgErr(1, "Error happened at line: %d", __LINE__);
}

void TestLogClass::printDebug(int var) {
	msgDbg(1, "Var's value: %d", var);
}

void TestLogClass::printWarn(float var) {
	msgWarn(1, "Var's value is too less: %f", var);
}

int main(int argc, char **argv) {
	int iVar = 10;
	float fVar = 5.0;
	const char* sVar = "Hello from SecBoxLog";
	TestLogClass obj;

	std::string msg = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";





	logStart("logger_test", 5, 5);
	setLogLevel(LOG_DEBUG);


	for (int i=0;1<1000000; i++)
	{
		msgDbg(1, "Var's value: %s", msg.c_str());
	}



	obj.printInfo(sVar);
	obj.printErr();
	obj.printDebug(iVar);
	obj.printWarn(fVar);

	setLogLevel(LOG_DEBUG);
	obj.printInfo("After Log Level set to Debug");
	obj.printDebug(100);
	msgWarn(1, "This is WARNING STRING without params");
	logStop();
	return 0;
}
