namespace Prefs {

	public struct Prefs {
		public string gradient;
		public bool effic;
		public bool rssi;
		public bool extrude;
		public bool kml;
		public bool dms;
		public string bbdec;
		public string outdir;
	}

	public Prefs read_prefs()
    {
		var p = Prefs();
		try {
			var uc = Environment.get_user_config_dir();
			var fn = GLib.Path.build_filename(uc,"fl2x","config.json");
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
		} catch (Error e) {
            error ("%s", e.message);
		}
		return p;
	}

}
