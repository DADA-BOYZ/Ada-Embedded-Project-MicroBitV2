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
   MyClock : Time;
   TxData : Radio.RadioData;

begin

   TxData.Length := 3+5;
   TxData.Version := 12;
   TxData.Group := 1;
   TxData.Protocol := 14;

	-- Setup for radio: Frequency, length, version, group and protocol for data transfer
   Radio.Setup(RadioFrequency => 2511,
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

		-- Sets payload for X and Y acc data from MicroBit.
      TxData.Payload(1) := Data.X.Low;
      TxData.Payload(2) := Data.X.High;
      TxData.Payload(3) := Data.Y.Low;
      TxData.Payload(4) := Data.Y.High;


      -- Resets Buttons
      TxData.Payload(5) := 2#0000_0000#;

		-- If button A is pressed and not Button B
      if (MicroBit.Buttons.State (Button_A) = Pressed) and not (MicroBit.Buttons.State (Button_B) = Pressed) then
         TxData.Payload(5) := 2#001#;

		-- If button B is pressed and not Button A
      elsif (MicroBit.Buttons.State (Button_B) = Pressed) and not (MicroBit.Buttons.State (Button_A) = Pressed) then
         TxData.Payload(5) := 2#010#;

		-- If Logo is pressed.
      elsif MicroBit.Buttons.State (Logo) = Pressed then
         TxData.Payload(5) := 2#100#;
		end if;

		-- Transmits Data
      Radio.Transmit(TxData);
		Put_Line("Loop Time = " & To_Duration(Clock - MyClock)'Image);
      delay until MyClock + Milliseconds(25);

   end loop;
end Main;
