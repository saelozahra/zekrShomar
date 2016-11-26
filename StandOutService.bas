Type=Service
Version=5.95
ModulesStructureVersion=1
B4A=true
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: false
#End Region

Sub Process_Globals
	#Region Standout Var
	Public StandOut As RSStandOut
	
	'Declaration of variabels
	Private mWindow As RSStandOutWindow
'	Private mConstants As RSStandOutConstants
	Private mFlags As RSStandOutFlags
	#End Region
	
'	Public MaxWidth,MaxHeight,MinWidth,MinHeight As Int
	Public width,height As Int
	Public AppName,Icon,HiddenTitle,RestoreTitle,NewTitle,RunningTitle As String
	Public ShowAnimationName,HideAnimationName,RestoreAnimationName As String
	Public LayoutName As String
	
	Public count As Int
	Dim t As Timer
End Sub

#Region Service
Sub Service_Create
	
End Sub

Sub Service_Start (StartingIntent As Intent)
	mWindow.Initialize("Window")
	StandOut.Show(mWindow.UniqueId)
	t.Initialize("t",18000)
	
	If File.ReadString(File.DirDefaultExternal,"setting-vibrate.dat") == "true" Then
		t.Enabled=True
	Else
		t.Enabled=False
	End If
	
End Sub

Sub t_Tick
	Main.pv.Vibrate(20)
End Sub

Sub Service_Destroy

End Sub
#End Region

#Region Window
Sub Window_Initialize (Id As Int, Window As RSStandOutWindow) As RSStandOutLayoutParams
	Dim params As RSStandOutLayoutParams
'	params.Initialize4(Id, MaxWidth, MaxHeight, mConstants.AUTO_POSITION, mConstants.AUTO_POSITION, MinWidth, MinHeight)
	params.Initialize2(Id,width,height)
	Return params
End Sub

'Final clean up that needs to be done.
'Called after all windows have been closed.
Sub Window_Destroy 
	StopService(Me)	
End Sub
#End Region

#Region Panel of window
'Create a panel and add it to the frame.
Sub Window_CreateAndAttachView (Id As Int, Frame As RSFrameLayout) As Panel
	Dim Content As Panel
	Content.Initialize("Content")
'	Frame.AddView(Content, MaxWidth, MaxHeight)
	Frame.AddView(Content, width, height)
	Dim cd As ColorDrawable
	cd.Initialize(Colors.ARGB(180,100,100,100),50dip)
	Content.Background=cd
	Dim ripple As RippleView
	
	Dim bbb As Button
	bbb.Initialize("bbb")
	Content.AddView(bbb,12dip,12dip,Content.Width-24dip,Content.Height-24dip)
	bbb.Color = Colors.LightGray
	bbb.TextColor=Colors.Black
	bbb.Typeface=Typeface.LoadFromAssets("Vazir-Light.ttf")
	bbb.Text=File.ReadString(File.DirDefaultExternal,"count")
	
	ripple.Initialize(bbb,Main.color,110,True)
	
	Return Content
End Sub
Sub bbb_Click
	count = File.ReadString(File.DirDefaultExternal,"count")+1
	File.WriteString(File.DirDefaultExternal,"count",count)
	Dim btn As Button
	btn = Sender
	btn.Text = count
	Main.pv.Vibrate(200)
End Sub

Sub bbb_LongClick
	StartActivity(Main)
End Sub
#End Region

#Region Manual Setting
'Returns the name of the Window.
Sub Window_AppName As String
	Return AppName
End Sub

'Returns the icon of the window.
Sub Window_AppIcon As String
	If Icon = "" Then Return "icon"
	Return Icon
End Sub

Sub Window_PersistentNotificationTitle(Id As Int) As String
	Return RunningTitle
End Sub

Sub Window_PersistentNotificationMessage(Id As Int) As String
	Return NewTitle
End Sub

Sub Window_HiddenIcon As String
	If Icon = "" Then Return "icon"
	Return Icon
End Sub

Sub Window_HiddenNotificationTitle(Id As Int) As String
	Return HiddenTitle
End Sub

Sub Window_HiddenNotificationMessage(Id As Int) As String
	Return RestoreTitle
End Sub


#End Region

#Region For windows
'Return a list of flags
Sub Window_Flags (Id As Int) As List
	Dim flags As List
	flags.Initialize
'	flags.Add(mFlags.FLAG_DECORATION_SYSTEM)' اون نوار بالای پنل را حذف میکنه
'	flags.Add(mFlags.FLAG_DECORATION_RESIZE_DISABLE) ' اون نوار بالای پنل را حذف میکنه
	flags.Add(mFlags.FLAG_BODY_MOVE_ENABLE)
	flags.Add(mFlags.FLAG_WINDOW_HIDE_ENABLE)
	flags.Add(mFlags.FLAG_WINDOW_BRING_TO_FRONT_ON_TAP)
	flags.Add(mFlags.FLAG_WINDOW_FOCUS_INDICATOR_DISABLE)
	flags.Add(mFlags.FLAG_WINDOW_EDGE_LIMITS_ENABLE) ' باشه جلوگیری میکنه از اینکه پنل از کنار صفحه بره بیرون 
	flags.Add(mFlags.FLAG_WINDOW_PINCH_RESIZE_ENABLE)
	Return flags
End Sub

Sub Window_PersistentNotificationIntent(Id As Int) As Intent
	Return StandOut.getShowIntent(mWindow.UniqueId)
End Sub

Sub Window_HiddenNotificationIntent(Id As Int) As Intent
	Return StandOut.getShowIntent(Id)
End Sub

'Data = bundle (Use JavaObject)
Sub Window_ReceiveData (Id As Int, RequestCode As Int, Data As Object, FromId As Int)
	ToastMessageShow("Data received from id: " & FromId & " with RequestCode: " & RequestCode, False)
End Sub
#End Region

#Region Animation
Sub Window_ShowAnimation (Id As Int) As String
	If (mWindow.isExistingId(Id)) Then
		'restore
		If RestoreAnimationName = "" Then Return "slide_in_left"
		Return RestoreAnimationName 'slide_in_left
	Else 
		'show
		If ShowAnimationName = "" Then Return "fade_in"
		Return ShowAnimationName 'fade_in
	End If
	'Return ""
End Sub

Sub Window_HideAnimation (Id As Int) As String
	If HideAnimationName = "" Then Return "slide_out_right"
	
	Return HideAnimationName 'slide_out_right
End Sub

Sub Window_CloseAnimation (Id As Int) As String
	Return "fade_out"
End Sub
#End Region

#Region Menu
Sub Window_DropDownItems (Id As Int) As List
	Dim l As List
	l.Initialize
	Dim item(2) As RSStandOutDropDownItem
'	item(0).Initialize("Item", "ic_menu_help", "About", "About") 
'	item(1).Initialize("Item", "ic_menu_preferences", "Settings", "Settings") 
'	l.Add(item(0))
'	l.Add(item(1))
	item(0).Initialize("mnuabout","ic_menu_help","درباره ما","")
	item(1).Initialize("mnusetting","ic_menu_preferences","تنظیمات","")
	l.Add(item(0))
	l.Add(item(1))

	Return l
End Sub

Sub mnuabout_Click(tag As String)
	ToastMessageShow("about me",False)
End Sub



#End Region

#Region Events
'/**
'	 * Implement this method To be alerted To touch events In the body of the
'	 * window corresponding To the id.
'	 * 
'	 * <p>
'	 * Note that even If you set {@link #FLAG_DECORATION_SYSTEM}, you will not
'	 * receive touch events from the system window decorations.
'	 * 
'	 * @see {@link View.OnTouchListener#onTouch(View, MotionEvent)}
'	 * @param id
'	 *            The id of the View, provided As a courtesy.
'	 * @param window
'	 *            The window corresponding To the id, provided As a courtesy.
'	 * @param View
'	 *            The View where the event originated from.
'	 * @param event
'	 *            See linked method.
'//
Sub Window_TouchBody (Id As Int, Window As RSStandOutWindow, pView As View, MotionEvent As Object) As Boolean

	Return False
End Sub

'/**
'	 * Implement this method To be alerted To when the window corresponding To
'	 * the id Is moved.
'	 * 
'	 * @param id
'	 *            The id of the View, provided As a courtesy.
'	 * @param window
'	 *            The window corresponding To the id, provided As a courtesy.
'	 * @param View
'	 *            The View where the event originated from.
'	 * @param event
'	 *            See linked method.
'	 * @see {@link #onTouchHandleMove(int, Window, View, MotionEvent)}
'	 */
Sub Window_Move (Id As Int, Window As RSStandOutWindow, pView As View, MotionEvent As Object)

End Sub

'/**
'	 * Implement this method To be alerted To when the window corresponding To
'	 * the id Is resized.
'	 * 
'	 * @param id
'	 *            The id of the View, provided As a courtesy.
'	 * @param window
'	 *            The window corresponding To the id, provided As a courtesy.
'	 * @param View
'	 *            The View where the event originated from.
'	 * @param event
'	 *            See linked method.
'	 * @see {@link #onTouchHandleResize(int, Window, View, MotionEvent)}
'	 */
Sub Window_Resize (Id As Int, Window As RSStandOutWindow, pView As View, MotionEvent As Object)
	
End Sub

'/**
'	 * Implement this callback To be alerted when a window corresponding To the
'	 * id Is about To be shown. This callback will occur before the View Is
'	 * added To the window manager.
'	 * 
'	 * @param id
'	 *            The id of the View, provided As a courtesy.
'	 * @param View
'	 *            The View about To be shown.
'	 * @Return Return True To cancel the View from being shown, OR False To
'	 *         Continue.
'	 * @see #show(int)
'	 */
Sub Window_Show (Id As Int, Window As RSStandOutWindow) As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when a window corresponding To the
'	 * id Is about To be hidden. This callback will occur before the View Is
'	 * removed from the window manager AND {@link #getHiddenNotification(int)}
'	 * Is called.
'	 * 
'	 * @param id
'	 *            The id of the View, provided As a courtesy.
'	 * @param View
'	 *            The View about To be hidden.
'	 * @Return Return True To cancel the View from being hidden, OR False To
'	 *         Continue.
'	 * @see #hide(int)
'	 */
Sub Window_Hide (Id As Int, Window As RSStandOutWindow) As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when a window corresponding To the
'	 * id Is about To be closed. This callback will occur before the View Is
'	 * removed from the window manager.
'	 * 
'	 * @param id
'	 *            The id of the View, provided As a courtesy.
'	 * @param View
'	 *            The View about To be closed.
'	 * @Return Return True To cancel the View from being closed, OR False To
'	 *         Continue.
'	 * @see #close(int)
'	 */
Sub Window_Close (Id As Int, Window As RSStandOutWindow) As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when all windows are about To be
'	 * closed. This callback will occur before any views are removed from the
'	 * window manager.
'	 * 
'	 * @Return Return True To cancel the views from being closed, OR False To
'	 *         Continue.
'	 * @see #closeAll()
'	 */
Sub Window_CloseAll As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when a Window corresponding To the
'	 * Id Is about To be updated In the layout. This callback will occur before
'	 * the View Is updated by the Window manager.
'	 * 
'	 * @param Id
'	 *            The Id of the Window, provided As a courtesy.
'	 * @param View
'	 *            The Window about To be updated.
'	 * @param Params
'	 *            The updated layout Params.
'	 * @Return Return True To cancel the Window from being updated, OR False To
'	 *         Continue.
'	 * @see #updateViewLayout(int, Window, StandOutLayoutParams)
'	 */
Sub Window_Update (Id As Int, Window As RSStandOutWindow, Params As RSStandOutLayoutParams) As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when a window corresponding To the
'	 * id Is about To be bought To the front. This callback will occur before
'	 * the window Is brought To the front by the window manager.
'	 * 
'	 * @param id
'	 *            The id of the window, provided As a courtesy.
'	 * @param View
'	 *            The window about To be brought To the front.
'	 * @Return Return True To cancel the window from being brought To the front,
'	 *         OR False To Continue.
'	 * @see #bringToFront(int)
'	 */
Sub Window_BringToFront (Id As Int, Window As RSStandOutWindow) As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when a Window corresponding To the
'	 * Id Is about To have its Focus changed. This callback will occur before
'	 * the Window's focus is changed.
'	 * 
'	 * @param Id
'	 *            The Id of the Window, provided As a courtesy.
'	 * @param View
'	 *            The Window about To be brought To the front.
'	 * @param Focus
'	 *            Whether the Window Is gaining OR losing Focus.
'	 * @Return Return True To cancel the Window's focus from being changed, or
'	 *         False To Continue.
'	 * @see #focus(int)
'	 */
Sub Window_FocusChange (Id As Int, Window As RSStandOutWindow, Focus As Boolean) As Boolean
	Return False
End Sub

'/**
'	 * Implement this callback To be alerted when a window corresponding To the
'	 * id receives a key event. This callback will occur before the window
'	 * handles the event with {@link Window#dispatchKeyEvent(KeyEvent)}.
'	 * 
'	 * @param id
'	 *            The id of the window, provided As a courtesy.
'	 * @param View
'	 *            The window about To receive the key event.
'	 * @param event
'	 *            The key event.
'	 * @Return Return True To cancel the window from handling the key event, OR
'	 *         False To let the window handle the key event.
'	 * @see {@link Window#dispatchKeyEvent(KeyEvent)}
'	 */
Sub Window_KeyEvent (Id As Int, Window As RSStandOutWindow, KeyEvent As Object) As Boolean
	Return False
End Sub

Sub Window_ThemeStyle As String
	Return ""
End Sub


#End Region

