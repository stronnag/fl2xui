project('fl2xui', 'vala', 'c', version : '1.2.2')
show_deprecated = get_option('deprecations')

if show_deprecated  == false
  # For now, as some replacements are not  well defined.
  add_project_arguments('-Wno-deprecated-declarations', language : 'c')
  add_project_arguments('--enable-deprecated', language : 'vala')
endif

conf_data = configuration_data()
conf_data.set('version', meson.project_version())

app = 'fl2xui'

gnome = import('gnome')

deps = []
dopts = []
vopts = []

configure_file(
  input : 'src/fl2xui-config.h.in',
  output : 'fl2xui-config.h',
  configuration : conf_data
)
configuration_inc = include_directories('.')

subdir('valaopts')
subdir('meson')
subdir('src')
subdir('data')

executable(
    meson.project_name(),
    fresources,
    wguisrcs,
    dependencies: [
        dependency('gtk4'),
	dependency('gio-2.0'),
	dependency('json-glib-1.0'),
	deps,
        meson.get_compiler('vala').find_library('posix'),
    ],
    vala_args : [dopts,vopts],
    c_args : vcargs,
    include_directories : configuration_inc,
    install: true,
    gui_app: true,
)

if host_machine.system() == 'windows'
  executable(
    'fl2xui-console',
    fresources,
    wguisrcs,
    dependencies: [
        dependency('gtk4'),
	dependency('gio-2.0'),
	dependency('json-glib-1.0'),
	deps,
        meson.get_compiler('vala').find_library('posix'),
    ],
    vala_args : [dopts,vopts],
    c_args : vcargs,
    include_directories : configuration_inc,
    install: false,
    build_by_default: false,
    gui_app: false,
)
elif host_machine.system() == 'darwin'
gnome.post_install(
  gtk_update_icon_cache: true,
)
else
  gnome.post_install(
    gtk_update_icon_cache: true,
    update_desktop_database: true,
  )
endif
#meson.add_install_script('meson/post_install.sh')
