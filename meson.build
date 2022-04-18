project('fl2xui', 'vala', 'c', version : '1.0.0-rc1')

conf_data = configuration_data()
conf_data.set('version', meson.project_version())

app = 'fl2xui'

gnome = import('gnome')

wresources = gnome.compile_resources(
    'f-resources',
    join_paths('data', app + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'f'
)

deps = []
dopts = []

configure_file(
  input : 'src/fl2xui-config.h.in',
  output : 'fl2xui-config.h',
  configuration : conf_data
)
configuration_inc = include_directories('build')

subdir('src')
executable(
    meson.project_name(),
    wresources,
    wguisrcs,
    dependencies: [
        dependency('gtk+-3.0'),
	dependency('gio-2.0'),
	dependency('json-glib-1.0'),
	deps,
        meson.get_compiler('vala').find_library('posix'),
    ],
    vala_args : dopts,
    include_directories : configuration_inc,
    install: true,
    gui_app: true,
)

subdir('data')
meson.add_install_script('meson/post_install.sh')
