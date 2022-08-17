using Gtk;

public class ScrolledView : Object {
	private ScrolledWindow sw;
	private TextView tv;
	public ScrolledView(){
		sw =  new Gtk.ScrolledWindow ();
		tv = new Gtk.TextView();
		sw.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		tv.monospace = true;
		tv.editable = false;
		tv.cursor_visible = false;
		tv.vexpand = true;
		tv.hexpand = true;
		tv.halign = Gtk.Align.FILL;
		sw.set_child (tv);
	}

	public ScrolledWindow get_window() {
		return sw;
	}
	public TextView get_view() {
		return tv;
	}

	public void add_text(string s) {
		Gtk.TextIter iter;
		var textbuf = tv.get_buffer();
		textbuf.get_end_iter(out iter);
		textbuf.insert(ref iter, s, -1);
		tv.scroll_to_iter(iter, 0.0, true, 0.0, 1.0);
		var adj = sw.get_vadjustment();
		adj.set_value(adj.get_upper());
	}

	public void set_target(bool active) {
		string css;
		if (active) {
			css =  "textview { border-style: dotted; border-color: @borders; border-width: 5px; }";
		} else {
			css =  "textview{ border-style: none; }";
		}
		var provider = new CssProvider();
		provider.load_from_data(css.data);
		var stylec = tv.get_style_context();
		stylec.add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
	}
}