; source: https://www.autohotkey.com/boards/viewtopic.php?t=97323
; https://cloud.google.com/text-to-speech/docs/voices
; https://cxl-services.appspot.com/proxy?url=https://texttospeech.googleapis.com/v1/voices&token=0
; https://www.gstatic.com/cloud-site-ux/text_to_speech/text_to_speech.min.html

/*  Language list array below
; Example: Get list of Languages
For Index, Voice In Voices
	Language .= Voice.Language (K = Voices.MaxIndex() ? "" : "`n")
Sort, Language, U
MsgBox, % Language
*/
; Voices[300] := {"Language": "Vietnamese (Vietnam)", "LanguageAlt": "Tiếng Việt (Việt Nam)"
; , "VoiceType": "Standard", "LanguageCode": "vi-VN", "VoiceName": "vi-VN-Standard-A"
; , "SSMLGender": "FEMALE", "NaturalSampleRateHertz": "24000"}

; Voices[83] := {"Language": "English (US)", "LanguageAlt": "English (United States)"
; , "VoiceType": "WaveNet", "LanguageCode": "en-US", "VoiceName": "en-US-Wavenet-D"
; , "SSMLGender": "MALE", "NaturalSampleRateHertz": "24000"}
;point2-point3: response time (varies by input complexity and network performance) ⇒ >1,3s
;duration is highly dependable on the above response time
;;presets:
;ggTTS("verification.initiated",,,, 0.97, -18)
;ggTTS("terminal.launched",, A_Audio "ggTTS",, 0.95, -18)

ggTTS(vInput:="supraphysiological", voiceCode:=308, outputDir:="", wavName:="", speakingRate:=1, pitch:=1,  speakOn:=true) {
    local                 
    global Voices, vPayload
    ; oInput := JSON.Load(vInput)   ;error if vInput not JSON
    ; if IsObject(oInput) && oInput.HasKey("input") && oInput.HasKey("voice") && oInput.HasKey("audioConfig")
    if (vInput="vPayload") {  ;query directly by JSON, retrieve text from JSON
        payload := vPayload
        vInput := regexMatches(payload, """text"":\s*""([^""]+).+", "text", 1)
    }
    else {
        languageCodeX := Voices[voiceCode].LanguageCode
        voiceNameX := Voices[voiceCode].VoiceName
        vInput := Trim(Jxon_Dump(vInput), """")    ;format string to JSON formatted  ;similar to JSON.Dump() but as a function, similar to stringify() in Javascript
        payload = {"input":{"text":"%vInput%"}      ;expression syntax doesn't work, maybe because JSON interprets quotes differently
        ,"voice":{"languageCode":"%languageCodeX%","name":"%voiceNameX%"}
        ,"audioConfig":{"audioEncoding":"LINEAR16","pitch":%pitch%,"speakingRate":%speakingRate%,"effectsProfileId":["headphone-class-device"]}}
        ;effectsProfileId => https://cloud.google.com/text-to-speech/docs/audio-profiles#available_audio_profiles
    }
    endpoint := "https://cxl-services.appspot.com/proxy?url=https://texttospeech.googleapis.com/v1beta1/text:synthesize&token=0"
    HTTP := ComObjCreate("Msxml2.XMLHTTP.6.0")
    ; HTTP := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
    HTTP.Open("POST", endpoint, true)
    HTTP.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36")
    HTTP.setRequestHeader("Cache-Control", "no-cache, no-store, max-age=0")
    HTTP.setRequestHeader("if-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT")
    HTTP.setRequestHeader("content-type", "text/plain;charset=UTF-8")  ;WinHTTP doesn't need this to work
    ;requestHeader referenced from Dev mod => Network => click on the item
    ; HTTP.setRequestHeader("referer", "https://www.gstatic.com/")
    ;Because Msxml2.XMLHTTP will cache content. Requesting to the same URL that has been cached will return the cached content, and the http request is not sent.
    ; HTTP.onreadystatechange := Func("reqReady").Bind(HTTP)   ;reference from URLDownloadToFile()-#4
    ;Set callback function reqReady() to be called whenever readystate change
    HTTP.Send(payload)     
    while !(HTTP.readyState = 4) { ;&& (HTTP.status = 200 || HTTP.status = 304))
    ;Wait for response whereas the onreadystatechange works asynchornously 
    ;Wait is valid in this case because we only need data from one endpoint to continue the operation
    ;And next operation wouldn't work with out that data
        if (A_Index=150) {
            Msgbox, % clipboard:=HTTP.responseText
            break
        }
        else
            sleep, 50
    }
    ; HTTP.WaitForResponse()                 ;most time costly, WinHTTP only
    ; point2 := A_TickCount - StartTime
        
    ; Body := HTTP.ResponseBody       
    ; pData := NumGet(ComObjValue(Body)+8+A_PtrSize)               ;WinHTTP ResponseBody returns raw data => need to convert to JSON
    ; vJSON := StrGet(pData, Body.MaxIndex() + 1, "utf-8")
    vJSON := HTTP.responseText
    if (vJSON="Unauthorized") {
        run, https://cloud.google.com/text-to-speech/#section-2             ;Solve capcha
        soundPlay(A_Audio "\ggTTS\verification.initiated.wav", true)
        return 
    }
    wavBase64 := RegExReplace(vJSON, "s)^.+?audioContent"":\s*""([^""]+).+", "$1") ;retrieve audioContent key's value
    CryptStringToBinary(wavBase64, data)    ; create wavBase64 from reponse                                         
    ; point4 := A_TickCount - StartTime 
    if (outputDir!="") {
        if (outputDir=="Audio") {     ;case-sensitive
            outputDir := A_Audio "\ggTTS"
            openDir := true
        }
        nBytes := Base64Dec(wavBase64, Bin)             
        if (wavName="") {
            wavName := RegExReplace(vInput, "\W+", "_")          ;replace consecutive non word characters with _
            wavName := SubStr(vInput, 1, 80)                     ;max 80 first chars only
        }
        if !(outputDir~="\$")
            outputDir .= "\"
        filePath := outputDir "\" wavName ".wav"
        File := FileOpen(filePath, "w")
        File.RawWrite(Bin, nBytes)
        File.Close()
    }
    if (openDir=true)
        run, % outputDir
    if (speakOn=true)
        DllCall("Winmm\PlaySound", "Ptr", &data, "Ptr", 0, "UInt", SND_MEMORY := 0x4)  ; play wavBase64
        ;DllCall("winmm\PlaySound" (A_IsUnicode?"W":"A"), "Str", vPath, "Ptr",0, "UInt",0x20002)
    if filePath
        return filePath
    ; point5 := A_TickCount - StartTime 
    ; Msgbox, % point1 "`r`n" point2 "`r`n" point3 "`r`n" point4 "`r`n" point5
}
CryptStringToBinary(string, ByRef outData, formatName := "CRYPT_STRING_BASE64") {
    static formats := { CRYPT_STRING_BASE64: 0x1
                        , CRYPT_STRING_HEX:    0x4
                        , CRYPT_STRING_HEXRAW: 0xC }
    fmt := formats[formatName]
    chars := StrLen(string)
    if !DllCall("Crypt32\CryptStringToBinary", "Str", string, "UInt", chars, "UInt", fmt
                                            , "Ptr", 0, "UIntP", bytes, "UIntP", 0, "UIntP", 0)
        throw "CryptStringToBinary failed. LastError: " . A_LastError
    VarSetCapacity(outData, bytes)
    DllCall("Crypt32\CryptStringToBinary", "Str", string, "UInt", chars, "UInt", fmt
                                        , "Str", outData, "UIntP", bytes, "UIntP", 0, "UIntP", 0)
    Return bytes
}
Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
    Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
    DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
            , "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
    VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
    DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
            , "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
    Return Rqd
}
