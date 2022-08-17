
vapi_dir = meson.current_source_dir() / 'vapi'

add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(['--pkg', 'fl2xui'], language: 'vala')

host_os = host_machine.system()
if host_os == 'windows'
  wguisrcs = files('fl2xui.vala', 'prefs.vala', 'winspawn.vala', 'winproc.c', 'combo.vala', 'scrollview.vala')
  windows = import('windows')
  wguisrcs += windows.compile_resources('winres.rc')
else
  wguisrcs = files('fl2xui.vala', 'prefs.vala', 'process.vala', 'combo.vala', 'scrollview.vala')
endif
dopts += '--define=OS_'+host_os
