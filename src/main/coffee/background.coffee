active = false


chrome.browserAction.onClicked.addListener (tab) =>
    if active
        disable(tab)
    else
        activate(tab)

# Badge functions

updateBadge = (text, iconPath) ->
    chrome.browserAction.setBadgeText { text: text }
    chrome.browserAction.setIcon { path: iconPath }


# Content script functions

sendMessageToTab = (recipientTab, payload) ->
    chrome.tabs.sendMessage recipientTab.id, payload

sendSimpleEventMessage = (recipientTab, eventName) ->
    sendMessageToTab recipientTab, { event: eventName }

sendDelayedMessageToTab = (recipentTab, delayInMillis, payload) ->
    delayedFunc = -> sendMessageToTab recipentTab, payload
    setTimeout delayedFunc, delayInMillis


disable = (tab) ->
    active = false
    updateBadge("", "assets/images/icon_19x19_grey.png")

    cyclableTabsInWindow tab.windowId, (tabs) ->
        sendSimpleEventMessage(t, 'slideshow.ended') for t in tabs


activate = (startingTab) ->
    active = true
    updateBadge("ON!", "assets/images/icon_19x19.png")


    cyclableTabsInWindow startingTab.windowId, (tabs) ->
        sendSimpleEventMessage(t, 'slideshow.started') for t in tabs

    withNextTab startingTab, (nextTab) ->
        transitionTo nextTab, ->



withFirstTab = (windowId, callback) ->
    withAllTabsInWindow windowId, (tabs) ->
        if tabs.length > 0
            callback tabs[0]


withSettingsFor = (tab, callback) ->
    settings = new TabSettings tab.url
    settings.load callback


considerReloading = (tab, settings) ->
    if settings.reload
        func = -> chrome.tabs.reload tab.id
        setTimeout func, 1000

transitionTo = (tab, callback) ->
    if active
        withSettingsFor tab, (tabSettings) ->
            secondsOnPage = tabSettings.seconds

            selectTab tab, ->
                sendSimpleEventMessage tab, 'tab.focus.gained'
                callback(tab)

                withNextTab tab, (next) ->
                    timeoutCallback = ->
                        considerReloading tab, tabSettings
                        transitionTo next, ->

                    beforeTimeoutCallback = ->
                        sendSimpleEventMessage(tab, 'tab.focusloss.imminent')

                    sendSimpleEventMessage(next, 'tab.focus.scheduled')
                    setTimeout timeoutCallback, secondsOnPage * 1000
                    setTimeout beforeTimeoutCallback, (secondsOnPage-1) * 1000

