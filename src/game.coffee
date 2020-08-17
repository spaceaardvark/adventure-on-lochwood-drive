import {html, render} from "https://unpkg.com/lit-html?module"
import * as R from "https://unpkg.com/ramda/es"


# CONSTANTS


TICK_TIME = 10
START_TIME = 5 * 60 + 2 * TICK_TIME  # padding for the intro room

DOG_POOP_TIME = START_TIME - 90
DOG_PENALTY_TIME = 2 * 60

DAD_PENALTY_TIME = 30
DAD_EXTRA_PENALTY_TIME = 90

BROTHER_PENALTY_TIME = 30


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
  VICTORY: "victory"


Inventory =
  PHONE: "phone"
  POWER_CORD: "powercord"
  CONTROLLER: "controller"
  TAPE_MEASURE: "tapemeasure"


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


Brother =
  PLAYING_WITH_LEGOS: "legos"
  PLAYING_WITH_TAPE_MEASURE: "tapemeasure"
  PLAYING_WITH_GAME: "game"
  TAKING_TAPE_MEASURE: "taking"
  PLAYING_WITH_PHONE: "phone"


Mom =
  ASKING_FOR_TAPE_MEASURE: "asking"
  MEASURING: "measuring"
  COMPLIMENTED: "complimented"
 

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
  brotherState: Brother.PLAYING_WITH_LEGOS
  momState: Mom.ASKING_FOR_TAPE_MEASURE


# UPDATE


MSG_AVOID_DAD = "AVOID_DAD"
MSG_CLEAN_UP_POOP = "CLEAN_UP_POOP"
MSG_COMPLIMENT_MOM = "COMPLIMENT_MOM"
MSG_DRINK_ENERGY = "DRINK_ENERGY"
MSG_GIVE_BROTHER_PHONE = "GIVE_BROTHER_PHONE"
MSG_GIVE_MOM_TAPE_MEASURE = "GIVE_MOM_TAPE_MEASURE"
MSG_GO_BEDROOM = "GO_BEDROOM"
MSG_GO_BROTHERS_ROOM = "GO_BROTHERS_ROOM"
MSG_GO_FOYER = "GO_FOYER"
MSG_GO_GARAGE = "GO_GARAGE"
MSG_GO_KITCHEN = "GO_KITCHEN"
MSG_GO_LIVING_ROOM = "GO_LIVING_ROOM"
MSG_GO_ONLINE = "GO_ONLINE"
MSG_HELP_DAD = "HELP_DAD"
MSG_HELP_MAD_DAD = "HELP_MAD_DAD"
MSG_INIT = "INIT"
MSG_LET_SYDNEY_OUT = "LET_SYDNEY_OUT"
MSG_OPEN_FRONT_DOOR = "OPEN_FRONT_DOOR"
MSG_PLAY_GAME_WITH_BROTHER = "PLAY_GAME_WITH_BROTHER"
MSG_PLUG_IN_CONTROLLER = "PLUG_IN_CONTROLLER"
MSG_PLUG_IN_GAME_CONSOLE = "PLUG_IN_GAME_CONSOLE"
MSG_TAKE_TAPE_MEASURE_FROM_BROTHER = "TAKE_TAPE_MEASURE_FROM_BROTHER"
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
    when MSG_COMPLIMENT_MOM then {
      ...model
      momState: Mom.COMPLIMENTED
      inventory: R.prepend Inventory.CONTROLLER, model.inventory
    }
    when MSG_DRINK_ENERGY then {
      ...model
      time: model.time + TICK_TIME
      energyDrinkState: EnergyDrink.EMPTY
    }
    when MSG_GIVE_BROTHER_PHONE then {
      ...model
      brotherState: Brother.PLAYING_WITH_PHONE
      inventory: (R.pipe (R.without Inventory.PHONE), (R.prepend Inventory.TAPE_MEASURE)) model.inventory
    }
    when MSG_GIVE_MOM_TAPE_MEASURE then {
      ...model
      momState: Mom.MEASURING
      inventory: R.without Inventory.TAPE_MEASURE, model.inventory
    }
    when MSG_GO_BEDROOM then { ...model, currentRoom: Room.BEDROOM }
    when MSG_GO_BROTHERS_ROOM then {
      ...model
      currentRoom: Room.BROTHERS_ROOM
      brotherState: switch model.brotherState
        when Brother.PLAYING_WITH_GAME, Brother.TAKING_TAPE_MEASURE then Brother.PLAYING_WITH_TAPE_MEASURE
        else model.brotherState
    }
    when MSG_GO_FOYER then { ...model, currentRoom: Room.FOYER }
    when MSG_GO_GARAGE then { ...model, currentRoom: Room.GARAGE }
    when MSG_GO_KITCHEN then { 
      ...model
      currentRoom: Room.KITCHEN
      energyDrinkState: EnergyDrink.FULL
     }
    when MSG_GO_LIVING_ROOM then { ...model, currentRoom: Room.LIVING_ROOM }
    when MSG_GO_ONLINE then {
      ...model
      currentRoom: Room.VICTORY
    }
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
      brotherState: Brother.PLAYING_WITH_TAPE_MEASURE
    }
    when MSG_PLAY_GAME_WITH_BROTHER then {
      ...model
      brotherState: Brother.PLAYING_WITH_GAME
    }
    when MSG_PLUG_IN_CONTROLLER then {
      ...model
      gameConsoleState: GameConsole.READY
      inventory: R.without Inventory.CONTROLLER, model.inventory
    }
    when MSG_PLUG_IN_GAME_CONSOLE then {
      ...model
      gameConsoleState: GameConsole.ON
      inventory: R.without Inventory.POWER_CORD, model.inventory
    }
    when MSG_TAKE_TAPE_MEASURE_FROM_BROTHER then {
      ...model
      time: model.time - BROTHER_PENALTY_TIME
      penaltyTime: model.penaltyTime + BROTHER_PENALTY_TIME
      brotherState: Brother.TAKING_TAPE_MEASURE
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

startGameLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_BEDROOM}>Start the game</a>"""

goBedroomLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_BEDROOM }>Go to your bedroom</a>"""
goBrothersRoomLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_BROTHERS_ROOM}>Go to your youngest brother's room</a>"""
goFoyerLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_FOYER}>Go to the foyer</a>"""
goGarageLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_GARAGE}>Go to the garage</a>"""
goKitchenLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_KITCHEN}>Go to the kitchen</a>"""
goLivingRoomLink = 
  html"""<a @click=#{() -> dispatch MSG_GO_LIVING_ROOM}>Go to the living room</a>"""

plugInGameConsoleLink =
  html"""<a @click=#{() -> dispatch MSG_PLUG_IN_GAME_CONSOLE}>Plug in the XSwitchStation</a>"""
plugInControllerLink =
  html"""<a @click=#{() -> dispatch MSG_PLUG_IN_CONTROLLER}>Connect the controller to the XSwitchStation</a>"""
goOnlineLink =
  html"""<a @click=#{() -> dispatch MSG_GO_ONLINE}>Go online with your friends!</a>"""

letSydneyOutLink = 
  html"""<a @click=#{() -> dispatch MSG_LET_SYDNEY_OUT}>Let Sydney out</a>"""
cleanUpPoopLink = 
  html"""<a @click=#{() -> dispatch MSG_CLEAN_UP_POOP}>Clean up the poop mess</a>"""

avoidDadLink = 
  html"""<a @click=#{() -> dispatch MSG_AVOID_DAD}>Duck out and avoid #{DAD}</a>"""
helpDadLink = 
  html"""<a @click=#{() -> dispatch MSG_HELP_DAD}>Help #{DAD} (eyeroll)</a>"""
helpMadDadLink = 
  html"""<a @click=#{() -> dispatch MSG_HELP_MAD_DAD}>Help #{DAD}</a>"""

openFridgeLink = 
  html"""<a @click=#{() -> dispatch MSG_DRINK_ENERGY}>Open the fridge</a>"""

openFrontDoorLink = 
  html"""<a @click=#{() -> dispatch MSG_OPEN_FRONT_DOOR}>Answer the door</a>"""

giveBrotherPhoneLink =
  html"""<a @click=#{() -> dispatch MSG_GIVE_BROTHER_PHONE}>Give him your phone</a>"""
playGameWithBrotherLink =
  html"""<a @click=#{() -> dispatch MSG_PLAY_GAME_WITH_BROTHER}>Distract him with a board game</a>"""
takeControllerFromBrotherLink =
  html"""<a @click=#{() -> dispatch MSG_TAKE_TAPE_MEASURE_FROM_BROTHER}>Grab the tape measure and run</a>"""

complimentMomLink =
  html"""<a @click=#{() -> dispatch MSG_COMPLIMENT_MOM}>Compliment #{MOM}'s idea</a>"""
giveMomTapeMeasureLink =
  html"""<a @click=#{() -> dispatch MSG_GIVE_MOM_TAPE_MEASURE}>Give #{MOM} the tape measure</a>"""

resetGameLink = 
  html"""<a @click=#{() -> dispatch MSG_INIT}>Start over</a>"""


viewTimer = (model) ->
  html"""<p class=time>Time remaining: #{formatTime model.time}</p>"""


formatTime = (seconds) ->
  mins = String(Math.floor seconds / 60).padStart(1, "0")
  secs = String(seconds % 60).padStart(2, "0")
  """#{mins}:#{secs}"""


viewIntro = (model) ->
  html"""
      <p>Welcome to Adventure on Lochwood Drive!</p>
      <p>Your friends just texted you and they want to play some Call of SiegeNiteCraft. Hurry!
        You only have <strong>5:00 minutes</strong> before they start the match without you.</p>
      <p>Good luck!</p>
      #{viewActions [ startGameLink ]}
      """


viewVictory = (model) ->
  html"""
      <p class="hooray">Congratulations, you won the game!</p>
      <p>You had #{formatTime model.time} to spare. Well done!</p>
      <p>Thanks for playing. :)</p>
      <p class="whisper">Want to see the <a href="https://github.com/spaceaardvark/adventure-on-lochwood-drive/blob/master/src/game.coffee">source code</a>?</p>
      """


viewBedroom = (model) ->
  canPlugIn = 
    model.gameConsoleState is GameConsole.OFF and R.includes Inventory.POWER_CORD, model.inventory
  canAttachController =
    model.gameConsoleState is GameConsole.ON and R.includes Inventory.CONTROLLER, model.inventory
  canGoOnline =
    model.gameConsoleState is GameConsole.READY
  actions = [
    ...(if canPlugIn then [ plugInGameConsoleLink ] else [])
    ...(if canAttachController then [ plugInControllerLink ] else [])
    ...(if canGoOnline then [ goOnlineLink ] else [])
    goFoyerLink
    goLivingRoomLink
  ]
  html"""
      <p>You are in your bedroom.</p>
      #{viewGameConsole model}
      #{viewInventory model.inventory}
      #{viewActions actions}
      """


viewBrothersRoom = (model) ->
  actions = switch model.brotherState
    when Brother.PLAYING_WITH_TAPE_MEASURE
      [ takeControllerFromBrotherLink, playGameWithBrotherLink, giveBrotherPhoneLink ]
    when Brother.PLAYING_WITH_GAME
      [ takeControllerFromBrotherLink, giveBrotherPhoneLink ]
    when Brother.TAKING_TAPE_MEASURE
      [ playGameWithBrotherLink, giveBrotherPhoneLink ]
    else
      []
  actions = R.append goLivingRoomLink, actions
  html"""
      <p>You are in your youngest brother's room.</p>
      #{viewBrother model}
      #{viewInventory model.inventory}
      #{viewActions actions}
      """


viewFoyer = (model) ->
  actions = [
    ...(if model.deliveryState == Delivery.ARRIVED then [ openFrontDoorLink ] else [])
    goBedroomLink
    goLivingRoomLink
  ]
  html"""
      <p>You are in the foyer by the front door.</p>
      #{viewDelivery model}
      #{viewInventory model.inventory}
      #{viewActions actions}
      """


viewGarage = (model) ->
  actions = switch model.dadState
    when Dad.GRUMPY then [ avoidDadLink, helpDadLink ]
    when Dad.MAD then [ helpMadDadLink ]
    when Dad.HAPPY then [ goLivingRoomLink ]
  html"""
      <p>You are in the garage.</p>
      #{viewDad model}
      #{viewInventory model.inventory}
      #{viewActions actions}
      """


viewKitchen = (model) ->
  actions = [
    ...(if model.energyDrinkState == EnergyDrink.FULL then [ openFridgeLink ] else [])
    ...(if R.includes Inventory.TAPE_MEASURE, model.inventory then [ giveMomTapeMeasureLink ] else [])
    ...(if model.momState is Mom.MEASURING then [ complimentMomLink ] else [])
    goLivingRoomLink
  ]
  html"""
      <p>You are in the kitchen</p>
      #{viewEnergyDrink model}
      #{viewMom model}
      #{viewInventory model.inventory}
      #{viewActions actions}
      """

TvShows = [
  "Regular Show is on the TV. \"FREE CAKE! FREE CAKE!\""
  "Foster's Home for Imaginary Friends is on the TV. \"Cheeeeeese\""
  "Impractical Jokers is on the TV. Did he just grab something out of her shopping cart?"
  "Phineas and Ferb is on the TV. Candace is yelling, \"There! Look, look, look, see?\""
]


viewLivingRoom = (model) ->
  showIndex = Math.floor (Math.random() * TvShows.length)
  navActions = [
    goBedroomLink
    goBrothersRoomLink
    goFoyerLink
    goGarageLink
    goKitchenLink
  ]
  actions = switch model.dogState
    when Dog.BARKING then [ letSydneyOutLink, ...navActions ]
    when Dog.POOPED then [ cleanUpPoopLink ]
    else navActions
  html"""
      <p>You are in the living room.</p>
      <p>#{TvShows[showIndex]}</p>
      #{viewDog model}
      #{viewInventory model.inventory}
      #{viewActions actions}
      """


viewBackYard = (model) ->
  timeHint = 
    if model.penaltyTime
      "You could save some time by making better decisions. Give it another try!"
    else
      "You did a lot of wandering around. Try again and focus!"
  html"""
      <p>You're in the back yard.</p>
      <p><span class="yikes">You lost the game.</span> It took you too long to get online with your 
        friends. Now you're on the back porch. Staring. Like a sad panda.</p>
      <p>#{timeHint}</p>
      #{viewActions [ resetGameLink ]}
      """


viewGameConsole = (model) ->
  switch model.gameConsoleState
    when GameConsole.OFF
      html"""<p>Your XSwitchStation is turned off. You try to turn it on, but nothing happens.
        The power cord is missing.</p>"""
    when GameConsole.ON
      html"""<p>Your XSwitchStation is on, but you don't have a way to control it.</p>"""
    when GameConsole.READY
      html"""<p class="hooray">Your XSwitchStation is on and ready to play.</p>"""


viewDog = (model) ->
  text = switch model.dogState
    when Dog.BARKING 
      html"""<p>Sydney is barking at the back door.</p>"""
    when Dog.OUTSIDE 
      html"""<p class="hooray">Sydney is outside enjoying the sun.</p>"""
    when Dog.POOPED 
      html"""<p class=yikes>You're lying on your back. Sydney pooped on the floor and you slipped
        in it. Gross. It's going to take some time to clean this up.</p>"""

viewDad = (model) ->
  switch model.dadState
    when Dad.GRUMPY 
      html"""<p>#{DAD} is cleaning the garage and looks a little grumpy. "Can you give me a hand?"
        he asks.</p>"""
    when Dad.MAD 
      html"""<p class="yikes">Uh oh, #{DAD} has steam coming out of his ears. He's barking about
        responsibilities and blah blah blah. Better give him a hand.</p>"""
    when Dad.HAPPY 
      html"""<p class="hooray">"Thanks for your help!" says #{DAD}.</p>"""


viewDelivery = (model) ->
  switch model.deliveryState
    when Delivery.ARRIVED
      html"""<p>The doorbell rang.</p>"""
    when Delivery.OPENED 
      html"""<p class="hooray">You found a package on the front porch. It's a new XSwitchStation
        power cord!</p>"""


viewEnergyDrink = (model) ->
  switch model.energyDrinkState
    when EnergyDrink.EMPTY 
      html"""<p class="hooray">Aaahhh you chugged a MonsterBull Not-All-Natural energy drink LET'S DO THIS!</p>"""


viewBrother = (model) ->
  switch model.brotherState
    when Brother.PLAYING_WITH_LEGOS
      html"""<p>Your youngest brother is playing with Legos.</p>"""
    when Brother.PLAYING_WITH_TAPE_MEASURE
      html"""<p>Your youngest brother is playing with a retractable tape measure.</p>"""
    when Brother.PLAYING_WITH_GAME
      html"""<p>You're playing Candyland and your youngest brother is still playing with the tape measure.</p>"""
    when Brother.TAKING_TAPE_MEASURE
      html"""<p class="yikes">Well that was a disaster. He thew a FIT and it took a while to calm him down. And he's still playing with the tape measure.</p>"""
    when Brother.PLAYING_WITH_PHONE
      html"""<p class="hooray">Your youngest brother dropped the tape measure and is now sending SnapToks with your phone. So cute.</p>"""


viewMom = (model) ->
  switch model.momState
    when Mom.ASKING_FOR_TAPE_MEASURE
      html"""<p>#{MOM} is working on something on the kitchen table. "Have you seen my tape
        measure?" she asks.</p>"""
    when Mom.MEASURING
      html"""<p>#{MOM} measures a small set of shelves on the kitchen table. "I was thinking about
        using these to store some of your youngest brother's art supplies and then move blah blah
        blah.</p>"""
    when Mom.COMPLIMENTED
      html"""<p class="hooray">#{MOM} says, "Thank you for your input!" She gave you your
        XSwitchStation controller. Apparently you left it in the bathroom. (Dude.)</p>"""


viewActions = (links) ->
  html"""
      <ul class="actions">
        #{links.map (l) -> html"""<li>#{l}</li>"""}
      </ul>
      """


viewInventory = (inventory) ->
  items = ((inventory.map viewInventoryItem).join ", ") or "nada"
  html"""<p>You're carrying: #{items}.</p>"""


viewInventoryItem = (item) ->
  switch item
    when Inventory.PHONE then "iPear phone"
    when Inventory.POWER_CORD then "XSwitchStation power cord"
    when Inventory.CONTROLLER then "XSwitchStation controller"
    when Inventory.TAPE_MEASURE then "retractable tape measure"


viewRoomFns =
  [Room.BACK_YARD]: viewBackYard
  [Room.BEDROOM]: viewBedroom
  [Room.BROTHERS_ROOM]: viewBrothersRoom
  [Room.FOYER]: viewFoyer
  [Room.GARAGE]: viewGarage
  [Room.INTRO]: viewIntro
  [Room.KITCHEN]: viewKitchen
  [Room.LIVING_ROOM]: viewLivingRoom
  [Room.VICTORY]: viewVictory


view = (model) ->
  displayTimer =
    not (model.currentRoom in [ Room.INTRO, Room.BACK_YARD, Room.VICTORY ])
  html"""
      <h1>Adventure on Lochwood Drive</h1>
      #{if displayTimer then viewTimer model}
      #{viewRoomFns[model.currentRoom] model}
      """


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
  render (view currentModel), (document.querySelector "main")


dispatch MSG_INIT