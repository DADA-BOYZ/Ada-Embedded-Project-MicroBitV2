with MicroBit.Types; use MicroBit.Types;

package TaskControl is
    
    -- Sense
    task Read_Distance_Sensors with Priority => 4;
    task Read_Radio with Priority => 0;
    
    -- Think
    task Avoid with Priority => 3;
    task Combine_Values  with Priority => 2;
    
    -- Act
    task Motor_Control with Priority => 1;
    
    private
    
    type States is (Idle, Radio, Avoiding);
    state : States := Idle;
    
    rf_pwm : Integer := 0;
    rb_pwm : Integer := 0;
    lf_pwm : Integer := 0;
    lb_pwm : Integer := 0;
    
    distance_front : Distance_cm := 0;
    distance_left  : Distance_cm := 0;
    distance_right : Distance_cm := 0;
    
    
    forward_pwr : Integer := 0; -- Positive => Forward
    left_pwr  : Integer := 0;   -- Positive => Left
    right_pwr   : Integer := 0; -- Positive => Right
    
    
end TaskControl;
