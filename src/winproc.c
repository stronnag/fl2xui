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

HANDLE create_win_process(char *cmd, int *wrout, bool winui) {
     PROCESS_INFORMATION piProcInfo;
     STARTUPINFO siStartInfo;
     bool bSuccess;
     int opipes[2];
     HANDLE ohandle;
     if (!winui) {
	  _pipe(opipes, 4096,_O_BINARY);
	  ohandle = (HANDLE)_get_osfhandle(opipes[1]);
     }
     memset(&piProcInfo, 0, sizeof(PROCESS_INFORMATION) );
     memset( &siStartInfo, 0, sizeof(STARTUPINFO) );
     siStartInfo.cb = sizeof(STARTUPINFO);

     if (!winui) {
	  siStartInfo.wShowWindow = SW_HIDE;
	  siStartInfo.hStdError = ohandle;
	  siStartInfo.hStdOutput = ohandle;
	  siStartInfo.dwFlags |= STARTF_USESTDHANDLES|STARTF_USESHOWWINDOW;
     }


#ifdef TEST
     printf("Running %s from %d\n", cmd, winui);
#endif
     bSuccess = CreateProcess(NULL,
			      cmd,     // command line
			      NULL,          // process security attributes
			      NULL,          // primary thread security attributes
			      TRUE,          // handles are inherited
			      0,             // creation flags
			      NULL,          // use parent's environment
			      NULL,          // current directory
			      &siStartInfo,  // STARTUPINFO pointer
			      &piProcInfo);  // receives PROCESS_INFORMATION

     if (!winui) {
	  *wrout = opipes[0];
	  close(opipes[1]);
     }
     if (bSuccess ) {
	  CloseHandle(piProcInfo.hThread);
     } else {
	  if (!winui) {
	       close(opipes[0]);
	  }
     }
#ifdef TEST
     printf("Startup %p %d\n", piProcInfo.hProcess, bSuccess);
#endif
     return piProcInfo.hProcess;
}

void waitproc(HANDLE h) {
     if(h != NULL) {
	  WaitForSingleObject(h, INFINITE);
#ifdef TEST
	  long unsigned int sts;
	  bool res = GetExitCodeProcess(h, &sts);
	  printf("Ends with %lu, %d\n", sts, res);
#endif
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
     int opipe = -1;
     char *cmd = "C:\\Program Files\\Google\\Google Earth Pro\\client\\googleearth.exe \"C:\\Users\\win10\\Documents\\KML Logs\\Talon_R9M-2019-05-18.2.kmz\"";
//     char *winpath = "C:\\Program Files\\Google\\Google Earth Pro\\client";
     HANDLE h = create_win_process(cmd, &opipe, true);
     if (opipe != -1) {
	  read_pipes(opipe);
     }
     waitproc(h);
     printf("->End of parent execution.\n");
     close(opipe);
     return 0;
}
#endif
