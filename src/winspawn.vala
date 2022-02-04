extern void *create_win_process(char *cmd, int *opipe);
extern uint get_exe_path(char *buf, uint blen);
extern void waitproc(void *h);



class ProcessLauncher : Object {
	public signal void result(string? d);
	public signal void complete(string? d);
	private int opipe;

	public static string? get_exe_dir() {
		char buf[4096];
		if (get_exe_path(buf, 4096) > 0) {
			return  Path.get_dirname((string)buf);
		} else {
			return null;
		}
	}

	public bool run(string[]? argv) {
		var sb = new StringBuilder();
		foreach(var a in argv) {
			if(a.contains(" ")) {
				sb.append_c('"');
			}
			sb.append(a);
			if(a.contains(" ")) {
				sb.append_c('"');
			}
			sb.append_c(' ');
		}
		var cmd = sb.str.strip();
		opipe=-1;
		var res = create_win_process(cmd, &opipe);
		if (res != null) {
			ThreadFunc<bool>  wrun = () => {
				waitproc(res);
				windone();
				return true;
			};
			new Thread<bool>("wrun", (owned)wrun);

			ThreadFunc<bool>  trun = () => {
				size_t nr;
				uchar buf[1024];
				while((nr = Posix.read(opipe, buf, 1023)) > 0) {
					buf[nr] = 0;
					var s = (string)buf;
					Idle.add(() => { result(s); return false; });
				}
				Posix.close(opipe);
				return true;
			};
			new Thread<bool>("trun", (owned)trun);
		}
		return (res != null);
	}

	private void windone(string? s=null) {
		Idle.add(() => {
				complete(s);
				return false;
			});
	}
}

#if TEST

extern  unowned string  __progname;
static int main(string[]? args) {
	print("I'm %s\n", __progname);
	print("I'm here %s\n", Environment.get_current_dir ());
	print("I'm on %s\n", Environment.get_os_info(OsInfoKey.NAME));
	print("I'm aka %s\n", Environment.get_os_info(OsInfoKey.PRETTY_NAME));

	if (args.length < 2)
		return 0;

	var p = new ProcessLauncher();
	var m = new MainLoop();
	p.result.connect((s) => {
			print("%s", s);
		});

	p.complete.connect((s) => {
			if(s != null) {
				print("%s\n", s);
			}
			Idle.add(() => {
					m.quit();
					return false;
				});
		});

	Idle.add(() => {
			if (p.run(args[1:]) == false) {
				m.quit();
			}
			return false;
		});
	m.run();
	return 0;
}
#endif
