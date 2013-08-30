active = false



# Badge functions

chrome.browserAction.onClicked.addListener (tab) =>
    if active then disable(tab) else activate(tab)

updateBadge = (text, iconPath) ->
    chrome.browserAction.setBadgeText { text: text }
    chrome.browserAction.setIcon { path: iconPath }


# Content script messaging functions

sendMessageToTab = (recipientTab, payload) ->
    chrome.tabs.sendMessage(recipientTab.id, payload)

sendSimpleEventMessage = (recipientTab, eventName) ->
    sendMessageToTab(recipientTab, { event: eventName })


# Lifecycle

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

                    setTimeout ( -> transitionTo(next) ), millisecondsDisplayTime
                    setTimeout ( -> reload(tab) if shouldBeReloaded ), millisecondsDisplayTime + 1000
                    setTimeout ( -> informContentScriptAboutImminentFocusLoss(tab) ), millisecondsDisplayTime - 1000


            selectTab tab, onPageActivation



# On install

chrome.runtime.onInstalled.addListener (type) ->
    if type.reason == "install"
        chrome.tabs.create url: "assets/html/after-install.html", active: true