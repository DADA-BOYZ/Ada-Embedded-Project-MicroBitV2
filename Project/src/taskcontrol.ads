with MicroBit.Types; use MicroBit.Types;

package TaskControl is
    
    -- Sense
    task Read_Distance_Sensors with Priority => 3;
    task Read_Radio with Priority => 0;
    
    -- Think
    --task Avoid with Priority => 3;
    task AvoidFront with Priority => 2;
    task AvoidLeft with Priority => 2;
    task AvoidRight with Priority => 2;
    task Stopping with Priority => 2;
    --task Combine_Values  with Priority => 2;
    
    -- Act
    task Motor_Control with Priority => 1;
    
    private
    
    type States is (Idle, Remote, AvoidingFront, AvoidingLeft, AvoidingRight);
    state : States := Idle;
    
    rf_pwm : Integer := 0;
    rb_pwm : Integer := 0;
    lf_pwm : Integer := 0;
    lb_pwm : Integer := 0;
    
    type Distances is record
        front : Distance_cm := 0;
        left  : Distance_cm := 0;
        right : Distance_cm := 0;
    end record;
    
    distance : Distances;
    
    backward_pwr : Integer := 0; -- Positive => Forward
    left_pwr  : Integer := 0;   -- Positive => Left
    right_pwr   : Integer := 0; -- Positive => Right
    
    type button_states is record
        a : Boolean := False;
        b : Boolean := False;
        touch : Boolean := False;
    end record;
    
    button : button_states;
    
    type acc_directions is record
        x : Boolean;
        y : Boolean;
        z : Boolean;
    end record;
    
    acc : acc_directions;
    
end TaskControl;
