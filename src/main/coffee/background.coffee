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
        transitionTo nextTab



withFirstTab = (windowId, callback) ->
    withAllTabsInWindow windowId, (tabs) ->
        if tabs.length > 0
            callback tabs[0]


withSettingsFor = (tab, callback) ->
    settings = new TabSettings tab.url
    settings.load callback


reload = (tab) ->
    chrome.tabs.reload tab.id


# Pre-defined messages
informContentScriptAboutFocus = (tab) ->
    sendSimpleEventMessage tab, 'tab.focus.gained'

informContentScriptAboutImminentFocusLoss = (tab) ->
    sendSimpleEventMessage(tab, 'tab.focusloss.imminent')

informContentScriptAboutScheduledFocus = (tab) ->
    sendSimpleEventMessage(tab, 'tab.focus.scheduled')


transitionTo = (tab) ->
    if active
        withSettingsFor tab, (tabSettings) ->
            millisecondsDisplayTime = tabSettings.seconds * 1000
            shouldBeReloaded = tabSettings.reload

            onPageActivation = ->
                informContentScriptAboutFocus(tab)

                withNextTab tab, (next) -> # Todo: Assert next tab
                    informContentScriptAboutScheduledFocus(next)

                    setTimeout ( -> transitionTo next ), millisecondsDisplayTime
                    setTimeout ( -> reload(tab) if shouldBeReloaded), millisecondsDisplayTime + 1000
                    setTimeout ( -> informContentScriptAboutImminentFocusLoss(tab)), millisecondsDisplayTime - 1000


            selectTab tab, onPageActivation



# On install

chrome.runtime.onInstalled.addListener (type) ->
    if type.reason == "install"
        chrome.tabs.create url: "assets/html/after-install.html", active: true