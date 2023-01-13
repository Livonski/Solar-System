unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls;

type
  planet = object
    procedure calculateOrbit;
    procedure calculateNewPosition;
    private

    public
      orbitalPeriod : Integer;
      orbitEccentricity : real;
      orbit : array[0..359] of TPoint;
      trueRadius, trueOrbit : Integer;
      planetRadius, orbitRadius : Integer;

      currentPosition: Integer;
      position: TPoint;

      color : TColor;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    procedure changeScale(Sender: TObject);
    procedure onStart(Sender: TObject);
    procedure onUpdate(Sender: TObject);

    procedure calculateScale(Sender: TObject);
    procedure drawPlanets(Sender: TObject);
    procedure drawOrbits(Sender: TObject);
    procedure calculatePositions(Sender: TObject);
  private

  public
        trueScale : boolean;
        scale : real;
        planets : array[0..7] of planet;
        systemCenter : TPoint;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.onStart(Sender: TObject);
var
  i : integer;
begin
     systemCenter.x := PaintBox1.Width div 2;
     systemCenter.y := PaintBox1.Height div 2;

     scale := 0.005;
     //SUN
     planets[0].planetRadius:= 436;
     planets[0].orbitRadius:= 0;
     planets[0].position := systemCenter;
     planets[0].color := clYellow;
     planets[0].orbitalPeriod := 1;
     //Mercury
     planets[1].planetRadius:= 2;
     planets[1].orbitRadius:= 40000;
     planets[1].color := TColor($708090);
     planets[1].orbitalPeriod := 87;
     planets[1].orbitEccentricity := 0.020;
     //Venus
     planets[2].planetRadius:= 4;
     planets[2].orbitRadius:= 70000;
     planets[2].color := clOlive;
     planets[2].orbitalPeriod := 225;
     planets[2].orbitEccentricity := 0.006;
     //Earth
     planets[3].planetRadius:= 4;     // 4 ≈ 6 378 km
     planets[3].orbitRadius:= 100000; // 100 000 == 1 AU (astronomic unit)
     planets[3].color := clGreen;
     planets[3].orbitalPeriod := 365;
     planets[3].orbitEccentricity := 0.016;
     //Mars
     planets[4].planetRadius:= 3;
     planets[4].orbitRadius:= 150000;
     planets[4].color := clRed;
     planets[4].orbitalPeriod := 686;
     planets[4].orbitEccentricity := 0.09;
     //Jupiter
     planets[5].planetRadius:= 55;
     planets[5].orbitRadius:= 520000;
     planets[5].color := clOlive;
     planets[5].orbitalPeriod := 4329;
     planets[5].orbitEccentricity := 0.04;
     //Saturn
     planets[6].planetRadius:= 38;
     planets[6].orbitRadius:= 950000;
     planets[6].color := clOlive;
     planets[6].orbitalPeriod := 10749;
     planets[6].orbitEccentricity := 0.05;
     //Uranus
     planets[7].planetRadius:= 16;
     planets[7].orbitRadius:= 1980000;
     planets[7].color := TColor($4682B4);
     planets[7].orbitalPeriod := 10749;
     planets[7].orbitEccentricity := 0.05;

     for i := 0 to Length(planets) - 1 do begin
         planets[i].trueRadius := planets[i].planetRadius;
         planets[i].trueOrbit := planets[i].orbitRadius;
     end;

     calculateScale(Sender);

end;

procedure TForm1.onUpdate(Sender: TObject);
begin
     PaintBox1.Canvas.Clear;
     calculatePositions(Sender);
     drawOrbits(Sender);
     drawPlanets(Sender);
end;

procedure TForm1.calculateScale(Sender: TObject);
var
  i : Integer;
  sunScale, planetScale, giantsScale : real;
begin
     scale := TrackBar1.position / 10000;
     sunScale := scale * 50;
     planetScale := scale * 1000;
     giantsScale := scale * 200;
     planets[0].planetRadius := round(planets[0].trueRadius * sunScale);
     for i := 0 to Length(planets) - 1 do begin
         if ((i > 0) and (i < 5)) then
            planets[i].planetRadius := round(planets[i].trueRadius * planetScale);
         if i > 4 then
            planets[i].planetRadius := round(planets[i].trueRadius * giantsScale);
         planets[i].orbitRadius := round(planets[i].trueOrbit * scale);
         planets[i].calculateOrbit;
     end;
end;

procedure TForm1.calculatePositions(Sender: TObject);
var
  i : Integer;
begin
     for i := 1 to Length(planets) do begin
         planets[i].calculateNewPosition;
     end;
end;

procedure TForm1.drawOrbits(Sender: TObject);
var
  i , j: Integer;
begin
     for i := 1 to Length(planets) do begin
         if planets[i].orbitRadius <> 0 then begin
             for j := 1 to Length(planets[i].orbit) - 1  do begin
                 PaintBox1.Canvas.Line(planets[i].orbit[j],planets[i].orbit[j - 1]);
             end;
            PaintBox1.Canvas.Line(planets[i].orbit[359],planets[i].orbit[1]);
         end;
     end;
end;

procedure TForm1.drawPlanets(Sender: TObject);
var
  i: integer;
  planet:TRect;
  p1,p2 : TPoint;
begin
     for i := 0 to Length(planets)-1 do begin
         p1.x := planets[i].position.x - planets[i].planetRadius;
         p1.y := planets[i].position.y - planets[i].planetRadius;

         p2.x := planets[i].position.x + planets[i].planetRadius;
         p2.y := planets[i].position.y + planets[i].planetRadius;

         planet.Create(p1,p2);
         PaintBox1.Canvas.Brush.Color := planets[i].color;
         PaintBox1.Canvas.Ellipse(planet);
         PaintBox1.Canvas.Brush.Color := clWhite;
     end;
end;

procedure planet.calculateOrbit;
var
  i : Integer;
  angle : real;
  x,y : integer;
begin

     if orbitRadius <> 0 then begin
       for i := 0 to 359 do begin

           angle := i * pi/180;
           x := Form1.systemCenter.x + round(orbitRadius * cos(angle));
           y := Form1.systemCenter.y + round(orbitRadius * sin(angle) *  (1 -orbitEccentricity));
           orbit[i].Create(x,y);
       end;

       currentPosition := 1;
       position := orbit[1];
     end;
end;

procedure planet.calculateNewPosition;
var
  newPosition : TPoint;
  x,y : Integer;
  angle : real;
begin

     if currentPosition + 1 > orbitalPeriod then
        currentPosition := 0;
     currentPosition := currentPosition + 1;
     if orbitalPeriod <> 0 then
        angle := currentPosition * pi/180 * (360 / orbitalPeriod);
     x := Form1.systemCenter.x + round(orbitRadius * cos(angle));
     y := Form1.systemCenter.y + round(orbitRadius * sin(angle) *  (1 -orbitEccentricity));

     newPosition.Create(x,y);
     position := newPosition;
end;

end.

