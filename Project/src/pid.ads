with MicroBit.Types; use MicroBit.Types;
with Ada.Real_Time; 
with HAL; use HAL;

generic
    
    Kp : Float;
    Ki : Float;
    Kd : Float;
    name : String;
    
package PID is
    
    m_Kp : Float := Kp;
    m_Ki : Float := Ki;
    m_Kd : Float := Kd;
    
    function regulate(target : in Integer; actual : in Integer) return Integer;
    
private
    
    m_prev_error : Integer := 0;
    m_prev_time : Ada.Real_Time.Time := Ada.Real_Time.Clock;
    
end PID;
