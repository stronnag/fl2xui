using Gtk;

public class ScrollView : Object {
	public Gtk.ScrolledWindow sw;
	private Gtk.Label label;
	public ScrollView(){
		sw = new Gtk.ScrolledWindow();
		label = new Gtk.Label (null);
		label.set_use_markup(true);
		label.hexpand = true;
        label.vexpand = true;
		label.xalign = 0;
		label.yalign = 0;
		var css = "label {font-family: monospace;}";
		var provider = new CssProvider();
		provider.load_from_data(css.data);
		var stylec = label.get_style_context();
		stylec.add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		sw.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        sw.set_child (label);
        sw.hexpand = true;
        sw.vexpand = true;
		sw.set_child(label);
	}

	public  void add_text(string s) {
		var lt = label.get_label();
		var sb = new StringBuilder(lt);
		sb.append(s);
		var str = sb.str;
		label.set_label(str);
		label.selectable = true;
		var adj = sw.get_vadjustment();
		adj.set_value(adj.get_upper());
	}
}