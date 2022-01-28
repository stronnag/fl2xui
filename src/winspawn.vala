extern bool create_win_process(char *cmd, int *opipe);

class ProcessLauncher : Object {
	public signal void result(string? d);
	public signal void complete(string? d);

	public void run(string[]? argv) {
		int opipe[2];
		var sb = new StringBuilder();
		foreach(var a in argv) {
			sb.append_c('"');
			sb.append(a);
			sb.append("\" ");
		}
		var cmd = sb.str.strip();
		Posix.pipe(opipe);
		var res = create_win_process(cmd, opipe);
		if (res) {
			ThreadFunc<bool>  trun = () => {
				size_t nr;
				uchar buf[1024];
				while((nr = Posix.read(opipe[0], buf, 1023)) > 0) {
					buf[nr] = 0;
					var s = (string)buf;
					Idle.add(() => { result(s); return false; });
				}
				Idle.add(() => { complete(null); return false; });
				return true;
			};
			new Thread<bool>("trun", (owned)trun);
		}
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
			p.run(args[1:]);
			return false;
		});
	m.run();
	return 0;
}
#endif
