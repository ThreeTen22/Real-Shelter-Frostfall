Scriptname RS_FFHelperScript extends ObjectReference  
{This guy is created, usually as part of as pairr, when a tent is placed down.  These contain self contained processes that help share the load of creating rain and snow.}

import math
import Debug

GlobalVariable Property RS_FFSnowAmount Auto 
GlobalVariable Property RS_Index Auto 
GlobalVariable Property RS_TimeUnderShelter Auto
GlobalVariable Property RS_Debug Auto
FormList Property RS_CurrentList Auto
FormList Property RS_WSList Auto
FormList Property _DE_SevereWeatherList Auto
FormList Property TentStaticList Auto hidden

Bool createdSnow = false
Bool Left = False
Bool hasPos = False

int TentType
float MHA
float AngleZ = 0.0

float[] Property snowPos Auto

ObjectReference[] snow


bool Function GiveInfo(Bool Leftt, float MHAngle, int tentTypee, float relativPoss, FormList Tent, FormList severeWeather, GlobalVariable TimeUnderShelter, GlobalVariable debug1)

  Left = Leftt
  MHA = MHAngle
  TentType = tentTypee
  AngleZ = relativPoss
  TentStaticList = Tent
  _DE_SevereWeatherList = severeWeather
  RS_TimeUnderShelter = TimeUnderShelter
  RS_Debug = debug1
  return true
EndFunction


Event RS_CreateSnow(Form Type, float relePos)
  
  int Amount = RS_FFSnowAmount.GetValue() As Int
  ;DEBUG===========
  ;Amount = 128
  ;ENDDEBUG=======
  int i = 0
  Amount /= 2
  If Amount < 11
    snow = new ObjectReference[10]
  ElseIF Amount > 10 && Amount < 21
    snow = new ObjectReference[20]
  ElseIF Amount > 20 && Amount < 31
    snow = new ObjectReference[30]
  ElseIF Amount > 30 && Amount < 41
    snow = new ObjectReference[40]
  ElseIF Amount > 40 && Amount < 51
    snow = new ObjectReference[50]
  Else 
    snow = new ObjectReference[64]
  EndIf
  If hasPos == false 
    GetSnowPositions()
  EndIf

  While i < Amount
    snow[i] = PlaceAtMe(Type,1,abForcePersist = false, abInitiallyDisabled = true)
    ;Trace(self + "Left? " + Left + "Snow:" +snow[i])
    i += 1
  EndWhile
  createdSnow = true

  If RS_Debug.GetValue() != 0
  Notification("Finished Creating Snow")
  EndIf

EndEvent



Function GetSnowPositions()
  int Amount = RS_FFSnowAmount.GetValue() As Int
  ;DEBUG===========
    ;Amount = 128
  ;ENDDEBUG=======
    If Amount < 21
      snowPos = new float[20]
    ElseIF Amount > 20 && Amount < 41
      snowPos = new float[40]
    ElseIF Amount > 40 && Amount < 61
      snowPos = new float[60]
    ElseIF Amount > 60 && Amount < 81
      snowPos = new float[80]
    ElseIF Amount > 80 && Amount < 101
      snowPos = new float[100]
    Else 
      snowPos = new float[128]
    EndIf

    int i = 0
    int j = 0
    float range
    float Height
    float Distance 
    float rangeFar
    float HeightFar
    float DistanceFar
    int halfAmount
    float increments
    float appliedAmount
    float angle
    Bool switch = false
   
    
      Amount = Amount/2
      range = 50

      if TentType == 4
      Height = 250.0
      Distance = 500
      DistanceFar = 600
      ElseIf TentType == 3
      range = 80
      Height = 250.0
      Distance = 500
      DistanceFar = 600
      ElseIF TentType <= 2
      Height = 200.0
      Distance = 400
      DistanceFar = 500
      EndIf

   
      halfAmount = Amount/2
      increments = range/halfAmount
      appliedAmount = 0
    If Left
      increments = -increments
    EndIf

  while i < Amount
    ;Trace("i: "+ i+ " Amount: " + Amount)
      angle = AngleZ+appliedamount
      if i <  halfAmount  

      snowPos[j] = Distance*Sin(angle)
      snowPos[j+1] = Distance*Cos(angle)
      appliedamount += increments
      Else
        If !switch
        Distance = DistanceFar
        appliedamount = 0
        switch = true
        EndIf
      snowPos[j] = Distance*Sin(angle)
      snowPos[j+1] = Distance*Cos(angle)
      appliedamount += increments
      EndIf 

      
    j += 2
    i += 1
  EndWhile
hasPos = true
If Left
  If RS_Debug.GetValue() != 0
  Notification("GatheredPositions: I Am Left")
  EndIf
Else
  If RS_Debug.GetValue() != 0
  Notification("GatheredPositions: I Am Right")
  EndIf
EndIf

EndFunction

Event EnableSnow(float windspeed, float MHAa, float rsIndex)
  form cWeather = RS_CurrentList.GetAt(rsIndex as Int)
  Weather updateWeather = cWeather as Weather
  float windDirection = updateWeather.GetWindDirection()
  float windRange = updateWeather.GetWindDirectionRange()
  float angle2
  float multiple = -90*(0.0044*windSpeed)
  Int iIndex = snow.Length
  Int posArraySize = 0
  float randomheight
  Int increase = 2
  Int i = 0
  
  if _DE_SevereWeatherList.HasForm(cWeather)
    If RS_Debug.GetValue() != 0  
      Notification("Severe Weather Detected")
    EndIf
    increase = 1
  EndIf
  if hasPos
    While i < iIndex
        if snow[i] != none
          angle2 = Utility.RandomFloat(windRange*(1+MHAa), -windRange*(1+MHAa)) + windDirection
          randomHeight = Utility.RandomFloat(150, 350)
          snow[i].MoveTo(self, snowPos[posArraySize], snowPos[posArraySize+1],randomHeight)
          snow[i].SetAngle(multiple,0,angle2)
          snow[i].EnableNoWait(true)
          ;snow[iIndex].SetAngle(0,0,180)
        EndIf
      i += increase
      posArraySize = (i*2)
    EndWhile
    i = 0
    posArraySize = 0
    ;While i < iIndex
    ;  if snow[i] != none
    ;    snow[i].EnableNoWait(true)
    ;  EndIf
    ;  i += increase
    ;EndWhile 
    If RS_Debug.GetValue() != 0  
      If Left
      Notification("I Have Enabled All The SnowLeft")
      Trace("I Have Enabled All The Left Snows")
      Else
      Notification("I Have Enabled All The SnowRight")
      Trace("I Have Enabled All The Right Snows")
      EndIf
    EndIf
  EndIf
UnregisterForModEvent("RS_EnableSnow")
EndEvent


Event DisableSnow()
  Int iIndex = snow.Length
  While iIndex > 0
      iIndex -= 1
        if snow[iIndex] != none
        snow[iIndex].DisableNoWait(false)
        EndIf
  EndWhile
  Utility.Wait(0.2)
UnregisterForModEvent("RS_DisableSnow")
EndEvent

Function DeleteSnow()
  Int iIndex = snow.Length
  If RS_Debug.GetValue() != 0
    Trace("I Am Deleting Snow1")
  EndIf
  While iIndex > 0
      iIndex -= 1
        if snow[iIndex] != none
        snow[iIndex].Delete()
        EndIf
        snow[iIndex] = none
  EndWhile
  Debug.Trace("RealShelter: Frostfall Ignore Warning Below")
  snow = none
  createdSnow = false
EndFunction



Event DeleteSelf()
  ObjectReference temp
  UnregisterForAllModEvents()
  RegisterForUpdate(10)
  DisableSnow()
  DeleteSnow()
  ;temp = Game.FindClosestReferenceOfAnyTypeInListFromRef(TentStaticList, self, 195.0)
    If RS_Debug.GetValue() != 0
      If Left
        Notification("I RSHelperLeft am deleting myself  Goodbye")
      Else
        Notification("I RSHelperRight am deleting myself  Goodbye")
      EndIf
    Trace(self + "I am deleting myself")
    EndIf
    Disable()
    UnRegisterForUpdate()
    Delete()
EndEvent

Function UnregisterForEvents()
  UnregisterForAllModEvents()
EndFunction

bool Function isReady()
  while createdSnow == false
    Utility.Wait(0.2)
  EndWhile
  return true
EndFunction