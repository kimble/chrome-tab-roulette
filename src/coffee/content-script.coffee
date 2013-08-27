###
    Will be injected into all http tabs!
###

###
chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
    if request.event == 'tab.focus.scheduled'
        if $('#chrometabblinder').length == 0
            blind = document.createElement 'div'
            blind.id = 'chrometabblinder'
            blind.className = 'chrome-tab-blinder'
            blind.style.top = window.crollY

            document.body.appendChild(blind)

    else if request.event == 'tab.focus.gained'
        $('#chrometabblinder').css('top', window.scrollY).addClass('roulette-fade-content-in').removeClass('roulette-fade-content-out')

    else if request.event == 'tab.focusloss.imminent'
        $('#chrometabblinder').css('top', window.scrollY).addClass('roulette-fade-content-out').removeClass('roulette-fade-content-in')

###

# Todo: Pull the dom specific functions out into a separate file

chromeEventStream = new Bacon.Bus

chromeBaconEventBridge = (request) ->
    chromeEventStream.push request.event # Todo: Rename event to name or something in that direction

eventsNamed = (predicate) ->
    (eventName) ->
        predicate == eventName


chrome.extension.onMessage.addListener(chromeBaconEventBridge)



slideshowStart = chromeEventStream.filter(eventsNamed('slideshow.started'))
slideshowEnd = chromeEventStream.filter(eventsNamed('slideshow.ended'))

scheduledForFocus = chromeEventStream.filter(eventsNamed('tab.focus.scheduled'))
focusGained = chromeEventStream.filter(eventsNamed('tab.focus.gained'))
aboutToLooseFocus = chromeEventStream.filter(eventsNamed('tab.focusloss.imminent'))

slideshowIsRunning = slideshowStart.map(true)
                          .merge(slideshowEnd.map(false))


chromeBlinderNode = -> $('#chrometabblinder')

missingBlinder = -> chromeBlinderNode().length == 0
removeBlinder = -> chromeBlinderNode().remove()

appendBlinder = ->
    blind = document.createElement 'div'
    blind.id = 'chrometabblinder'
    blind.className = 'chrome-tab-blinder'
    blind.style.top = window.crollY

    document.body.appendChild(blind)




scheduledForFocus.filter(missingBlinder).onValue(appendBlinder)


hideBlinder = ->
    chromeBlinderNode().css('top', window.scrollY).addClass('roulette-fade-content-in').removeClass('roulette-fade-content-out')
    console.log("Hidd blinder")

focusGained.onValue(hideBlinder)




showBlinder = ->
    chromeBlinderNode().css('top', window.scrollY).addClass('roulette-fade-content-out').removeClass('roulette-fade-content-in')
    console.log("Showed blinder")

aboutToLooseFocus.onValue(showBlinder)


slideshowEnd.onValue(removeBlinder)
