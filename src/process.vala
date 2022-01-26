
class ProcessLauncher : Object {
	public signal void result(string? d);
	public signal void complete(string? d);

	public void run(string[]? argv) {
		try {
			var p = new Subprocess.newv(argv,
										SubprocessFlags.STDOUT_PIPE|
										SubprocessFlags.STDERR_PIPE);
			var std1 = p.get_stdout_pipe();
			p.wait_check_async.begin(null, (obj,res) => {
					try {
						p.wait_check_async.end (res);
						complete(null);
					} catch (Error e) {
//						stderr.printf("WASN: %s\n", e.message);
						var std2 = p.get_stderr_pipe();
						uint8 buffer[4096];
						size_t bs;
						try {
							std2.read_all(buffer, out bs);
						} catch {}
						complete((string)buffer);
					}
				});

			var ds1 = new DataInputStream(std1);
			queue_read(ds1);
		} catch(Error e) {
			stderr.printf("SUBP: %s\n", e.message);
		}
	}

	private void queue_read(DataInputStream ds) {
		ds.read_line_utf8_async.begin(Priority.DEFAULT, null,  (obj,res) => {
				try {
					var s = ds.read_line_utf8_async.end(res);
					if(s != null) {
						result(s);
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
