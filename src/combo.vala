namespace FlCombo {

	class GradStore : GLib.Object {
		public GradStore (string name, string? image = null) {
			this.name = name;
			this.image = image;
		}
		public string name { get; set; }
		public string image { get; set; }
	}

	struct GradDef {
		string name;
		string png;
		string id;
	}
	private GradDef[] graddef;

	Gtk.DropDown build_grad_combo() {

		graddef += GradDef(){name = "Red", png = "reds", id = "red"};
		graddef += GradDef(){name = "Green/Red", png = "rdylgn", id = "rdgn"};
		graddef += GradDef(){name = "Yellow/Orange/Red", png = "ylorrd", id = "yor"};

		GLib.ListStore liststore = new GLib.ListStore ( typeof (GradStore) );
		foreach(var g in graddef) {
			var li = new GradStore(g.name, "/org/stronnag/fl2xui/%s.png".printf(g.png));
			liststore.append(li);
		}

		var factory = grad_factory_new();

		Gtk.DropDown dropdown = new Gtk.DropDown (null, null);
		dropdown.model = liststore;
        dropdown.factory = factory;
        dropdown.list_factory = null;
		dropdown.tooltip_text = "Set the colour gradient for attribute plots";
		return dropdown;
	}

	Gtk.ListItemFactory grad_factory_new () {
        var factory = new Gtk.SignalListItemFactory ();
		factory.setup.connect (grad_setup_item);
		factory.bind.connect (grad_bind_item);
        return factory;
    }


	void grad_setup_item (Gtk.SignalListItemFactory factory, GLib.Object o) {
        var box = new Gtk.Grid ();
		box.column_spacing = 8;
        var name = new Gtk.Label ("");
        var image = new Gtk.Picture ();

        name.xalign = 0.0f;
		name.hexpand = true;
        box.attach(name, 0, 0);
        box.attach(image, 1, 0);
		Gtk.ListItem list_item = o as Gtk.ListItem;
        list_item.set_data ("name", name);
        list_item.set_data ("image", image);
        list_item.set_child (box);
    }


	void grad_bind_item (Gtk.SignalListItemFactory factory, GLib.Object o) {
		Gtk.ListItem list_item =  (Gtk.ListItem)o;

		var item = list_item.get_item () as GradStore;
        var name = list_item.get_data<Gtk.Label>("name");
        var image = list_item.get_data<Gtk.Picture>("image");

        name.label = item.name;
        if (image != null) {
            image.set_resource (item.image);
            image.visible = true;
        }
    }

	string? get_name (uint id) {
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