with MicroBit.Types; use MicroBit.Types;
with LSM303AGR; use LSM303AGR;

package TaskControl is
    
    -- Sense
    task Read_Distance_Sensors with Priority => 3;
    task Read_Radio with Priority => 3;
    
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
    
    type PWMs is record
        rf : Integer := 0;
        rb : Integer := 0;
        lf : Integer := 0;
        lb : Integer := 0;
    end record;
    pwm : PWMs;
    
    type power is record
        forward : Integer := 0; -- Positive => Forward
        strafe  : Integer := 0;   -- Positive => Left
        rotate   : Integer := 0; -- Positive => Right
    end record;
    pwr : power;
        
    type Distances is record
        front : Distance_cm := 0;
        left  : Distance_cm := 0;
        right : Distance_cm := 0;
    end record;
    distance : Distances;
    
    type button_states is record
        a : Boolean := False;
        b : Boolean := False;
        touch : Boolean := False;
    end record;
    button : button_states;
    
    type acc_directions is record
        X : Axis_Data := 0;
        Y : Axis_Data := 0;
        Z : Axis_Data := 0;
    end record;
    acc : acc_directions;
    
end TaskControl;
