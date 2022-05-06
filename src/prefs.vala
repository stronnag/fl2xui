/*
{
   "blackbox-decode" : "blackbox_decode",
   "blt-vers" : 2,
   "dms" : false,
   "efficiency" : false,
   "extrude" : false,
   "gradient" : "",
   "home-alt" : -999999,
   "kml" : false,
   "outdir" : "",
   "rssi" : false,
   "split-time" : 120,
   "type" : 0,
   "visibility" : 0,
   "max-wp" : 120
   "attributes" : "",
   }
 */

namespace Prefs {

	public enum ATTRS {
		effic  = (1 << 0),
		speed = (1 << 1),
		altitude = (1 << 2),
	}

	public struct Prefs {
		public string bbdec;
		public bool dms;
		public bool effic;
		public bool extrude;
		public string gradient;
		public bool kml;
		public string outdir;
		public bool rssi;
		// part of attributes
		public bool speed;
		public bool altitude;
		public bool battery;
		public bool fast_is_red;
		public bool low_is_red;
		public string ge_name;
	}

	private string? have_conf_file(string fn) {
        var file = File.new_for_path (fn);
        if (file.query_exists ())  {
            return fn;
        } else {
            return null;
        }
    }

	public void save_prefs(Prefs p, string? ufn=null) {
		try {
			var uc = Environment.get_user_config_dir();
			var dir = GLib.Path.build_filename(uc,"fl2x");
			var fn = GLib.Path.build_filename(dir, "config.json");
			var s = attr_string(p);
			Json.Node root;

			if(ufn == null && have_conf_file(fn) != null)	{
				var parser = new Json.Parser ();
				parser.load_from_file (fn);
				root = parser.get_root ();
				var obj = root.get_object ();
				obj.set_boolean_member("efficiency", p.effic);
				obj.set_boolean_member("extrude", p.extrude);
				obj.set_string_member("gradient", p.gradient);
				obj.set_string_member("outdir", p.outdir);
				obj.set_string_member("attributes", s);
				obj.set_boolean_member("rssi", p.rssi);
				obj.set_boolean_member("kml", p.kml);
				obj.set_boolean_member("dms", p.dms);
				obj.set_boolean_member("fast-is-red", p.fast_is_red);
				obj.set_boolean_member("low-is-red", p.low_is_red);
			} else {
				if (ufn == null) {
					File dpath = File.new_for_path (dir);
					if (dpath.query_exists () == false) {
						dpath.make_directory_with_parents ();
					}
				} else {
					fn = ufn;
				}
				Json.Builder builder = new Json.Builder ();
				builder.begin_object ();
				builder.set_member_name("efficiency");
				builder.add_boolean_value(p.effic);
				builder.set_member_name("extrude");
				builder.add_boolean_value(p.extrude);
				builder.set_member_name("gradient");
				builder.add_string_value(p.gradient);
				builder.set_member_name("outdir");
				builder.add_string_value( p.outdir);
				builder.set_member_name("attributes");
				builder.add_string_value(s);
				builder.set_member_name("rssi");
				builder.add_boolean_value(p.rssi);
				builder.set_member_name("kml");
				builder.add_boolean_value( p.kml);
				builder.set_member_name("dms");
				builder.add_boolean_value( p.dms);
				builder.set_member_name("fast-is-red");
				builder.add_boolean_value( p.fast_is_red);
				builder.set_member_name("low-is-red");
				builder.add_boolean_value( p.low_is_red);
				builder.end_object ();
				root = builder.get_root ();
			}
			var gen = new Json.Generator ();
			gen.set_root (root);
			gen.set_pretty(true);

#if TEST
			stderr.printf("P=%s\n", gen.to_data(null));
#else
			gen.to_file(fn);
#endif
		} catch (Error e) {
			error ("%s", e.message);
		}
	}

	public string attr_string(Prefs p) {
		string [] astrs={};
		if(p.effic) {
			astrs += "effic";
		}
		if(p.speed) {
			astrs += "speed";
		}
		if(p.altitude) {
			astrs += "altitude";
		}
		if(p.battery) {
			astrs += "battery";
		}
		return string.joinv(",", astrs);
	}

	public Prefs read_prefs()
    {
		var p = Prefs();
		try {
			var uc = Environment.get_user_config_dir();
			var fn = GLib.Path.build_filename(uc,"fl2x","config.json");
			if(have_conf_file(fn) != null)	{
				var parser = new Json.Parser ();
				parser.load_from_file (fn);
				var obj = parser.get_root ().get_object ();
				if (obj.has_member("efficiency")) {
					p.effic = obj.get_boolean_member("efficiency");
				}
				if (obj.has_member("dms")) {
					p.dms = obj.get_boolean_member("dms");
				}
				if (obj.has_member("rssi")) {
					p.rssi = obj.get_boolean_member("rssi");
				}
				if (obj.has_member("extrude")) {
					p.extrude = obj.get_boolean_member("extrude");
				}
				if (obj.has_member("kml")) {
					p.kml = obj.get_boolean_member("kml");
				}
				if (obj.has_member("fast-is-red")) {
					p.fast_is_red = obj.get_boolean_member("fast-is-red");
				}
				if (obj.has_member("low-is-red")) {
					p.low_is_red = obj.get_boolean_member("low-is-red");
				}
				if (obj.has_member("gradient")) {
						p.gradient = obj.get_string_member("gradient");
				}
				if (obj.has_member("attributes")) {
					var attr = obj.get_string_member("attributes");
					if (attr.contains("effic")) {
						p.effic = true;
					}
					p.speed = attr.contains("speed");
					p.altitude = attr.contains("altitude");
					p.battery = attr.contains("battery");
				}
				if (obj.has_member("blackbox-decode")) {
					p.bbdec = obj.get_string_member("blackbox-decode");
				}
				if (obj.has_member("outdir")) {
					p.outdir = obj.get_string_member("outdir");
				}
				if (obj.has_member("ge-name")) {
					p.ge_name = obj.get_string_member("ge-name");
				}
			}
		} catch (Error e) {
			error ("%s", e.message);
		}
		return p;
	}
}

namespace Init {
	public string? setup () {
#if WINDOWSNT
    var homed = Environment.get_home_dir ();
	var epath= ProcessLauncher.get_exe_dir();
	if (epath != null) {
		var path = Environment.get_variable("PATH");
		var sb = new StringBuilder();
		sb.append(epath);
		sb.append(";");
		sb.append(path);
		Environment.set_variable("PATH", sb.str, true);
	}
	var docd =  GLib.Path.build_filename(homed, "Documents");
	return docd;
#else
	return null;
#endif
	}
}


#if TEST
// valac --pkg posix --pkg json-glib-1.0 --pkg gio-2.0 --define TEST prefs.vala
public static int main(string?[] args) {
	var prefs = Prefs.read_prefs();
	var od  = Init.setup();
	if (prefs.outdir == null || prefs.outdir == "") {
		prefs.outdir = od;
	}

	prefs.extrude = false;
	prefs.kml = true;
	prefs.speed = false;
	Prefs.save_prefs(prefs);
	return 0;
}
#endif
