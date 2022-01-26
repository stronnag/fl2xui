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
    private const Gtk.TargetEntry[] targets = {
		{"text/uri-list",0,0},
		{"STRING",0,1},
	};

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

		this.add_window (window);
        window.set_application (this);
		window.set_default_size(600,480);

		handle_dnd(window);
        window.destroy.connect( () => {
                quit();
            });

		try {
			var pix =  new Gdk.Pixbuf.from_resource("/org/stronnag/fl2xui/fl2xui.png");
			window.set_icon(pix);
		} catch (Error e) {
			stderr.printf("failed to set icon %s\n", e.message);
			window.set_icon_name("fl2xui");
		}
		runbtn.sensitive = false;
		connect_signals();
		outdir = Init.setup();
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

	private void handle_dnd (Gtk.Widget w) {
		Gtk.drag_dest_set (w, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
		w.drag_data_received.connect((ctx, x, y, data, info, time) => {
				string mf = null; // mission
				string[] items = {};
				if (info == 0) {
					uint8 buf[1024];
					foreach(var uri in data.get_uris ())
					{
						try {
							var f = Filename.from_uri(uri);
							var fs = FileStream.open (f, "r");
							var nr =  fs.read (buf);
							if (nr > 128) {
								if(buf[0] == '<') {
									buf[nr-1] = 0;
									if( ((string)buf).contains("<MISSION>") || ((string)buf).contains("<mission>"))
										mf = f;
								} else if(buf[0] == '{' && buf[1] == '\n') {
									mf = f;
								} else if(buf[0] == 'H' && buf[1] == ' ') {
									items +=  f;
								} else if (((string)buf).has_prefix("Date,Time,")) {
									items +=  f;
								}
							}
						} catch (Error e) {
							stderr.printf("dnd: %s\n", e.message);
						}
					}
				}
				Gtk.drag_finish (ctx, true, false, time);
				if(mf != null) {
					missionname.text = mf;
				}
				if(items.length > 0) {
					var s = lognames.text;
					foreach(var p in s.split(",")) {
						items += p;
					}
					lognames.text = string.joinv(",", items);
					runbtn.sensitive = true;
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

		var p = new ProcessLauncher();
		bool running = true;
		p.result.connect((s) => {
				add_textview("%s\n".printf(s));
			});

        p.complete.connect((s) => {
				if(s != null) {
					add_textview("%s".printf(s));
				}
                running = false;
			});

		Timeout.add(50, () => {
				if(running) {
					pbar.pulse();
				} else {
					pbar.set_fraction(0.0);
					runbtn.sensitive = true;
				}
				return running;
			});
		p.run(args);
	}

	private void add_textview(string s) {
		var textbuf = textview.get_buffer();
		Gtk.TextIter iter;
		textbuf.get_end_iter(out iter);
		textbuf.insert(ref iter, s, -1);
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
