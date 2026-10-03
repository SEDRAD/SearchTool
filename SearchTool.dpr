{
  SearchTool
  Copyright (C) 2026 SEDRAD

  This Source Code Form is subject to the terms of the
  Mozilla Public License, v. 2.0. If a copy of the MPL was not
  distributed with this file, You can obtain one at
  https://mozilla.org/MPL/2.0/.
}

program SearchTool;

uses
  Vcl.Forms,
  U_Main in 'U_Main.pas' {F_Main},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glossy');
  Application.CreateForm(TF_Main, F_Main);
  Application.Run;
end.
