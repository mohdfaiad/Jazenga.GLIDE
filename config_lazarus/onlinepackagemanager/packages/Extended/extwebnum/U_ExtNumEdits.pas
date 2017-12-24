﻿{*********************************************************************}
{                                                                     }
{                                                                     }
{             Matthieu Giroux                                         }
{             TExtNumEdit  :                                       }
{             Composant edit de nombre              }
{             TExtDBNumEdit :                                       }
{             Composant dbedit de nombre }
{             22 Avril 2006                                           }
{                                                                     }
{                                                                     }
{*********************************************************************}

unit U_ExtNumEdits;

{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}

interface

{$I ..\DLCompilers.inc}
{$I ..\extends.inc}

uses
  Messages,  SysUtils, Classes, Graphics, Controls,
{$IFDEF FPC}
  LCLType, MaskEdit, lmessages, lresources, sqldb,
{$ELSE}
  Windows, Mask, DBTables,
{$ENDIF}
{$IFDEF ADO}
   ADODB,
{$ENDIF}
{$IFDEF VERSIONS}
  fonctions_version,
{$ENDIF}
{$IFDEF TNT}
   TntStdCtrls,
{$ENDIF}
  Forms, Dialogs,
  Db, StdCtrls,
  DBCtrls, fonctions_numedit,
  u_extcomponent ;

  const
{$IFDEF VERSIONS}
    gVer_TExtNumEdit : T_Version = ( Component : 'Composant TExtNumEdit' ;
                                     FileUnit : 'U_NumEdits' ;
                                     Owner : 'Matthieu Giroux' ;
                                     Comment : 'Edition de nombres.' ;
                                     BugsStory : '1.1.0.0 : Testing largely.' + #13#10
                                               + '1.0.1.3 : Testing on LAZARUS' + #13#10
                                               + '1.0.1.2 : Mask on num edit' + #13#10
                                               + '1.0.1.1 : NumRounded property not tested' + #13#10
                                               + '1.0.1.0 : Better ExtNumEdit with good colors' + #13#10
                                               + '1.0.0.1 : Bug rafraîchissement de AValue' + #13#10
                                               + '1.0.0.0 : Gestion en place.';
                                     UnitType : 3 ;
                                     Major : 1 ; Minor : 1 ; Release : 0 ; Build : 0 );
    gVer_TExtDBNumEdit : T_Version = ( Component : 'Composant TExtDBNumEdit' ;
                                       FileUnit : 'U_NumEdits' ;
                                       Owner : 'Matthieu Giroux' ;
                                       Comment : 'Edition de nombres en données.' ;
                                       BugsStory : '1.1.0.0 : Uprading parent Not Tested.' + #13#10
                                                 + '1.0.1.4 : Testing on LAZARUS.' + #13#10
                                                 + '1.0.1.3 : Better num edit.' + #13#10
                                                 + '1.0.1.2 : NumRounded property not tested.' + #13#10
                                                 + '1.0.1.1 : Less methods with good colors.' + #13#10
                                                 + '1.0.1.0 : Améliorations sur la gestion des erreurs.' + #13#10
                                                 + '1.0.0.0 : Gestion en place.';
                                       UnitType : 3 ;
                                       Major : 1 ; Minor : 1 ; Release : 0 ; Build : 0 );
{$ENDIF}
    CST_NUM_NEGATIVE = True ;
    CST_NUM_POSITIVE = True ;
    CST_NUM_BEFORECOMMA = 42 ;
    CST_NUM_AFTERCOMMA  = 2 ;




  { TExtNumEdit }

type
  TExtNumEdit   = class(TCustomEdit, IFWComponent, IFWComponentEdit)
  private
    FValue: TAFloat ;
    FCanvas: TControlCanvas;
    FFocused: Boolean;
    FAlwaysSame: Boolean;
    FBeforeEnter: TnotifyEvent;
    FBeforeExit: TnotifyEvent;
    FLabel : {$IFDEF TNT}TTntLabel{$ELSE}TLabel{$ENDIF} ;
    FColorReadOnly,
    FColorFocus ,
    FColorEdit ,
    FOldColor ,
    FColorLabel : TColor;
    FOnSetValue  ,
    FOnValueSet  ,
    FNotifyOrder : TNotifyEvent;
    FOnPopup: TNotifyEvent;
   procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
  protected
    FNumRounded : TNumRounded;
    FAlignment: TAlignment;
    gby_NbAvVirgule ,
    gby_NbApVirgule : Byte ;
    gby_MinLevel    : Byte ;
    gb_Negatif   : Boolean ;
    gb_Calculate : Boolean ;
    FMin         ,
    FMax         : Double ;
    FChangingValue,
    FHasMin      ,
    FHasMax      : Boolean ;
    procedure DoExitText; virtual;
    procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
    procedure SetName(const NewName: TComponentName); override;
    procedure {$IFNDEF FPC}Change{$ELSE}TextChanged{$ENDIF}; override;
    function  InitComma( as_text : String ):String; virtual;
    procedure SetTextToValue; virtual;
    procedure SetToText(const as_text : String ); virtual;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure p_SetValue ( AValue : TAFloat ); virtual;
    procedure SetFocused(AValue: Boolean); virtual;
    function GetTextMargins: TPoint; virtual;
    procedure p_SetNbAvVirgule ( const Avalue    : Byte ); virtual;
    procedure p_SetNbApVirgule ( const Avalue    : Byte ); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetTextFloat: String; virtual;
    procedure Loaded; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure SetOrder ; virtual;
  published
    property FWBeforeEnter : TNotifyEvent read FBeforeEnter write FBeforeEnter stored False;
    property FWBeforeExit  : TNotifyEvent read FBeforeExit  write FBeforeExit stored False ;
    property OnSetValue    : TNotifyEvent read FOnSetValue  write FOnSetValue;
    property OnValueSet    : TNotifyEvent read FOnValueSet  write FOnValueSet;
    property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
    property Value : TAFloat read FValue write p_SetValue stored False ;
    property NbNegative : Boolean read gb_Negatif write gb_Negatif default CST_NUM_NEGATIVE ;
    property NbBeforeComma : Byte read gby_NbAvVirgule write p_SetNbAvVirgule default CST_NUM_BEFORECOMMA;
    property NbAfterComma  : Byte read gby_NbApVirgule write p_SetNbApVirgule default CST_NUM_AFTERCOMMA ;
    property ColorLabel : TColor read FColorLabel write FColorLabel default CST_EDIT_SELECT ;
    property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
    property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
    property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
    property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
    property MyLabel : {$IFDEF TNT}TTntLabel{$ELSE}TLabel{$ENDIF} read FLabel write FLabel;
    property Max : Double read FMax write FMax ;
    property Min : Double read FMin write FMin ;
    property HasMin : Boolean read FHasMin write FHasMin default False;
    property HasMax : Boolean read FHasMax write FHasMax default False;
    property NumRounded : TNumRounded read FNumRounded write FNumRounded default nrMiddle;
    property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
    property Alignment default taRightJustify;
    property Anchors;
    property AutoSelect;
    property AutoSize;
  {$IFDEF DELPHI}
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property ImeMode;
    property ImeName;
    property OEMConvert;
    property HideSelection;
  {$ENDIF}
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
  {$IFNDEF FPC}
    property Ctl3D;
    property ParentCtl3D;
  {$ENDIF}
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnMouseEnter;
    property OnMouseLeave;
    property Align;

  end;

  { TExtDBNumEdit }

  TExtDBNumEdit = class(TExtNumEdit)
  private
    FDataLink: TFieldDataLink;
    FSetText : Boolean;
    FFormat : String ;
    procedure ActiveChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    procedure ResetMaxLength;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(AValue: TDataSource);
    procedure WMCut(var Message: TMessage); message {$IFDEF FPC} LM_CUT {$ELSE} WM_CUT {$ENDIF};
    procedure WMPaste(var Message: TMessage); message {$IFDEF FPC} LM_PASTE {$ELSE} WM_PASTE {$ENDIF};
{$IFNDEF FPC}
    procedure WMUndo(var Message: TMessage); message WM_UNDO;
{$ENDIF}
{$IFDEF FPC}
    procedure WMEnter(var Message: TLMEnter); message LM_ENTER;
    procedure WMExit(var Message: TLMExit); message LM_EXIT;
{$ELSE}
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
{$ENDIF}
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
   protected
{$IFDEF FPC}
    procedure SetReadOnly(AValue: Boolean); override;
{$ENDIF}
    function GetEditString: string;
    procedure SetFocused(AValue: Boolean); override;
    procedure p_SetValue ( AValue : TAFloat ); override ;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure SetToText(const as_text : String ); override;
    procedure SetTextToValue; override;
   public
 {$IFDEF FPC}
     procedure Undo; override;
 {$ENDIF}
    procedure Loaded; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(AAction: TBasicAction): Boolean; override;
    function UpdateAction(AAction: TBasicAction): Boolean; override;
    function UseRightToLeftAlignment: Boolean; override;
    property Field: TField read GetField;
   published
     property EditMask : String read FFormat write FFormat ;
     property DataField: string read GetDataField write SetDataField;
     property DataSource: TDataSource read GetDataSource write SetDataSource;
   end;

implementation

uses
{$IFDEF FPC}
    LCLIntf, tmschema,
{$ENDIF}
    fonctions_erreurs, fonctions_string,
    fonctions_proprietes, Math ;

{ TExtDBNumEdit }

procedure TExtDBNumEdit.ResetMaxLength;
var
  F: TField;
begin
  if (MaxLength > 0) and Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    F := DataSource.DataSet.FindField(DataField);
    if Assigned(F) and (F.DataType in [ftString, ftWideString]) and (F.Size = MaxLength) then
      MaxLength := 0;
  end;
end;

constructor TExtDBNumEdit.Create(AOwner: TComponent);
begin
  FDataLink := TFieldDataLink.Create;
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnActiveChange := ActiveChange;
  {$IFDEF FORMATSETTING}
  with FormatSettings do
  {$ENDIF}
  FFormat := '#0'+DecimalSeparator+'00';
end;

destructor TExtDBNumEdit.Destroy;
begin
  inherited Destroy;
  FDataLink.Free;
  FDataLink := nil;
end;


procedure TExtDBNumEdit.Loaded;
begin
  inherited Loaded;
  ResetMaxLength;
  if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TExtDBNumEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

function TExtDBNumEdit.UseRightToLeftAlignment: Boolean;
begin
  Result := DBUseRightToLeftAlignment(Self, Field);
end;

procedure TExtDBNumEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FSetText:=True;
  inherited KeyDown(Key, Shift);
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    FDataLink.Edit;
end;

procedure TExtDBNumEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FSetText:=False;
  inherited KeyUp(Key, Shift);
end;

procedure TExtDBNumEdit.SetToText(const as_text: String);
var li_SelPos, li_SelLength : Integer;
begin
  if  not FSetText
  and assigned ( FDataLink.Field )
  and (FDataLink.Dataset.State in [dsEdit,dsInsert])  Then
   try
     FSetText:=True;
     li_SelPos := SelStart;
     li_SelLength := SelLength;
     FValue := StrToFloat(as_text);
     FDataLink.Field.Value := FValue;
//     showmessage ( FDataLink.Field.AsString );
     Text := as_text;
   finally
     SelStart := li_SelPos;
     SelLength := li_SelLength;
     FSetText:=False;
   end;
  FDataLink.Modified;
end;

procedure TExtDBNumEdit.SetTextToValue;
var le_float : TAFloat;
begin
  if assigned(FDataLink.Field)
  and (FDataLink.DataSet.State in [dsInsert,dsEdit]) Then
    if ( GetEditString > '' ) //
     Then
      try
       le_float := StrToFloat (GetEditString);
       if le_float = FValue Then Exit;
       FDataLink.Field.AsFloat := le_float;
    //     showmessage ( FDataLink.Field.AsString );
       FValue:=FDataLink.Field.AsFloat;

      except
        FDataLink.Field.Value := 0;
        FValue := 0;
      end
     else
      Begin
        FDataLink.Field.Value := 0;
        FValue := 0;
      end;
end;

function TExtDBNumEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TExtDBNumEdit.SetDataSource(AValue: TDataSource);
begin
  if not (FDataLink.DataSourceFixed) then
    FDataLink.DataSource := AValue;
  if AValue <> nil then AValue.FreeNotification(Self);
end;

procedure TExtDBNumEdit.SetFocused(AValue: Boolean);
begin
  inherited SetFocused(AValue);
  FDataLink.Reset;
end;

function TExtDBNumEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TExtDBNumEdit.SetDataField(const AValue: string);
begin
  if not (csDesigning in ComponentState) then
    ResetMaxLength;
  FDataLink.FieldName := AValue;
end;
{$IFDEF FPC}
procedure TExtDBNumEdit.SetReadOnly(AValue: Boolean);
begin
  Inherited SetReadOnly(AValue);
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
end;
{$ENDIF}
function TExtDBNumEdit.GetEditString: string;
var li_i : Integer;
    ls_text : String;
begin
  ls_text := Text ;
  Result := '';
  {$IFDEF FORMATSETTING}
  with FormatSettings do
  {$ENDIF}
  for li_i := 1 to length ( ls_text ) do
   if ls_text[li_i] in ['0'..'9','-','+',DecimalSeparator] Then
     AppendStr(Result,ls_text[li_i]);
end;


function TExtDBNumEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TExtDBNumEdit.ActiveChange(Sender: TObject);
begin
  ResetMaxLength;
  if assigned ( FDataLink.Field ) then
    Begin
      FDataLink.Field.Alignment:=FAlignment;
      p_setComponentProperty ( FDataLink.Field, 'EditFormat', FFormat );
      p_setComponentProperty ( FDataLink.Field, 'DisplayFormat', FFormat );
      DataChange ( Self);
    End;
end;

procedure TExtDBNumEdit.DataChange(Sender: TObject);
begin
 if FSetText
  Then Exit;

  if FDataLink.Field <> nil then
  try
    if FAlignment <> FDataLink.Field.Alignment then
    begin
      Text := GetTextFloat;  {forces update}
      FAlignment := FDataLink.Field.Alignment;
    end;
  {$IFDEF DELPHI}
    EditMask := FDataLink.Field.EditMask;
  {$ENDIF}
    if not (csDesigning in ComponentState) then
    begin
      if (FDataLink.Field.DataType in [ftString, ftWideString]) and (MaxLength = 0) then
        MaxLength := FDataLink.Field.Size;
    end;
  Text := FDataLink.Field.AsString;
  if FDataLink.Editing and assigned ( FDataLink.Dataset ) and FDataLink.Dataset.Modified then
    Modified := True;
  finally
  end else
  begin
    FAlignment := taLeftJustify;
    EditMask := '';
    if csDesigning in ComponentState then
      Text := Name else
      Text := GetTextFloat;
  end;
  if Text > '' Then
    try
      Text := InitComma(Text);
      FValue := StrToFloat(Text);
    except
      FValue:=0;
    end;
end;

procedure TExtDBNumEdit.EditingChange(Sender: TObject);
begin
  ReadOnly := not FDataLink.CanModify;
end;

{$IFDEF FPC}
procedure TExtDBNumEdit.Undo;
{$ELSE}
procedure TExtDBNumEdit.WMUndo(var Message: TMessage);
{$ENDIF}
begin
  FDataLink.Edit;
  inherited;
end;

procedure TExtDBNumEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TExtDBNumEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

{$IFDEF FPC}
procedure TExtDBNumEdit.WMEnter(var Message: TLMEnter);
{$ELSE}
procedure TExtDBNumEdit.CMEnter(var Message: TCMEnter);
{$ENDIF}
begin
  SetFocused(True);
  inherited;
  if SysLocale.FarEast and FDataLink.CanModify then
    ReadOnly := False;
end;

{$IFDEF FPC}
procedure TExtDBNumEdit.WMExit(var Message: TLMExit);
{$ELSE}
procedure TExtDBNumEdit.CMExit(var Message: TCMExit);
{$ENDIF}
var laco_connecteur : TCustomConnection ;
begin
  try
    FDataLink.UpdateRecord;
  except
    on e: Exception do
      Begin
        SelectAll;
        SetFocus;
        laco_connecteur := nil ;
        f_GereException ( e, FDataLink.DataSet, laco_connecteur , False )
      End ;
  end;
  SetFocused(False);
  DoExit;
end;

procedure TExtDBNumEdit.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

function TExtDBNumEdit.ExecuteAction(AAction: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(AAction) or (FDataLink <> nil)
    {$IFDEF DELPHI}
   and FDataLink.ExecuteAction(AAction)
    {$ENDIF};
end;

function TExtDBNumEdit.UpdateAction(AAction: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(AAction) or (FDataLink <> nil)
    {$IFDEF DELPHI}
    and FDataLink.UpdateAction(AAction)
    {$ENDIF};
end;

procedure TExtDBNumEdit.p_SetValue(AValue: TAFloat);
begin
  if AValue <> FValue Then
    Begin
      FValue := fext_CalculateNumber(AValue,FNumRounded, gby_NbApVirgule );
      if assigned ( FDataLink.Field ) Then
        Begin
          FDataLink.DataSet.Edit ;
          FDataLink.Field.Value := FValue ;
//          showmessage ( FDataLink.Field.AsString );
        End
      Else
        Text := InitComma (GetTextFloat);
    End ;

end;


{ TExtNumEdit }

constructor TExtNumEdit.Create(AOwner: TComponent);
begin
  inherited;
  gb_Calculate := True;
  FAlwaysSame := True;
  FChangingValue := False;
  Alignment := taRightJustify;
  gby_NbAvVirgule := CST_NUM_BEFORECOMMA ;
  gby_NbApVirgule := CST_NUM_AFTERCOMMA ;
  gb_Negatif   := CST_NUM_NEGATIVE ;
  FColorReadOnly := CST_EDIT_READ;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FMin := 0;
  FMax := 0;
  FHasMin := false;
  FHasMax := false;
  FNumRounded := nrMiddle;
  FOnSetValue := nil ;
  FOnValueSet := nil;
end;

function TExtNumEdit.GetTextFloat: String;
var li_i, li_length : Integer;
begin
  Result := IntToStr(trunc(fext_CalculateNumber ( Value, FNumRounded, gby_NbApVirgule )*Power(10,gby_NbApVirgule)));
  if gby_NbApVirgule > 0 Then
   Begin
     li_length :=length ( Result );
     {$IFDEF FORMATSETTING}
     with FormatSettings do
     {$ENDIF}
     Result := copy ( Result, 1, li_length - gby_NbApVirgule)+DecimalSeparator+copy ( Result, li_length - gby_NbApVirgule + 1, gby_NbApVirgule);
   end;

end;

function TExtNumEdit.GetTextMargins: TPoint;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  if NewStyleControls then
  begin
    if BorderStyle = bsNone then I := 0 else
      {$IFNDEF FPC} if Ctl3D then I := 1 else{$ENDIF} I := 2;

    {$IFDEF DELPHI}
    Result.X := SendMessage(Handle, EM_GETMARGINS, 0, 0) and $0000FFFF + I;
    {$ENDIF}
    Result.Y := I;
  end else
  begin
    if BorderStyle = bsNone then I := 0 else
    begin
      DC := GetDC(0);
      GetTextMetrics(DC, SysMetrics);
      SaveFont := SelectObject(DC, Font.Handle);
      GetTextMetrics(DC, Metrics);
      SelectObject(DC, SaveFont);
      ReleaseDC(0, DC);
      I := SysMetrics.tmHeight;
      if I > Metrics.tmHeight then I := Metrics.tmHeight;
      I := I div 4;
    end;
    Result.X := I;
    Result.Y := I;
  end;
end;

procedure TExtNumEdit.p_SetNbAvVirgule(const Avalue: Byte);
begin
  if Avalue <> gby_NbAvVirgule Then
   Begin
     gby_NbAvVirgule := Avalue;
   end;
end;

procedure TExtNumEdit.p_SetNbApVirgule(const Avalue: Byte);
begin
  if Avalue <> gby_NbApVirgule Then
   Begin
     gby_NbApVirgule := Avalue;
   end;

end;

destructor TExtNumEdit.Destroy;
begin
  FCanvas.Free;
  inherited;
end;

procedure TExtNumEdit.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son {$IFDEF TNT}TTntLabel{$ELSE}TLabel{$ENDIF} par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TExtNumEdit.SetFocused(AValue: Boolean);
begin
  if FFocused <> AValue then
  begin
    FFocused := AValue;
    if (FAlignment <> taLeftJustify) then Invalidate;
  end;
end;


procedure TExtNumEdit.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );
  DoExitText;
end;

procedure TExtNumEdit.DoExitText;
begin
  SetToText ( InitComma(Text));
end;

function TExtNumEdit.InitComma( as_text : String ):String;
    var li_pos, li_length  : Integer;
    function fs_eraseZero ( const as_text : String ) : String;
    var li_i : Integer;
        li_StopDelete : Integer;
        lb_EraseZero : Boolean;
    Begin
      Result:='';
      li_StopDelete := 0;
      lb_EraseZero := True;
      li_length:=length ( as_text );
  {$IFDEF FORMATSETTING}
  with FormatSettings do
  {$ENDIF}
        for li_i := 1 to li_length do
       Begin
         if (      (as_text [li_i] in ['-','+'] )
             and ( li_i = 1 )) // first char can be + or -
         or (      (as_text [li_i] in ['0'..'9'] ) // or every numerics
             and (   (li_StopDelete=0)
                  or (( li_i - li_StopDelete <= gby_NbApVirgule ) and (li_StopDelete>0))))
         or ((as_text [li_i] = DecimalSeparator ) and (li_StopDelete=0))
          Then
           Begin
             if lb_EraseZero
             and (   (as_text [li_i] in ['1'..'9'] )
                 or  ((li_i<li_length) and (as_text [li_i+1] = DecimalSeparator )))
              Then lb_EraseZero:=False;
             if  lb_EraseZero
             and (as_text [li_i]  = '0' )
              Then
              Continue;
             if (as_text [li_i] = DecimalSeparator ) then
              Begin
               li_StopDelete:=li_i;
               if  ( li_i > 1 )
               and not ( as_text [li_i-1] in ['0'..'9'] )
                Then
                 AppendStr(Result,'0');
              end;
             AppendStr(Result,as_text[li_i]);
           end;
       end;
    end;

    var li_SelPos, li_SelLength : Integer;
begin
  li_SelPos := SelStart;
  li_SelLength := SelLength;
  li_length := Length ( as_text);
  {$IFDEF FORMATSETTING}
  with FormatSettings do
  {$ENDIF}
   try
    if (as_text='')
    or (as_text [1] = DecimalSeparator) Then
     as_text := '0' + as_text;
    case DecimalSeparator of
      '.' : if pos ( ',', as_text ) > 0 Then
              Begin
                Text := fs_remplaceChar ( as_text, ',', '.');
                Exit;
              end;
      ',' : if pos ( '.', as_text ) > 0 Then
              Begin
                Text := fs_remplaceChar ( as_text, '.', ',');
                Exit;
              end;
    end;
    li_pos  := pos ( DecimalSeparator, as_text );
    if li_pos = 0 then
     Begin
       AppendStr ( as_text, DecimalSeparator );
       inc ( li_length );
       li_pos:=li_length;
     end;
    if li_pos > 0 then
     Begin
      li_pos :=gby_nbApVirgule-( li_length - li_pos );
      if li_pos > 0 then
        as_text:=as_text+fs_repetechar ( '0', li_pos);
      as_Text := fs_eraseZero (as_text);
     end;
   finally
     SelStart := li_SelPos;
     SelLength := li_SelLength;
     Result := as_text;
   end;
end;

procedure TExtNumEdit.KeyPress(var Key: Char);
var ls_text : String;
    li_selstart,
    li_sellength : Integer;
begin
  li_selstart := SelStart;
  li_sellength := SelLength;
  ls_text := Text;
  try
    if      ( Key in ['-','+'] )
    and     ( ls_text > '' )
    and not ( ls_text [1] in ['-','+'])
     Then
      Begin
       Text := Key+ls_Text;
       Key:=#0;
       Exit;
      end;
    p_editGridKeyPress ( Self, Key,gby_NbApVirgule, gby_NbAvVirgule, gb_Negatif, SelStart, {$IFDEF FPC}CaretPos.X{$ELSE}SelStart{$ENDIF}, ls_Text, SelText, gby_NbApVirgule > 0 );

  finally
    Selstart := li_selstart;
    SelLength := li_SelLength;

  end;

  inherited;

end;

procedure TExtNumEdit.SetTextToValue;
Begin
  if FChangingValue Then
   Exit;
  if Text > '' Then
   {$IFDEF FORMATSETTING}
   with FormatSettings do
   {$ENDIF}
    try
      if not(Text[1] in ['+','-',DecimalSeparator,'0'..'9']) Then
       Text := GetTextFloat;
      FValue := StrToFloat ( fs_remplaceEspace ( Text, '' ));
      if  ( FHasMax )
      and ( FValue > FMax )  then
        Begin
          Value := FMax ;
        End;

      if  ( FHasMin )
      and ( FValue < FMin )  then
        Begin
          Value := FMin ;
        End;
    Except
      SetToText ( InitComma( Text ));
    End ;

end;

procedure TExtNumEdit.SetToText(const as_text: String);
begin
  Text := as_text;
end;

procedure TExtNumEdit.KeyUp(var Key: Word; Shift: TShiftState);
var lext_Value : TAFloat;
    ls_text : ShortString ;
    li_SelLength, li_SelStart : Integer;
begin
  li_SelLength := SelLength;
  li_SelStart  := SelStart;
  try
    lext_Value := FValue;
    ls_text := Text;
    p_editKeyUp ( lext_Value, Key,gby_NbApVirgule, gby_NbAvVirgule, gb_Negatif, ls_text );
  finally
    SelLength := li_SelLength;
    SelStart  := li_SelStart;
  end;
  inherited;
  SetToText ( InitComma ( ls_text ));
end;

procedure TExtNumEdit.p_SetValue(AValue: TAFloat);
begin
  if AValue <> FValue Then
    try
      if assigned ( FOnSetValue )
       Then FOnSetValue ( Self );
      FChangingValue := True;
      FValue:=fext_CalculateNumber(AValue,FNumRounded, gby_NbApVirgule);
      if  ( FHasMax )
      and ( FValue > FMax )  then
        Begin
          FValue := FMax ;
        End;

      if  ( FHasMin )
      and ( FValue < FMin )  then
        Begin
          FValue := FMin ;
        End;
      Text := InitComma (GetTextFloat);
    finally
      FChangingValue := False;
      if assigned ( FOnValueSet )
       Then FOnValueSet ( Self );
    End ;

end;

procedure TExtNumEdit.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
const
  AlignStyle : array[Boolean, TAlignment] of DWORD =
   ((WS_EX_LEFT, WS_EX_RIGHT, WS_EX_LEFT),
    (WS_EX_RIGHT, WS_EX_LEFT, WS_EX_LEFT));
var
  ALeft: Integer;
  Margins: TPoint;
  R: TRect;
  DC: HDC;
  PS: TPaintStruct;
  S: string;
  AAlignment: TAlignment;
  ExStyle: DWORD;
begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  AAlignment := FAlignment;
  if UseRightToLeftAlignment then ChangeBiDiModeAlignment(AAlignment);
  if ((AAlignment = taLeftJustify) or FFocused) and
    not (csPaintCopy in ControlState) then
  begin
    if SysLocale.MiddleEast and HandleAllocated and (IsRightToLeft) then
    begin { This keeps the right aligned text, right aligned }
      ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) and (not WS_EX_RIGHT) and
        (not WS_EX_RTLREADING) and (not WS_EX_LEFTSCROLLBAR);
      if UseRightToLeftReading then ExStyle := ExStyle or WS_EX_RTLREADING;
      if UseRightToLeftScrollbar then ExStyle := ExStyle or WS_EX_LEFTSCROLLBAR;
      ExStyle := ExStyle or
        AlignStyle[UseRightToLeftAlignment, AAlignment];
      if DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) <> ExStyle then
        SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
    end;
    inherited;
    Exit;
  end;
{ Since edit controls do not handle justification unless multi-line (and
  then only poorly) we will draw right and center justify manually unless
  the edit has the focus. }
  if FCanvas = nil then
  begin
    FCanvas := TControlCanvas.Create;
    FCanvas.Control := Self;
  end;
  DC := Message.DC;
  if DC = 0 then DC := BeginPaint(Handle, PS);
  FCanvas.Handle := DC;
  try
    FCanvas.Font := Font;
    with FCanvas do
    begin
      R := ClientRect;
      if {$IFNDEF FPC} not (NewStyleControls and Ctl3D) and {$ENDIF}  (BorderStyle = bsSingle) then
      begin
        Brush.Color := clWindowFrame;
        FrameRect(R);
        InflateRect(R, -1, -1);
      end;
      Brush.Color := Color;
      if not Enabled then
        Font.Color := clGrayText;
      if (csPaintCopy in ControlState) then
      begin
        S := Text;
        case CharCase of
          ecUpperCase: S := AnsiUpperCase(S);
          ecLowerCase: S := AnsiLowerCase(S);
        end;
      end else
        S := Text;
      if PasswordChar <> #0 then FillChar(S[1], Length(S), PasswordChar);
      Margins := GetTextMargins;
      case AAlignment of
        taLeftJustify: ALeft := Margins.X;
        taRightJustify: ALeft := ClientWidth - TextWidth(S) - Margins.X - 1;
      else
        ALeft := (ClientWidth - TextWidth(S)) div 2;
      end;
    {$IFDEF DELPHI}
      if SysLocale.MiddleEast then UpdateTextFlags;
     {$ENDIF}
      TextRect(R, ALeft, Margins.Y, S);
    end;
  finally
    FCanvas.Handle := 0;
    if Message.DC = 0 then EndPaint(Handle, PS);
  end;
End;

procedure TExtNumEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,OnContextPopup,FOnPopup);
end;

procedure TExtNumEdit.SetName(const NewName: TComponentName);
begin
  if  (NewName <> Name) Then
   Begin
    inherited SetName(NewName);
    if not (csDesigning in ComponentState) then
     Text := GetTextFloat;
   end;
end;

procedure TExtNumEdit.{$IFNDEF FPC}Change{$ELSE}TextChanged{$ENDIF};
begin
  inherited;
  SetTextToValue;
end;

procedure TExtNumEdit.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TExtNumEdit.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;


{$IFDEF VERSIONS}
initialization
  p_ConcatVersion ( gVer_TExtNumEdit  );
  p_ConcatVersion ( gVer_TExtDBNumEdit );
{$ENDIF}
end.