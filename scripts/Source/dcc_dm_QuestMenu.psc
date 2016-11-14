Scriptname dcc_dm_QuestMenu extends SKI_ConfigBase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dcc_dm_QuestController Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Function GetVersion()
	Return 1
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnGameReload()
{things to do when the game is loaded from disk.}

	parent.OnGameReload()

	;; do a dependency check every launch.
	
	Main.ResetMod_Prepare()

	;; do a self bondage check for the lulz.

	If(Main.BehaviourPackageGet(Main.Player) != None)
		Main.Print("Your self-bondage timer has been reset.")
		StorageUtil.SetFloatValue(Main.Player,"DM2.Actor.BondageClientStart",Utility.GetCurrentRealTime())
		Main.PrintDebug("GIVE BUFF MKAY")
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnConfigInit()
{things to do when the menu initalises (is opening)}

	self.Pages = new String[3]

	self.Pages[0] = "General"
	self.Pages[1] = "Debug & Repair"
	self.Pages[2] = "Splash"

	Return
EndEvent

Event OnConfigOpen()
{things to do when the menu actually opens.}

	self.OnConfigInit()
	Return
EndEvent

Event OnConfigClose()
{things to do when the menu closes.}

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnPageReset(String Page)
{when a different tab is selected in the menu.}

	self.UnloadCustomContent()

	If(Page == "General")
		self.ShowPageGeneral()
	ElseIf(Page == "Debug & Repair")
		self.ShowPageDebug()
	Else
		self.ShowPageIntro()
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnOptionSelect(Int Item)
	Bool Val = FALSE

	If(Item == ItemReset)
		self.SetToggleOptionValue(Item,TRUE)
		Debug.MessageBox("Quit the menu fully to finish resetting.")
		Utility.Wait(0.20)
		Main.ResetMod()
		Return
	EndIf

	If(Item == ItemResetBondageTimeStat)
		Main.ActorBondageTimeReset(Main.Player)
		Debug.MessageBox("Your bondage time stat has been reset to zero.")
		Return
	EndIf

	;; ShowPageGeneral()
	If(Item == ItemTutorials)
		Val = !Main.OptTutorials
		Main.OptTutorials = Val
	ElseIf(Item == ItemPoseCancelNIOHH)
		Val = !Main.OptPoseCancelNIOHH
		Main.OptPoseCancelNIOHH = Val
	ElseIf(Item == ItemArousedTickSound)
		Val = !Main.OptArousedTickSound
		Main.OptArousedTickSound = Val
	ElseIf(Item == ItemArousedTickExpression)
		Val = !Main.OptArousedTickExpression
		Main.OptArousedTickExpression = Val
	ElseIf(Item == ItemArousedTickBlush)
		Val = !Main.OptArousedTickBlush
		Main.OptArousedTickBlush = Val
	ElseIf(Item == ItemArousedTickExposure)
		Val = !Main.OptArousedTickExposure
		Main.OptArousedTickExposure = Val
	ElseIf(Item == ItemArousedTickTimeRate)
		Val = !Main.OptArousedTickTimeRate
		Main.OptArousedTickTimeRate = Val

	;; ShowPageDebug()
	ElseIf(Item == ItemDebug)
		Val = !Main.OptDebug
		Main.OptDebug = Val


	EndIf

	self.SetToggleOptionValue(Item,Val)
	Return
EndEvent

Event OnOptionSliderOpen(Int Item)
	Float Val = 0.0
	Float Min = 0.0
	Float Max = 0.0
	Float Interval = 0.0

	If(Item == ItemArousedTickFactor)
		Val = Main.OptArousedTickFactor
		Min = 0.01
		Max = 5.0
		Interval = 0.01
	ElseIf(Item == ItemForceBondageTime)
		Val = Main.OptForceBondageTime / 60.0
		Min = 0.0
		Max = 60.0
		Interval = 0.25
	ElseIf(Item == ItemEscapeBondageChance)
		Val = Main.OptEscapeBondageChance
		Min = 0.0
		Max = 100.0
		Interval = 1.0
	EndIf

	SetSliderDialogStartValue(Val)
	SetSliderDialogRange(Min,Max)
	SetSliderDialogInterval(Interval)
	Return
EndEvent

Event OnOptionSliderAccept(Int Item, Float Val)
	String Fmt = "{0}"

	If(Item == ItemArousedTickFactor)
		Main.OptArousedTickFactor = Val
		Fmt = "x{2}"
	ElseIf(Item == ItemForceBondageTime)
		Main.OptForceBondageTime = (Val * 60) as Int
		Fmt = "{2} Min"
	ElseIf(Item == ItemEscapeBondageChance)
		Main.OptEscapeBondageChance = Val as Int
		Fmt = "{0}%"
	EndIf

	SetSliderOptionValue(Item,Val,Fmt)
	Return
EndEvent

Event OnOptionHighlight(Int Item)

	;; ShowPageGeneral()
	If(Item == ItemTutorials)
		self.SetInfoText("Show popup messages that explain how things work.")
	ElseIf(Item == ItemPoseCancelNIOHH)
		self.SetInfoText("Cancel out any offsets done by NIO HH type equip effects. Your heels will clip through the devices, but the character will fit the bindings and that is better.")
	ElseIf(Item == ItemArousedTickFactor)
		self.SetInfoText("Bondage modifies 'Arousal' by '1' every 30 seconds (SLA will actually math differnet things). Use this to as a multiplier of that.")
	ElseIf(Item == ItemArousedTickExposure)
		self.SetInfoText("Bondage modifies Arousal Exposure - this is the default way Arousal is modified. The amount it changes is equal to the factor value above. Normal characters, Arousal is lowered by self bondage. If your character is flagged as an Exhibitionist in SLA then your arousal goes up instead.")
	ElseIf(Item == ItemArousedTickTimeRate)
		self.SetInfoText("Bondage modifies Time Rate - most mods do not do this, but for me self bondage totally counts as release from time based sexual tension and can often be just as good a replacement. The amount it changes is equal to 1/8th of the factor rate above. Unlike Exposure time rate only goes down, Exhibitionist or not.")
	ElseIf(Item == ItemArousedTickSound)
		self.SetInfoText("Characters will moan when their arousal updates.")
	ElseIf(Item == ItemArousedTickExpression)
		self.SetInfoText("Characters faces will distort in delight when arousal updates.")
	ElseIf(Item == ItemArousedTickBlush)
		self.SetInfoText("Characters will blush in ecstasy when arousal updates.")
	ElseIf(Item == ItemFnisYouFuck)
		self.SetInfoText("You need to run GenerateFNISforUsers after installing or updating this mod or any mods that this mod depends on. If you post stupid things on the forum I will make fun of you.")
	ElseIf(Item == ItemHasUIExtensions)
		self.SetInfoText("Detects if UI Extensions is installed.")
	Elseif(Item == ItemHasZap)
		self.SetInfoText("Detects if ZaZ Animation Pack is intalled.")
	ElseIf(Item == ItemHasSexLab)
		self.SetInfoText("Detects if SexLab is installed.")
	ElseIf(Item == ItemHasSexLabActive)
		self.SetInfoText("If this is FALSE then go to the SexLab MCM and turn it on.")
	ElseIf(Item == ItemHasPapyrusUtil)
		self.SetInfoText("If this is FALSE then something like SoS overwrote SexLab or PapyrusUtil. Fix your load order or reinstall SoS with PapyrusUtil disabled.")
	ElseIf(Item == ItemStatBondageTimePlayerGame)
		self.SetInfoText("How long the player has spent in self bondage in Skyrim Time.")
	ElseIf(Item == ItemStatBondageTimePlayerReal)
		self.SetInfoText("How long the player has spent bound in real life time. This is only an estimate. If you change your timescale mid-game or use a dynamic timescale mod, this number will not be accurate. The above game time however is.")
	ElseIf(Item == ItemForceBondageTime)
		self.SetInfoText("Disallow the player to escape self-bondage until this amount of your real life time has passed. Set to 0 to disable.")
	ElseIf(Item == ItemEscapeBondageChance)
		self.SetInfoText("Chance that the player can escape self-bondage before the timer expires.")

	;; ShowPageDebug()
	ElseIf(Item == ItemReset)
		self.SetInfoText("Perform a mod reset.")
	ElseIf(Item == ItemDebug)
		self.SetInfoText("Display debugging output.")

	;; default
	Else
		self.SetInfoText("Display Model II")
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ShowPageIntro()
	LoadCustomContent("dcc-display-model/splash.dds")
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int ItemTutorials
Int ItemHasUIExtensions
Int ItemHasZap
Int ItemHasSexLab
Int ItemHasSexLabActive
Int ItemHasPapyrusUtil
Int ItemFnisYouFuck
Int ItemHasAroused
Int ItemPoseCancelNIOHH
Int ItemArousedTickFactor
Int ItemArousedTickExposure
Int ItemArousedTickTimeRate
Int ItemArousedTickSound
Int ItemArousedTickExpression
Int ItemArousedTickBlush
Int ItemForceBondageTime
Int ItemEscapeBondageChance

Int ItemStatBondageTimePlayerGame
Int ItemStatBondageTimePlayerReal

Function ShowPageGeneral()
{main options and status page}

	Main.ActorBondageTimeUpdate(Main.Player)
	Main.ActorBondageTimeStart(Main.Player)

	self.SetTitleText("General")
	self.SetCursorFillMode(TOP_TO_BOTTOM)
	
	self.SetCursorPosition(0)
	self.AddHeaderOption("General Settings")
	ItemTutorials = self.AddToggleOption("Enable Tutorials",Main.OptTutorials)
	ItemPoseCancelNIOHH = self.AddToggleOption("Cancel NIO HH When Bound",Main.OptPoseCancelNIOHH)
	ItemArousedTickFactor = self.AddSliderOption("Arousal Mod Factor",Main.OptArousedTickFactor,"{2}x")
	ItemArousedTickExposure = self.AddToggleOption("Arousal Mod Exposure",Main.OptArousedTickExposure)
	ItemArousedTickTimeRate = self.AddToggleOption("Arousal Mod Time Rate",Main.OptArousedTickTimeRate)
	ItemArousedTickSound = self.AddToggleOption("Arousal Mod Moans",Main.OptArousedTickSound)
	ItemArousedTickExpression = self.AddToggleOption("Arousal Mod Expression",Main.OptArousedTickExpression)
	ItemArousedTickBlush = self.AddToggleOption("Arousal Mod Blush",Main.OptArousedTickBlush)

	If(Main.BehaviourPackageGet(Main.Player) != None)
		ItemForceBondageTime = self.AddSliderOption("Force Bondage Time",(Main.OptForceBondageTime / 60.0),"{2} Min",OPTION_FLAG_DISABLED)
		ItemEscapeBondageChance = self.AddSliderOption("Escape Bondage Chance",Main.OptEscapeBondageChance,"{0}",OPTION_FLAG_DISABLED)
	Else
		ItemForceBondageTime = self.AddSliderOption("Force Bondage Time",(Main.OptForceBondageTime / 60.0),"{2} Min")
		ItemEscapeBondageChance = self.AddSliderOption("Escape Bondage Chance",Main.OptEscapeBondageChance,"{0}%")
	EndIf


	self.SetCursorPosition(1)
	self.AddHeaderOption("Requirements")	
	ItemFnisYouFuck = self.AddHeaderOption("DON'T FORGET: RUN FNIS")
	ItemHasUIExtensions = self.AddToggleOption("UI Extensions",Main.IsInstalledUIExtensions(FALSE),OPTION_FLAG_DISABLED)
	ItemHasZap = self.AddToggleOption("ZaZ Animation Pack",Main.IsInstalledZap(FALSE),OPTION_FLAG_DISABLED)
	ItemHasSexLab = self.AddToggleOption("SexLab Installed",Main.IsInstalledSexLab(FALSE),OPTION_FLAG_DISABLED)
	ItemHasSexLabActive = self.AddToggleOption("SexLab Running",Main.IsInstalledSexLabReally(FALSE),OPTION_FLAG_DISABLED)
	ItemHasPapyrusUtil = self.AddToggleOption("Papyrus Util > 3.1",Main.IsInstalledPapyrusUtil(FALSE),OPTION_FLAG_DISABLED)

	self.AddHeaderOption("Optional Support")
	ItemhasAroused = self.AddToggleOption("SexLab Aroused",Main.IsInstalledAroused(FALSE),OPTION_FLAG_DISABLED)

	self.AddHeaderOption("Stats")
	ItemStatBondageTimePlayerGame = self.AddTextOption("Game Time Bound",Main.ReadableTimeDelta(Main.ActorBondageTimeTotal(Main.Player)),OPTION_FLAG_DISABLED)
	ItemStatBondageTimePlayerReal = self.AddTextOption("Real Time Bound",Main.ReadableTimeDelta(Main.ActorBondageTimeTotal(Main.Player),TRUE),OPTION_FLAG_DISABLED)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int ItemDebug
Int ItemReset
Int ItemResetBondageTimeStat

Function ShowPageDebug()
	self.SetTitleText("Debugging")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	self.AddHeaderOption("Repair")
		self.AddHeaderOption("")
	ItemReset = self.AddToggleOption("Reset Mod",FALSE)
		ItemResetBondageTimeStat = self.AddToggleOption("Reset Bondage Time Stat",FALSE)

	self.AddHeaderOption("Debugging")
		self.AddHeaderOption("")
	ItemDebug = self.AddToggleOption("Debugging Messages",Main.OptDebug)
		self.AddEmptyOption()

	Return
EndFunction
