with MicroBit.Ultrasonic; 
with MicroBit.Radio; use MicroBit.Radio;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Console; use MicroBit.Console;
with LSM303AGR; use LSM303AGR;
with PID;
with HAL; use HAL;
use MicroBit;


package body TaskControl is


    -- Sense
    task body Read_Distance_Sensors is
        package front_sensor is new Ultrasonic(MB_P2,  MB_P0);
        package left_sensor  is new Ultrasonic(MB_P15, MB_P13);
        package right_sensor is new Ultrasonic(MB_P1,  MB_P16);
        min_d : Distance_cm;
        timer : Time;
        PERIOD : Time_Span := Milliseconds(80);
        dt : Time_Span;
    begin
        loop
            distance.front := front_sensor.Read;
            
            distance.left  := left_sensor.Read;
            timer := Clock;
            distance.right := right_sensor.Read;
            dt := Clock - timer;
            if distance.front = 0 or distance.front > 40
            then
                distance.front := 40;
            end if;
            if distance.left = 0 or distance.left > 40
            then
                distance.left := 40;
            end if;
            if distance.right = 0 or distance.right > 40
            then
                distance.right := 40;
            end if;
           
            
            min_d := 41;
            if (distance.right < min_d)
            then
                min_d := distance.right;
            end if;
            if (distance.front < min_d)
            then
                min_d := distance.front;
            end if;
            if (distance.left < min_d)
            then
                min_d := distance.left;
            end if;
              
            
            if (distance.right <= 20 and distance.right = min_d)
            then
                state := AvoidingRight;
            elsif (distance.front <= 20 and distance.front = min_d)
            then
                state := AvoidingFront;
            elsif (distance.left <= 20 and distance.left = min_d)
            then
                state := AvoidingLeft;
            else
                state := Idle;
            end if;
            Put_Line("state=" & state'Image);
            
            
            Put_Line("RDS:");
            Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            Put_Line("dt= " & To_Duration(dt)'Image);
            Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Read_Distance_Sensors;
    
    
    task body Read_Radio is
        
        RXdata : RadioData;
        --X, Y, Z : Axis_Data;
       
      
        timer : Time;
        PERIOD : Time_Span := Milliseconds(100);
        dt : Time_Span;
        
    begin
        Radio.Setup(RadioFrequency => 2511,
                    Length => 3+12,
                    Version => 12,
                    Group => 1,
                    Protocol => 14);
        Radio.StartReceiving;
        loop
            timer := Clock;
            if (state = Remote)
            then
                while Radio.DataReady loop
                    RXdata := Radio.Receive;
                    
                    -- Button states
                    if RXdata.Payload(7) = 2#001# then
                        button.a := True;
                    else
                        button.a := False;
                    end if;
                    if RXdata.Payload(7) = 2#010# then
                        button.b := True;
                    else
                        button.b := False;
                    end if;
                    if RXdata.Payload(7) = 2#100# then
                        button.touch := True; 
                    else
                        button.touch := False;
                    end if;
                    
                    
                    
                    
                    
                end loop;
            end if;
            dt := Clock - timer;
            --Put_Line("Radio:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Read_Radio;
    
    
    -- Think
    task body AvoidFront is
        PERIOD : Time_Span := Milliseconds(80);
        timer : Time;
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if state = AvoidingFront
            then
                rf_pwm := -4095;
                rb_pwm := -4095;
                lf_pwm := -4095;
                lb_pwm := -4095;
            end if;
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
    end AvoidFront;
    
    task body AvoidLeft is
        PERIOD : Time_Span := Milliseconds(80);
        timer : Time;
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if state = AvoidingLeft
            then
                rf_pwm := -4095;
                rb_pwm := 4095;
                lf_pwm := 4095;
                lb_pwm := -4095;
            end if;
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
    end AvoidLeft;
    
    task body AvoidRight is
        PERIOD : Time_Span := Milliseconds(80);
        timer : Time;
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if state = AvoidingRight
            then
                rf_pwm := 4095;
                rb_pwm := -4095;
                lf_pwm := -4095;
                lb_pwm := 4095;
            end if;
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
    end AvoidRight;
    
    task body Stopping is
        PERIOD : Time_Span := Milliseconds(80);
        timer : Time;
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if state = Idle
            then
                rf_pwm := 0;
                rb_pwm := 0;
                lf_pwm := 0;
                lb_pwm := 0;
            end if;
            dt := Clock - timer;
            delay until Clock + PERIOD;
        end loop;
        
    end Stopping;
    
    
    -- Act
    task body Motor_Control is
        speeds : Speeds2;
        timer : Time;
        PERIOD : Time_Span := Milliseconds(80);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            speeds := (rf_pwm, rb_pwm, lf_pwm, lb_pwm);
            case state is
                when Idle => Drive(Stop);
                when others => Drive3(speeds);
            end case;
            dt := Clock - timer;
            --Put_Line("Motor Control:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
       
            end loop;
    end Motor_Control;
    

end TaskControl;
