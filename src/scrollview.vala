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
		init_css();
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
		tv.set_name(active ? "borderattn" : "bordernone");
	}

	private void init_css() {
       	string css = """
#borderattn { border-style: dotted; border-color: @borders; border-width: 5px; }
#bordernone textview{ border-style: none; }
""";
		var provider = new Gtk.CssProvider ();
		Utils.load_provider_string(ref provider, css);
		Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
	}
}

namespace Utils {
	public void load_provider_string(ref Gtk.CssProvider provider, string str) {
#if CSS_USE_LOAD_DATA
        provider.load_from_data(str.data);
#elif CSS_USE_LOAD_DATA_STR_LEN
        provider.load_from_data(str, -1);
#else
        provider.load_from_string(str);
#endif
	}
}
