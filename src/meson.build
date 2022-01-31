
vapi_dir = meson.current_source_dir() / 'vapi'

add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(['--pkg', 'fl2xui'], language: 'vala')

if host_machine.system() == 'windows'
  dopts += '--define=WINDOWSNT'
  wguisrcs = files('fl2xui.vala', 'prefs.vala', 'winspawn.vala', 'winproc.c')
  windows = import('windows')
  wguisrcs += windows.compile_resources('winres.rc')

else
  wguisrcs = files('fl2xui.vala', 'prefs.vala', 'process.vala')
endif
