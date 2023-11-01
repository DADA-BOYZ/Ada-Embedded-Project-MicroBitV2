with MicroBit.Types; use MicroBit.Types;

package TaskControl is
    
    -- Sense
    task Read_Distance_Sensors with Priority => 3;
    task Read_Radio with Priority => 3;
    
    -- Think
    task Avoid with Priority => 4;
    task Forward with Priority => 4;
    task Combine_Values  with Priority => 4;
    
    -- Act
    task Motor_Control with Priority => 2;
    task Stop with Priority => 1;
    
    type States is (Idle, Radio, Forwarding, Avoiding);
    state : States := Idle;
    
    rf_pwm : Integer := 0;
    rb_pwm : Integer := 0;
    lf_pwm : Integer := 0;
    lb_pwm : Integer := 0;
    
    distance_front : Distance_cm := 0;
    distance_left  : Distance_cm := 0;
    distance_right : Distance_cm := 0;
    
    forward_pwr : Integer := 0;
    right_pwr   : Integer := 0;
    rotate_pwr  : Integer := 0;
    
end TaskControl;
