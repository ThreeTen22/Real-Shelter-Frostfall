Scriptname RS_FFRainScript extends ObjectReference  

import Debug
import Math

FormList Property RS_PrecipStatic Auto hidden

GlobalVariable Property RS_IsSheltered Auto hidden
GlobalVariable Property RS_Debug Auto hidden
GlobalVariable Property RS_Index Auto hidden
GlobalVariable Property RS_FFUseRSStatic Auto hidden
GlobalVariable Property RS_FFRainAmount Auto hidden

int Property i2 = 20 Auto hidden
int Property TentType Auto hidden

bool isCreating = false 
float Property relePos Auto hidden
ObjectReference[] Property rain Auto hidden

ObjectReference Property OriginPosition Auto hidden
Form Property TempForm Auto hidden

bool Function GiveInfo(GlobalVariable Debugg, GlobalVariable Index, GlobalVariable FFUseRSStatic, GlobalVariable FFRainAmount, FormList PrecipStatic, ObjectReference OriginPos, int TentNumber, int RainNumber,Form formTypes, float relePosition)
RS_Debug = Debugg
RS_Index = Index
RS_FFUseRSStatic = FFUseRSStatic
RS_FFRainAmount = FFRainAmount
RS_PrecipStatic = PrecipStatic
TentType = TentNumber
OriginPosition = OriginPos
TempForm = formTypes
relePos = relePosition
RegisterForSingleUpdate(0)
return true
EndFunction

Event OnUpdate()
	RS_CreateRain(TempForm, relePos)
EndEvent

Event RS_CreateRain(Form Type, float relePos)
	Trace(self + " Creating Rain Now")
 isCreating = true
 i2 = RS_FFRainAmount.GetValue() as Int
 int i = 0
 int FirstHalf = (i2/2)
 float xPos
 float yPos
 float xPosNear = 0.0
 float yPosNear = 0.0


 Form rainNear
 Form rainFar 
 

 If RS_FFUseRSStatic
    If RS_FFUseRSStatic.GetValue() >= 1
      i2 = 6
      FirstHalf = 6
      xPosNear = 400.0*Sin(relePos)
      YPosNear = 400.0*Cos(relePos)
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
  while i < i2+-1
    if rain[i] == none
     if i > FirstHalf
      rain[i] = OriginPosition.PlaceAtMe(rainFar,1,abForcePersist = false, abInitiallyDisabled = true)
      rain[i].MoveTo(OriginPosition,xPosNear,yPosNear,600)
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
      i += 1
    else
      i += 1
    endif
   EndWhile
  If RS_Debug.GetValue() != 0
  Notification("Finished Creating Rain")
  EndIf
isCreating = false
EndEvent

Function EnableRain(bool bFade)
 Int iIndex = rain.Length

   If RS_Debug.GetValue() != 0
    Trace("I am Enabling Rain " + rain.Length + " " + isCreating)
  EndIf
 While isCreating == true
	Utility.Wait(0.1)
 EndWhile
  While iIndex > 0
        iIndex -= 1
        if rain[iIndex] != none
        rain[iIndex].EnableNoWait(bFade)
        EndIf
  EndWhile
  Utility.Wait(0.2)
EndFunction

Event DisableRain(bool bFade, bool bFastMode = false)
 Int iIndex = rain.Length
  While iIndex > 0
        iIndex -= 1
        if rain[iIndex] != none
        rain[iIndex].DisableNoWait(bFade)
        EndIf
  EndWhile
  If !bFastMode
  Utility.Wait(0.2)
  EndIf
EndEvent

Function DeleteRain()
  Int iIndex = 0
  While iIndex < rain.Length
      If rain[iIndex] != none
        rain[iIndex].Delete()
        rain[iIndex] = none
      endif
        iIndex += 1
  EndWhile
  Debug.Trace("RealShelter: Frostfall Ignore Warning Below")
  rain = none
EndFunction

Event DeleteSelf()
	RegisterForUpdate(100)
	DisableRain(false)
	DeleteRain()
	If RS_Debug.GetValue() != 0
    Notification("I am Deleting Rain")
    Trace("I Am Deleting Rain")
    EndIf
    Disable()
    UnregisterForUpdate()
    Delete()
EndEvent

bool Function isReady()
 while isCreating == false
 	Utility.Wait(0.1)
 EndWhile
return true
EndFunction