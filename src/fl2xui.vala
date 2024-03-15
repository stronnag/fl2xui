using Gtk;

public class Flx2Ui : Gtk.Application {
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
	private Gtk.DropDown grad_combo;
	private Gtk.Entry idx_entry;
	private Gtk.Button runbtn;
	private Gtk.Button earthbtn;
	private Gtk.Button savebtn;
	private Gtk.Button outbtn;
	private Gtk.Button logbtn;
	private Gtk.Button missionbtn;
	private Gtk.Button clibtn;

	private Gtk.SpinButton intspin;
	private Gtk.Entry lognames;
	private Gtk.Entry missionname;
	private Gtk.Entry cliname;
	private Gtk.Entry outdirname;
	private Gtk.ProgressBar pbar;
	private Gtk.CheckButton fast_is_red;
	private Gtk.CheckButton low_is_red;
	private string[] genkmz;
	private string[] fileargs;
	private bool is_Windows;
	private bool ge_running;
	private ScrolledView sv;

	public Flx2Ui () {
		Object(application_id: "org.stronnag.fl2xui",
			   flags: /*ApplicationFlags.HANDLES_OPEN|*/ApplicationFlags.HANDLES_COMMAND_LINE);

		const OptionEntry[] options = {
			{ "version", 'v', 0, OptionArg.NONE, null, "show version", null},
			{null} };

		fileargs={};
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
		fileargs = args[1:args.length];
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
							vsum = int.parse(vparts[i])+ 100*vsum;
						}
						res = vsum > 10014;
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
				} else {
					add_textview(sb.str);
				}
			});
		p.run(args);
	}

    protected override void activate () {
		if(active_window == null) {
			present_main_window();
		} else {
			handle_fileargs();
		}
	}

	private void present_main_window() {
		sv = new ScrolledView();
		var builder = new Builder.from_resource("/org/stronnag/fl2xui/fl2xui.ui");
		prefs = Prefs.read_prefs();
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
		earthbtn = builder.get_object("ge_launch") as Gtk.Button;
		earthbtn.set_action_name("win.launch");

		missionbtn = builder.get_object("mission_btn") as Gtk.Button;
		clibtn = builder.get_object("cli_btn") as Gtk.Button;

		intspin = builder.get_object("intspin") as Gtk.SpinButton;

		lognames =  builder.get_object("log_label") as Gtk.Entry;
		missionname =  builder.get_object("mission_label") as Gtk.Entry;
		cliname =  builder.get_object("cli_label") as Gtk.Entry;
		outdirname =  builder.get_object("out_label") as Gtk.Entry;
		pbar =  builder.get_object("pbar") as Gtk.ProgressBar;

		var gradbox = builder.get_object("grad_box") as Gtk.Box;
		var gradlabel = new Gtk.Label("Gradient:");
		grad_combo=FlCombo.build_grad_combo();
		gradbox.append (gradlabel);
		gradbox.append (grad_combo);

		var swin = builder.get_object("swin") as Gtk.Box;
		swin.append(sv.get_window());

		//		window.set_title("fl2xui %s".printf(FL2XUI_VERSION_STRING));
		this.add_window (window);
		window.set_application (this);
		window.set_default_size(600,480);

		if(prefs.gradient != null) {
			var id = FlCombo.get_id(prefs.gradient);
			grad_combo.selected = id;
		}
		savebtn.clicked.connect( () => {
				var name = FlCombo.get_name(grad_combo.selected);
				prefs.gradient = name;
				Prefs.save_prefs(prefs);
			});

		var saq = new GLib.SimpleAction("launch",null);
		saq.activate.connect(() => {
				earthbtn.sensitive = false;
				launch_ge();
			});
		window.add_action(saq);

		saq = new GLib.SimpleAction("clear",null);
		saq.activate.connect(() => {
				runbtn.sensitive = false;
				lognames.text = "";
				missionname.text = "";
				cliname.text = "";
			});
		window.add_action(saq);

		window.close_request.connect( () => {
				remove_window(window);
				return true;
			});

		window.set_icon_name("fl2xui");

		runbtn.sensitive = false;
		earthbtn.sensitive = false;
		connect_signals();
		var od  = Init.setup();
		is_Windows = (od != null);
		if (prefs.outdir == null || prefs.outdir == "") {
			prefs.outdir = od;
		}
		if (prefs.outdir != null)
			outdirname.text = prefs.outdir;
		if(fileargs !=null && fileargs.length > 0) {
			runbtn.sensitive = handle_fileargs();
		}
		check_version();
		setup_dnd();

		var header_bar = new Gtk.HeaderBar ();
		header_bar.decoration_layout = "icon:menu,minimize,maximize,close";
		header_bar.set_title_widget (new Gtk.Label("fl2xui %s".printf(FL2XUI_VERSION_STRING)));
		header_bar.set_show_title_buttons(true);
		window.set_titlebar (header_bar);

		window.present ();
	}

#if !OS_freebsd
	void setup_dnd() {
		var droptgt = new Gtk.DropTarget(typeof (Gdk.FileList), Gdk.DragAction.COPY);
		droptgt.drop.connect((tgt, value, x, y) => {
				fileargs = {};
				if(value.type() == typeof (Gdk.FileList)) {
					var flist = ((Gdk.FileList)value).get_files();
					foreach(var u in flist) {
						fileargs += u.get_path();
					}
				}
				sv.set_target(false);
				runbtn.sensitive = handle_fileargs();
				return runbtn.sensitive;
			});
		droptgt.accept.connect((d) => {
				sv.set_target(true);
				return true;
			});
		droptgt.leave.connect(() => {
				sv.set_target(false);
			});
		sv.get_view().add_controller((EventController)droptgt);
	}
#else
	void setup_dnd() {
		var droptgt = new Gtk.DropTarget(typeof (string), Gdk.DragAction.COPY);
		droptgt.on_drop.connect((tgt, value, x, y) => {
				if(value.type() == typeof (string)) {
					foreach(var u in ((string)value).split( "\r\n")) {
						if (u!= null && u.length > 0) {
							fileargs += u;
						}
					}
				}
				runbtn.sensitive = handle_fileargs();
				return runbtn.sensitive;
			});
		droptgt.accept.connect((d) => {
				sv.set_target(true);
				return true;
			});
		droptgt.leave.connect(() => {
				sv.set_target(false);
			});
		sv.get_view().add_controller((EventController)droptgt);
	}

#endif

	private bool handle_fileargs() {
		string[] items = {};
		var handled = false;
		foreach(var u in fileargs) {
			string fn;
			var mtype = guess_content_type(u, out fn);
			switch(mtype) {
			case 1:
				missionname.text = fn;
				handled = true;
				break;
			case 2,3:
				items += fn;
				handled = true;
				break;
			case 4:
				cliname.text = fn;
				break;
			default:
				break;
			}
		}
		if(items.length > 0) {
			var s = lognames.text;
			var sb = new StringBuilder(s);
			foreach (var i in items) {
				if(sb.len > 0)
					sb.append_c(',');
				sb.append(i);
			}
			lognames.text = sb.str;
		}
		fileargs={};
		return handled;
	}

	private int guess_content_type(string uri, out string? fn) {
		fn = null;
		int mt = 0;
		try {
			if (uri.has_prefix("file://")) {
				fn = Filename.from_uri(uri);
			} else {
				fn = uri;
			}
			uint8 buf[1024]={0};
			var fs = FileStream.open (fn, "r");
			if (fs != null) {
				if(fs.read (buf) > 0) {
					if(((string)buf).has_prefix("H Product:Blackbox")) {
						mt = 2;
					} else if (((string)buf).has_prefix("{\"missions\":")) {
						mt = 1 ;
					} else if (((string)buf).has_prefix
								("<?xml version=\"1.0\" encoding=")) {
						if (((string)buf).contains("<mission>") || ((string)buf).contains("<MISSION>")) {
							mt = 1;
						}
					} else if (((string)buf).has_prefix("Date,Time,"))  {
						mt = 3;
					} else if (((string)buf).contains("safehome")) {
						mt = 4;
					}
				}
			}
		} catch {}
		return mt;
	}

	private void connect_signals() {
		runbtn.clicked.connect(() => {
				runbtn.sensitive = false;
				run_generator();
			});

		logbtn.clicked.connect (() => {
				var fd = new Gtk.FileDialog ();
				fd.title = "Log File";
				var ls = new GLib.ListStore(typeof(Gtk.FileFilter));
				Gtk.FileFilter filter = new Gtk.FileFilter ();
				filter.set_filter_name("All Logs");
				filter.add_pattern("*.bbl");
				filter.add_pattern("*.BBL");
				filter.add_pattern("*.TXT");
				filter.add_pattern("*.txt");
				filter.add_pattern("*.csv");
				filter.add_pattern("*.CSV");
				ls.append(filter);

				filter = new Gtk.FileFilter ();
				filter.set_filter_name("BBox Logs");
				filter.add_pattern("*.bbl");
				filter.add_pattern("*.BBL");
				filter.add_pattern("*.TXT");
				filter.add_pattern("*.txt");
				ls.append(filter);

				filter = new Gtk.FileFilter ();
				filter.set_filter_name("OTX/ETX Logs");
				filter.add_pattern("*.csv");
				filter.add_pattern("*.CSV");
				ls.append(filter);

				filter = new Gtk.FileFilter ();
				filter.set_filter_name("All files");
				filter.add_pattern("*");
				ls.append(filter);
                fd.set_filters(ls);

				fd.open_multiple.begin (window, null, (o,r) => {
						try {
							var fns = fd.open_multiple.end(r);
							var sb = new StringBuilder();
							for(var j = 0; j < fns.get_n_items (); j++) {
								if (j != 0)
									sb.append(",");
								var s = fns.get_item(j) as File;
								sb.append(s.get_path ());
							}
							lognames.text = sb.str;
							runbtn.sensitive = true;
						} catch {}
					});
			});

		missionbtn.clicked.connect (() => {
				var fd = new Gtk.FileDialog ();
				fd.title = "Mission File";
				var ls = new GLib.ListStore(typeof(Gtk.FileFilter));
				Gtk.FileFilter filter = new Gtk.FileFilter ();
				filter.set_filter_name("inav missions");
				filter.add_pattern("*.mission");
				filter.add_pattern("*.json");
				ls.append(filter);
				filter = new Gtk.FileFilter ();
				filter.set_filter_name("All files");
				filter.add_pattern("*");
				ls.append(filter);

				fd.open.begin (window, null, (o,r) => {
						try {
							var fh = fd.open.end(r);
							missionname.text = fh.get_path();
							runbtn.sensitive = true;
						} catch {}
					});
			});
		clibtn.clicked.connect (() => {
				var fd = new Gtk.FileDialog ();
				fd.title = "CLI File";
				var ls = new GLib.ListStore(typeof(Gtk.FileFilter));
				Gtk.FileFilter filter = new Gtk.FileFilter ();
				filter.set_filter_name("CLI Files");
				filter.add_pattern("*.txt");
				ls.append(filter);
				filter = new Gtk.FileFilter ();
				filter.set_filter_name("All files");
				filter.add_pattern("*");
				ls.append(filter);

				fd.open.begin (window, null, (o,r) => {
						try {
							var fh = fd.open.end(r);
							cliname.text = fh.get_path();
							runbtn.sensitive = true;
						} catch {}
					});
			});

		outbtn.clicked.connect (() => {
				var fd = new  Gtk.FileDialog ();
				var dir = File.new_for_path(prefs.outdir);
				fd.initial_folder = dir;
				fd.initial_file = dir;
				fd.title = "Output Directory";

				fd.select_folder.begin(window, null, (o,r) => {
				try {
					var fh =  fd.select_folder.end(r);
					prefs.outdir = fh.get_path();
					outdirname.text = prefs.outdir;
				} catch {}
					});
			});
	}

	private bool get_ge_status() {
		return (!ge_running && prefs.ge_name != null && prefs.ge_name != "" && genkmz.length > 0);
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
					earthbtn.sensitive = true;
				});
			p.run(args, is_Windows);
		} else {
			add_textview("Notice  : Not spwaning GoogleEarth (not configured, or no KML/Z available)\n");
		}
		earthbtn.sensitive = false;

	}

	private void run_generator() {
		string[] args={};
		genkmz={};
		args += "flightlog2kml";
		string? tmpnam = null;
		try {
			var fd = FileUtils.open_tmp (".fl2xui-XXXXXX", out tmpnam);
			Posix.close(fd);
			var name = FlCombo.get_name(grad_combo.selected);
			prefs.gradient = name;
			Prefs.save_prefs(prefs, tmpnam);
			args += "-config";
			args += tmpnam;
		} catch {}

		if (missionname.text != null && missionname.text != "") {
			args += "-mission";
			args += missionname.text;
		}

		if (cliname.text != null && cliname.text != "") {
			args += "-cli";
			args += cliname.text;
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
				earthbtn.sensitive = get_ge_status();
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
		sv.add_text(s);
	}

	public override int command_line (ApplicationCommandLine command_line) {
        hold ();
        int res = _command_line (command_line);
        release ();
        return res;
    }

	public static int main (string[] args) {
        var app = new Flx2Ui ();
        return app.run (args);
    }
}
