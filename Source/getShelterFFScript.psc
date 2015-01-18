Scriptname getShelterFFScript extends ObjectReference 
{This is the script that will be attached to _DE_CampTent2_ activators.  The ones with the bedroll Models}
;getShelterFFScript 
import math
import Debug


GlobalVariable Property RS_FFIsOn Auto


int Property TentType Auto
int[] Property RainPos Auto hidden
float[] Property Snow1Pos Auto hidden
float[] Property Snow2Pos Auto hidden



;/States
  1 - Disabled/Deleted/
  2 - Disabled
  3 - Active
/;
FormList Property RS_PrecipStatic Auto
FormList Property RS_FFTentList Auto
FormList Property RS_FFSnowOverrides Auto
FormList Property RS_CurrentList Auto
FormList Property RS_RSList Auto
FormList Property RS_WSList Auto
FormList Property RS_ActiveTentList Auto
FormList Property _DE_SevereWeatherList Auto

GlobalVariable Property RS_IsSheltered Auto
GlobalVariable Property RS_Debug Auto
GlobalVariable Property RS_Index Auto
GlobalVariable Property RS_FFUseRSStatic Auto
GlobalVariable Property RS_FFSnowAmount Auto 
GlobalVariable Property RS_FFRainAmount Auto 
GlobalVariable Property RS_TimeUnderShelter Auto
GlobalVariable Property RS_FluidTransitions Auto

GlobalVariable Property RS_HasRegions Auto

;GlobalVariable Property RS_FFTotalTents Auto
;GlobalVariable Property RS_FFGVIndex Auto

;/
  1 - Small Functionr
  2 - Small Leather
  3 - Large Fur
  4 - Large Leather
  5 - MageSpheres
/;


;Bool property isInit = false Auto hidden 
ObjectReference Property OriginPosition Auto hidden
ObjectReference Property WeatherMarker Auto hidden

RS_FFHelperScript Property ScriptHelper1 Auto hidden
RS_FFHelperScript2 Property ScriptHelper2 Auto hidden

static Property XMarker auto

Activator Property RS_FFHelper Auto
Activator Property RS_FFHelper2 Auto


Actor Property PlayerREF auto



;GetShelterData Property ShelterManager auto


int SnowAmount = 23
int RainAmount = 20
int shelterState = 1
int QuestIndex = -1
int regPlaceholder
float playerDistance = 0.0 
float[] relativePos

Int rsWTHRIndx = -1 
Int rsWTHRClass = 0 
Int SwitchTriggerCheck = 0 
;dbRS variables

Bool shelterTransf = false
Bool alive = false
Bool running = false
Bool Updated = false
Bool infWTHR = false

Bool snowEnabled = false
Bool rainEnabled = true
Weather CurrentWeather
Weather RSWeather

ObjectReference[] rain

Event OnInit()
      ;Debug.Notification("Rainsoundfx2 " +rainsoundfx2.GetFormID())
    if RS_FFIsOn.GetValue() == 1
      if RS_HasRegions.GetValue() != 1
        infWTHR = true
      EndIf
      if TentType < 5
        ;If the player is under RealShelter shelter, we don't need the tent to do all this stuff
      while !self.Is3DLoaded()
      EndWhile 
      alive = true
      running = true
     
      relativePos = new float[13]


      relativePos[5] = PlayerREF.GetAngleZ()
      relativePos[11] = GetAngleZ()
      relativePos[0] = PlayerREF.GetPositionX()
      relativePos[1] = PlayerREF.GetPositionY()
      relativePos[2] = PlayerREF.GetPositionZ()
      relativePos[3] = PlayerREF.GetAngleX()
      relativePos[4] = PlayerREF.GetAngleY()
      relativePos[6] = GetPositionX()
      relativePos[7] = GetPositionY()
      relativePos[8] = GetPositionZ()
      relativePos[9] = GetAngleX()
      relativePos[10] = GetAngleY()

      if TentType == 3
        relativePos[12] = relativePos[11] 
      ElseIf TentType == 4
        relativePos[12] = relativePos[11] - 90

      ElseIf TentType <= 2
      relativePos[12] = relativePos[11] - 180
      EndIf
      if RS_Debug.GetValue() != 0
        Trace("RelativePos11 " + relativePos[11]+ " PlayerRefange "+ relativePos[5])
      EndIf
      SetLocalVar()

      ;RS_FFHelper = Game.GetFormFromFile(0x0004F2C0, "RealShelter.esp") as Activator
      StartUpTent()
     
      ;Trace("I" + self +" have just created " + rainsoundfx1 + " and " + rainsoundfx2) 
      ;Debug.Notification("Length" + shelter.GetLength() + "-Width-"+ shelter.GetWidth() + " Height:" + shelter.GetHeight())
      ;Debug.Notification(shelter.GetPositionX() + "-" + shelter.GetPositionY() + "-" + shelter.GetPositionZ())
      ;Debug.Notification(GetPositionX() + "-" + GetPositionY() + "-" + GetPositionZ())
      EndIf
      If TentType == 5
        GotoState("FFCS")
      EndIf 
    EndIf
  
EndEvent


Auto State Default 

Event OnLoad()
    if RS_Debug.GetValue() != 0
  	Trace(self + "I Have Loaded Once")
    EndIf
  GotoState("FFS")
  ;RS_ActiveTentList.AddForm(self as Form)
EndEvent

int Function SetLocalVar()
    CurrentWeather = Weather.GetCurrentWeather()
    rsWTHRClass = CurrentWeather.GetClassification()
      If RS_Debug.GetValue() != 0
      Trace(self +"Inside of SetLocalVar:  wthrClass " + rsWTHRClass)
      EndIf
    RS_Index.SetValue(RS_CurrentList.Find(CurrentWeather as Form))
Return  0
EndFunction

Event OnEndState()
  if SwitchTriggerCheck == 0
    If RS_Debug.GetValue() != 0
    Trace(self+ "I am going inside of FFS")
    EndIf
  SwitchTriggerCheck = 1
  EndIf
EndEvent

EndState

State FFS
    ;/
    ===The Active, but not starting, State Your Shelter is in===
     If it is in this state then that means:
       1.The next Unload will delete temporary references
       2.The next load will recreate them
       3.When CellDetach occurs it will stop registering for updates
       3.When CellAttach occurs it will start registering for updates again /;

      Event OnBeginState()
        Trace(self + "I Have Loaded Twice")
        SwitchTriggerCheck = 3
        RegisterForSingleUpdate(1)
      EndEvent

     Event OnLoad()
     	if SwitchTriggerCheck >= 3
       If RS_Debug.GetValue() != 0
         Trace(self + "I Have loaded more than Twice Creating and Registering")
       EndIf
      RegisterForSingleUpdate(1)
      EndIf
     EndEvent


      Event OnUnload()
        RegisterForUpdate(10)
      	if SwitchTriggerCheck <= 2
      		Trace(self + "Inside of FFS it is at 1")
          SwitchTriggerCheck = 3
      	ElseIf SwitchTriggerCheck == 3
          If RS_Debug.GetValue() != 0
            Trace(self +"I Am Unloading More Than Twice,  checking if I need to Delete Objects")
          EndIf
        EndIf
        if IsDeleted()
         ShutdownTent()
         RS_IsSheltered.SetValue(0)
        EndIf
        UnRegisterForUpdate()
      EndEvent

      Event OnCellAttach()
      running = true
      StartUpTent()
      NewRegister(1)
      EndEvent

      Event OnCellDetach()
        If RS_Debug.GetValue() != 0
          Trace("Inside of CellDetach")
        EndIf
        UnregisterForUpdate()
        shelterTransf = false
        RS_IsSheltered.SetValue(0)
        ShutdownTent()
        DisableRain(false,true)
      EndEvent

      Event OnUpdate()
        float GetTent
        shelterState = RS_FFIsOn.GetValue() as Int
      	if self.Is3DLoaded() && shelterState == 1
      	  if self.IsNearPlayer()
      	     SetLocalVar()
      	    if rsWTHRClass > 1 
        	    	GetTent = CheckIfInside(TentType)
        	      if GetTent > 0 && !shelterTransf
                  RS_TimeUnderShelter.SetValue(0)
          	        if rsWTHRClass == 2
          	            shelterTransf = true
          	            ActivateSoundFX(1)
          	        ElseIf rsWTHRClass == 3
                       shelterTransf = true
                       ActivateSoundFX(2)
                    EndIf
        	      ElseIf GetTent == 0 && shelterTransf
                  ;Trace("inside of 4th  b if Statement")
            	      RevertWeather()
        	      Else
                  RS_TimeUnderShelter.Mod(1.0)
        	        ;Trace(self+"GETTEnt:" + GetTent + "shelterTransf" + shelterTransf)
        	      EndIf  
        	  Elseif shelterTransf
              if !rain[0].isDisabled()
                DisableRain(false)
              Else 
                DisableSnow(false)
              EndIf
              GotoState("WaitingToLeaveTent")
            EndIf
            ;Trace("NewRegister  " + NewRegister(GetDistance(PlayerREF)))
            ;RegisterForSingleUpdate(1)
            NewRegister(playerDistance)
        	Else
          NewRegister(playerDistance)
          ;RegisterForSingleUpdate(1)
        	EndIf
      	EndIf
      EndEvent

    
EndState


State WaitingToLeaveTent

Event OnBeginState()
  If RS_Debug.GetValue() != 0
   Notification("Entering WaitingToLeaveTent")
  EndIf
EndEvent

Event OnUpdate()
  float GetTent
  GetTent = CheckIfInside(TentType)
  If GetTent == 0
     RS_IsSheltered.SetValue(0)
     RevertWeather()
     shelterTransf = false
     RegisterForSingleUpdate(0.5)
     GotoState("FFS")
  EndIf
  RegisterForSingleUpdate(0.5)
EndEvent

Event OnEndState()
  If RS_Debug.GetValue() != 0
    Notification("Leaving WaitingToLeaveTent")
  EndIf
EndEvent

EndState

Event OnUpdate()
EndEvent


Event OnCellAttach()
EndEvent

Event OnCellDetach()
EndEvent

float Function CheckIfInside(int TentNum)
  ;Original function created by Chesko,  mod it over to GetShelter because it would be wasteful to 
  ;constantly check for things we do not need.
  float iIsInTent = 0
  ObjectReference myTent
  If TentNum == 1
      myTent = Game.FindClosestReferenceOfAnyTypeInListFromRef(RS_FFTentList, playerREF, 50.0)
      if myTent
        iIsInTent = 1
        return iIsInTent
      endif
  ElseIf TentNum == 3
        myTent = Game.FindClosestReferenceOfAnyTypeInListFromRef(RS_FFTentList, playerREF, 146.0)
        if myTent
          iIsInTent = 2
          return iIsInTent
        endif
  ElseIf TentNum == 2
        myTent = Game.FindClosestReferenceOfAnyTypeInListFromRef(RS_FFTentList, playerREF, 85.0)
        if myTent
         iIsInTent = 3
         return iIsInTent
        endif
  ElseIf TentNum == 4
        myTent = Game.FindClosestReferenceOfAnyTypeInListFromRef(RS_FFTentList, playerREF, 195.0)
        if myTent
          iIsInTent = 4
          return iIsInTent
        endif
  EndIf
  Return iIsInTent
EndFunction   


Int Function NewRegister(float PlayerDist)
	if PlayerDist < 200
    RegisterForSingleUpdate(1)
        return 1
	ElseIf PlayerDist < 400
    RegisterForSingleUpdate(2)
        return 2
	ElseIf PlayerDist < 600
    RegisterForSingleUpdate(3)
        return 3
	Elseif PlayerDist < 800
    RegisterForSingleUpdate(4)
        return 4
	Elseif PlayerDist < 1000
    RegisterForSingleUpdate(5)
        return 5
	Elseif PlayerDist < 1200
    RegisterForSingleUpdate(6)
        return 6
  Elseif PlayerDist < 1400
    RegisterForSingleUpdate(7)
     return 7
  Elseif PlayerDist < 1600
    RegisterForSingleUpdate(8)
     return 8
  Elseif PlayerDist < 1800
    RegisterForSingleUpdate(9)
     return 9
  Elseif PlayerDist < 2100
    RegisterForSingleUpdate(10)
    return 10
  Elseif PlayerDist < 2300
    RegisterForSingleUpdate(11)
    return 11
  Elseif PlayerDist < 2500
    RegisterForSingleUpdate(12)
    return 12
  Elseif PlayerDist < 2900
    RegisterForSingleUpdate(13)
    return 13
  Elseif PlayerDist > 3000
    RegisterForSingleUpdate(14)
    return 14
	EndIf
  RegisterForSingleUpdate(15)
	return 15
EndFunction

Function StartUpTent()
  if RS_FFRainAmount
      RainAmount = RS_FFRainAmount.GetValue() as Int
      SnowAmount = RS_FFSnowAmount.GetValue() as Int
  EndIf

      CreateMarkers()
      CreateHelpers()
      ;GetProperties()
      CreateSnowEvent()
      CreateRain()
EndFunction

Function ShutdownTent()
    RevertWeather()
    DisableSnow(true)
    DisableRain(false, true)
    DeleteRain()
    DeleteMarkers()
    shelterTransf = false
    running = false
    RS_IsSheltered.SetValue(0)
EndFunction



int Function SetLocalVar()
    CurrentWeather = Weather.GetCurrentWeather()
    rsWTHRClass = CurrentWeather.GetClassification()
    ;Trace(self +"Inside of SetLocalVar:  wthrClass " + rsWTHRClass)
Return  0
EndFunction


int Function RevertWeather()
  Weather Temp = Weather.GetCurrentWeather()
  If rsWTHRIndx != -1
    if RS_RSList.HasForm(Temp)
      RSWeather = RS_CurrentList.GetAt(rsWTHRIndx) as Weather
      RSWeather.ForceActive()
      Utility.Wait(0.1)
      RS_Index.SetValue(rsWTHRIndx)
       RS_IsSheltered.SetValue(0)
      shelterTransf = false
    EndIF 
    ;Debug.MessageBox("rsWTHRIndx != -1" + (RS_CurrentList.GetAt(rsWTHRIndx) as Weather))
  ElseIf RS_RSList.HasForm(Temp)
    rsWTHRIndx = RS_RSList.Find(Temp)
    Utility.Wait(0.1)
    CurrentWeather = RS_CurrentList.GetAt(rsWTHRIndx) as Weather
    CurrentWeather.ForceActive()
    RS_Index.SetValue(rsWTHRIndx)
  EndIf
    DisableSnow(false)
    DisableRain(true)
  Return 1
EndFunction


int Function CreateMarkers()
    Weather updateWeather = Weather.GetCurrentWeather()
    float windDirection = updateWeather.GetWindDirection()
   If RS_Debug.GetValue() != 0
   Trace("About To set Markers OriginPostion and WeatherMarker")
   EndIf
	 OriginPosition = PlaceAtMe(XMarker)
   OriginPosition.SetPosition(relativePos[6],relativePos[7],relativePos[8])
   OriginPosition.SetAngle(0,0,relativePos[12])
   WeatherMarker = OriginPosition.PlaceAtMe(XMarker)
   WeatherMarker.MoveTo(OriginPosition,1000*Sin(windDirection),1000*Cos(windDirection),relativePos[8])
Return 0
EndFunction


int Function DeleteMarkers()
  OriginPosition.Disable()
  WeatherMarker.Disable()
  OriginPosition.Delete()
  WeatherMarker.Delete()
Return 0
EndFunction

int Function CreateHelpers()
  float MHA = OriginPosition.GetHeadingAngle(WeatherMarker)
  int halfAmount = SnowAmount/2
  ;Activator RS_FFHelper2 = Game.GetForm as Activator
  If RS_Debug.GetValue() != 0
    Trace("About To Create Helpers")
  EndIf
  ScriptHelper1 = PlaceAtMe(RS_FFHelper) as RS_FFHelperScript
  ScriptHelper1.SetPosition(relativePos[6],relativePos[7],relativePos[8])
  ScriptHelper1.GiveInfo(true, MHA, TentType,(relativePos[12]),RS_FFTentList,_DE_SevereWeatherList, RS_TimeUnderShelter, RS_Debug)
  ScriptHelper2 = PlaceAtMe(RS_FFHelper2) as RS_FFHelperScript2
  ScriptHelper2.SetPosition(relativePos[6],relativePos[7],relativePos[8])
  ScriptHelper2.GiveInfo(false, MHA, TentType,(relativePos[12]),RS_FFTentList,_DE_SevereWeatherList, RS_TimeUnderShelter, RS_Debug)
  
  If RS_Debug.GetValue() != 0
    Trace("ScriptHelper1: " + ScriptHelper1)
    Trace("ScriptHelper2: " + ScriptHelper2)
  EndIf
  
  Return 0
EndFunction

int Function CreateRain()
 int i = 0
 int i2 = RainAmount
 int FirstHalf = (RainAmount/2)
 float xPos
 float yPos
 float relePos = relativePos[5]

 Form rainNear
 Form rainFar 


 If RS_FFUseRSStatic
    If RS_FFUseRSStatic.GetValue() >= 1
      i2 = 6
      FirstHalf = 3
      rainNear = RS_PrecipStatic.GetAt(5)
      rainFar = RS_PrecipStatic.GetAt(5)
    Else
      rainNear = RS_PrecipStatic.GetAt(0)
      rainFar = RS_PrecipStatic.GetAt(1)
    EndIf
 Else
   rainNear = RS_PrecipStatic.GetAt(0)
   rainFar = RS_PrecipStatic.GetAt(1)
 EndIf

  If i2 < 21
    rain = new ObjectReference[20]
  ElseIF i2 > 20 && i2 < 41
    rain = new ObjectReference[40]
  ElseIF i2 > 40 && i2 < 61
    rain = new ObjectReference[60]
  ElseIF i2 > 60 && i2 < 81
    rain = new ObjectReference[80]
  ElseIF i2 > 80 && i2 < 101
    rain = new ObjectReference[100]
  Else 
    rain = new ObjectReference[128]
  EndIf

   If TentType == 3
    xPos = -3000*Sin(relePos)
    YPos = -300*Cos(relePos)
  ElseIf TentType == 4
    xPos = 100*Sin(relePos)
    YPos = 100*Cos(relePos)
  EndIf
  while i < rain.Length
    if rain[i] == none
     if i > FirstHalf
      rain[i] = OriginPosition.PlaceAtMe(rainFar,1,abForcePersist = false, abInitiallyDisabled = true)
      rain[i].MoveTo(OriginPosition,0,0,600)
     Else
      rain[i] = OriginPosition.PlaceAtMe(rainNear,1,abForcePersist = false, abInitiallyDisabled = true)
      rain[i].MoveTo(OriginPosition,xPos,yPos,800)
      
      ;rain[i].MoveTo(OriginPosition,0,0,800)
     EndIf
      If TentType == 3
      rain[i].SetAngle(0,0,relePos+90)
      ElseIf TentType == 4
      rain[i].SetAngle(0,0,relePos)  
      EndIf
    else
      i += 1
    endif
   EndWhile
  If RS_Debug.GetValue() != 0
  Notification("Finished Creating Rain")
  EndIf
Return 0
EndFunction

Function EnableRain(bool bFade)
 Int iIndex = 0

  While iIndex < rain.Length
        if rain[iIndex] != none
        rain[iIndex].EnableNoWait(bFade)
        EndIf
        iIndex += 1
  EndWhile
   If RS_Debug.GetValue() != 0
    Notification("I am Enabling Rain " + rain.Length)
    Trace("I Am Enabling Rain")
  EndIf
  Utility.Wait(0.2)
EndFunction

Function DisableRain(bool bFade, bool bFastMode = false)
 Int iIndex = 0
  While iIndex < rain.Length
        if rain[iIndex] != none
        rain[iIndex].DisableNoWait(bFade)
        EndIf
        iIndex += 1
  EndWhile
  If !bFastMode
  Utility.Wait(0.2)
  EndIf
EndFunction

Function DeleteRain()
    If RS_Debug.GetValue() != 0
    Notification("I am Deleting Rain")
    Trace("I Am Deleting Rain")
    EndIf
  Int iIndex = 0
  While iIndex < RainAmount
        rain[iIndex].Delete()
        rain[iIndex] = none
        iIndex += 1
  EndWhile
EndFunction


Function CreateSnowEvent()

ScriptHelper1.RegisterForModEvent("RS_CreateSnowEvent", "RS_CreateSnow")
ScriptHelper2.RegisterForModEvent("RS_CreateSnowEvent", "RS_CreateSnow")
Form tempForm = Game.GetFormFromFile(0x0004F2C5,"RealShelter.esp")

  int Handle = ModEvent.Create("RS_CreateSnowEvent")
    if (handle)
      ModEvent.PushForm(handle, tempForm)
      ModEvent.Send(handle)
    EndIf
  
EndFunction


Function EnableSnow(float WTHRIndx)
  float MHA = OriginPosition.GetHeadingAngle(WeatherMarker)
  GlobalVariable temp = (RS_WSList.GetAt(WTHRIndx as Int) as GlobalVariable)
  float temp2 = temp.GetValue()
  ScriptHelper1.RegisterForModEvent("RS_EnableSnow", "EnableSnow")
  ScriptHelper2.RegisterForModEvent("RS_EnableSnow", "EnableSnow")

  int handle = ModEvent.Create("RS_EnableSnow")
    if (handle)
      ModEvent.PushFloat(handle, temp2)
      ModEvent.PushFloat(handle, MHA)
      ModEvent.PushFloat(handle, WTHRIndx)
      ModEvent.Send(handle)
    EndIf

  
;ScriptHelper1.RegisterForEvents()
;ScriptHelper2.RegisterForEvents()
;ScriptHelper1.EnableSnow(temp.GetValue(), MHA)
;ScriptHelper2.EnableSnow(temp.GetValue(), MHA)

EndFunction

Function DisableSnow(bool bDelete)
  ScriptHelper1.RegisterForModEvent("RS_DisableSnow", "DisableSnow")
  ScriptHelper2.RegisterForModEvent("RS_DisableSnow", "DisableSnow")
   int handle = ModEvent.Create("RS_DisableSnow")
    if (handle)
      ModEvent.PushBool(handle,bDelete)
      ModEvent.Send(handle)
    EndIf
EndFunction

Function ActivateSoundFX(int Choices)
  Form rsWeatherForm
  Form tempW = Weather.GetCurrentWeather() as Form
  rsWTHRIndx = RS_Index.GetValue() As Int
  RS_TimeUnderShelter.SetValue(0.0)
  If (tempW as Form != RS_CurrentList.GetAt(rsWTHRIndx))
      rsWTHRIndx = RS_CurrentList.Find(tempW)
  EndIf
  Utility.Wait(0.1)
  if rsWTHRIndx != -1
    EnableVisualFX(Choices,rsWTHRIndx)
     RS_IsSheltered.SetValue(1)
     rsWeatherForm = RS_RSList.GetAt(rsWTHRIndx) 
     RSWeather = rsWeatherForm as Weather
     RS_Index.SetValue(rsWTHRIndx)
     If RS_FluidTransitions.GetValue() > 0
      RSWeather.SetActive(infWTHR,true)
     Else
      RSWeather.ForceActive(infWTHR)
     EndIf
  Else
    Utility.Wait(0.1)
    if RS_RSList.HasForm(tempW)
      rsWTHRIndx = RS_RSList.Find(tempW)
      RS_Index.SetValue(rsWTHRIndx)
    EndIf
  EndIf
  
EndFunction 

Function EnableVisualFX(int choices, int wIndex)
  If wIndex != -1
    If Choices == 1
      EnableRain(true)
    ElseIf Choices == 2
      EnableSnow(wIndex)
    EndIf
  EndIf
EndFunction

bool Function IsNearPlayer()
 
  Cell targetCell = self.GetParentCell()
  Cell playerCell = playerREF.GetParentCell()
  
  if (targetCell != playerCell)
    ; player and target are in different cells
    if (targetCell && targetCell.IsInterior() || playerCell && playerCell.IsInterior())
      ; in different cells and at least one is an interior
      ;  -- we can safely enable or disable
      playerDistance = 4000
      return false
    else
     playerDistance = playerREF.GetDistance(self)
     return true
    EndIf
  else
    playerDistance = playerREF.GetDistance(self)
    ; in the same cell -- err on the side of caution
    return true
  endif
endFunction