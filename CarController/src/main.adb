with LSM303AGR; use LSM303AGR;

with MicroBit.DisplayRT;
with MicroBit.DisplayRT.Symbols;
with MicroBit.Accelerometer;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.Buttons; use MicroBit.Buttons;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Radio; use MicroBit.Radio;

with HAL; use HAL;
use MicroBit;

procedure Main is

   Data: All_Axes_Data_Raw;
   Threshold : constant := 150;
   MyClock : Time;
   TxData : Radio.RadioData;
   X, Y, Z : Axis_Data;

begin

   TxData.Length := 3+12;
   TxData.Version := 12;
   TxData.Group := 1;
   TxData.Protocol := 14;

   Radio.Setup(RadioFrequency => 2407,
               Length => TxData.Length,
               Version => TxData.Version,
               Group => TxData.Group,
               Protocol => TxData.Protocol);

   Radio.StartReceiving;
   Put_Line(Radio.State);

   TxData.Payload(1) := 16#FF#;
   TxData.Payload(2) := 16#FF#;
   Radio.Transmit(TxData);
   delay 0.1;

   loop
      MyClock := Clock;

      Data := Accelerometer.AccelDataRaw;

      TxData.Payload(1) := Data.X.Low;
      TxData.Payload(2) := Data.X.High;
      TxData.Payload(3) := Data.Y.Low;
      TxData.Payload(4) := Data.Y.High;
      TxData.Payload(5) := Data.Z.Low;
      TxData.Payload(6) := Data.Z.High;

      X := LSM303AGR.Convert(Data.X.Low, Data.X.High) * Axis_Data (-1);
      Y := LSM303AGR.Convert(Data.Y.Low, Data.Y.High);
      Z := LSM303AGR.Convert(Data.Z.Low, Data.Z.High);

      MicroBit.DisplayRT.Clear;
      if X > Threshold then
         MicroBit.DisplayRT.Symbols.Left_Arrow;


         TxData.Payload(7) := 2#0000_0100#;  --ROW1
         TxData.Payload(8) := 2#0000_1000#;  --ROW2
         TxData.Payload(9) := 2#0001_1111#;  --ROW3
         TxData.Payload(10) := 2#0000_1000#;  --ROW4
         TxData.Payload(11) := 2#0000_0100#;  --ROW5
         Put_Line("X > Treshold");
      elsif X < -Threshold then
         MicroBit.DisplayRT.Symbols.Right_Arrow;

         TxData.Payload(7) := 2#0000_0100#;  --ROW1
         TxData.Payload(8) := 2#0000_0010#;  --ROW2
         TxData.Payload(9) := 2#0001_1111#;  --ROW3
         TxData.Payload(10) := 2#0000_0010#;  --ROW4
         TxData.Payload(11) := 2#0000_0100#;  --ROW5
         Put_Line("X < -Treshold");
      elsif Y > Threshold then
         DisplayRT.Symbols.Up_Arrow;

         TxData.Payload(7) := 2#0000_0100#;  --ROW1
         TxData.Payload(8) := 2#0000_1110#;  --ROW2
         TxData.Payload(9) := 2#0001_0101#;  --ROW3
         TxData.Payload(10) := 2#0000_0100#;  --ROW4
         TxData.Payload(11) := 2#0000_0100#;  --ROW5
         Put_Line("Y > Treshold");
      elsif Y < -Threshold then
         MicroBit.DisplayRT.Symbols.Down_Arrow;

         TxData.Payload(7) := 2#0000_0100#;  --ROW1
         TxData.Payload(8) := 2#0000_0100#;  --ROW2
         TxData.Payload(9) := 2#0001_0101#;  --ROW3
         TxData.Payload(10) := 2#0000_1110#;  --ROW4
         TxData.Payload(11) := 2#0000_0100#;  --ROW5
         Put_Line("Y < -Threshold");
      else
         MicroBit.DisplayRT.Symbols.Heart;

         TxData.Payload(7) := 2#0000_1010#;  --ROW1
         TxData.Payload(8) := 2#0001_0101#;  --ROW2
         TxData.Payload(9) := 2#0001_0001#;  --ROW3
         TxData.Payload(10) := 2#0000_1010#;  --ROW4
         TxData.Payload(11) := 2#0000_0100#;  --ROW5
         Put_Line("Stable");
      end if;


      -- Resets Buttons
      TxData.Payload(12) := 2#0000_0000#;

      if MicroBit.Buttons.State (Button_A) = Pressed then
         TxData.Payload(12) := 2#001#;
         Put_Line("Button A pressed");

      elsif MicroBit.Buttons.State (Button_B) = Pressed then
         TxData.Payload(12) := 2#010#;
         Put_Line("Button B pressed");

      elsif MicroBit.Buttons.State (Logo) = Pressed then
         TxData.Payload(12) := 2#100#;
         Put_Line("Logo pressed");
      end if;
      Radio.Transmit(TxData);
      Put_Line("Transmitted Data over Radio");

      delay until MyClock + Milliseconds(50);

   end loop;
end Main;
