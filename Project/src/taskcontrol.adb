with MicroBit.Ultrasonic; 
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Ada.Real_Time; use Ada.Real_Time;
with PID;
use MicroBit;


package body TaskControl is
    
    timer : Time;
    dt : Time_Span;
    -- Sense
    task body Read_Distance_Sensors is
        package front_sensor is new Ultrasonic(MB_P2,  MB_P0);
        package left_sensor  is new Ultrasonic(MB_P14,MB_P13);
        package right_sensor is new Ultrasonic(MB_P1,  MB_P8);
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
        
        distance_front := front_sensor.Read;
        distance_left  := left_sensor.Read;
        distance_right := right_sensor.Read;
        
        dt := Clock - timer;
    end Read_Distance_Sensors;
    
    
    task body Read_Radio is
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
        
        
        
        dt := Clock - timer;
    end Read_Radio;
    
    
    -- Think
    task body Avoid is
        package front_pid   is new PID(Kp => 25, Ki => 0, Kd => 0);
        package strafe_pid  is new PID(Kp => 25, Ki => 0, Kd => 0);
        package rotate_pid  is new PID(Kp => 0,  Ki => 0, Kd =>10);
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
        
        
        
        dt := Clock - timer;
    end Avoid;    
    
    task body Forward is
        package front_pid is new PID(Kp =>-50, Ki => 0, Kd => 0);
        package strafe_pid is new PID(Kp => 25, Ki => 0, Kd => 0);
        package rotate_pid is new PID(Kp => 0,  Ki => 0, Kd =>10);
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
        
        
        
        dt := Clock - timer;
    end Forward;
    
    
    task body Combine_Values is
        denominator : Integer;
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
       
        denominator := abs(forward_pwr) + abs(right_pwr) + abs(rotate_pwr);
        
        if (denominator < 1)
        then
            denominator := 1;
        end if;
       
        rf_pwm := ((forward_pwr - right_pwr - rotate_pwr) / denominator) * 4095;
        rb_pwm := ((forward_pwr + right_pwr - rotate_pwr) / denominator) * 4095;
        lf_pwm := ((forward_pwr + right_pwr + rotate_pwr) / denominator) * 4095;
        lb_pwm := ((forward_pwr - right_pwr + rotate_pwr) / denominator) * 4095;
        
        dt := Clock - timer;
    end Combine_Values;
    
    -- Act
    task body Motor_Control is
        speeds : Speeds2;
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
        
        speeds := (lf_pwm, rf_pwm, lb_pwm, rb_pwm);
        Drive3(speeds);
        
        dt := Clock - timer;
    end Motor_Control;
    
    
    task body Stop is
        timer : Time;
        dt : Time_Span;
    begin
        timer := Clock;
        
        
        
        dt := Clock - timer;
    end Stop;
begin
    timer := Clock;
    
    
    
    dt := Clock - timer;
end TaskControl;
