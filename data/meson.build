

blueprints_src = [  join_paths( app + '.blp'), ]

blueprints_ui = []
blueprints_vala = []
foreach b : blueprints_src
        blueprints_ui += b.replace('.blp', '.ui')
        blueprints_vala += b + '.vala'
endforeach


blueprints = custom_target('blueprints',
  input: blueprints_src,
  output: blueprints_ui,
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTDIR@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

blueprints_hack = custom_target('blueprints_hack',
        input: blueprints,
        output: blueprints_vala,
        command: [find_program('touch'), '@OUTPUT@'],
)

#blueprints = custom_target('blueprints',
#  input: files(
#    'fl2xui.blp',
#  ),
#  output: '.',
#  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_D#IR@', '@INPUT@'],
#)

fresources = gnome.compile_resources(
    'f-resources',
    app + '.gresource.xml',
    source_dir: 'data',
    c_name: 'f',
    dependencies: blueprints,
)

#icon_sizes = ['16', '24', '32', '48', '64', '128']
#foreach i : icon_sizes
#    install_data(
#        join_paths('icons', i, 'fl2xui.svg'),
#        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
#    )
#endforeach

install_data(
	'fl2xui.svg',
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)

install_data('org.stronnag.fl2xui.desktop', install_dir : get_option('datadir') / 'applications')
