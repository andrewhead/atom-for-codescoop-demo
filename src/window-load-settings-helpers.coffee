windowLoadSettings = null

exports.getWindowLoadSettings = ->
  # Hard-code window-load settings
  windowLoadSettings = {
    initialPaths: [],
    locationsToOpen: [{}],
    # windowInitializationScript: 'atom/src/initialize-application-window.coffee',
    resourcePath: "/home/andrew/",
    # resourcePath,
    devMode: false,
    safeMode: false,
    profileStartup: false,
    clearWindowState: false,
    env: {
      ATOM_HOME: process.env.ATOM_HOME,
      ATOM_DEV_RESOURCE_PATH: '/This/is/fake',
    },
    appVersion: '1.11.2',
    atomHome: '',
    shellLoadTime: 999,
  }
  # windowLoadSettings ?= JSON.parse(window.decodeURIComponent(window.location.hash.substr(1)))

exports.setWindowLoadSettings = (settings) ->
  # windowLoadSettings = settings
  # location.hash = encodeURIComponent(JSON.stringify(settings))
