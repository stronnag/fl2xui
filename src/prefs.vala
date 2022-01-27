namespace Prefs {

	public struct Prefs {
		public string gradient;
		public bool effic;
		public bool rssi;
		public bool extrude;
		public bool kml;
		public bool dms;
		public string bbdec;
	}

	private string? have_conf_file(string fn) {
        var file = File.new_for_path (fn);
        if (file.query_exists ())  {
            return fn;
        } else {
            return null;
        }
    }

	public Prefs read_prefs()
    {
		var p = Prefs();
		try {
			var uc = Environment.get_user_config_dir();
			var fn = GLib.Path.build_filename(uc,"fl2x","config.json");

			if  (have_conf_file(fn) == null) {
				var apd = Environment.get_variable("APPDATA");
				if (apd != null) {
					fn = GLib.Path.build_filename(apd,"fl2x","config.json");
				}
			}

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
				if (obj.has_member("gradient")) {
						p.gradient = obj.get_string_member("gradient");
				}
				if (obj.has_member("blackbox-decode")) {
					p.bbdec = obj.get_string_member("blackbox-decode");
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
		var osname = Environment.get_os_info(OsInfoKey.NAME);
		bool iswin = osname.has_prefix("Windows");
		if (iswin) {
			var homed = Environment.get_home_dir ();
			var curd = Environment.get_current_dir ();
			var path = Environment.get_variable("PATH");
			var sb = new StringBuilder();
			sb.append(curd);
			sb.append(";");
			sb.append(path);
			Environment.set_variable("PATH", sb.str, true);
			stderr.printf("INIT: %s\n", sb.str);
			return homed;
		} else {
			return null;
		}
	}
}