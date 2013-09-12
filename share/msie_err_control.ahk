#ErrorStdOut
SetTitleMatchMode, RegEx
SetControlDelay, 1000

WinWait, ahk_class IEFrame
WinActivate
Loop,
{
  WinWaitActive, ahk_class #32770,,5
  if ! ErrorLevel
    Loop,
    {
      ControlClick, Button1 ; OK
      WinWaitClose, ahk_class #32770,,1
      if ! ErrorLevel
        Break
    }

  WinWaitClose, ahk_class IEFrame,,1
  if ! ErrorLevel
    Break
}
