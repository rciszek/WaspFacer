
function WaspFacer()
%WaspFacer - Wasp facial pattern assymmetry calculator
%A tool intended to faciliate the assessment of fluctuating asymmetry
%in wasps. Calculates continuous assymetry measure, procrustes distance,
%logarithmic difference in areas between shape sides and the total area of
%a shape.
% Other m-files required: GUI Layout Toolbox by David Sampson
%
% Author: Robert Ciszek 
% July 2015; Last revision: 26-April-2019

    addpath(genpath(pwd))

    image_map = containers.Map('UniformValues',false);
    preprocessed_map = containers.Map('UniformValues',false);
    result_metadata_map = containers.Map('UniformValues',false);
    symmetry_line = [];
    rotation_line = [];
    area = [];
    original_image = [];
    preprocessed_image = [];
    outlined_image = [];
    cropped_image = [];
    landmark_image = [];
    threshold = 0.2;

    LOADING_LABEL = 'Loading images';
    CALCULATING_LABEL = 'Calculating...';

    shape_image_format = 'bmp';
    ZOOM_FACTOR = 0.8;
    

    fill = 300;
    mask = [];
    outlines = [];
    image_state = 0;
    image_size = [0 0];

    landmark_amount = 10;
    landmark_size = 3;
    pixels_per_mm_default = 10;
    crop_upper = 0;
    crop_lower = 0;
    show_symmetry = 0;

    result_header = {'Image', 'Symm. Dist.', 'Proc. Dist.', 'Area Dif.', 'Area Total'};
    landmark_data = containers.Map('UniformValues',false);

    %Define main GUI figure
    main_gui_figure = figure('Visible','off', 'Resize', 'on', 'DockControls', 'off', 'Units', 'Normalized','Position', [ 0 0 0.5 0.5]);

    set(main_gui_figure, 'Name', 'WaspFacer 0.96');
    set(main_gui_figure, 'NumberTitle', 'Off');
    set(main_gui_figure, 'Toolbar', 'none');
    set(main_gui_figure, 'Menubar', 'none');
    set(main_gui_figure, 'Color', [.94 .94 .94] );
    
    %%Testing
    horizontal_box = uix.Grid( 'Parent', main_gui_figure, 'Spacing', 5, 'Padding', 5 );
    left_box = uix.Grid( 'Parent', horizontal_box, 'Spacing', 15, 'Padding', 15 );    
    center_box = uix.Grid( 'Parent', horizontal_box, 'Spacing', 5, 'Padding', 15 ); 
    
    right_box = uix.Grid( 'Parent', horizontal_box, 'Spacing', 5, 'Padding', 15 );
    set( horizontal_box, 'Widths', [250 -8 250 ], 'Heights', [-1] ); 
    
    %Define GUI components
    file_menu = uimenu(main_gui_figure,'Label', 'Files');
        menu_item_images = uimenu(file_menu,'Label', 'Select images');
        menu_save_results = uimenu(file_menu,'Label', 'Save results', 'Visible', 'off');       
        menu_export_submenu = uimenu(file_menu,'Label', 'Export', 'Visible', 'off');        
            menu_export_coordinates = uimenu(menu_export_submenu,'Label', 'Coordinates', 'Visible', 'on');
            menu_export_patterns = uimenu(menu_export_submenu,'Label', 'Patterns', 'Visible', 'on');
        menu_import_measurements = uimenu(file_menu,'Label', 'Import', 'Visible', 'off'); 
        
    settings_menu = uimenu(main_gui_figure,'Label', 'Settings');
    menu_item_preferences = uimenu(settings_menu,'Label', 'Preferences');

    panel_image_list = uipanel(left_box, 'Title', 'Images', 'Position', [ .094, .56, .156, .29] );
        list_images = uicontrol(panel_image_list, 'Style', 'List', 'String', [],'Units', 'Normalized', 'Position', [0.03, 0.01, 0.94, 0.98], 'Visible', 'off');

    panel_result = uipanel(left_box, 'Title', 'Results', 'Position', [ .094, .14, .156, .39] );
        table_result = uitable(panel_result,'Data',cell(0,5), 'Units', 'normalized', 'Position', [ 0.01 0.02 0.97 0.97], 'ColumnName', result_header, 'ColumnWidth', { 75, 60, 60, 60, 70}, 'Visible', 'off', 'Enable', 'Inactive'); 

    zoom_button_box = uix.HBox( 'Parent', center_box, 'Spacing', 10, 'Padding', 5 );   
        uix.Empty( 'Parent', zoom_button_box );
        button_zoom_out = uicontrol( zoom_button_box, 'Style', 'pushbutton', 'String', 'Zoom Out', 'Units', 'Normalized','Position', [ 0.01, 0.01, 0.4 , 0.5], 'Enable', 'off' );     
        button_zoom_in = uicontrol( zoom_button_box, 'Style', 'pushbutton', 'String', 'Zoom In', 'Units', 'Normalized','Position', [ 0.5, 0.01, 0.4 , 0.5], 'Enable', 'off' ); 
        uix.Empty( 'Parent', zoom_button_box );
        set( zoom_button_box, 'Widths', [ -1 60 60 -1 ] ); 
    
    panel_image = uipanel(center_box, 'Title', [] , 'Position', [ .26, .1, 0.48, .8], 'BorderType', 'none' );
        image_axes = axes('parent',panel_image,'position',[0.01 0.02 0.97 0.97],'Units','normalized');   
        is = imshow(original_image);
        isp = imscrollpanel( panel_image, is);
        isp_api = iptgetapi(isp);
        
       set( center_box, 'Widths', [-1 ], 'Heights', [36 -1] );     
        
    panel_loading = uipanel(main_gui_figure, 'Title', [] , 'Position', [ .3, .4, 0.3, .2], 'BorderType', 'line', 'Visible', 'off', 'HighlightColor', 'black' );     
        loading_label = uicontrol('Parent',panel_loading, 'Style', 'text', 'String','Loading...', 'Units', 'normalized', 'Position',[ .1 0.5, 0.2 0.1] , 'FontSize', 30 ,'Visible', 'off');    

    symmetry_rotation_box = uiextras.HBox( 'Parent', right_box, 'Spacing', 10, 'Padding', 5 );    
        panel_symmetryline = uiextras.Panel('Parent',symmetry_rotation_box, 'Title', 'Symmetry axis','Padding', 5 );    
            button_symmetryline = uicontrol( panel_symmetryline, 'Style', 'pushbutton', 'String', 'Place', 'Enable', 'off');
        panel_rotationline = uiextras.Panel('Parent',symmetry_rotation_box, 'Title', 'Rotation line','Padding', 5 );
            button_rotationline = uicontrol( panel_rotationline, 'Style', 'pushbutton', 'String', 'Place', 'Enable', 'off'); 
        set( symmetry_rotation_box, 'Sizes', [100 100] );

    area_rotate_box = uiextras.HBox( 'Parent', right_box, 'Spacing', 10, 'Padding', 5 );                 
        panel_area = uiextras.Panel('Parent',area_rotate_box, 'Title', 'Area','Padding', 5 );
            button_area = uicontrol( panel_area, 'Style', 'pushbutton', 'String', 'Place', 'Enable', 'off' );

        panel_rotate = uiextras.Panel('Parent',area_rotate_box, 'Title', 'Rotation' ,'Padding', 5);
            button_rotate = uicontrol( panel_rotate, 'Style', 'pushbutton', 'String', 'Rotate', 'Enable', 'off' );    
    set( area_rotate_box, 'Sizes', [100 100] );
 
    original_outlines_box = uiextras.HBox( 'Parent', right_box, 'Spacing', 10, 'Padding', 5 );     
        panel_display_original = uiextras.Panel('Parent',original_outlines_box, 'Title', 'Image', 'Padding', 5 );
            button_display_original = uicontrol( panel_display_original, 'Style', 'pushbutton', 'String', 'Processed',  'Units', 'Normalized','Position', [ 0.15, 0.17, 0.7 , 0.73],  'Enable', 'off');

        panel_display_outlines = uiextras.Panel('Parent',original_outlines_box, 'Title', 'Outlines', 'Padding', 5 );    
            button_display_outlines = uicontrol( panel_display_outlines, 'Style', 'pushbutton', 'String', 'Off', 'Units', 'Normalized','Position', [ 0.15, 0.17, 0.7 , 0.73], 'Visible', 'on', 'Enable', 'off');           
    set( original_outlines_box, 'Sizes', [100 100] );
    
    panel_threshold = uiextras.Panel('Parent',right_box, 'Title', 'Threshold' );
        threshold_box = uiextras.HBox( 'Parent', panel_threshold, 'Spacing', 10, 'Padding', 5 );     
            slider_threshold = uicontrol( threshold_box, 'Style', 'slider', 'Min', 1, 'Max', 99,  'value', threshold*100, 'SliderStep', [1/100 1/100], 'Enable', 'off');     
            label_threshold = uix.Text( 'Parent', threshold_box, 'String', get(slider_threshold, 'Value') / 100, 'Visible', 'on', 'VerticalAlignment', 'middle' );  
            set( threshold_box, 'Sizes', [-10 -2] );
            
    panel_fill = uiextras.Panel('Parent',right_box, 'Title', 'Fill');
        fill_box = uiextras.HBox( 'Parent', panel_fill, 'Spacing', 10, 'Padding', 5 );      
            slider_fill = uicontrol( 'Parent',fill_box, 'Style', 'slider', 'Min', 1, 'Max', 1000,  'value', fill, 'SliderStep', [1/1000 1/1000], 'Enable', 'off');     
            label_fill = uix.Text( 'Parent',fill_box, 'String', get(slider_fill, 'Value'), 'Visible', 'on','VerticalAlignment', 'middle' );      
            set( fill_box, 'Sizes', [-10 -2] );
   
            
    symmetry_mm_box = uiextras.HBox( 'Parent', right_box, 'Spacing', 10, 'Padding', 5 );               
        panel_calculate_symmetry = uiextras.Panel( 'Parent',symmetry_mm_box, 'Title', 'Symmetry', 'Padding', 5 ); 
            button_calculate_symmetry = uicontrol( panel_calculate_symmetry, 'Style', 'pushbutton', 'String', 'Calculate', 'Enable', 'off'); 

        panel_pixels_per_mm = uiextras.Panel( 'Parent',symmetry_mm_box, 'Title', 'Pixels/mm', 'Padding', 5  ); 
            editbox_pixels_per_mm = uicontrol( panel_pixels_per_mm, 'Style', 'edit', 'String', pixels_per_mm_default);     
    set( symmetry_mm_box, 'Sizes', [100 100] );
  
    distance_similarity_box = uiextras.HBox( 'Parent', right_box, 'Spacing', 10, 'Padding', 5 );      
        panel_symmetry_distance = uiextras.Panel('Parent',distance_similarity_box, 'Title', 'Symm. Dis.' );
            label_symmetry_distance = uix.Text('Parent',panel_symmetry_distance,  'String', [],'VerticalAlignment', 'middle');     

        panel_symmetry_similarity = uiextras.Panel('Parent',distance_similarity_box, 'Title', 'Proc. Dis');
            label_symmetry_similarity = uix.Text('Parent',panel_symmetry_similarity,  'String', [],'VerticalAlignment', 'middle');     

    difference_total_box = uiextras.HBox( 'Parent', right_box, 'Spacing', 10, 'Padding', 5 );             
        panel_symmetry_area_difference = uiextras.Panel( 'Parent',difference_total_box, 'Title', 'Area Dif.');
            label_symmetry_area_difference =  uix.Text('Parent',panel_symmetry_area_difference',  'String', [],'VerticalAlignment', 'middle');           

        panel_symmetry_area_total = uiextras.Panel('Parent',difference_total_box, 'Title', 'Total area' );
            label_symmetry_area_total =  uix.Text( 'Parent',panel_symmetry_area_total,  'String', [],'VerticalAlignment', 'middle');      

    set( left_box, 'Widths', [-1 ], 'Heights', [-1 -1] );         
    set( right_box, 'Widths',[220], 'Heights',  [60 60 60 45 45 60 50 50] );         
    %Set callbacks  
    
    %For menu
    set(menu_item_images, 'Callback', @select_files_callback);   
    set(menu_save_results, 'Callback', @save_results_callback);
    set(menu_export_coordinates, 'Callback', @export_coordinates_callback);
    set(menu_export_patterns, 'Callback', @export_patterns_callback);
    set(menu_item_preferences, 'Callback', @settings_callback);
    set(menu_import_measurements, 'Callback', @import_callback);
    
    %For image list
    set(list_images, 'Callback', @list_images_callback);   
    %For zoom buttons
    set(button_zoom_out, 'Callback', @zoom_out_callback);
    set(button_zoom_in, 'Callback', @zoom_in_callback);

    %For buttons and sliders used in processing of the images
    set(button_symmetryline, 'Callback', @symmetryline_callback);
    set(button_rotationline, 'Callback', @rotationline_callback);
    set(button_area, 'Callback', @area_callback);
    set(button_rotate, 'Callback', @rotate_callback);
    set(button_display_original, 'Callback', @display_original_callback);
    set(button_display_outlines, 'Callback', @display_outlines_callback);
    set(button_calculate_symmetry, 'Callback', @calculate_symmetry_callback);

    set(slider_threshold, 'Callback', @threshold_silder_callback);
    set(slider_fill, 'Callback', @fill_silder_callback);

    %Hide processing controls initiallly, as there are no images to process.
    hide_processing_controls();

    movegui(main_gui_figure, 'center');
    set(main_gui_figure, 'Visible', 'on');
    drawnow;
    set(get(handle(main_gui_figure),'JavaFrame'),'Maximized',1);
       

    function select_files_callback( hObject, eventdata )
        [filenames pathname ] = uigetfile({'*.jpg';'*.png';'*.bmb'},'Select images','MultiSelect', 'on');
           
        image_name_list = cell(1,0);
        %If a file was actually selected...        
        if size(filenames,2) > 1  
            
            %Clear all previously stored data
            remove(preprocessed_map, keys(preprocessed_map));
            remove(image_map, keys(image_map));
            remove(result_metadata_map, keys(result_metadata_map));
            
            %Show loading text
            %If a single file was selected
            if isa(filenames, 'char')    
                complete_filename = strcat(pathname, filenames);
                image_name_list = horzcat( image_name_list, filenames);
                image_map(filenames) = complete_filename;
                show_loading_panel(LOADING_LABEL);
                preprocessed_map(filenames) = preprocess_image(imread(complete_filename)); 
                hide_loading_panel();
            %If multiple files were selected     
            else
                show_loading_panel(strcat(LOADING_LABEL, ' 0%'));                
                for i = 1:size(filenames,2)  
                    percent = floor((i/size(filenames,2))*100);                    
                    complete_filename = strcat(pathname, filenames{1,i});
                    image_name_list = horzcat( image_name_list, filenames{1,i});
                    image_map(filenames{1,i}) = complete_filename;
                    preprocessed_map(filenames{1,i}) = preprocess_image(imread(complete_filename));
                    update_loading_panel(strcat(LOADING_LABEL, strcat(sprintf(' %i',percent)),'%'));
                    %hide_loading_panel();
                    %show_loading_panel(strcat(LOADING_LABEL, strcat(sprintf(' %i',percent)),'%'));                    
                end  
                hide_loading_panel();
            end
            %hide_loading_panel();
            set(list_images,'Visible', 'on')   
            set(list_images, 'String', image_name_list);
            set(list_images, 'Value', 1);
            
            set(button_symmetryline,'Enable', 'on');
            set(button_rotationline,'Enable', 'on') ;           
            set(button_area,'Enable', 'on');          
            set(button_zoom_in,'Enable', 'on');
            set(button_zoom_out,'Enable', 'on')                
            clear_results();
            list_images_callback(list_images, eventdata);
            landmark_data = containers.Map('UniformValues',false);
        end
        

    end

    function save_results_callback( hObject, eventdata )
       
        [file_name,path_name, filter] = uiputfile( {'*.xlsx', 'Excel Worksheet (*.xlsx)'; '*.csv', 'Comma separated values (*.csv)'; '*.txt', 'Tab delimited file (*.txt)'}, 'Save as' );     
        
        if file_name ~= 0
            
            [pathstr,name,ext] = fileparts(file_name); 
            save_result(strcat(path_name,file_name), filter);  
            %Also save the metadata for choices that produced the results
            save(strcat(strcat(path_name,name), '.meta'),'result_metadata_map');
        end
    end

    function export_coordinates_callback( hObject, eventdata )
       
        [file_name,path_name, filter] = uiputfile( {'*.csv', 'Comma separated values (*.csv)';}, 'Save as' );     
        
        if file_name ~= 0  
            [pathstr,name,ext] = fileparts(file_name);      
            save_raw(path_name, name);
            %Also save the metadata for choices that produced the results
            save(strcat(strcat(path_name,name), '.meta'),'result_metadata_map');
        end
    end

    function export_patterns_callback( hObject, eventdata )
       
        folder_name = uigetdir(pwd,'Export patterns');     
        
        if folder_name ~= 0      
            save_shapes(folder_name)
            %Also save the metadata for choices that produced the results
            save(strcat(folder_name, filesep, 'patterns.meta'),'result_metadata_map');
        end
    end

    function list_images_callback( hObject, eventdata )
        change_image();
        reset_ui();
    end

    function symmetryline_callback( hObject, eventdata )
             
        if strcmp( get(button_symmetryline, 'String'), 'Place'  )
            
            delete_roi('imline', 0 );
            prepare_to_draw(button_symmetryline);
            try
                symmetry_line = imline(image_axes);
            catch
                finish_drawing(button_symmetryline);
                return; 
            end
            finish_drawing(button_symmetryline);         
            
            setColor(symmetry_line, 'green'); 
            set(findobj(symmetry_line, 'Type', 'line'), 'UIContextMenu',[]);

            set(button_symmetryline, 'String', 'Place')
            setColor(symmetry_line, 'green');    

            display_symmetry_controls();                
            set(button_symmetryline, 'String', 'Place');
        
        else
            finish_drawing(button_symmetryline);              
            uiresume(main_gui_figure)  
        end
              
    end

    function rotationline_callback( hObject, eventdata )
        
        
        if strcmp( get(button_rotationline, 'String'), 'Place'  )
            
            reset_ui();
            delete_roi('imline', 0 );
            prepare_to_draw(button_rotationline);
            try
                rotation_line = imline(image_axes);
            catch
                finish_drawing(button_rotationline);
                return; 
            end
            finish_drawing(button_rotationline);         
            
            setColor(rotation_line, 'cyan'); 
            set(findobj(rotation_line, 'Type', 'line'), 'UIContextMenu',[]);

            set(button_rotationline, 'String', 'Place')
            setColor(rotation_line, 'cyan');    

            set(button_rotate, 'Enable', 'on');
            set(button_rotationline, 'String', 'Place');
        
        else
            finish_drawing(button_rotationline);              
            uiresume(main_gui_figure)  
        end
              
    end

    function delete_roi( tag, allowed)
        roi = findobj('Tag',tag);  
        for i = allowed+1:length(roi)
            delete(roi(i));
        end        
    end


    function area_callback( hObject, eventdata )
         
        if strcmp( get(button_area, 'String'), 'Place'  )
            
            hide_processing_controls();          
            image_state = 0;
            
            show_image();    
            reset_images();
            delete_roi('imfreehand', 0 );     

            prepare_to_draw(button_area);
            area = imfreehand(image_axes);
             finish_drawing(button_area);  
            if isempty( getPosition(area) )
               return; 
            end
                         
            setColor(area, 'green');
         
            %Hide the context menu
            handles = findobj(area);
            for i = 1:length(handles)
                set(handles(i), 'UIContextMenu',[]);                
            end
            
            mask = createMask(area);
            delete(area);
            image_state = 1;
            process_image();
            show_image();
            show_processing_controls();
            display_symmetry_controls()
        else
            finish_drawing(button_area);              
            uiresume(main_gui_figure)  
        end
       
              
    end

    %Counterclockwise rotation
    function rotate_callback(  hObject, eventdata )

        line_position = getPosition(rotation_line);
        
        line_start = line_position(1,:);
        line_end = line_position(2,:);
        
        if ( line_position(1,1) > line_position(2,1)) 
            line_start = line_position(2,:);
            line_end = line_position(1,:);
        end
        
        d_x = line_end(1) - line_start(1);
        d_y = line_end(2) - line_start(2);
        
        angle = atand(d_y/d_x);
        original_image = imrotate(original_image, angle, 'bicubic', 'loose');
        preprocessed_image = imrotate(preprocessed_image, angle, 'bicubic', 'loose');        
        show_image();
        delete_roi('imline', 0 );
        set(button_rotate, 'Enable', 'off');
    end    
        
    function display_symmetry_controls()

        if isobject(symmetry_line) && isvalid(symmetry_line) && ~isempty(cropped_image)           
            set(button_calculate_symmetry, 'Enable', 'on');
        else
             set(button_calculate_symmetry, 'Enable', 'off');           
        end
        
    end

    function reset_images()
        cropped_image = [];
        outlined_image = [];
        landmark_image = [];
    end

    function process_image()
                
        landmark_image = [];
        cropped_image = preprocessed_image;        
             
        cropped_image(repmat(~mask,[1,1,1])) = 255;        
        
        bw = im2bw(cropped_image,threshold);
        
        bw = imcomplement(bw);

        c = bwconncomp(bw,8);
        numOfPixels = cellfun(@numel,c.PixelIdxList);
        [unused,indexOfMax] = max(numOfPixels);
        c.PixelIdxList(indexOfMax) = [];
        
        for i=1:size(c.PixelIdxList,2)
            bw( c.PixelIdxList{i} ) = 0;        
        end
                
        image_white = bw;
        image_white = mat2gray(image_white);
        
        image_white = im2bw(image_white, 0.01);
        
        %Remove holes inside selected areas
        image_white = bwareaopen(image_white, fill);
        %And similarly sized objects outside the selection       
        image_white = imcomplement(bwareaopen( imcomplement(image_white), fill));     
        cropped_image = image_white;
        %If requested, crop the top and bottom of the area
        cropped_image = crop_top_and_bottom(cropped_image);
        image_white = crop_top_and_bottom(image_white);
        %Calculate area sizes
        [labeled_image, area_count] = bwlabel(image_white,8);
        area_measurements = regionprops(labeled_image, 'area');
        % Get all the areas
        areas = [area_measurements.Area];
        [sorted_areas, indexes] = sort(areas, 'descend');
        largest_area = ismember(labeled_image, indexes(1:1));
        image_white = largest_area > 0;     
        cropped_image = image_white;     
    
        outlines = bwperim(image_white);
        
        %Ignore image border
        outlines(1,:) = 0;
        outlines(end,:) = 0;
        outlines(:,1) = 0;
        outlines(:,end) = 0;
          
        %outline the detected area with green color
        green_channel = original_image(:,:,2); 
        green_channel(outlines) = 255;
        
        outlined_image = original_image;      
        outlined_image( :,:,2 ) = green_channel;

    end

    function change_image()
        selected_image = get(list_images, 'Value' );
        name_list = get(list_images, 'String');
        image_name = name_list{selected_image};
        original_image = imread(char(image_map(image_name)));
        preprocessed_image = preprocessed_map(image_name);
        image_size = size(original_image);
    end

    function reset_ui()
        
        delete_roi('imline', 0);
        delete_roi('imfreehand',0);        
        outlined_image = [];
        cropped_image = [];      
        outlines = [];
        landmark_image = [];
        image_state = 0;
        set(button_display_original, 'String', 'Processed');        
        set(button_display_outlines, 'String', 'Off');          
        hide_processing_controls();
        
        show_image();
    end

    function prepare_to_draw( button )
        
        set(button_symmetryline, 'Enable', 'off');         
        set(button_rotationline, 'Enable', 'off');         
        set(button_area, 'Enable', 'off'); 
        set(button_rotate, 'Enable', 'off');      
        set(button_zoom_in, 'Enable', 'off');   
        set(button_zoom_out, 'Enable', 'off');         
        set(button, 'Enable', 'on'); 
        
        set(button, 'String', 'Cancel'); 
        set(button, 'String', 'Cancel'); 
        set(button_calculate_symmetry, 'Enable', 'off');        
        set(list_images, 'Enable', 'off');      
        set(file_menu, 'Enable', 'off');     
        hide_processing_controls();
    end

    function finish_drawing( button )
        
        set(button_symmetryline, 'Enable', 'on');       
        set(button_rotationline, 'Enable', 'on');         
        set(button_area, 'Enable', 'on');   
        set(button_zoom_in, 'Enable', 'on');         
        set(button_zoom_out, 'Enable', 'on'); 
        
        set(button, 'String', 'Place'); 
        set(button, 'String', 'Place');      
        set(list_images, 'Enable', 'on');      
        set(file_menu, 'Enable', 'on');     

        if ~isempty(cropped_image)
            show_processing_controls();
        end
        
    end

    function show_image()   
        
        if isempty(original_image)
           return; 
        end
        zoom_mag = isp_api.getMagnification();  
        visible_rect = isp_api.getVisibleImageRect();
        center_position = [ floor(visible_rect(1) + visible_rect(3)/2) floor( visible_rect(2) + visible_rect(4)/2) ];
        switch image_state
            case 1
                if isempty(landmark_image)
                    isp_api.replaceImage(outlined_image); 
                    isp_api.setMagnificationAndCenter(zoom_mag,center_position(1), center_position(2));    
                else                    
                    isp_api.replaceImage(landmark_image);
                    isp_api.setMagnificationAndCenter(zoom_mag,center_position(1), center_position(2));                        
                end
            case 2            
                isp_api.replaceImage(cropped_image); 
                isp_api.setMagnificationAndCenter(zoom_mag,center_position(1), center_position(2));    
            otherwise                 
                isp_api.replaceImage(original_image);       
                isp_api.setMagnification(zoom_mag);    
        end    
     
    end
    
    function display_original_callback(hObject, eventdata)
  
        if strcmp( get(button_display_original, 'String'), 'Processed')
            image_state = 2;
            show_image();
            set(button_display_original, 'String',  'Original');
            set(button_display_outlines, 'Enable',  'off');
        else
            image_state = 1;
            show_image();
            set(button_display_original, 'String',  'Processed');  
            set(button_display_outlines, 'Enable',  'On');
            set(button_display_outlines, 'String',  'Off' );              
        end
        
    end

    function display_outlines_callback(hObject, eventdata)
  
        if strcmp( get(button_display_outlines, 'String'), 'Off')
            image_state = 0;
            show_image();
            set(button_display_outlines, 'String',  'On');
        else
            image_state = 1;
            show_image();
            set(button_display_outlines, 'String',  'Off' );           
        end
        
    end

    function threshold_silder_callback(hObject, eventdata)
        
        if hObject == slider_threshold
            value = get(slider_threshold, 'Value');
            set(label_threshold, 'String', num2str(value / 100,'%.2f')  );
            threshold = value/100;
        end        
        process_image();
        show_image();
    end

    function fill_silder_callback(hObject, eventdata)
        
        value = get(slider_fill, 'Value');
        set(label_fill, 'String', round(value)  );
        set(slider_fill, 'Value', round(value)  );
        fill = round(value);
        process_image();
        show_image();
    end

    function calculate_symmetry_callback(hObject, eventdata)
        show_loading_panel(CALCULATING_LABEL);
        set(button_calculate_symmetry, 'Enable', 'off');
        set(button_symmetryline, 'Enable', 'off');
        set(button_rotationline, 'Enable', 'off');
        set(button_area, 'Enable', 'off');
        set(button_rotate, 'Enable', 'off');
        set(button_display_original,'Enable', 'off');
        set(button_display_outlines, 'Enable', 'off');
        set(slider_threshold, 'Enable', 'off');       
        set(slider_fill, 'Enable', 'off');        
        drawnow;
        hide_processing_controls();
        try
            perform_calculations();
        catch ME
            errordlg('Error has occurred. Calculations halted', 'Error' );
            event_log('Errors.log', ME.message);
        end
        show_processing_controls();
        hide_loading_panel();
        
        set(button_calculate_symmetry, 'Enable', 'on');
        set(button_symmetryline, 'Enable', 'on');
        set(button_rotationline, 'Enable', 'on');
        set(button_area, 'Enable', 'on');
        set(button_rotate, 'Enable', 'on');
        set(button_display_original,'Enable', 'on');
        set(button_display_outlines, 'Enable', 'on');  
        set(slider_threshold, 'Enable', 'on');
        set(slider_fill, 'Enable', 'on');          
        drawnow;
    end

    function settings_callback(hObject, eventdata)
        settings_window( landmark_amount, landmark_size, crop_upper, crop_lower, show_symmetry, @change_settings);
    end

    function change_settings( p_landmark_amount, p_landmark_size, p_crop_upper, p_crop_lower, p_show_symmetry )
        landmark_amount = p_landmark_amount;
        landmark_size = p_landmark_size;
        crop_upper = p_crop_upper;
        crop_lower = p_crop_lower;
        show_symmetry = p_show_symmetry;
    end

    function perform_calculations()
        [top bottom ] = find_intersection();
        
        %Trace the points along the left and right sides of the contour
        left_end_point = trace_contour_half(top, bottom, -1);
        right_end_point = trace_contour_half(top, bottom, 1);
        [left_length left_points ]= count_contour_length(left_end_point);        
        [right_length right_points] = count_contour_length(right_end_point);
        %Place equidistant landmarks on both sides
        left_landmarks = place_landmarks(left_end_point, landmark_amount, round( left_length/(landmark_amount+1)) );
        right_landmarks = place_landmarks(right_end_point, landmark_amount, round( right_length/(landmark_amount+1)) ); 
            
        %Remove possible empty cells
        left_landmarks(find(cellfun(@isempty,left_landmarks))) = [];
        right_landmarks(find(cellfun(@isempty,right_landmarks))) = [];
        
        %If landmarks are missing from one side, trim to minimum common
        %amount of landmarks;
        pairs = min(size(left_landmarks,2), size(right_landmarks,2));
        
        if size(left_landmarks,2) ~= pairs || size(right_landmarks,2) ~= pairs
           errordlg('Unable to place equal amount of landmarks. Number of landmarks trimmed to lowest common number.', 'Error' ) 
           left_landmarks = left_landmarks(1,1:pairs);
           right_landmarks = right_landmarks(1,1:pairs);
        end
   
        landmark_image = outlined_image;
        draw_landmarks(left_landmarks);        
        draw_landmarks(right_landmarks);
        
        %Extract the coordinates from path nodes
        left_landmark_coordinates = extract_landmark_coordinates(left_landmarks');
        right_landmark_coordinates = extract_landmark_coordinates(right_landmarks');
        
        [symmetry_distance, un_left_reflected, un_right_reflected ] = calculate_symmetry_distance(left_landmark_coordinates, right_landmark_coordinates,top,bottom);
        paint_symmetry(un_left_reflected,un_right_reflected);
        [pd, Z, tr] = procrustes(left_landmark_coordinates, right_landmark_coordinates, 'Reflection',true, 'Scaling',false );

        store_landmark_data(left_points, right_points, top, bottom); 
              
        set(label_symmetry_distance, 'String', symmetry_distance );
        set(label_symmetry_distance, 'Visible', 'on' );        
        
        set(label_symmetry_similarity, 'String', pd);
        set(label_symmetry_similarity, 'Visible', 'on');
        
        [ area_difference, area_total] = calculate_pixels();
        set(label_symmetry_area_difference, 'String', area_difference);
        set(label_symmetry_area_difference, 'Visible', 'on'); 
        
        set(label_symmetry_area_total, 'String', area_total);
        set(label_symmetry_area_total, 'Visible', 'on');         
               
        add_result(symmetry_distance, pd, area_difference, area_total); 
        show_image();
    end

    function coordinates = extract_landmark_coordinates(landmarks)
        coordinates = zeros(size(landmarks,1),2);
        for c_i = 1:size(landmarks,1)
            coordinates(c_i,1) = landmarks{c_i}.y;
            coordinates(c_i,2) = landmarks{c_i}.x;            
        end
    end

    function paint_symmetry(un_left_reflected,un_right_reflected )     
        if show_symmetry      
            for l_i = 1:size(un_left_reflected,1)
                    paint_debug( round(un_left_reflected(l_i,2)  ), round(un_left_reflected(l_i,1)   ),[0,0,255]); 
                    paint_debug( round(un_right_reflected(l_i,2)), round(un_right_reflected(l_i,1)),[0,0,255]);           
            end   
        end
    end

    function paint_debug(p_x,p_y, color)
       
        landmark_image(p_y-landmark_size-1:p_y+landmark_size,p_x-landmark_size-1:p_x+landmark_size,1) = color(1);   
        landmark_image(p_y-landmark_size-1:p_y+landmark_size,p_x-landmark_size-1:p_x+landmark_size,2) = color(2); 
        landmark_image(p_y-landmark_size-1:p_y+landmark_size,p_x-landmark_size-1:p_x+landmark_size,3) = color(3);            
        
    end

    function [ area_difference, total_area ]= calculate_pixels()
        
        line_position = getPosition(symmetry_line);
        line_start = line_position(1,:);
        line_end = line_position(2,:);
        direction = 1;
        if line_end(2) < line_start(2)
           temp = line_start;
           line_start = line_end;
           line_end = temp;
        end  
        if line_end(1) < line_start(1)
            direction = -1;
        end
            
        d_X = abs( line_end(1) - line_start(1) );
        d_Y = abs( line_end(2) - line_start(2) );
                     
        angle = atan( d_X / d_Y  );
        
        left_side = zeros(round(d_Y), 1);
        right_side = left_side;
           
        for i = 1:round(d_Y)
            
            hyp_y = round(line_start(2) + i);
            hyp_x = round ( line_start(1) + direction*i * tan(angle));
            
            left_side(i,1) = horizontal_black_pixel_count( hyp_x-1, hyp_y, -1, cropped_image );
            right_side(i,1) = horizontal_black_pixel_count( hyp_x, hyp_y, 1, cropped_image );
                     
        end 

        [left_side, right_side] = truncate_pixel_data(left_side, right_side);
        
        left = left_side;
        right = right_side; 
        
        normalized_left = sum(left) / get_pixels_per_mm()^2;
        normalized_right = sum(right) / get_pixels_per_mm()^2;
        
        area_difference = log(normalized_left) - log(normalized_right);
        total_area = normalized_left + normalized_right; 
    end

    function store_landmark_data(left, right, line_start, line_end )
        
        selected_image = get(list_images, 'Value' );
        name_list = get(list_images, 'String');
        image_name = char(name_list{selected_image}); 
        
        data = struct;
        data.left = left;
        data.right = right;
        data.line_start = line_start;
        data.line_end = line_end;
        landmark_data(image_name) = data;
        
    end

    function [ top bottom ] = find_intersection()
    
        line_position = getPosition(symmetry_line);
        line_start = line_position(1,:);
        line_end = line_position(2,:);
        direction = 1;
        if line_end(2) < line_start(2)
           temp = line_start;
           line_start = line_end;
           line_end = temp;
        end  
        if line_end(1) < line_start(1)
            direction = -1;
        end
        
       
        d_X = abs( line_end(1) - line_start(1) );
        d_Y = abs( line_end(2) - line_start(2) );
                     
        angle = atan( d_X / d_Y  );
           
        top = [];
        bottom = [];
        
        inside = 0;
        
        %line_start
        for i = 1:round(d_Y)
            
            hyp_y = round(line_start(2) + i);
            hyp_x = round ( line_start(1) + direction*i * tan(angle));            
                  
            if isempty(top) && outlines(hyp_y, hyp_x) == 1  
                top = [ hyp_y, hyp_x ];
                inside = 1;
            elseif ( isempty(bottom) || ( hyp_y >= bottom(1) )) && ~isempty(top) && outlines(hyp_y, hyp_x) == 1 && inside == 1
                bottom = [ hyp_y, hyp_x ];
            end
            
            
            
        end        
        
    end


    function result = crop_top_and_bottom(image)
        result = image;
        
        [ rows columns ] = find(result < 1);
        
        top = min(rows);
        bottom = max(rows);
        
        result( 1:top+crop_upper,:) = 1;
        result(bottom-crop_lower:end,:) = 1;
        
    end

    function contour = crop_contour( side, top, bottom  )
        
        contour = outlines;
        
        if side < 0 && top(2) > 0 && top(1) > 0 && top(1) < size(outlines,1) && top(2) < size(outlines,2)
           contour(top(1)-1:top(1)+1,top(2)+1) = 0;   
        else  
           contour(top(1)-1:top(1)+1,top(2) - 1) = 0;   
        end            
        
        contour(bottom(1),bottom(2)) = 0;
                  
    end

    function path = trace_contour_half( top, bottom, direction )
        
        x = top(2);
        y = top(1);
              
        visited = zeros(size(outlines,1), size(outlines,2));
        contour = crop_contour(direction,top,  bottom);      
        visited(y,x) = 1;
        start_node = Node([], x, y );
        points = cell(1,1);
        points{1,1} = start_node;
        while ~isempty(points)

            point = points{1,1};
            points(1) = [];
           
            [ found_points visited ] = next_contour_points( point, visited, contour, bottom);

            if ~isempty(found_points)
                points = horzcat(points, found_points);       
            end
        end
        
        path = point;
    end

    function [ points visited ] = next_contour_points(node, visited, contour, bottom)
        
        points = cell(1,0);
        previous_x = node.x;
        previous_y = node.y;       
        for i = 1:8

            switch i
                case 1
                    y = previous_y -1;
                    x = previous_x;
                case 2
                     y = previous_y -1;
                     x = previous_x +1;                   
                case 3
                     y = previous_y;
                     x = previous_x +1;                     
                case 4
                     y = previous_y + 1;
                     x = previous_x + 1;    
                case 5 
                     y = previous_y + 1;
                     x = previous_x;                       
                case 6
                     y = previous_y + 1;
                     x = previous_x - 1;  
                case 7
                     y = previous_y;
                     x = previous_x - 1;                        
                case 8
                     y = previous_y -1;
                     x = previous_x - 1; 
            end
            
            if x >= 0 && y >= 0 && visited(y, x) == 0 && contour( y, x) == 1 
                new_node = Node(node, x, y);
                visited(y, x) = 1;
                points{1,end+1} = new_node;
            end
            
        end

    end

    function [ length positions ] = count_contour_length( end_node )
        
        parent = end_node.parent;
        length = 1;
        positions = [];
        
        while ~isempty(parent)
           positions = vertcat(positions, [parent.y parent.x ]);
           parent = parent.parent;
           length = length +1;
        end
          
    end

    function coordinates = place_landmarks(end_node, landmark_amount, distance)
        coordinates = cell(1,0);
        parent = end_node.parent;
        length = 1;
        placed_landmarks = 0;
        while ~isempty(parent) && placed_landmarks < landmark_amount
           parent = parent.parent;
           
           if  length >= distance 
               coordinates{1,end+1} = parent;
               length = 0;
               placed_landmarks = placed_landmarks +1;
           end
           length = length +1;
        end        
        
    end

    function draw_landmarks( landmarks )
          
        for i = 1:size(landmarks,2)
           landmark = landmarks{1,i};
           
           if isempty(landmark)
              break; 
           end
           
        %Paint the landmark
        red_channel = landmark_image(:,:,1); 
        green_channel = landmark_image(:,:,2); 
        blue_channel = landmark_image(:,:,3); 
        red_channel(landmark.y-landmark_size-1:landmark.y+landmark_size,landmark.x-landmark_size-1:landmark.x+landmark_size) = 0;   
        blue_channel(landmark.y-landmark_size-1:landmark.y+landmark_size,landmark.x-landmark_size-1:landmark.x+landmark_size) = 0; 
        green_channel(landmark.y-landmark_size-1:landmark.y+landmark_size,landmark.x-landmark_size-1:landmark.x+landmark_size) = 255;
        landmark_image( :,:,1 ) = red_channel;                
        landmark_image( :,:,2 ) = green_channel;
        landmark_image( :,:,3 ) = blue_channel;
    
        end
    end

    function [ left,  right ] = truncate_pixel_data( left, right )
             
        temp_left = left;
        temp_right = right;
        temp_left( left == 0 & right == 0 ) = [];
        temp_right(left == 0 & right == 0 )= [];
        left = temp_left;
        right = temp_right;
        
    end


    function pixel_count = horizontal_black_pixel_count(start_x, start_y, direction, image )
        
        offset = 1;
        pixel_count = 0;
        while true
            if start_x < 1 || start_x > image_size(2) || start_y < 1 || start_y > image_size(1)
                break;
            end  
            if start_x+direction*offset < 1 || start_x+direction*offset > image_size(2)
                break;
            end                 
            if image(start_y,start_x+direction*offset) ~= 0 
                pixel_count = pixel_count +1;  
            end  

            offset = offset +1;
          
        end
         
    end

    function show_processing_controls()
        set(slider_threshold, 'Enable', 'on');;        
        set(slider_fill, 'Enable', 'on');    
        set(button_display_original, 'Enable', 'on');
        set(button_display_outlines, 'Enable', 'on');
    end

    function hide_processing_controls()
        set(slider_threshold, 'Enable', 'off');      
        set(slider_fill, 'Enable', 'off');      
        set(button_display_original, 'Enable', 'off');       
        set(button_display_original, 'String', 'Processed');         
        set(button_display_outlines, 'Enable', 'off');      
        set(button_calculate_symmetry, 'Enable', 'off');   
        set(label_symmetry_distance, 'Visible', 'off');   
        set(label_symmetry_similarity, 'Visible', 'off');
        set(label_symmetry_area_difference, 'Visible', 'off');      
        set(label_symmetry_area_total, 'Visible', 'off');          
    end

    function add_result( symmetry_distance, proc_dist, area_dif, area_total )
             
        data = get(table_result, 'Data');
        selected_image_index = get(list_images, 'Value');
        image_names = get(list_images, 'String');
        selected_image_name = image_names(selected_image_index);
            
        new_entry = cell(1,5);
        new_entry{1,1} = char(selected_image_name);
        new_entry{1,2} = symmetry_distance; 
        new_entry{1,3} = proc_dist;         
        new_entry{1,4} = area_dif;
        new_entry{1,5} = area_total;
                
        exists = [];
        if ~isempty(data)
            exists = strmatch(char(selected_image_name), { data{:,1} });
        end
        
        if ( isempty(exists))
            data = vertcat(data, new_entry );
        else
           data(exists,:) = new_entry;
        end
        set(table_result, 'Data', data);
        set(table_result, 'Visible', 'on');  
        set(menu_save_results, 'Visible', 'on');
        set(menu_export_submenu, 'Visible', 'on');        
        
        %Store metadata
        result_metadata = struct;
        result_metadata.shape = cropped_image;
        result_metadata.outlines = outlines;
        result_metadata.landmark_image = landmark_image;        
        result_metadata.symmetry_line = getPosition(symmetry_line);
        result_metadata.threshold = threshold;    
        result_metadata.fill = fill;
        result_metadata.symmetry_distance = symmetry_distance;           
        result_metadata.proc_dist = proc_dist;        
        result_metadata.area_dif = area_dif;  
        result_metadata.area_total = area_total;
        result_metadata.crop_upper = crop_upper; 
        result_metadata.crop_lower = crop_lower;    
        result_metadata.landmark_amount = landmark_amount;        
        result_metadata.landmark_size = landmark_size;           
        result_metadata.show_symmetry = show_symmetry;   
        
        result_metadata_map(char(selected_image_name)) = result_metadata;
    end

    function save_result( file_name, format )
               
        data = get(table_result, 'Data');
        data = vertcat(result_header, data );
        
        if format == 1
           xlswrite(file_name,data); 
        end
        if format == 2
          fid = fopen(file_name,'w');
          fprintf(fid,'%s, %s, %s, %s, %s\n',data{1,:});
          fprintf(fid,'%s, %f, %f, %f, %f\n',data{2:end,1}, data{2:end,2}, data{2:end,3}, data{2:end,4}, data{2:end,5});
          fclose(fid); 
        end     
        if format == 3
          fid = fopen(file_name,'w');
          fprintf(fid,'%s\t %s\t %s\t %s\t %s\n',data{1,:});
          fprintf(fid,'%s\t %f\t %f\t %f\t %f\n',data{2:end,1}, data{2:end,2}, data{2:end,3}, data{2:end,4}, data{2:end,5});
          fclose(fid); 
        end      
        
    end

    function save_raw( path_name, name )
        
        file_name = strcat( path_name, name, '.csv' );
        
        image_names = get(list_images, 'String');
        
        landmarks = zeros(size(image_names,2));
        landmark_rows= [];

        fid = fopen(file_name,'w');  
          
        fprintf(fid,'Image_name');  
        first_entry = landmark_data(char(image_names(1)));
        for l = 1:1:size(first_entry.left,1)
            fprintf(fid,',LX%i,LY%i', l, l);  
        end

        for r = 1:1:size(first_entry.right,1)
            fprintf(fid,',RX%i,RY%i', r, r);   
        end  
         fprintf(fid,'\n');
        
        used_images = keys(result_metadata_map);  
         
        for i = 1:size(used_images,2)
            data = landmark_data( char(used_images{i}));
            landmarks(i) = size(data.left,1);
         
            
            new_entry = cell(1, size(data.left,1)*2 + size(data.right,1)*2 + 5);
            
            new_entry{1,1} = char(image_names(i));
            fprintf(fid,'%s',char(image_names(i)));
            
            for l = 1:1:size(data.left,1)
                fprintf(fid,',%d,%d',data.left(l,2),data.left(l,1 ));
            end
            
            for r = 1:1:size(data.right,1)
                fprintf(fid,',%d,%d',data.right(r,2),data.right(r,1 ));
            end            
            
            if size(landmark_rows,2) >0 && size(landmark_rows,2) ~= size(new_entry,2)
                errordlg('Inconsistent number of landmarks. Raw landmark data not saved.','Error'); 
                landmark_rows = [];
                break;
            end
            fprintf(fid,'\n');         
        end
        
        if isempty(landmark_rows)
            fclose(fid); 
           return;  
        end
        fclose(fid); 
    end

    function save_shapes(shapses_folder_path, name ) 
        
        metadata_keys = keys(result_metadata_map);
        for i = 1:size(metadata_keys,2)
            metadata_struct = result_metadata_map(metadata_keys{1,i});
            image_name = regexp(metadata_keys{1,i},'[.]','split');
            imwrite(metadata_struct.shape, strcat(shapses_folder_path, filesep, image_name{1}, '.', shape_image_format), shape_image_format);
        end
        
    end
        
    function clear_results()
        set(table_result, 'Data', cell(0,5));        
        set(table_result, 'Visible', 'off');   
        set(menu_save_results, 'Visible', 'off');    
        set(menu_export_submenu, 'Visible', 'off');         
    end

    function ppmm = get_pixels_per_mm()
        
        pixels = str2num(get(editbox_pixels_per_mm, 'String'));
        if isempty(pixels)
           errordlg('Invalid value for pixels per mm. Default value used instead.','Error'); 
           pixels = pixels_per_mm_default; 
           set(editbox_pixels_per_mm, 'String', pixels_per_mm_default);
        end
        ppmm = pixels;
    end


    function show_loading_panel(label)
        panel_loading = uipanel(main_gui_figure, 'Title', [] , 'Position', [ .43, .5, 0.13, .0325], 'BorderType', 'line', 'Visible', 'on', 'HighlightColor', 'black' );     
        loading_label = uicontrol('Parent',panel_loading, 'Style', 'text', 'String','Loading...', 'Units', 'normalized', 'Position',[ .01 0.01, 0.98 0.85 ] , 'FontUnits', 'normalized', 'FontSize', 0.6 ,'Visible', 'on');         
        set(loading_label, 'String', label);
        set(panel_loading, 'Visible', 'on')
        drawnow expose;
    end

    function update_loading_panel(label)
        set(loading_label, 'String', label);
        drawnow expose;
    end

    function hide_loading_panel()   
        if ishandle(panel_loading)
            delete(panel_loading);               
        end     
        drawnow expose;
    end

    function zoom_in_callback(hObject, eventdata)
        current_magnification = isp_api.getMagnification();
        isp_api.setMagnification(current_magnification/ZOOM_FACTOR);
    end

    function zoom_out_callback(hObject, eventdata)
        current_magnification = isp_api.getMagnification();
        fit_mag = isp_api.findFitMag();
        desired_mag = current_magnification*ZOOM_FACTOR;
        
        if desired_mag < fit_mag
            desired_mag = fit_mag;
        end
        isp_api.setMagnification(desired_mag);  
    end

    function import_callback(hObject, eventdata)
        
        [filenames pathname ] = uigetfile({'*.meta';},'Select meta file','MultiSelect', 'off');
           
        image_name_list = cell(1,0);
        %If a file was actually selected...        
        if size(filenames,2) > 1  
            
            %Clear all previously stored data
            
            %Show loading text
            %If a single file was selected
            if isa(filenames, 'char')    
                complete_filename = strcat(pathname, filenames);
                meta_data = importdata(complete_filename);
            %If multiple files were selected     
            end

            %hide_loading_panel();
            set(list_images,'Visible', 'on')   
            set(list_images, 'String', image_name_list);
            set(list_images, 'Value', 1);
            
            set(button_symmetryline,'Enable', 'on');
            set(button_rotationline,'Enable', 'on') ;           
            set(button_area,'Enable', 'on');          
            set(button_zoom_in,'Enable', 'on');
            set(button_zoom_out,'Enable', 'on')                ;
        end   
    end


    function import_measurements(measurement_map)
        
        image_names = keys(measurement_map);
        
        add_result( symmetry_distance, proc_dist, area_dif, area_total );        
    end

end

