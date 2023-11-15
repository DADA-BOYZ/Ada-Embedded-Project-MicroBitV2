with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.Radio; use MicroBit.Radio;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Ultrasonic; 
with HAL; use HAL;
with LSM303AGR;
use MicroBit;
with PID;

package body TaskControl is


    -- Sense
    task body Read_Distance_Sensors is
        package front_sensor is new Ultrasonic(MB_P2,  MB_P0);
        package left_sensor  is new Ultrasonic(MB_P15, MB_P13);
        package right_sensor is new Ultrasonic(MB_P1,  MB_P16);
        
        timer : Time;
        PERIOD : constant Time_Span := Milliseconds(80);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            distance.front := front_sensor.Read;
            distance.left  := left_sensor.Read;
            distance.right := right_sensor.Read;
            dt := Clock - timer;
            --Put_Line("Read_Distance_Sensors:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Read_Distance_Sensors;
    
    
    task body Read_Radio is
        timer : Time;
        PERIOD : constant Time_Span := Milliseconds(20);
        dt : Time_Span;
    begin
        Radio.Setup(RadioFrequency => 2511,
                    Length => 3+5,
                    Version => 12,
                    Group => 1,
                    Protocol => 14);
        Radio.StartReceiving;
        loop
            timer := Clock;
            while Radio.DataReady loop
                RXdata := Radio.Receive;
            end loop;
            dt := Clock - timer;
            --Put_Line("Read_Radio:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Read_Radio;
    
    
    -- Think
    task body Determine_State is
        minimum_distance : Distance_cm;
        
        timer : Time;
        PERIOD : constant Time_Span := Milliseconds(80);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            
            -- Clamps distance values to range 1 .. 40 because we are not interested in > 40 or 0
            if distance.front = 0 or distance.front > 40 then
                distance.front := 40;
            end if;
            if distance.left = 0 or distance.left > 40 then
                distance.left := 40;
            end if;
            if distance.right = 0 or distance.right > 40 then
                distance.right := 40;
            end if;
           
            -- Finds the lowest distance value
            minimum_distance := 41;
            if distance.right < minimum_distance then
                minimum_distance := distance.right;
            end if;
            if distance.front < minimum_distance then
                minimum_distance := distance.front;
            end if;
            if distance.left < minimum_distance then
                minimum_distance := distance.left;
            end if;
              
            -- Based on lowest distance value, determine which direction to Avoid
            if distance.right <= 20 and distance.right = minimum_distance then
                state := AvoidingRight;
            elsif distance.front <= 20 and distance.front = minimum_distance then
                state := AvoidingFront;
            elsif distance.left <= 20 and distance.left = minimum_distance then
                state := AvoidingLeft;
            else
                state := Remote;
            end if;
            
            Put_Line("state=" & state'Image);
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
    end Determine_State;

    
    task body Determine_Radio is
        THRESHOLD : constant := 20;
        
        PERIOD : constant Time_Span := Milliseconds(20);
        timer : Time;
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            
            -- Button states
            if RXdata.Payload(5) = 2#001# then
                button.a := True;
                Put_Line("A");
            else
                button.a := False;
            end if;
            if RXdata.Payload(5) = 2#010# then
                button.b := True;
                Put_Line("B");
            else
                button.b := False;
            end if;
            if RXdata.Payload(5) = 2#100# then
                button.touch := True; 
                Put_Line("Touch");
            else
                button.touch := False;
            end if;
            
            -- Buttons determine rotation
            if button.a and not button.b then
                acc.Rot := -2**9;
                Put_Line("A not B");
            elsif not button.a and button.b then
                acc.Rot := 2**9 - 1;
                Put_Line("B not A");
            else
                acc.Rot := 0;
            end if;
            
            -- Accelerometer states
            acc.X := LSM303AGR.Convert(RXdata.Payload(1), RXdata.Payload(2)) * Axis_Data(-1);
            acc.Y := LSM303AGR.Convert(RXdata.Payload(3), RXdata.Payload(4));
            
            if abs(acc.X) < Threshold then
                acc.X := 0;
            end if;
            if abs(acc.Y) < Threshold then
                acc.Y := 0;
            end if;
            
            -- Safe state when touch button is pressed
            if button.touch then
                acc.X := 0;
                acc.y := 0;
                acc.Rot := 0;
            end if;
            
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
    end Determine_Radio;
    
    
    -- Act
    task body Avoid is
        PERIOD : constant Time_Span := Milliseconds(80);
        timer : Time;
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if state = AvoidingFront then
                pwm.rf := -4095;
                pwm.rb := -4095;
                pwm.lf := -4095;
                pwm.lb := -4095;
            elsif state = AvoidingLeft then
                pwm.rf := -4095;
                pwm.rb := 4095;
                pwm.lf := 4095;
                pwm.lb := -4095;
            elsif state = AvoidingRight then
                pwm.rf := 4095;
                pwm.rb := -4095;
                pwm.lf := -4095;
                pwm.lb := 4095;
            end if;
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
    end Avoid;
    
    
    task body Move_Radio is
        denominator : Integer;
        FACTOR : constant := 8;
        
        timer : Time;
        PERIOD : constant Time_Span := Milliseconds(20);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if state = Remote then
                denominator := abs(Integer(acc.Y)*Factor) + abs(Integer(acc.X)*Factor) + abs(Integer(acc.Rot)*Factor);
                if denominator < 1 then
                    denominator := 1;
                end if;
                
                pwm.rf := Clamp(-4095, 4095, Integer(acc.Y*Factor + acc.X*Factor - acc.Rot*Factor/2));
                pwm.rb := Clamp(-4095, 4095, Integer(acc.Y*Factor - acc.X*Factor - acc.Rot*Factor/2));
                pwm.lf := Clamp(-4095, 4095, Integer(acc.Y*Factor - acc.X*Factor + acc.Rot*Factor/2));
                pwm.lb := Clamp(-4095, 4095, Integer(acc.Y*Factor + acc.X*Factor + acc.Rot*Factor/2));
                
                dt := Clock - timer;
            end if;
            delay until Clock + PERIOD;
        end loop;
    end Move_Radio;
    
    
    task body Motor_Control is
        speeds : Speeds2;

        timer : Time;
        PERIOD : constant Time_Span := Milliseconds(80);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            speeds := (pwm.rf, pwm.rb, pwm.lf, pwm.lb);
            case state is
                when Idle => Drive(Stop);
                when others => Drive3(speeds);
            end case;
            dt := Clock - timer;
            delay until Clock + PERIOD;
            end loop;
    end Motor_Control;
    
    
    -- Private functions
    function Clamp(min : Integer; max : Integer; value : Integer) return Integer is
    begin
        if value < min then
            return min;
        elsif value > max then
            return max;
        else
            return value;
        end if; 
    end Clamp;
    

end TaskControl;
