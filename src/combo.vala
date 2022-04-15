namespace FlCombo {

    enum Column {
        NAME,
        IMAGE
    }

	struct GradDef {
		string name;
		string png;
		string id;
	}
	private GradDef[] graddef;

	Gtk.ComboBox build_grad_combo() {

		graddef += GradDef(){name = "Red", png = "reds", id = "red"};
		graddef += GradDef(){name = "Green/Red", png = "rdylgn", id = "rdgn"};
		graddef += GradDef(){name = "Yellow/Orange/Red", png = "ylorrd", id = "yor"};

		Gtk.ListStore liststore = new Gtk.ListStore (2, typeof (string),  typeof (Gdk.Pixbuf) );

		try {
			foreach(var g in graddef) {
				Gtk.TreeIter iter;
				liststore.append (out iter);
				var pname = "/org/stronnag/fl2xui/%s.png".printf(g.png);
				var pb = new Gdk.Pixbuf.from_resource(pname);
				liststore.set (iter, Column.NAME, g.name);
				liststore.set (iter, Column.IMAGE, pb);
			}
		} catch {}

        Gtk.ComboBox combobox = new Gtk.ComboBox.with_model (liststore);

        /* CellRenderers render the data. */
        Gtk.CellRendererText cell = new Gtk.CellRendererText ();
        Gtk.CellRendererPixbuf cell_pb = new Gtk.CellRendererPixbuf ();

        combobox.pack_start (cell, false);
        combobox.pack_start (cell_pb, false);

        combobox.set_attributes (cell, "text", Column.NAME);
        combobox.set_attributes (cell_pb, "pixbuf", Column.IMAGE);
		combobox.active = 0;
		return combobox;
	}

	string? get_name (int id) {
		return (id > -1 && id < graddef.length) ? graddef[id].id : "red";
	}

	int get_id(string? name) {
		for (var i = 0; i < graddef.length; i++) {
			if (graddef[i].id == name) {
				return i;
			}
		}
		return 0;
	}
}