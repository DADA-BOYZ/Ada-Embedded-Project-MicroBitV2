with MicroBit.Ultrasonic; 
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Console; use MicroBit.Console;
with PID;
use MicroBit;


package body TaskControl is


    -- Sense
    task body Read_Distance_Sensors is
        package front_sensor is new Ultrasonic(MB_P2,  MB_P0);
        package left_sensor  is new Ultrasonic(MB_P14,MB_P13);
        package right_sensor is new Ultrasonic(MB_P1,  MB_P8);
        timer : Time;
        PERIOD : Time_Span := Milliseconds(100);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            distance_front := front_sensor.Read;
            distance_left  := left_sensor.Read;
            distance_right := right_sensor.Read;
            
            if distance_front = 0 or distance_front > 40
            then
                distance_front := 40;
            end if;
            if distance_left = 0 or distance_left > 40
            then
                distance_left := 40;
            end if;
            if distance_right = 0 or distance_right > 40
            then
                distance_right := 40;
            end if;
            
            Put_Line("state=" & state'Image);
            
            if (distance_left <= 20)
            then
                state := Avoiding;
            elsif (distance_front <= 20)
            then
                state := Avoiding;
            elsif (distance_right <= 20)
            then
                state := Avoiding;
            else
                state := Idle;
            end if;
            
            dt := Clock - timer;
            --Put_Line("RDS:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Read_Distance_Sensors;
    
    
    task body Read_Radio is
        timer : Time;
        PERIOD : Time_Span := Milliseconds(100);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if (state = Radio)
            then
                null;
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
    task body Avoid is
        package front_pid is new PID(Kp => -0.75, Ki => 0.0, Kd => 0.0, name => "front_avd");
        package left_pid  is new PID(Kp => -0.75, Ki => 0.0, Kd => 0.0, name => "left_avd");
        package right_pid is new PID(Kp => -0.75, Ki => 0.0, Kd => 0.0, name => "right_avd");
        timer : Time;
        PERIOD : Time_Span := Milliseconds(50);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            if (state = Avoiding)
            then
                forward_pwr := front_pid.regulate(40, Integer(distance_front));
                left_pwr    := left_pid.regulate (40, Integer(distance_left));
                right_pwr   := right_pid.regulate(40, Integer(distance_right));
            end if;
            dt := Clock - timer;
            --Put_Line("Avoid:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Avoid;    
    
    task body Combine_Values is
        denominator : Integer;
        timer : Time;
        PERIOD : Time_Span := Milliseconds(50);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            denominator := abs(forward_pwr) + abs(right_pwr);
            if (denominator < 1)
            then
                denominator := 1;
            end if;
            
            rf_pwm := ((forward_pwr - right_pwr + left_pwr) / denominator) * 4095;
            rb_pwm := ((forward_pwr + right_pwr - left_pwr) / denominator) * 4095;
            lf_pwm := ((forward_pwr + right_pwr - left_pwr) / denominator) * 4095;
            lb_pwm := ((forward_pwr - right_pwr + left_pwr) / denominator) * 4095;
            dt := Clock - timer;
            --Put_Line("Combine:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Combine_Values;
    
    -- Act
    task body Motor_Control is
        speeds : Speeds2;
        timer : Time;
        PERIOD : Time_Span := Milliseconds(50);
        dt : Time_Span;
    begin
        loop
            timer := Clock;
            case state is   
            when Idle =>
                speeds := (0,0,0,0);
            when others =>
                speeds := (lf_pwm, rf_pwm, lb_pwm, rb_pwm);
            end case;
            
            Drive3(speeds);
            dt := Clock - timer;
            --Put_Line("Motor Control:");
            --Put_Line("PERIOD= " & To_Duration(PERIOD)'Image);
            --Put_Line("dt= " & To_Duration(dt)'Image);
            --Put_Line("diff= " & To_Duration(PERIOD - dt)'Image);
            delay until Clock + PERIOD;
        end loop;
    end Motor_Control;
    

end TaskControl;
