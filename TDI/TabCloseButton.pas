unit TabCloseButton;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, UxTheme, Themes, Math, PageControlEx;

type
  TTabCloseButton = class(TPageControlEx)
  private
    FCloseButtonsRect: array of TRect;
    FCloseButtonMouseDownIndex: Integer;
    FCloseButtonShowPushed: Boolean;
    FOnCloseClick: TNotifyEvent;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); override;
    procedure MouseLeave(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;

    property OnCloseClick: TNotifyEvent read FOnCloseClick write FOnCloseClick;
    procedure UpdateCloseButtons;
  end;

implementation

constructor TTabCloseButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabWidth     := 150;
  OwnerDraw    := True;
  UpdateCloseButtons;
end;

destructor TTabCloseButton.Destroy;
begin

  inherited;
end;

procedure TTabCloseButton.UpdateCloseButtons;
var
  I: Integer;
begin
//  {$IF RTLVersion < 18}
  OnMouseLeave := MouseLeave; //CM_MOUSELEAVE not reliable before D2006
//  {$IFEND}

  SetLength(FCloseButtonsRect, PageCount);
  FCloseButtonMouseDownIndex := -1;

  for I := 0 to Length(FCloseButtonsRect) - 1 do
  begin
    FCloseButtonsRect[I] := Rect(0, 0, 0, 0);
  end;
end;

procedure TTabCloseButton.DrawTab(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
var
  CloseBtnSize: Integer;
  TabCaption: TPoint;
  CloseBtnRect: TRect;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
begin
  //inherited;

  if InRange(TabIndex, 0, Length(FCloseButtonsRect) - 1) then
  begin
    CloseBtnSize := 14;
    TabCaption.Y := Rect.Top + 3;

    if Active then
    begin
      CloseBtnRect.Top := Rect.Top + 4;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 6;
    end
    else
    begin
      CloseBtnRect.Top := Rect.Top + 3;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 3;
    end;

    CloseBtnRect.Bottom := CloseBtnRect.Top + CloseBtnSize;
    CloseBtnRect.Left := CloseBtnRect.Right - CloseBtnSize;
    FCloseButtonsRect[TabIndex] := CloseBtnRect;

    Canvas.FillRect(Rect);
    Canvas.TextOut(TabCaption.X, TabCaption.Y, Pages[TabIndex].Caption);

    if not UseThemes then
    begin
      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED
      else
        CloseBtnDrawState := DFCS_CAPTIONCLOSE;

      Windows.DrawFrameControl(Canvas.Handle,
        FCloseButtonsRect[TabIndex], DFC_CAPTION, CloseBtnDrawState);
    end
    else
    begin
      Dec(FCloseButtonsRect[TabIndex].Left);

      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonPushed)
      else
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonNormal);

      ThemeServices.DrawElement(Canvas.Handle, CloseBtnDrawDetails,
        FCloseButtonsRect[TabIndex]);
    end;
  end;
end;

procedure TTabCloseButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I: Integer;
begin
  inherited;
  if Button = mbLeft then
  begin
    for I := 0 to Length(FCloseButtonsRect) - 1 do
    begin
      if PtInRect(FCloseButtonsRect[I], Point(X, Y)) then
      begin
        FCloseButtonMouseDownIndex := I;
        FCloseButtonShowPushed := True;
        Repaint;
      end;
    end;
  end;
end;

procedure TTabCloseButton.MouseLeave(Sender: TObject);
begin
  inherited;
  FCloseButtonShowPushed := False;
  Repaint;
end;

procedure TTabCloseButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Inside: Boolean;
begin
  inherited;
  if (ssLeft in Shift) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    Inside := PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y));

    if FCloseButtonShowPushed <> Inside then
    begin
      FCloseButtonShowPushed := Inside;
      Repaint;
    end;
  end;
end;

procedure TTabCloseButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    if PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y)) then
    begin
      if Assigned(FOnCloseClick) then
      begin
        FOnCloseClick(Pages[FCloseButtonMouseDownIndex]);
      end;

      FCloseButtonMouseDownIndex := -1;
      Repaint;
    end;
  end;
end;

end.
