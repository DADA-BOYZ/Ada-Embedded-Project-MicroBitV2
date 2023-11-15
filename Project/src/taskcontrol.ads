with MicroBit.Types; use MicroBit.Types;
with LSM303AGR; use LSM303AGR;

package TaskControl is
    
    -- Sense
    task Read_Radio with Priority => 3;
    task Read_Distance_Sensors with Priority => 3;
    
    
    -- Think
    task Stopping with Priority => 2;
    task Move_Remote with Priority => 2;
    task Avoid_Left with Priority => 2;
    task Avoid_Front with Priority => 2;
    task Avoid_Right with Priority => 2;
    
    -- Act
    task Motor_Control with Priority => 1;
    
    private
    
    -- State Machine
    type States is (Idle, Remote, AvoidingFront, AvoidingLeft, AvoidingRight);
    state : States := Idle;
    
    type PWMs is record
        rf : Integer := 0;
        rb : Integer := 0;
        lf : Integer := 0;
        lb : Integer := 0;
    end record;
    pwm : PWMs;
    
    type Distances is record
        front : Distance_cm := 0;
        left  : Distance_cm := 0;
        right : Distance_cm := 0;
    end record;
    distance : Distances;
    
    type Button_States is record
        a : Boolean := False;
        b : Boolean := False;
        touch : Boolean := False;
    end record;
    button : Button_States;
    
    type Acc_Directions is record
        X : Axis_Data := 0;
        Y : Axis_Data := 0;
        Rot : Axis_Data := 0;
    end record;
    acc : Acc_Directions;
    
    function Clamp(min : Integer; max : Integer; value : Integer) return Integer;
    
end TaskControl;
