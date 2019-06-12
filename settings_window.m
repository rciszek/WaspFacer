function settings_window( p_landmark_amount, p_landmark_size, p_crop_upper, p_crop_lower, p_show_symmetry, p_settings_callback )

landmark_amount = p_landmark_amount;
landmark_size = p_landmark_size;
crop_upper = p_crop_upper;
crop_lower = p_crop_lower;
show_symmetry = p_show_symmetry;
settings_callback = p_settings_callback;

main_gui_figure = figure('Visible','off', 'Units', 'Pixels', 'Resize', 'off', 'DockControls', 'off', 'Position', [ 10 10 180 180 ]);

set(main_gui_figure, 'Name', 'Settings');
set(main_gui_figure, 'NumberTitle', 'Off');
set(main_gui_figure, 'Toolbar', 'none');
set(main_gui_figure, 'Menubar', 'none');
set(main_gui_figure, 'Color', [.94 .94 .94] )

main_grid = uix.Grid( 'Parent', main_gui_figure, 'Spacing', 5, 'Padding', 10 );
landmark_per_side_box = uix.HBox( 'Parent', main_grid, 'Spacing', 10, 'Padding', 1 );
    label_landmark_amount = uix.Text('Parent',landmark_per_side_box, 'String', 'Landmarks per side',  'Visible', 'On','HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
    editbox_landmark_amount = uicontrol(landmark_per_side_box, 'Style', 'Edit', 'String', landmark_amount, 'Visible', 'On');
    set( landmark_per_side_box, 'Widths', [-3 -1]); 

landmark_per_size = uix.HBox( 'Parent', main_grid, 'Spacing', 10, 'Padding', 1 );    
    label_landmark_size = uix.Text('Parent',landmark_per_size, 'String', 'Drawn landmark size',  'Visible', 'On', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );    
    editbox_landmark_size = uicontrol(landmark_per_size, 'Style', 'Edit', 'String', landmark_size, 'Visible', 'On');
    set( landmark_per_size, 'Widths', [-3 -1]); 
    
crop_upper_box = uix.HBox( 'Parent', main_grid, 'Spacing', 10, 'Padding', 1 );    
    label_crop_upper = uix.Text('Parent',crop_upper_box,  'String', 'Crop upper', 'Visible', 'On','HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );    
    editbox_crop_upper = uicontrol(crop_upper_box, 'Style', 'Edit', 'String', crop_upper, 'Visible', 'On')
    set( crop_upper_box, 'Widths', [-3 -1]); 
    
crop_lower_box = uix.HBox( 'Parent', main_grid, 'Spacing', 10, 'Padding', 1 );
    label_crop_lower = uix.Text('Parent',crop_lower_box, 'String', 'Crop lower', 'Visible', 'On','HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
    editbox_crop_lower = uicontrol(crop_lower_box, 'Style', 'Edit', 'String', crop_lower, 'Position', [135, 96, 50, 20], 'Visible', 'On');  
    set( crop_lower_box, 'Widths', [-3 -1]); 
    
show_symmetry_box = uix.HBox( 'Parent', main_grid, 'Spacing', 10, 'Padding', 1 );
    uix.Empty( 'Parent', show_symmetry_box );
    checkbox_show_symmetry = uicontrol(show_symmetry_box, 'Style', 'checkbox', 'String', 'Show symmetry', 'Value',show_symmetry, 'Position', [ 60 55, 120, 20],  'Visible', 'On' );  
    set( show_symmetry_box, 'Widths', [-2 -5]); 
    
buttons_box = uix.HBox( 'Parent', main_grid, 'Spacing', 10, 'Padding', 1 );  
    button_ok = uicontrol( buttons_box, 'Style', 'pushbutton', 'String', 'Apply', 'Position', [ 52,15 , 50 , 25] );
    button_cancel = uicontrol( buttons_box, 'Style', 'pushbutton', 'String', 'Cancel', 'Position', [ 108,15 , 50 , 25] );

set( main_grid, 'Widths', [-1], 'Heights', [ 22 22 22 22 22 25] ); 

set(button_ok, 'Callback', @ok_button_callback);
set(button_cancel, 'Callback', @cancel_button_callback);

movegui(main_gui_figure, 'center');
set(main_gui_figure, 'Visible', 'on');

drawnow;

    function ok_button_callback(hObject, eventdata)
 
        new_landmark_amount = str2num( get(editbox_landmark_amount, 'String'));
        new_landmark_size = str2num( get(editbox_landmark_size, 'String'));
        new_crop_upper = str2num( get(editbox_crop_upper, 'String'));
        new_crop_lower = str2num( get(editbox_crop_lower, 'String'));
        new_show_symmetry = get(checkbox_show_symmetry, 'Value');

        if isempty(new_landmark_amount) || new_landmark_amount <= 0
            new_landmark_amount = landmark_amount;
        end
        if isempty(new_landmark_size) || new_landmark_size <= 0
            new_landmark_size = landmark_size;
        end          
        if isempty(new_crop_upper) || new_crop_upper <= 0
            new_crop_upper = crop_upper;
        end          
        if isempty(new_crop_lower) || new_crop_lower <= 0
            new_crop_lower = crop_lower;
        end       
         
        settings_callback(new_landmark_amount, new_landmark_size, new_crop_upper, new_crop_lower, new_show_symmetry );  

        close(main_gui_figure);
        
    end

    function cancel_button_callback(hObject, eventdata)
        close(main_gui_figure);
    end

end

