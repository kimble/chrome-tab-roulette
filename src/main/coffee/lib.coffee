storage = chrome.storage.local

class TabSettings
    constructor : (fullUrl) ->
        @key = @stripQuery fullUrl

        # Default values
        @state =
            reload : true
            seconds : 10

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


###
    Chrome helper functions
###

window.selectTab = (tab, callback) -> chrome.tabs.update tab.id, { active: true }, callback
window.withCurrentTab = (callback) -> chrome.tabs.getCurrent (current) => callback current
window.withAllTabsInWindow = (windowId, callback) -> chrome.tabs.query { windowId: windowId }, callback
window.withCurrentWindow = (callback) -> chrome.windows.getCurrent { populate: false }, callback

window.anyTabsInWindowMatching = (windowId, predicate, callback) ->
    withAllTabsInWindow windowId, (tabs) ->
        callback _.filter tabs, predicate

window.httpTabPredicate = (tab) -> /^http/.test(tab.url)