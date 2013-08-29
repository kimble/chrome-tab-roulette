storage = chrome.storage.local

class TabSettings
    constructor : (fullUrl) ->
        @key = @stripQuery fullUrl

        # Default values
        @state =
            reload : true
            seconds : 4

    stripQuery : (url) ->
        if url.indexOf('?') > -1
            return url.substring 0, url.indexOf '?'
        else if url.indexOf('#') > -1
            return url.substring 0, url.indexOf '#'
        else
            return url

    load : (callback) =>
        defaults = { }
        defaults[@key] = JSON.stringify @state

        storage.get defaults, (settings) =>
            @state = JSON.parse settings[@key]
            callback @state

    set : (key, value) =>
        @state[key] = value

    flush : =>
        update = { }
        update[@key] = JSON.stringify @state

        storage.set update, =>
            console.dir update


window.TabSettings = TabSettings


window.withSettingsFor = (tab, callback) ->
    settings = new TabSettings tab.url
    settings.load callback