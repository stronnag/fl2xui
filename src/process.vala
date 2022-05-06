
class ProcessLauncher : Object {
	public signal void result(string? d);
	public signal void complete(string? d);

	public bool run(string[]? argv, string? winpath=null) {
		try {
			var p = new Subprocess.newv(argv, SubprocessFlags.STDOUT_PIPE|SubprocessFlags.STDERR_MERGE);
			var std1 = p.get_stdout_pipe();
			p.wait_check_async.begin(null, (obj,res) => {
					try {
						p.wait_check_async.end (res);
						complete(null);
					} catch (Error e) {
						complete(null);
					}
				});

			var ds1 = new DataInputStream(std1);
			queue_read(ds1);
		} catch(Error e) {
			stderr.printf("SUBP: %s %s\n", argv[0],  e.message);
			complete(null);
			return false;
		}
		return true;
	}

	private void queue_read(DataInputStream ds) {
		ds.read_line_utf8_async.begin(Priority.DEFAULT, null,  (obj,res) => {
				try {
					var s = ds.read_line_utf8_async.end(res);
					if(s != null) {
						result("%s\n".printf(s));
						queue_read(ds);
					} else {
					}
				} catch (Error e) {
				}
			});
	}
}

#if TEST
static int main(string[]? args) {

	var p = new ProcessLauncher();
	var m = new MainLoop();
	p.result.connect((s) => {
			print("%s\n", s);
		});

	p.complete.connect((s) => {
			if(s != null) {
				print("%s\n", s);
			}
			m.quit();
		});

	Idle.add(() => {
			p.run(args[1:]);
			return false;
		});
	m.run();
	return 0;
}
#endif
