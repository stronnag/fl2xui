#include <windows.h>
#include <wchar.h>
#include <tchar.h>
#include <stdio.h>
#include <strsafe.h>
#include <io.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdbool.h>

#define BUFSIZE 4096

unsigned int get_exe_path(char*buf, unsigned int blen) {
     return GetModuleFileName(NULL, buf, blen);
}

HANDLE create_win_process(char *cmd, int *wrout) {
     PROCESS_INFORMATION piProcInfo;
     STARTUPINFO siStartInfo;
     bool bSuccess;
     int opipes[2];

     pipe(opipes);

     HANDLE ohandle = (HANDLE)_get_osfhandle(opipes[1]);
     memset(&piProcInfo, 0, sizeof(PROCESS_INFORMATION) );
     memset( &siStartInfo, 0, sizeof(STARTUPINFO) );
     siStartInfo.cb = sizeof(STARTUPINFO);
     siStartInfo.hStdError = ohandle;
     siStartInfo.hStdOutput = ohandle;
     siStartInfo.dwFlags |= STARTF_USESTDHANDLES|STARTF_USESHOWWINDOW;
     siStartInfo.wShowWindow = SW_HIDE;

     bSuccess = CreateProcess(NULL,
			      cmd,     // command line
			      NULL,          // process security attributes
			      NULL,          // primary thread security attributes
			      TRUE,          // handles are inherited
			      0,             // creation flags
			      NULL,          // use parent's environment
			      NULL,          // use parent's current directory
			      &siStartInfo,  // STARTUPINFO pointer
			      &piProcInfo);  // receives PROCESS_INFORMATION

     *wrout = opipes[0];
     close(opipes[1]);
     if (bSuccess ) {
	  CloseHandle(piProcInfo.hThread);
     } else {
	  close(opipes[0]);
     }
     return piProcInfo.hProcess;
}

void waitproc(HANDLE h) {
     if(h != NULL) {
	  WaitForSingleObject(h, INFINITE);
	  CloseHandle(h);
    }
}

#ifdef TEST
void read_pipes (int  hout) {
     size_t nr;
     char buf[BUFSIZE+1];

   for (;;) {
	nr = read(hout, buf, BUFSIZE);
	if(nr <= 0 ) break;
	buf[nr] = 0;
	printf("%s", buf);
   }
}

int main(int argc, char *argv[])
{
     int opipe;
     if (argc < 2) {
	  fprintf(stderr, "Please specify a command to run.\n");
	  exit(1);
     }
     create_win_process(argv[1], &opipe);
     read_pipes(opipe);
     printf("->End of parent execution.\n");
     close(opipe);
     return 0;
}
#endif
