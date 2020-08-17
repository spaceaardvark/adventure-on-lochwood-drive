import { h, patch, text } from "https://unpkg.com/superfine"
import * as R from "https://unpkg.com/ramda/es"


# CONSTANTS


TICK_TIME = 10
START_TIME = 5 * 60 + 2 * TICK_TIME  # padding for the intro room

DOG_POOP_TIME = START_TIME - 90
DOG_PENALTY_TIME = 2 * 60

DAD_PENALTY_TIME = 30
DAD_EXTRA_PENALTY_TIME = 90


DAD = if R.includes "seth", window.location.search then "Seth" else "Dad"
MOM = if R.includes "mandy", window.location.search then "Mandy" else "Mom"


Room =
  BACK_YARD: "backyard"
  BEDROOM: "bedroom"
  BROTHERS_ROOM: "brother"
  FOYER: "foyer"
  GARAGE: "garage"
  INTRO: "intro"
  KITCHEN: "kitchen"
  LIVING_ROOM: "living"


Inventory =
  PHONE: "phone"
  POWER_CORD: "powercord"
  CONTROLLER: "controller"


GameConsole =
  OFF: "off"
  ON: "on"
  READY: "ready"


Dog =
  BARKING: "barking"
  OUTSIDE: "outside"
  POOPED: "pooped"


Dad =
  GRUMPY: "grumpy"
  MAD: "mad"
  HAPPY: "happy"


Delivery =
  NOT_HERE: "nothere"
  ARRIVED: "arrived"
  OPENED: "opened"


EnergyDrink =
  FULL: "full"
  EMPTY: "empty"
 

# MODEL


initialModel =
  currentRoom: Room.INTRO
  inventory: [ Inventory.PHONE ]
  time: START_TIME
  penaltyTime: 0
  gameConsoleState: GameConsole.OFF
  dogState: Dog.BARKING
  dadState: Dad.GRUMPY
  deliveryState: Delivery.NOT_HERE
  energyDrinkState: EnergyDrink.FULL


# UPDATE


MSG_AVOID_DAD = "AVOID_DAD"
MSG_CLEAN_UP_POOP = "CLEAN_UP_POOP"
MSG_DRINK_ENERGY = "DRINK_ENERGY"
MSG_GO_BEDROOM = "GO_BEDROOM"
MSG_GO_BROTHERS_ROOM = "GO_BROTHERS_ROOM"
MSG_GO_FOYER = "GO_FOYER"
MSG_GO_GARAGE = "GO_GARAGE"
MSG_GO_KITCHEN = "GO_KITCHEN"
MSG_GO_LIVING_ROOM = "GO_LIVING_ROOM"
MSG_HELP_DAD = "HELP_DAD"
MSG_HELP_MAD_DAD = "HELP_MAD_DAD"
MSG_INIT = "INIT"
MSG_LET_SYDNEY_OUT = "LET_SYDNEY_OUT"
MSG_OPEN_FRONT_DOOR = "OPEN_FRONT_DOOR"
MSG_PLUG_IN_PLAYSTATION = "PLUG_IN_PLAYSTATION"
MSG_TICK = "TICK"


update = (model, msg) ->
  switch msg
    when MSG_AVOID_DAD then {
      ...model
      dadState: Dad.MAD
    }
    when MSG_CLEAN_UP_POOP then { 
      ...model
      dogState: Dog.OUTSIDE
      time: model.time - DOG_PENALTY_TIME
      penaltyTime: model.penaltyTime + DOG_PENALTY_TIME
    }
    when MSG_DRINK_ENERGY then {
      ...model
      energyDrinkState: EnergyDrink.EMPTY
    }
    when MSG_GO_BEDROOM then { ...model, currentRoom: Room.BEDROOM }
    when MSG_GO_BROTHERS_ROOM then { ...model, currentRoom: Room.BROTHERS_ROOM }
    when MSG_GO_FOYER then { ...model, currentRoom: Room.FOYER }
    when MSG_GO_GARAGE then { ...model, currentRoom: Room.GARAGE }
    when MSG_GO_KITCHEN then { 
      ...model
      currentRoom: Room.KITCHEN
      energyDrinkState: EnergyDrink.FULL
     }
    when MSG_GO_LIVING_ROOM then { ...model, currentRoom: Room.LIVING_ROOM }
    when MSG_HELP_DAD then {
      ...model
      dadState: Dad.HAPPY
      deliveryState: Delivery.ARRIVED
      time: model.time - DAD_PENALTY_TIME
    }
    when MSG_HELP_MAD_DAD then {
      ...model
      dadState: Dad.HAPPY
      deliveryState: Delivery.ARRIVED
      time: model.time - DAD_EXTRA_PENALTY_TIME
      penaltyTime: model.penaltyTime + DAD_EXTRA_PENALTY_TIME
    }
    when MSG_INIT then { ...initialModel }
    when MSG_LET_SYDNEY_OUT then {
      ...model
      dogState: Dog.OUTSIDE
    }
    when MSG_OPEN_FRONT_DOOR then {
      ...model
      deliveryState: Delivery.OPENED
      inventory: R.prepend Inventory.POWER_CORD, model.inventory
    }
    when MSG_PLUG_IN_PLAYSTATION then {
      ...model
      gameConsoleState: GameConsole.OFF
      inventory: R.without Inventory.PowerCord, model.inventory
    }
    when MSG_TICK then tick model


tick = (model) ->
  time = model.time - TICK_TIME 

  timeExpired = time <= 0
  dogPooped = model.dogState == Dog.BARKING and time <= DOG_POOP_TIME

  {
    ...model
    time,
    currentRoom: if timeExpired then Room.BACK_YARD else model.currentRoom
    dogState: if dogPooped then Dog.POOPED else model.dogState
  }


# VIEW

startGameLink = h "a", { onclick: () -> dispatch MSG_GO_BEDROOM }, [ text "Start the game" ]

goBedroomLink = h "a", { onclick: () -> dispatch MSG_GO_BEDROOM }, [ text "Go to your bedroom" ]
goBrothersRoomLink = h "a", { onclick: () -> dispatch MSG_GO_BROTHERS_ROOM }, [ text "Go to your youngest brother's room" ]
goFoyerLink = h "a", { onclick: () -> dispatch MSG_GO_FOYER }, [ text "Go to the foyer" ]
goGarageLink = h "a", { onclick: () -> dispatch MSG_GO_GARAGE }, [ text "Go to the garage" ]
goKitchenLink = h "a", { onclick: () -> dispatch MSG_GO_KITCHEN }, [ text "Go to the kitchen" ]
goLivingRoomLink = h "a", { onclick: () -> dispatch MSG_GO_LIVING_ROOM }, [ text "Go to the living room" ]

letSydneyOutLink = h "a", { onclick: () -> dispatch MSG_LET_SYDNEY_OUT }, [ text "Let Sydney out" ]
cleanUpPoopLink = h "a", { onclick: () -> dispatch MSG_CLEAN_UP_POOP }, [ text "Clean up the poop mess" ]

avoidDadLink = h "a", { onclick: () -> dispatch MSG_AVOID_DAD }, [ text """Duck out and avoid #{DAD}""" ]
helpDadLink = h "a", { onclick: () -> dispatch MSG_HELP_DAD }, [ text """Help #{DAD} (eyeroll)""" ]
helpMadDadLink = h "a", { onclick: () -> dispatch MSG_HELP_MAD_DAD }, [ text """Help #{DAD}""" ]

openFridgeLink = h "a", { onclick: () -> dispatch MSG_DRINK_ENERGY }, [ text "Open the fridge" ]

openFrontDoorLink = h "a", { onclick: () -> dispatch MSG_OPEN_FRONT_DOOR }, [ text "Answer the door" ]

resetGameLink = h "a", { onclick: () -> dispatch MSG_INIT }, [ text "Start over" ]


view = (model) ->
  h "main", {}, [
    h "h1", {}, [ text "Adventure on Lochwood Drive" ]
    unless model.currentRoom == Room.INTRO then h "p", { class: "time" }, [ text viewTimer model ]
    switch model.currentRoom
      when Room.BACK_YARD then viewBackYard model
      when Room.BEDROOM then viewBedroom model
      when Room.BROTHERS_ROOM then viewBrothersRoom model
      when Room.FOYER then viewFoyer model
      when Room.GARAGE then viewGarage model
      when Room.INTRO then viewIntro model
      when Room.KITCHEN then viewKitchen model
      when Room.LIVING_ROOM then viewLivingRoom model
  ]


viewTimer = (model) ->
  """Time remaining: #{formatTime model.time}"""


formatTime = (seconds) ->
  mins = String(Math.floor seconds / 60).padStart(1, "0")
  secs = String(seconds % 60).padStart(2, "0")
  """#{mins}:#{secs}"""


viewIntro = (model) ->
  h "div", {}, [
    h "p", {}, [ text "Welcome to Adventure on Lochwood Drive!"]
    h "p", {}, [ 
      text "Your friends just texted you and they want to play some Call of SiegeNiteCraft. Hurry and get online to join them. You only have " 
      h "strong", {}, [ text "5:00 minutes" ]
      text " before they start the match without you."
    ]
    h "p", {}, [ text "Good luck!" ]
    viewActions [ startGameLink ]
  ]


viewBedroom = (model) ->
  h "div", {}, [
    h "p", {}, [ text "You are in your bedroom." ]
    viewGameConsole model
    viewInventory model.inventory
    viewActions [ goFoyerLink, goLivingRoomLink ]
  ]


viewBrothersRoom = (model) ->
  h "div", {}, [
    h "p", {}, [ text "You are in your youngest brother's room." ]
    viewInventory model.inventory
    viewActions [ goLivingRoomLink ]
  ]


viewFoyer = (model) ->
  actions = [
    ...(if model.deliveryState == Delivery.ARRIVED then [ openFrontDoorLink ] else [])
    goBedroomLink
    goLivingRoomLink
  ]
  h "div", {}, [
    h "p", {}, [ text "You are in the foyer by the front door." ]
    viewDelivery model
    viewInventory model.inventory
    viewActions actions
  ]


viewGarage = (model) ->
  actions = switch model.dadState
    when Dad.GRUMPY then [ avoidDadLink, helpDadLink ]
    when Dad.MAD then [ helpMadDadLink ]
    when Dad.HAPPY then [ goLivingRoomLink ]
  h "div", {}, [
    h "p", {}, [ text "You are in the garage." ]
    viewDad model
    viewInventory model.inventory
    viewActions actions
  ]


viewKitchen = (model) ->
  actions = [
    ...(if model.energyDrinkState == EnergyDrink.FULL then [ openFridgeLink ] else [])
    goLivingRoomLink
  ]
  h "div", {}, [
    h "p", {}, [ text "You are in the kitchen." ]
    viewEnergyDrink model
    viewInventory model.inventory
    viewActions actions
  ]


viewLivingRoom = (model) ->
  actions = [
    ...(switch model.dogState
    )
    if model.dogState == Dog.BARKING then letSydneyOutLink
    if model.dogState == Dog.POOPED then cleanUpPoopLink
    goBedroomLink
    goBrothersRoomLink
    goFoyerLink
    goGarageLink
    goKitchenLink
  ]
  h "div", {}, [
    h "p", {}, [ text "You are in the living room." ]
    viewDog model
    viewInventory model.inventory
    viewActions actions
  ]


viewBackYard = (model) ->
  timeHint = 
    if model.penaltyTime
      """You lost #{formatTime model.penaltyTime} to bad decisions. Can you avoid them next time and get online within 5 minutes?"""
    else
      "You did a lot of wandering around. Try again and focus!"

  h "div", {}, [
    h "p", {}, [ text "You're in the back yard." ]
    h "p", { class: "yikes" }, [ text "You lost the game." ]
    h "p", {}, [ text "It took you too long to get online with your friends. Now you're on the back porch just staring at the trees like a sad panda."]
    h "p", {}, [ text timeHint ]
    viewActions [ resetGameLink ]
  ]


viewGameConsole = (model) ->
  switch model.gameConsoleState
    when GameConsole.OFF then h "p", {}, [ text "Your XSwitchStation is turned off. You try to turn it on, but nothing happens. The power cord is missing." ]
    when GameConsole.ON then h "p", {}, [ text "Your XSwitchStation is on, but you don't have a way to control it." ]
    when GameConsole.READY then h "p", {}, [ text "Your XSwitchStation is on and ready to play." ]


viewDog = (model) ->
  switch model.dogState
    when Dog.BARKING then h "p", {}, [ text "Sydney is barking at the back door." ]
    when Dog.OUTSIDE then h "p", {}, [ text "Sydney is outside enjoying the sun." ]
    when Dog.POOPED then h "p", { class: "yikes" }, [ text "You're lying on your back. Sydney pooped on the floor and you slipped in it. Gross. It's going to take some time to clean this up." ]


viewDad = (model) ->
  switch model.dadState
    when Dad.GRUMPY then h "p", {}, [ text """#{DAD} is cleaning the garage and looks a little grumpy. "Can you give me a hand?" he asks.""" ]
    when Dad.MAD then h "p", { class: "yikes" }, [ text """Uh oh, #{DAD} has steam coming out of his ears. He's barking about responsibilities and blahblahblah. Better give him a hand."""]
    when Dad.HAPPY then h "p", {}, [ text """"Thanks for your help!" says #{DAD}."""]


viewDelivery = (model) ->
  switch model.deliveryState
    when Delivery.ARRIVED then h "p", {}, [ text "The doorbell rang." ]
    when Delivery.OPENED then h "p", { class: "hooray" }, [ text "You found a package on the front porch. It's a new XSwitchStation power cord!" ]


viewEnergyDrink = (model) ->
  switch model.energyDrinkState
    when EnergyDrink.EMPTY then h "p", {}, [ text "Aaahhh you chugged a MonsterBull All Natural energy drink LET'S DO THIS!" ]


cleanLinks = R.pipe (R.reject (link) -> link == undefined), R.flatten


viewActions = (links) ->
  cleanedLinks = cleanLinks links
  h "div", {}, [
    h "ul", { class: "actions" }, cleanedLinks.map (link) -> h "li", {}, [ link ]
  ]


viewInventory = (inventory) ->
  items = (inventory.map viewInventoryItem).join ", " or "nada"
  h "div", {}, [
    h "p", {}, [ 
      text "You're carrying: "
      text items 
      text "."
    ]
  ]


viewInventoryItem = (item) ->
  switch item
    when Inventory.PHONE then "iPear phone"
    when Inventory.POWER_CORD then "XSwitchStation power cord"
    when Inventory.CONTROLLER then "XSwitchStation controller"
    else """(What is this thing? -> #{item})"""


# DEBUGGING


if R.includes "debug", window.location.search
  log = (...args) -> window.console.log ...args
else
  log = () -> undefined


# APP


currentModel = initialModel


dispatch = (msg) ->
  updatedByMsg = update currentModel, msg
  updatedByTick = update updatedByMsg, MSG_TICK
  currentModel = updatedByTick
  log msg, currentModel
  patch (document.querySelector "main"), view currentModel


dispatch MSG_INIT