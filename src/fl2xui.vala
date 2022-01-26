using Gtk;

public class MyApplication : Gtk.Application {
    private Gtk.ApplicationWindow window;
	private Prefs.Prefs prefs;
	private Gtk.CheckButton dms_check;
	private Gtk.CheckButton rssi_check;
	private Gtk.CheckButton extrude_check;
	private Gtk.CheckButton kml_check;
	private Gtk.CheckButton effic_check;
	private Gtk.ComboBoxText grad_combo;
	private Gtk.Entry idx_entry;
	private Gtk.Button runbtn;
	private Gtk.Button outbtn;
	private Gtk.Button logbtn;
	private Gtk.Button missionbtn;
	private Gtk.TextView textview;
	private Gtk.Entry lognames;
	private Gtk.Entry missionname;
	private Gtk.ProgressBar pbar;
	private string outdir;

	public static bool show_version;


	const OptionEntry[] options = {
		{ "version", 'v', 0, OptionArg.NONE, out show_version, "show version", null},
		{null}
	};

    public MyApplication () {
        Object(application_id: "org.stronnag.fl2xui",
               flags:ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        Builder builder;
        builder = new Builder.from_resource("/org/stronnag/fl2xui/fl2xui.ui");
		prefs = Prefs.read_prefs();
		builder.connect_signals (null);
        window = builder.get_object ("appwin") as Gtk.ApplicationWindow;
		dms_check = builder.get_object("dms_check") as Gtk.CheckButton;
		dms_check.active = prefs.dms;
		rssi_check = builder.get_object("rssi_check") as Gtk.CheckButton;
		rssi_check.active = prefs.rssi;
		extrude_check = builder.get_object("extrude_check") as Gtk.CheckButton;
		extrude_check.active = prefs.extrude;
		kml_check = builder.get_object("kml_check") as Gtk.CheckButton;
		kml_check.active = prefs.kml;
		effic_check = builder.get_object("effic_check") as Gtk.CheckButton;
		effic_check.active = prefs.effic;
		grad_combo =  builder.get_object("grad_combo") as Gtk.ComboBoxText;
		if(prefs.gradient != null) {
			grad_combo.active_id = prefs.gradient;
		}
		idx_entry =  builder.get_object("idx_entry") as Gtk.Entry;
		runbtn = builder.get_object("runbtn") as Gtk.Button;
		outbtn = builder.get_object("out_btn") as Gtk.Button;
		logbtn = builder.get_object("log_btn") as Gtk.Button;
		missionbtn = builder.get_object("mission_btn") as Gtk.Button;
		textview = builder.get_object("textview") as Gtk.TextView;

		lognames =  builder.get_object("log_label") as Gtk.Entry;
		missionname =  builder.get_object("mission_label") as Gtk.Entry;
		pbar =  builder.get_object("pbar") as Gtk.ProgressBar;
		window.set_default_size(600,480);
		this.add_window (window);
        window.set_application (this);

        window.destroy.connect( () => {
                quit();
            });

        window.set_icon_name("fl2xui");
		runbtn.sensitive = false;
		connect_signals();
        window.show_all ();
    }

	private void connect_signals() {
		runbtn.clicked.connect(() => {
				runbtn.sensitive = false;
				run_generator();
			});
		logbtn.clicked.connect (() => {
				var chooser = new Gtk.FileChooserNative (
					"Log file", window, Gtk.FileChooserAction.OPEN,
					"_Open", "_Cancel");
				Gtk.FileFilter filter = new Gtk.FileFilter ();
				filter.set_filter_name("All Logs");
				filter.add_pattern("*.bbl");
				filter.add_pattern("*.BBL");
				filter.add_pattern("*.TXT");
				filter.add_pattern("*.txt");
				filter.add_pattern("*.csv");
				filter.add_pattern("*.CSV");
				chooser.add_filter(filter);

				filter = new Gtk.FileFilter ();
				filter.set_filter_name("BBox Logs");
				filter.add_pattern("*.bbl");
				filter.add_pattern("*.BBL");
				filter.add_pattern("*.TXT");
				filter.add_pattern("*.txt");
				chooser.add_filter(filter);

				filter = new Gtk.FileFilter ();
				filter.set_filter_name("OTX/ETX Logs");
				filter.add_pattern("*.csv");
				filter.add_pattern("*.CSV");
				chooser.add_filter(filter);

				filter = new Gtk.FileFilter ();
				filter.set_filter_name("All files");
				filter.add_pattern("*");
				chooser.add_filter(filter);
				chooser.select_multiple = true;

				var id = chooser.run();
				if (id == Gtk.ResponseType.ACCEPT || id == Gtk.ResponseType.OK) {
					var fns = chooser.get_filenames ();
					var sb = new StringBuilder();
					var j = 0;
					fns.@foreach((s) => {
							if (j != 0)
								sb.append(",");
							sb.append(s);
							j++;
						});
					lognames.text = sb.str;
					runbtn.sensitive = true;
				}
			});

		missionbtn.clicked.connect (() => {
				var chooser = new Gtk.FileChooserNative (
					"Mission file", window, Gtk.FileChooserAction.OPEN,
					"_Open", "_Cancel");

				Gtk.FileFilter filter = new Gtk.FileFilter ();
				filter.set_filter_name("inav missions");
				filter.add_pattern("*.mission");
				filter.add_pattern("*.json");
				chooser.add_filter(filter);
				filter = new Gtk.FileFilter ();
				filter.set_filter_name("All files");
				filter.add_pattern("*");
				chooser.add_filter(filter);
				chooser.select_multiple = false;

				var id = chooser.run();
				if (id == Gtk.ResponseType.ACCEPT || id == Gtk.ResponseType.OK) {
					var fns = chooser.get_filenames ();
					missionname.text = fns.nth_data(0);
				}
			});

		outbtn.clicked.connect (() => {
				var chooser = new Gtk.FileChooserNative (
					"Output Directory", window, Gtk.FileChooserAction.SELECT_FOLDER,
					"_Open", "_Cancel");
				var id = chooser.run();
				if (id == Gtk.ResponseType.ACCEPT || id == Gtk.ResponseType.OK) {
					outdir = chooser.get_filename ();
				}
			});
	}

	private void run_generator() {
		string[] args={};
		args += "flightlog2kml";
		args += "-dms=%s".printf(dms_check.active.to_string());
		args += "-efficiency=%s".printf(effic_check.active.to_string());
		args += "-extrude=%s".printf(extrude_check.active.to_string());
		args += "-kml=%s".printf(kml_check.active.to_string());
		args += "-rssi=%s".printf(rssi_check.active.to_string());
		args += "-gradient=%s".printf(grad_combo.active_id);

		if (missionname.text != null && missionname.text != "") {
			args += "-mission=%s".printf(missionname.text);
		}

		if (outdir != null && outdir != "") {
			args += "-outdir=%s".printf(outdir);
		}

		if(idx_entry.text != "" && idx_entry.text != "0") {
			args += "--index=%s".printf(idx_entry.text);
		}

		foreach(var s in lognames.text.split(",")) {
			args += s;
		}
//		print("CMD: %s\n", string.joinv(" ", args));

		Pid child_pid;
		int p_stdout;
		int p_stderr;
		var running = true;
		try {
			Process.spawn_async_with_pipes (null,
											args,
											null,
											SpawnFlags.SEARCH_PATH |
											SpawnFlags.DO_NOT_REAP_CHILD,
											null,
											out child_pid,
											null,
											out p_stdout,
											out p_stderr);

			pbar.show();
			Timeout.add(50, () => {
					if(running) {
						pbar.pulse();
					} else {
						pbar.hide();
					}
					return running;
			});

			IOChannel error = new IOChannel.unix_new (p_stderr);
			IOChannel output = new IOChannel.unix_new (p_stdout);
			error.add_watch (IOCondition.IN|IOCondition.HUP, (source, condition) => {
					string line = null;
					 size_t len = 0;
					if (condition == IOCondition.HUP)
						 return false;
					try {
						IOStatus eos = source.read_line (out line, out len, null);
                        if(eos == IOStatus.EOF)
                            return false;
						if (len > 0) {
							var s = "ERROR: %s".printf(line);
							add_textview(s);
						}
						return true;
					} catch (IOChannelError e) {
						stderr.printf("%s\n", e.message);
					}  catch (ConvertError e) {
						stderr.printf("%s\n", e.message);
					}
					return false;
				});
			output.add_watch (IOCondition.IN|IOCondition.HUP, (source, condition) => {
					string line = null;
					size_t len = 0;
					if (condition == IOCondition.HUP)
						return false;
					try {
						IOStatus eos = source.read_line (out line, out len, null);
						if(eos == IOStatus.EOF)
							return false;
						if (len > 0) {
							add_textview(line);
						}
						return true;
					} catch (IOChannelError e) {
						stderr.printf("%s\n", e.message);
					}  catch (ConvertError e) {
						stderr.printf("%s\n", e.message);
					}
					return false;
				});

			ChildWatch.add (child_pid, (pid, status) => {
					try { error.shutdown(false); } catch {}
					Process.close_pid (pid);
					running = false;
				});
		} catch  (SpawnError e) {
            stderr.printf("%s\n", e.message);
			running = false;
		}
	}

	private void add_textview(string s) {
		var textbuf = textview.get_buffer();
		Gtk.TextIter iter;
		textbuf.get_end_iter(out iter);
		textbuf.insert(ref iter, s, -1);
		textbuf.get_end_iter(out iter);
		textview.scroll_to_iter(iter, 0.0, true, 0.0, 1.0);
	}

	public static int main (string[] args) {
        var opt = new OptionContext("");
        try
        {
            opt.set_summary("fl2xui %s".printf(FL2XUI_VERSION_STRING));
            opt.set_help_enabled(true);
            opt.add_main_entries(options, null);
            opt.parse(ref args);
        } catch (OptionError e) {
            stderr.printf("Error: %s\n", e.message);
            stderr.printf("Run '%s --help' to see a full list of available options\n", args[0]);
            return 1;
        }
        if (show_version) {
            stdout.printf("%s\n", FL2XUI_VERSION_STRING);
            return 0;
        }
        MyApplication app = new MyApplication ();
        return app.run (args);
    }
}
