#singleInstance force
#persistent
#include *i <Lib_1>
SetBatchLines, -1
i:=0

Gui, Add, Button, x182 y99 w100 h30 gStartRecord, Start
Gui, Add, Button, x182 y149 w100 h30 gStopRecord disabled, Stop
; Generated using SmartGUI Creator for SciTE
Gui, Show, w479 h379, bassRecord Test
return

GuiClose:
ExitApp


StartRecord:
recording:=new bassRecord(a_scriptDir . "\bass.dll")
loop {
    if FileExist("test_" . ++i ".wav") {
        MsgBox, 4,, % "File " i "_test.wav already exists! `n`n Do you want to overvrite it?"
        IfMsgBox Yes
        {
            FileDelete, % "test_" . i ".wav"
            break
        }
    } else break
}
recording.start("test_" . i ".wav")
control,disable,,Start
control,enable,,Stop
return

StopRecord:
recording.stop()
control,enable,,Start
control,disable,,Stop
return

class bassRecord {
    
    __new(bassLoc:=""){
        this.bassLoc:=bassLoc?bassLoc:a_scriptDir . "\bass.dll"
        return this
    }
    
    __delete(){
        if(this.currentFile)
            this.stop()
    }
    
    start(fileName){
        if(this.currentFile)
            return 1
        
        this.currentFile:=fileName

        this.recordCallback:=registerCallback("_callback","","",&this)
        dllCall(this.recordCallback,"int",42)
        this._writeWAV(fileName)
        
        if(!this.bToken)
            this.bToken:=DllCall("LoadLibrary","str",this.bassLoc) 
        DllCall(this.bassLoc . "\BASS_RecordInit", Int,-1)
        DllCall(this.bassLoc . "\BASS_ErrorGetCode")
        this.hrecord := DllCall(this.bassLoc . "\BASS_RecordStart", UInt, 44100, UInt, 2, UInt, 0, UInt, this.recordCallback, UInt, 0)
    }
    
    stop(){
        DllCall(this.bassLoc . "\BASS_ChannelStop", UInt,this.hrecord)
        this.file.seek(40)
    
        data_datasize=0
        numput(this.datasize, data_datasize, "UInt") ; little endian
        this.file.rawwrite(data_datasize, 4)

        this.datasize+=36

        this.file.seek(4)

        riff_size=0
        numput(this.datasize, riff_size, "UInt") ; little endian
        this.file.rawwrite(riff_size, 4)
        dllCall("GlobalFree","ptr",this.recordCallback)
        this.file.close()
        this.currentFile:=""
    }
    
    _writeWAV(fileName){
        this.file := fileopen(fileName, "rw", CP1252)
        this.file.write("RIFF    ") ; leave space for file size - 8

        this.file.write("WAVEfmt ") ; Wave Container, 'fmt ' chunk, this takes up 8 bytes.

        this.file.writeUInt(16) ; 16 bytes, length of formatchunk in bytes

        this.file.writeUShort(1) ; format, 1 = PCM, linear aka non compressed

        this.file.writeUShort(2) ; 2 channels

        this.file.writeUInt(44100) ; 44100 samples per second

        this.file.writeUInt(146400) ; bytes per second, 176400

        this.file.writeUShort(4) ; NumChannels * BitsPerSample/8

        this.file.writeUShort(16) ; 16 bit resolution

        this.file.write("data    ") ; this takes up 8 bytes. leave space to write in the size of data chunk.
        this.datasize := 0
    }
    
    callback(handle,buffer,length,user){
        this.file.rawwrite(buffer+0,length)
        this.datasize += length
        return true
    }
}

_callback(handle,buffer,length,user){
    return Object(a_eventInfo).callback(handle,buffer,length,user)
}