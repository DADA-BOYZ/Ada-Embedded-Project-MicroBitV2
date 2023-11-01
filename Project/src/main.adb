with MicroBit.Types; use MicroBit.Types;
with PID;
with Ada.Real_Time; use Ada.Real_Time;
with HAL; use HAL;
with HAL.Time; use HAL.Time;
with MicroBit.Ultrasonic;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with MicroBit.Console; use MicroBit.Console;
use MicroBit;

with TaskControl;

procedure main is
begin
    loop

    end loop;
    null;
end main;




procedure Main is

    package sensor is new Ultrasonic (MB_P1, MB_P0);
    package my_pid is new PID (Kp => -100,
                               Ki => 0,
                               Kd => 0);
    motor_pwm_value : UInt12;
    pid_value : Integer;
    distance_front : Distance_cm;
    target : Distance_cm := 25;
    min_pwm : Integer := -4000;
    max_pwm : Integer := 4000;
    --time : Time;

begin

    loop
        distance_front := sensor.Read;
        --time := Clock;

        pid_value := my_pid.regulate(target, distance_front);
        if (pid_value > max_pwm) then
            pid_value := max_pwm;
        elsif (pid_value < min_pwm) then
            pid_value := min_pwm;
        end if;

        if (distance_front < target) then
            motor_pwm_value := UInt12(-pid_value);
            Drive(Backward,(motor_pwm_value, motor_pwm_value, motor_pwm_value, motor_pwm_value));
        elsif (distance_front > target) then
            motor_pwm_value := UInt12(pid_value);
            Drive(Forward,(motor_pwm_value, motor_pwm_value, motor_pwm_value, motor_pwm_value));
        else
            Drive(Stop);
        end if;
    end loop;
end Main;
