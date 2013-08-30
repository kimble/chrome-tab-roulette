window.define = (factory) ->
    delete window.define
    window.when = factory();

window.define.amd = {};