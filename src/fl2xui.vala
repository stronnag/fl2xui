using Gtk;

public class MyApplication : Gtk.Application {
    private Gtk.ApplicationWindow window;
	private Prefs.Prefs prefs;
	private Gtk.CheckButton dms_check;
	private Gtk.CheckButton rssi_check;
	private Gtk.CheckButton extrude_check;
	private Gtk.CheckButton kml_check;
	private Gtk.CheckButton effic_check;
	private Gtk.CheckButton speed_check;
	private Gtk.CheckButton altitude_check;
	private Gtk.CheckButton battery_check;
	private Gtk.ComboBox grad_combo;
	private Gtk.Entry idx_entry;
	private Gtk.Button runbtn;
	private Gtk.Button savebtn;
	private Gtk.Button outbtn;
	private Gtk.Button logbtn;
	private Gtk.Button missionbtn;
	private Gtk.SpinButton intspin;
	private Gtk.TextView textview;
	private Gtk.Entry lognames;
	private Gtk.Entry missionname;
	private Gtk.Entry outdirname;
	private Gtk.ProgressBar pbar;
	private Gtk.CheckButton fast_is_red;
	private Gtk.CheckButton low_is_red;
	private string[] genkmz;
	private string fileargs;
	private bool is_Windows;
	private bool ge_running;

	private const Gtk.TargetEntry[] targets = {
		{"text/uri-list",0,0},
		{"STRING",0,1},
	};

	public MyApplication () {
		Object(application_id: "org.stronnag.fl2xui",
			   flags: ApplicationFlags.HANDLES_OPEN|ApplicationFlags.HANDLES_COMMAND_LINE);

		const OptionEntry[] options = {
			{ "version", 'v', 0, OptionArg.NONE, null, "show version", null},
			{null} };

		add_main_option_entries(options);
		handle_local_options.connect(do_handle_local_options);
	}

    private int do_handle_local_options(VariantDict o) {
        if (o.contains("version")) {
            stdout.printf("%s\n", FL2XUI_VERSION_STRING);
            return 0;
        }
		return -1;
    }

    private int _command_line (ApplicationCommandLine command_line) {
		string[] args = command_line.get_arguments ();
		fileargs = string.joinv(",", args[1:args.length]);
		activate();
		return 0;
	}

	private void check_version() {
		string?[] args = {"flightlog2kml", "-version"};
		var p = new ProcessLauncher();
		var sb = new StringBuilder();
		p.result.connect((text) => {
				sb.append(text);
			});

        p.complete.connect((s) => {
				if (s != null) {
					sb.append(s);
				}
				var text = sb.str;
				bool res = false;
				if (text != null && text != "") {
					var parts = text.split(" ");
					if (parts.length == 3) {
						int vsum = 0;
						var vparts = parts[1].split(".");
						for(var i = 0; i < 3 && i < parts.length; i++) {
							vsum = int.parse(vparts[i])+ 10*vsum;
						}
						res = vsum > 100;
					}
				}
				if (!res) {
					var rsb = new StringBuilder("Error: flightlog2kml ");
					if (text != null && text != "") {
						rsb.append_printf("too old (%s)\n", text.chomp());
					} else {
						rsb.append("not found\n");
					}
					add_textview(rsb.str);
				}
			});
		p.run(args);
	}

    protected override void activate () {
        Builder builder;
        builder = new Builder.from_resource("/org/stronnag/fl2xui/fl2xui.ui");
		prefs = Prefs.read_prefs();
		builder.connect_signals (null);
        window = builder.get_object ("appwin") as Gtk.ApplicationWindow;
		dms_check = builder.get_object("dms_check") as Gtk.CheckButton;
		dms_check.active = prefs.dms;
		dms_check.toggled.connect(() => {
				prefs.dms= dms_check.active;
			});
		rssi_check = builder.get_object("rssi_check") as Gtk.CheckButton;
		rssi_check.active = prefs.rssi;
		rssi_check.toggled.connect(() => {
				prefs.rssi= rssi_check.active;
			});
		extrude_check = builder.get_object("extrude_check") as Gtk.CheckButton;
		extrude_check.active = prefs.extrude;
		extrude_check.toggled.connect(() => {
				prefs.extrude = extrude_check.active;
			});
		kml_check = builder.get_object("kml_check") as Gtk.CheckButton;
		kml_check.active = prefs.kml;
		kml_check.toggled.connect(() => {
				prefs.kml = kml_check.active;
			});
		effic_check = builder.get_object("effic_check") as Gtk.CheckButton;
		effic_check.active = prefs.effic;
		effic_check.toggled.connect(() => {
				prefs.effic = effic_check.active;
			});
		speed_check = builder.get_object("speed_check") as Gtk.CheckButton;
		speed_check.active = prefs.speed;
		speed_check.toggled.connect(() => {
				prefs.speed= speed_check.active;
			});

		fast_is_red = builder.get_object("fast-is-red") as Gtk.CheckButton;
		fast_is_red.active = prefs.fast_is_red;
		fast_is_red.toggled.connect(() => {
				prefs.fast_is_red = fast_is_red.active;
			});

		low_is_red = builder.get_object("low-is-red") as Gtk.CheckButton;
		low_is_red.active = prefs.low_is_red;
		low_is_red.toggled.connect(() => {
				prefs.low_is_red = low_is_red.active;
			});

		altitude_check = builder.get_object("altitude_check") as Gtk.CheckButton;
		altitude_check.active = prefs.altitude;
		altitude_check.toggled.connect(() => {
				prefs.altitude= altitude_check.active;
			});
		battery_check = builder.get_object("battery_check") as Gtk.CheckButton;
		battery_check.active = prefs.battery;
		battery_check.toggled.connect(() => {
				prefs.battery =  battery_check.active;
			});
		idx_entry =  builder.get_object("idx_entry") as Gtk.Entry;
		savebtn = builder.get_object("save_prefs") as Gtk.Button;
		runbtn = builder.get_object("runbtn") as Gtk.Button;
		outbtn = builder.get_object("out_btn") as Gtk.Button;
		logbtn = builder.get_object("log_btn") as Gtk.Button;
		missionbtn = builder.get_object("mission_btn") as Gtk.Button;
		textview = builder.get_object("textview") as Gtk.TextView;
		intspin = builder.get_object("intspin") as Gtk.SpinButton;

		lognames =  builder.get_object("log_label") as Gtk.Entry;
		missionname =  builder.get_object("mission_label") as Gtk.Entry;
		outdirname =  builder.get_object("out_label") as Gtk.Entry;
		pbar =  builder.get_object("pbar") as Gtk.ProgressBar;

		var gradbox = builder.get_object("grad_box") as Gtk.Box;
		var gradlabel = new Gtk.Label("Gradient:");
		grad_combo=FlCombo.build_grad_combo();
		gradbox.pack_start (gradlabel, false);
        gradbox.pack_start (grad_combo, false);

		window.set_title("fl2xui %s".printf(FL2XUI_VERSION_STRING));
		this.add_window (window);
        window.set_application (this);
		window.set_default_size(600,480);

		if(prefs.gradient != null) {
			var id = FlCombo.get_id(prefs.gradient);
			grad_combo.active = id;
		}

		grad_combo.changed.connect(() => {
				var name = FlCombo.get_name(grad_combo.active);
				prefs.gradient = name;
			});

		savebtn.clicked.connect( () => {
				Prefs.save_prefs(prefs);
			});

		var ag = new Gtk.AccelGroup();
        ag.connect('l', Gdk.ModifierType.CONTROL_MASK, 0, (a,o,k,m) => {
                launch_ge();
				return true;
            });
        window.add_accel_group(ag);

		handle_dnd(window);
        window.destroy.connect( () => {
                quit();
            });

		try {
			var pix =  new Gdk.Pixbuf.from_resource("/org/stronnag/fl2xui/fl2xui.svg");
			window.set_icon(pix);
		} catch (Error e) {
		stderr.printf("failed to set icon %s\n", e.message);
			window.set_icon_name("fl2xui");
		}
		runbtn.sensitive = false;
		connect_signals();
		var od  = Init.setup();
		is_Windows = (od != null);
		if (prefs.outdir == null || prefs.outdir == "") {
			prefs.outdir = od;
		}
		if (prefs.outdir != null)
			outdirname.text = prefs.outdir;
		if(fileargs !=null && fileargs.length > 0) {
			lognames.text = fileargs;
			runbtn.sensitive = true;
		}
		check_version();
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
				if (prefs.outdir != null) {
					chooser.set_filename (prefs.outdir);
				}
				var id = chooser.run();
				if (id == Gtk.ResponseType.ACCEPT || id == Gtk.ResponseType.OK) {
					prefs.outdir = chooser.get_filename ();
					outdirname.text = prefs.outdir;
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
					foreach(var uri in data.get_uris ()) {
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

	private void launch_ge() {
		if (ge_running) {
			add_textview("Notice  : Unable to spawn additonal GoogleEarth instance\n");
		} else if (prefs.ge_name != null && prefs.ge_name != "" && genkmz.length > 0) {
			string[] args={};
			args += prefs.ge_name;

			foreach(var s in genkmz) {
				args += s;
			}
			var p = new ProcessLauncher();
			ge_running = true;
			p.complete.connect((s) => {
					ge_running = false;
				});
			p.run(args, is_Windows);
		} else {
			add_textview("Notice  : Not spwaning GoogleEarth (not configured, or no KML/Z available)\n");
		}
	}

	private void run_generator() {
		string[] args={};
		genkmz={};
		args += "flightlog2kml";
/*
		args += "-dms=%s".printf(prefs.dms.to_string());
		args += "-efficiency=%s".printf(prefs.effic.to_string()); // legacy
		args += "-extrude=%s".printf(prefs.extrude.to_string());
		args += "-kml=%s".printf(prefs.kml.to_string());
		args += "-rssi=%s".printf(prefs.rssi.to_string());
		var astr = Prefs.attr_string(prefs);
		if (prefs.outdir != null && prefs.outdir != "") {
			args += "-outdir";
			args += prefs.outdir;
		}
		if (astr.length > 0) {
			args += "-attributes=%s".printf(astr);
		}
		args += "-gradient=%s".printf(prefs.gradient);
*/
		string? tmpnam = null;
		try {
			var fd = FileUtils.open_tmp (".fl2xui-XXXXXX", out tmpnam);
			Posix.close(fd);
			Prefs.save_prefs(prefs, tmpnam);
			args += "-config";
			args += tmpnam;
		} catch {}

		if (missionname.text != null && missionname.text != "") {
			args += "-mission";
			args += missionname.text;
		}

		if(idx_entry.text != "" && idx_entry.text != "0") {
			args += "--index=%s".printf(idx_entry.text);
		}

		var sval = intspin.get_value ();
		args += "-interval=%d".printf((int)(1000*sval));

		foreach(var s in lognames.text.split(",")) {
			args += s;
		}

		var p = new ProcessLauncher();
		bool running = true;
		p.result.connect((s) => {
				add_textview("%s".printf(s));
				if (s.has_prefix("Output   : ")) {
					//           012345678901
					// #/tmp/Talon_R9M-2019-05-18.2.kmz
					genkmz += s[11:s.length].chomp();
				}
			});

        p.complete.connect((s) => {
				if(s != null) {
					add_textview("%s".printf(s));
				}
                running = false;
				if (tmpnam != null)
					Posix.unlink(tmpnam);
			});

		Timeout.add(100, () => {
				if(running) {
					pbar.pulse();
				} else {
					pbar.set_fraction(0.0);
					runbtn.sensitive = true;
				}
				return running;
			});
		running = p.run(args);
	}

	private void add_textview(string s) {
		var textbuf = textview.get_buffer();
		Gtk.TextIter iter;
		textbuf.get_end_iter(out iter);
		textbuf.insert(ref iter, s, -1);
		textview.scroll_to_iter(iter, 0.0, true, 0.0, 1.0);
	}

	public override int command_line (ApplicationCommandLine command_line) {
        hold ();
        int res = _command_line (command_line);
        release ();
        return res;
    }

	public static int main (string[] args) {
        MyApplication app = new MyApplication ();
        return app.run (args);
    }
}
