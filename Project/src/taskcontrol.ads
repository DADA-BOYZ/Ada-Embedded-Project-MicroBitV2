with MicroBit.Types; use MicroBit.Types;
with MicroBit.Radio; use MicroBit.Radio;
with Ada.Real_Time; use Ada.Real_Time;
with LSM303AGR; use LSM303AGR;




package TaskControl is
    
    pragma Elaborate_Body(TaskControl);
    
    -- Sense
    task Read_Distance_Sensor_Front with Priority => 7;
    task Read_Distance_Sensor_Left with Priority => 6;
    task Read_Distance_Sensor_Right with Priority => 5;
    task Read_Radio with Priority => 4;
    
    -- Think
    task Determine_State with Priority => 3;
    task Determine_Radio with Priority => 2;
    
    -- Act
    task Avoid with Priority => 1;
    task Move_Radio with Priority => 1;
    task Motor_Control with Priority => 1;
    
private
        
    type PERIODS is record
        RSF : Time_Span := Milliseconds(100);
        RSL : Time_Span := Milliseconds(100);
        RSR : Time_Span := Milliseconds(100);
        RR : Time_Span := Milliseconds(100);
        DS : Time_Span := Milliseconds(100);
        DR : Time_Span := Milliseconds(100);
        AV : Time_Span := Milliseconds(100);
        MR : Time_Span := Milliseconds(100);
        MC : Time_Span := Milliseconds(100);
    end record;
    PERIOD : PERIODS;
    
    RXdata : RadioData;
    
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
    
    type Deadlines is record
        amount : Integer := 0;
        name : String(1 .. 2) := "XX";
    end record;
    
    deadlines_missed : Deadlines;
    
    function Clamp(min : Integer; max : Integer; value : Integer) return Integer;
    
end TaskControl;
