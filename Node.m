classdef Node

    properties
        parent;
        x;
        y;
    end
    
    methods
        
        function obj = Node(p_parent, p_x, p_y )
            obj.parent = p_parent;
            obj.x = p_x;
            obj.y = p_y;
        end
    end
    
end

