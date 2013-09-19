###
    Will be injected into all http tabs!
###


eventBus = new Bacon.Bus

eventsNamed = (predicate) ->
    (request) ->
        predicate == request.event


chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
    request.sendResponse = sendResponse
    request.sender = sender

    eventBus.push request


# Event streams

focusGained = eventBus.filter(eventsNamed('tab.focus.gained'))
fadingScreenshots = eventBus.filter(eventsNamed('tab.previous.screenshot'))
slideshowEnd = eventBus.filter(eventsNamed('slideshow.ended'))


# Receiving screenshot of previous tab

findOrCreateImageNode = ->
    $el = $('.chrome-tab-blinder')

    if $el.length == 0
        imageElement = document.createElement('img')
        imageElement.className = 'chrome-tab-blinder'
        document.getElementsByTagName('body')[0].appendChild(imageElement)
        $el = $(imageElement)

    return $el


fadingScreenshots.onValue (request) ->
    $el = findOrCreateImageNode()
    $el.removeClass("fade-element-out")
    $el.attr("src", request.imageUri)
    $el.css("top", window.scrollY + 'px')
    $el.css("opacity", 1)
    $el.css("z-index", 999999)

    request.sendResponse("ok")


# Gaining focus

removePreviousScreenshot = ->
    $('.chrome-tab-blinder').remove()

fadeOutScreenshotOfPreviousTab = ->
    $('.chrome-tab-blinder')
        .css('top', window.scrollY + 'px')
        .addClass('fade-element-out')


focusGained.onValue (request) ->
    fadeOutScreenshotOfPreviousTab()
    request.sendResponse("ok")


# Slideshow ended

slideshowEnd.onValue (request) ->
    removePreviousScreenshot
    request.sendResponse("ok")
