with HAL; use HAL;
with MicroBit.Types; use MicroBit.Types;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Console; use MicroBit.Console;

package body PID is
    
    
    
    
    function regulate(target : in Distance_cm; actual : in Distance_cm) return Integer is
        error : Distance_cm;
        --dt : Ada.Real_Time.Time_Span;
        -- d_error : Distance_cm;
        P : Integer;
        --D : Time_Span;
        result : Integer;
        
    begin
        
        
        --dt := time - m_prev_time;
        error := target - actual;
        -- d_error := m_prev_error - error;
        
        P := Kp * Integer(error);
        --D := dt / (1/d_error);
        
        result := P;
        
        return result;
        
    end regulate;
    
    
    
end PID;
