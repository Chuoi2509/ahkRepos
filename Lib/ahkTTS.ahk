

; voice := "ShowAvailableVoices"   ; uncomment to get names of all available voices
; file := A_ScriptDir "\test.wav"   ; file will be replaced if exist! comment if not needed save to file
; speed := 1   ; float from 0 till 2
; pitch := 1   ; float from 0 till 2

myTTS(text := "This is sample text", voice := "Microsoft Zira", file := "", speed := 1, pitch := 1)
{
   static init, CurrentVoice, Currentspeed, Currentpitch, SpeechSynthesizerActive, SpeechSynthesizer, SpeechSynthesizer2, SpeechSynthesizerOptions, SpeechSynthesizerOptions2, VoicesCount, VoiceInformationList, DataReaderFactory, StorageFileStatics, FileIOStatics, RandomAccessStream, DataReader, pByteStream, pObject, SourceNode, OutputNode, IMFTopology, pISourceResolver, pDescriptor, pPresentationDescriptor, IMFActivate, IMFMediaSource, pMediaSession
   if RandomAccessStream
   {
      ObjReleaseClose(RandomAccessStream)
      ObjReleaseClose(DataReader)
   }
   if pMediaSession
   {
      ObjRelease(pByteStream)
      ObjRelease(pObject)
      ObjRelease(SourceNode)
      ObjRelease(OutputNode)
      ObjRelease(IMFTopology)
      ObjRelease(pISourceResolver)
      ObjRelease(pDescriptor)
      ObjRelease(pPresentationDescriptor)
      DllCall(NumGet(NumGet(IMFActivate+0)+34*A_PtrSize), "ptr", IMFActivate)   ; IMFActivate::ShutdownObject
      ObjRelease(IMFActivate)
      DllCall(NumGet(NumGet(IMFMediaSource+0)+12*A_PtrSize), "ptr", IMFMediaSource)   ; IMFMediaSource::Shutdown
      ObjRelease(IMFMediaSource)
      DllCall(NumGet(NumGet(pMediaSession+0)+13*A_PtrSize), "ptr", pMediaSession)   ; IMFMediaSession::Shutdown
      ObjRelease(pMediaSession)
      pMediaSession := ""
   }
   if !init
   {
      CreateClass("Windows.Media.SpeechSynthesis.SpeechSynthesizer",, SpeechSynthesizerActive)
      SpeechSynthesizer := ComObjQuery(SpeechSynthesizerActive, ISpeechSynthesizer := "{CE9F7C76-97F4-4CED-AD68-D51C458E45C6}")
      SpeechSynthesizer2 := ComObjQuery(SpeechSynthesizerActive, ISpeechSynthesizer2 := "{a7c5ecb2-4339-4d6a-bbf8-c7a4f1544c2e}")
      DllCall(NumGet(NumGet(SpeechSynthesizer2+0)+6*A_PtrSize), "ptr", SpeechSynthesizer2, "ptr*", SpeechSynthesizerOptions)   ; SpeechSynthesizer.get_Options
      SpeechSynthesizerOptions2 := ComObjQuery(SpeechSynthesizerOptions, ISpeechSynthesizerOptions2 := "{1cbef60e-119c-4bed-b118-d250c3a25793}")
      CreateClass("Windows.Media.SpeechSynthesis.SpeechSynthesizer", IInspectable := "{AF86E2E0-B12D-4c6a-9C5A-D7AA65101E90}", SpeechSynthesizerFactory)
      InstalledVoicesStatic := ComObjQuery(SpeechSynthesizerFactory, IInstalledVoicesStatic := "{7D526ECC-7533-4C3F-85BE-888C2BAEEBDC}")
      DllCall(NumGet(NumGet(InstalledVoicesStatic+0)+6*A_PtrSize), "ptr", InstalledVoicesStatic, "ptr*", VoiceInformationList)   ; InstalledVoicesStatic.get_AllVoices
      DllCall(NumGet(NumGet(VoiceInformationList+0)+7*A_PtrSize), "ptr", VoiceInformationList, "int*", VoicesCount)   ; IVectorView.GetSize
      ObjReleaseClose(SpeechSynthesizerFactory)
      ObjReleaseClose(InstalledVoicesStatic)      
      DllCall("LoadLibrary", "str", "Mf.dll")
      DllCall("LoadLibrary", "str", "Mfplat.dll")
      DllCall("Mfplat.dll\MFStartup", "uint", 2, "uint", MFSTARTUP_NOSOCKET := 1)
      init := 1
   }
   if (Currentspeed != speed)
   {
      DllCall(NumGet(NumGet(SpeechSynthesizerOptions2+0)+9*A_PtrSize), "ptr", SpeechSynthesizerOptions2, "double", speed)   ; SpeechSynthesizerOptions2.put_SpeakingRate
      Currentspeed := speed
   }
   if (Currentpitch != pitch)
   {
      DllCall(NumGet(NumGet(SpeechSynthesizerOptions2+0)+11*A_PtrSize), "ptr", SpeechSynthesizerOptions2, "double", pitch)   ; SpeechSynthesizerOptions2.put_AudioPitch
      Currentpitch := pitch
   }
   if (CurrentVoice != voice)
   {  
      loop % VoicesCount
      {
         DllCall(NumGet(NumGet(VoiceInformationList+0)+6*A_PtrSize), "ptr", VoiceInformationList, "int", A_Index - 1, "ptr*", VoiceInformation)   ; IVectorView.GetAt
         DllCall(NumGet(NumGet(VoiceInformation+0)+6*A_PtrSize), "ptr", VoiceInformation, "ptr*", hText)   ; VoiceInformation.get_DisplayName
         buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
         if (voice = "ShowAvailableVoices")
            AvailableVoices .= StrGet(buffer, "UTF-16") "`n"
         else if (StrGet(buffer, "UTF-16") = voice)
         {
            CurrentVoice := voice
            DllCall(NumGet(NumGet(SpeechSynthesizer+0)+8*A_PtrSize), "ptr", SpeechSynthesizer, "ptr", VoiceInformation)   ; SpeechSynthesizer.put_Voice
            ObjReleaseClose(VoiceInformation)
            break
         }
         ObjReleaseClose(VoiceInformation)
         if (A_Index = VoicesCount)
         {
            if (voice = "ShowAvailableVoices")
               msgbox % AvailableVoices
            else
               msgbox No such voice installed
            exitapp
         }
      }
   }
   CreateHString(text, hString)
   if RegexMatch(text, "i)^(<speak|<\?xml)")
      DllCall(NumGet(NumGet(SpeechSynthesizer+0)+7*A_PtrSize), "ptr", SpeechSynthesizer, "ptr", hString, "ptr*", SpeechSynthesisStream)   ; SpeechSynthesizer.SynthesizeSsmlToStreamAsync
   else
      DllCall(NumGet(NumGet(SpeechSynthesizer+0)+6*A_PtrSize), "ptr", SpeechSynthesizer, "ptr", hString, "ptr*", SpeechSynthesisStream)   ; SpeechSynthesizer.SynthesizeTextToStreamAsync
   WaitForAsync(SpeechSynthesisStream)
   DeleteHString(hString)
   if (file != "")
   {
      FileDelete, %file%
      FileAppend,, %file%
      RandomAccessStream := ComObjQuery(SpeechSynthesisStream, IRandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}")
      DllCall(NumGet(NumGet(RandomAccessStream+0)+6*A_PtrSize), "ptr", RandomAccessStream, "uint64*", size)   ; IRandomAccessStream.get_size
      if !DataReaderFactory
         CreateClass("Windows.Storage.Streams.DataReader", IDataReaderFactory := "{D7527847-57DA-4E15-914C-06806699A098}", DataReaderFactory)
      DllCall(NumGet(NumGet(DataReaderFactory+0)+6*A_PtrSize), "ptr", DataReaderFactory, "ptr", SpeechSynthesisStream, "ptr*", DataReader)   ; DataReaderFactory.CreateDataReader
      DllCall(NumGet(NumGet(DataReader+0)+29*A_PtrSize), "ptr", DataReader, "uint", size, "ptr*", DataReaderLoadOperation)   ; DataReader.LoadAsync
      WaitForAsync(DataReaderLoadOperation)
      DllCall(NumGet(NumGet(DataReader+0)+15*A_PtrSize), "ptr", DataReader, "uint", size, "ptr*", buffer)   ; DataReader.ReadBuffer
      if !StorageFileStatics
         CreateClass("Windows.Storage.StorageFile", IStorageFileStatics := "{5984C710-DAF2-43C8-8BB4-A4D3EACFD03F}", StorageFileStatics)
      CreateHString(file, hString)
      DllCall(NumGet(NumGet(StorageFileStatics+0)+6*A_PtrSize), "ptr", StorageFileStatics, "ptr", hString, "ptr*", StorageFile)   ; StorageFile.GetFileFromPathAsync
      WaitForAsync(StorageFile)
      DeleteHString(hString)
      if !FileIOStatics
         CreateClass("Windows.Storage.FileIO", IFileIOStatics := "{887411EB-7F54-4732-A5F0-5E43E3B8C2F5}", FileIOStatics)
      DllCall(NumGet(NumGet(FileIOStatics+0)+19*A_PtrSize), "ptr", FileIOStatics, "ptr", StorageFile, "ptr", buffer, "ptr*", AsyncAction)   ; FileIOStatics.WriteBufferAsync
      WaitForAsync(AsyncAction)
      ObjReleaseClose(buffer)
      ObjReleaseClose(StorageFile)
   }
   DllCall("Mf.dll\MFCreateMediaSession", "ptr", 0, "ptr*", pMediaSession)
   DllCall("Mfplat.dll\MFCreateSourceResolver", "ptr*", pISourceResolver)
   DllCall("Mfplat.dll\MFCreateMFByteStreamOnStreamEx", "ptr", SpeechSynthesisStream, "ptr*", pByteStream)
   DllCall(NumGet(NumGet(pISourceResolver+0)+4*A_PtrSize), "ptr", pISourceResolver, "ptr", pByteStream, "ptr", 0, "uint", MF_RESOLUTION_MEDIASOURCE := 1, "ptr", 0, "uint*", pObjectType, "ptr*", pObject)   ; IMFSourceResolver::CreateObjectFromByteStream
   IMFMediaSource := ComObjQuery(pObject, IID_IMFMediaSource := "{279A808D-AEC7-40C8-9C6B-A6B492C78A66}")
   DllCall(NumGet(NumGet(IMFMediaSource+0)+8*A_PtrSize), "ptr", IMFMediaSource, "ptr*", pPresentationDescriptor)   ; IMFMediaSource::CreatePresentationDescriptor
   DllCall(NumGet(NumGet(pPresentationDescriptor+0)+34*A_PtrSize), "ptr", pPresentationDescriptor, "uint", 0, "uint*", fSelected, "ptr*", pDescriptor)   ; IMFPresentationDescriptor::GetStreamDescriptorByIndex
   DllCall("Mf.dll\MFCreateTopologyNode", "uint", MF_TOPOLOGY_SOURCESTREAM_NODE := 1, "ptr*", SourceNode)
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", MF_TOPONODE_SOURCE := "{835C58EC-E075-4BC7-BCBA-4DE000DF9AE6}", "ptr", &GUID)
   DllCall(NumGet(NumGet(SourceNode+0)+27*A_PtrSize), "ptr", SourceNode, "ptr", &GUID, "ptr", IMFMediaSource)   ; IMFAttributes::SetUnknown
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", MF_TOPONODE_PRESENTATION_DESCRIPTOR := "{835C58ED-E075-4BC7-BCBA-4DE000DF9AE6}", "ptr", &GUID)
   DllCall(NumGet(NumGet(SourceNode+0)+27*A_PtrSize), "ptr", SourceNode, "ptr", &GUID, "ptr", pPresentationDescriptor)   ; IMFAttributes::SetUnknown
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", MF_TOPONODE_STREAM_DESCRIPTOR := "{835C58EE-E075-4BC7-BCBA-4DE000DF9AE6}", "ptr", &GUID)
   DllCall(NumGet(NumGet(SourceNode+0)+27*A_PtrSize), "ptr", SourceNode, "ptr", &GUID, "ptr", pDescriptor)   ; IMFAttributes::SetUnknown
   DllCall("Mf.dll\MFCreateAudioRendererActivate", "ptr*", IMFActivate)
   DllCall("Mf.dll\MFCreateTopologyNode", "uint", MF_TOPOLOGY_OUTPUT_NODE := 0, "ptr*", OutputNode)
   DllCall(NumGet(NumGet(OutputNode+0)+33*A_PtrSize), "ptr", OutputNode, "ptr", IMFActivate)   ; IMFTopologyNode::SetObject
   DllCall(NumGet(NumGet(SourceNode+0)+40*A_PtrSize), "ptr", SourceNode, "uint", 0, "ptr", OutputNode, "uint", 0)   ; IMFTopologyNode::ConnectOutput
   DllCall("Mf.dll\MFCreateTopology", "ptr*", IMFTopology)
   DllCall(NumGet(NumGet(IMFTopology+0)+34*A_PtrSize), "ptr", IMFTopology, "ptr", SourceNode)   ; IMFTopology::AddNode
   DllCall(NumGet(NumGet(IMFTopology+0)+34*A_PtrSize), "ptr", IMFTopology, "ptr", OutputNode)   ; IMFTopology::AddNode
   DllCall(NumGet(NumGet(pMediaSession+0)+7*A_PtrSize), "ptr", pMediaSession, "uint", 0, "ptr", IMFTopology)   ; IMFMediaSession::SetTopology
   DllCall(NumGet(NumGet(pMediaSession+0)+9*A_PtrSize), "ptr", pMediaSession, "ptr", 0, "ptr", &(PROPVARIANT:=0))   ; IMFMediaSession::Start
   return
}

CreateClass(string, interface := "", ByRef Class := "")
{
   CreateHString(string, hString)
   if (interface = "")
      result := DllCall("Combase.dll\RoActivateInstance", "ptr", hString, "ptr*", Class, "uint")
   else
   {
      VarSetCapacity(GUID, 16)
      DllCall("ole32\CLSIDFromString", "wstr", interface, "ptr", &GUID)
      result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", &GUID, "ptr*", Class, "uint")
   }
   if (result != 0)
   {
      if (result = 0x80004002)
         msgbox No such interface supported
      else if (result = 0x80040154)
         msgbox Class not registered
      else
         msgbox error: %result%
      ExitApp
   }
   DeleteHString(hString)
}

CreateHString(string, ByRef hString)
{
    DllCall("Combase.dll\WindowsCreateString", "wstr", string, "uint", StrLen(string), "ptr*", hString)
}

DeleteHString(hString)
{
   DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}

WaitForAsync(ByRef Object)
{
   AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
   loop
   {
      DllCall(NumGet(NumGet(AsyncInfo+0)+7*A_PtrSize), "ptr", AsyncInfo, "uint*", status)   ; IAsyncInfo.Status
      if (status != 0)
      {
         if (status != 1)
         {
            DllCall(NumGet(NumGet(AsyncInfo+0)+8*A_PtrSize), "ptr", AsyncInfo, "uint*", ErrorCode)   ; IAsyncInfo.ErrorCode
            msgbox AsyncInfo status error: %ErrorCode%
            ExitApp
         }
         break
      }
      sleep 10
   }
   DllCall(NumGet(NumGet(Object+0)+8*A_PtrSize), "ptr", Object, "ptr*", ObjectResult)   ; GetResults
   ObjReleaseClose(Object)
   Object := ObjectResult
   DllCall(NumGet(NumGet(AsyncInfo+0)+10*A_PtrSize), "ptr", AsyncInfo)   ; IAsyncInfo.Close
   ObjRelease(AsyncInfo)
}

ObjReleaseClose(ByRef Object)
{
   if Object
   {
      if (Close := ComObjQuery(Object, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}"))
      {
         DllCall(NumGet(NumGet(Close+0)+6*A_PtrSize), "ptr", Close)   ; Close
         ObjRelease(Close)
      }
      ObjRelease(Object)
   }
   Object := ""
}