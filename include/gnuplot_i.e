
include dll.e
include machine.e
include misc.e
include wildcard.e

constant SIZEOF_DOUBLE = 8
constant C_STRING = C_POINTER

atom gnuplot_i
gnuplot_i = NULL

if platform() = WIN32 then
	gnuplot_i = open_dll( "libgnuplot_i.dll" )

elsif platform() = LINUX then
	gnuplot_i = open_dll( "libgnuplot_i.so" )

end if

if gnuplot_i = NULL then
	puts( 2, "could not open libgnuplot_i\n" )
	?1/0
end if

constant
	xgnuplot_init               = define_c_func( gnuplot_i, "gnuplot_init", {}, C_POINTER ),
	xgnuplot_close              = define_c_proc( gnuplot_i, "gnuplot_close", {C_POINTER} ),
	xgnuplot_cmd                = define_c_proc( gnuplot_i, "gnuplot_cmd", {C_POINTER,C_STRING} ),
	xgnuplot_setstyle           = define_c_proc( gnuplot_i, "gnuplot_setstyle", {C_POINTER,C_STRING} ),
	xgnuplot_set_xlabel         = define_c_proc( gnuplot_i, "gnuplot_set_xlabel", {C_POINTER,C_STRING} ),
	xgnuplot_set_ylabel         = define_c_proc( gnuplot_i, "gnuplot_set_ylabel", {C_POINTER,C_STRING} ),
	xgnuplot_resetplot          = define_c_proc( gnuplot_i, "gnuplot_resetplot", {C_POINTER} ),
	xgnuplot_plot_x             = define_c_proc( gnuplot_i, "gnuplot_plot_x", {C_POINTER,C_POINTER,C_INT,C_STRING} ),
	xgnuplot_plot_xy            = define_c_proc( gnuplot_i, "gnuplot_plot_xy", {C_POINTER,C_POINTER,C_POINTER,C_INT,C_STRING} ),
	xgnuplot_plot_once          = define_c_proc( gnuplot_i, "gnuplot_plot_once", {C_STRING,C_STRING,C_STRING,C_STRING,C_POINTER,C_POINTER,C_INT} ),
	xgnuplot_plot_slope         = define_c_proc( gnuplot_i, "gnuplot_plot_slope", {C_POINTER,C_DOUBLE,C_DOUBLE,C_STRING} ),
	xgnuplot_plot_equation      = define_c_proc( gnuplot_i, "gnuplot_plot_equation", {C_POINTER,C_STRING,C_STRING} ),
	xgnuplot_write_x_csv        = define_c_func( gnuplot_i, "gnuplot_write_x_csv", {C_STRING,C_POINTER,C_INT,C_STRING}, C_INT ),
	xgnuplot_write_xy_csv       = define_c_func( gnuplot_i, "gnuplot_write_xy_csv", {C_STRING,C_POINTER,C_POINTER,C_INT,C_STRING}, C_INT ),
	xgnuplot_write_multi_csv    = define_c_func( gnuplot_i, "gnuplot_write_multi_csv", {C_STRING,C_POINTER,C_INT,C_STRING}, C_INT )

--
--  @brief    Opens up a gnuplot session, ready to receive commands.
--  @return   Newly allocated gnuplot control structure.
--
--  This opens up a new gnuplot session, ready for input. The struct
--  controlling a gnuplot session should remain opaque and only be
--  accessed through the provided functions.
--
--  The session must be closed using gnuplot_close().
--
global function gnuplot_init()
	return c_func( xgnuplot_init, {} )
end function

--
--  @brief    Closes a gnuplot session previously opened by gnuplot_init()
--  @param    handle    Gnuplot session control handle.
--
--  Kills the child PID and deletes all opened temporary files.
--  It is mandatory to call this function to close the handle, otherwise
--  temporary files are not cleaned and child process might survive.
--
global procedure gnuplot_close( atom handle )
	c_proc( xgnuplot_close, {handle} )
end procedure

--
--  @brief    Sends a command to an active gnuplot session.
--  @param    handle    Gnuplot session control handle
--  @param    cmd       Command to send, same as a printf statement.
--  @param    opts      Options to pass to cmd for printf processing.
--
--  This sends a string to an active gnuplot session, to be executed.
--  There is strictly no way to know if the command has been
--  successfully executed or not.
--  The command syntax is the same as printf. Use opts={} if you do
--  not need to pass any printf-style parameters.
--
--  Examples:
--
--  @code
--    gnuplot_cmd(g, "plot %d*x", 23.0);
--    gnuplot_cmd(g, "plot %g * cos(%g * x)", {32.0,-3.0});
--  @endcode
--
--  Since the communication to the gnuplot process is run through
--  a standard Unix pipe, it is only unidirectional. This means that
--  it is not possible for this interface to query an error status
--  back from gnuplot.
--
global procedure gnuplot_cmd( atom handle, sequence cmd, object opts )
	
	atom pcmd
	
	if not equal( opts, {} ) then
		cmd = sprintf( cmd, opts )
	end if
	
	pcmd = allocate_string( cmd )
	
	c_proc( xgnuplot_cmd, {handle,pcmd} )
	
	free( pcmd )
	
end procedure

constant VALID_PLOT_STYLES = {
	"lines",
	"points",
	"linespoints",
	"impulses",
	"dots",
	"steps",
	"errorbars",
	"boxes",
	"boxeserrorbars"
}

--
--  @brief    Change the plotting style of a gnuplot session.
--  @param    handle        Gnuplot session control handle
--  @param    plot_style    Plotting-style to use (a string)
--
--  The provided plotting style is a character string. It must be one of
--  the following:
--
--  - lines
--  - points
--  - linespoints
--  - impulses
--  - dots
--  - steps
--  - errorbars
--  - boxes
--  - boxeserrorbars
--
global procedure gnuplot_setstyle( atom handle, sequence plot_style )
	
	atom pplot_style
	
	plot_style = lower( plot_style )
	
	if not find( plot_style, VALID_PLOT_STYLES ) then
		printf( 2, "invalid plot_style: '%s'\n", {plot_style} )
		?1/0
	end if
	
	pplot_style = allocate_string( plot_style )
	
	c_proc( xgnuplot_setstyle, {handle,pplot_style} )
	
	free( pplot_style )
	
end procedure

--
--  @brief    Sets the x label of a gnuplot session.
--  @param    handle    Gnuplot session control handle.
--  @param    label     Character string to use for X label.
--
--  Sets the x label for a gnuplot session.
--
global procedure gnuplot_set_xlabel( atom handle, sequence label_ )
	
	atom plabel
	plabel = allocate_string( label_ )
	
	c_proc( xgnuplot_set_xlabel, {handle,plabel} )
	
	free( plabel )
	
end procedure

--
--  @brief    Sets the y label of a gnuplot session.
--  @param    handle    Gnuplot session control handle.
--  @param    label     Character string to use for Y label.
--
--  Sets the y label for a gnuplot session.
--
global procedure gnuplot_set_ylabel( atom handle, sequence label_ )
	
	atom plabel
	plabel = allocate_string( label_ )
	
	c_proc( xgnuplot_set_ylabel, {handle,plabel} )
	
	free( plabel )
	
end procedure

--
--  @brief    Resets a gnuplot session (next plot will erase previous ones).
--  @param    handle Gnuplot session control handle.
--
--  Resets a gnuplot session, i.e. the next plot will erase all previous
--  ones.
--
global procedure gnuplot_resetplot( atom handle )
	c_proc( xgnuplot_resetplot, {handle} )
end procedure

--
--  @brief    Plots a 2d graph from a list of doubles.
--  @param    handle    Gnuplot session control handle.
--  @param    points    Sequence of values.
--  @param    title     Title of the plot.
--
--  Plots out a 2d graph from a list of values. The x-coordinate is the
--  index of the value in the list, the y coordinate is the value in
--  the list.
--
--  Example:
--
--  @code
--    atom h
--    sequence d
--
--    h = gnuplot_init()
--    d = repeat( 0, 50 )
--    for i = 1 to 50 do
--        d[i] = i*i
--    end for
--    gnuplot_plot_x(h, d, "parabola")
--    sleep(2)
--    gnuplot_close(h)
--  @endcode
--
global procedure gnuplot_plot_x( atom handle, sequence points, sequence title )
	
	integer n
	atom ppoints, ptitle
	
	n = length( points )
	
	ppoints = allocate( n * SIZEOF_DOUBLE )
	ptitle = allocate_string( title )
	
	for i = 1 to n do
		poke( ppoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(points[i]) )
	end for
	
	c_proc( xgnuplot_plot_x, {handle,ppoints,n,ptitle} )
	
	free( ppoints )
	free( ptitle )
	
end procedure

--
--  @brief    Plot a 2d graph from a list of points.
--  @param    handle    Gnuplot session control handle.
--  @param    xpoints   Sequence of x coordinates.
--  @param    ypoints   Sequence of y coordinates.
--  @param    title     Title of the plot.
--
--  Plots out a 2d graph from a list of points. Provide points through a list
--  of x and a list of y coordinates. Both provided arrays are assumed to
--  contain the same number of values.
--
--  @code
--    atom h
--    sequence x
--    sequence y
--
--    h = gnuplot_init()
--    x = repeat( 0, 50 )
--    y = repeat( 0, 50 )
--    for i = 1 to 50 do
--        x[i] = i/10.0
--        y[i] = x[i] * x[i]
--    end for
--    gnuplot_plot_xy(h, x, y, "parabola")
--    sleep(2)
--    gnuplot_close(h)
--  @endcode
--
global procedure gnuplot_plot_xy( atom handle, sequence xpoints, sequence ypoints, sequence title )
	
	integer n
	atom pxpoints, pypoints, ptitle
	
	if length( xpoints ) != length( ypoints ) then
		puts( 2, "length( xpoints ) != length( ypoints )\n" )
		?1/0
	end if
	
	n = length( xpoints )
	
	pxpoints = allocate( n * SIZEOF_DOUBLE )
	pypoints = allocate( n * SIZEOF_DOUBLE )
	ptitle = allocate_string( title )
	
	for i = 1 to n do
		poke( pxpoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(xpoints[i]) )
		poke( pypoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(ypoints[i]) )
	end for
	
	c_proc( xgnuplot_plot_xy, {handle,pxpoints,pypoints,n,ptitle} )
	
	free( pxpoints )
	free( pypoints )
	free( ptitle )
	
end procedure

--
--  @brief    Open a new session, plot a signal, close the session.
--  @param    title     Plot title
--  @param    style     Plot style
--  @param    label_x   Label for X
--  @param    label_y   Label for Y
--  @param    xpoints   Array of X coordinates
--  @param    ypoints   Array of Y coordinates (can be empty)
--
--  This function opens a new gnuplot session, plots the provided
--  signal as an X or XY signal depending on a provided y, waits for
--  a carriage return on stdin and closes the session.
--
--  It is Ok to provide an empty title, empty style, or empty labels for
--  X and Y. Defaults are provided in this case.
--
global procedure gnuplot_plot_once( sequence title, sequence style, sequence label_x, sequence label_y, sequence xpoints, sequence ypoints )
	
	integer n
	atom ptitle, pstyle, plabel_x, plabel_y, pxpoints, pypoints
	
	if length( ypoints ) = 0 then
		ypoints = repeat( NULL, length(xpoints) )
		
	elsif length( xpoints ) != length( ypoints ) then
		puts( 2, "length( xpoints ) != length( ypoints )\n" )
		?1/0
		
	end if
	
	n = length( xpoints )
	
	ptitle = allocate_string( title )
	pstyle = allocate_string( style )
	plabel_x = allocate_string( label_x )
	plabel_y = allocate_string( label_y )
	pxpoints = allocate( n * SIZEOF_DOUBLE )
	pypoints = allocate( n * SIZEOF_DOUBLE )
	
	for i = 1 to n do
		poke( pxpoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(xpoints[i]) )
		poke( pypoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(ypoints[i]) )
	end for
	
	c_proc( xgnuplot_plot_once, {ptitle,pstyle,plabel_x,plabel_y,pxpoints,pypoints,n} )
	
	free( ptitle )
	free( pstyle )
	free( plabel_x )
	free( plabel_y )
	free( pxpoints )
	free( pypoints )
	
end procedure

--
--  @brief    Plot a slope on a gnuplot session.
--  @param    handle    Gnuplot session control handle.
--  @param    slope     Slope.
--  @param    intercept Intercept.
--  @param    title     Title of the plot.
--
--  Plot a slope on a gnuplot session. The provided slope has an
--  equation of the form y=ax+b
--
--  Example:
--
--  @code
--    atom h
--
--    h = gnuplot_init()
--    gnuplot_plot_slope(h, 1.0, 0.0, "unity slope")
--    sleep(2)
--    gnuplot_close(h)
--  @endcode
--
global procedure gnuplot_plot_slope( atom handle, atom slope, atom intercept, sequence title )
	
	atom ptitle
	
	ptitle = allocate_string( title )
	
	c_proc( xgnuplot_plot_slope, {handle,slope,intercept,ptitle} )
	
	free( ptitle )
	
end procedure

--
--  @brief    Plot a curve of given equation y=f(x).
--  @param    hangle    Gnuplot session control handle.
--  @param    equation  Equation to plot.
--  @param    title     Title of the plot.
--
--  Plots out a curve of given equation. The general form of the
--  equation is y=f(x), you only provide the f(x) side of the equation.
--
--  Example:
--
--  @code
--    atom h
--    sequence eq
--    
--    h = gnuplot_init()
--    eq = "sin(x) * cos(2*x)"
--    gnuplot_plot_equation(h, eq, "sine wave", normal)
--    gnuplot_close(h)
--  @endcode
--
global procedure gnuplot_plot_equation( atom handle, sequence equation, sequence title )
	
	atom pequation, ptitle
	
	pequation = allocate_string( equation )
	ptitle = allocate_string( title )
	
	c_proc( xgnuplot_plot_equation, {handle,pequation,ptitle} )
	
	free( pequation )
	free( ptitle )
	
end procedure

--
-- Writes a CSV file for use with gnuplot commands later.  Allows files to also be saved for post
-- analysis with excel for example. Arguments are similar to gnuplot_plot_x()
--
-- Uses title as gnuplot "comment" on the first line.
--
-- @param fileName file name to write to.  This should be the same name used in the gnuplot command
-- @param points
-- @param title
-- @return int      <0 if error writing file.
--
global function gnuplot_write_x_csv( sequence fileName, sequence points, sequence title )
	
	integer n, result
	atom pfileName, ppoints, ptitle
	
	n = length( points )
	
	pfileName = allocate_string( fileName )
	ppoints = allocate( n * SIZEOF_DOUBLE )
	ptitle = allocate_string( title )
	
	for i = 1 to n do
		poke( ppoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(points[i]) )
	end for
	
	result = c_func( xgnuplot_write_x_csv, {pfileName,ppoints,n,ptitle} )
	
	free( pfileName )
	free( ppoints )
	free( ptitle )
	
	return result
end function

--
-- Writes a CSV file for use with gnuplot commands later.  Allows files to also be saved for post
-- analysis with excel for example. Arguments are similar to gnuplot_plot_xy()
--
-- Uses title as gnuplot "comment" on the first line.
--
-- @param fileName file name to write to.  This should be the same name used in the gnuplot command
-- @param xpoints
-- @param ypoints
-- @param title
-- @return int <0 if file wasn't written.
--
global function gnuplot_write_xy_csv( sequence fileName, sequence xpoints, sequence ypoints, sequence title )
	
	integer n, result
	atom pfileName, pxpoints, pypoints, ptitle
	
	if length( xpoints ) != length( ypoints ) then
		puts( 2, "length( xpoints ) != length( ypoints )\n" )
		?1/0
	end if
	
	n = length( xpoints )
	
	pfileName = allocate_string( fileName )
	pxpoints = allocate( n * SIZEOF_DOUBLE )
	pypoints = allocate( n * SIZEOF_DOUBLE )
	ptitle = allocate_string( title )
	
	for i = 1 to n do
		poke( pxpoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(xpoints[i]) )
		poke( pypoints + (i-1) * SIZEOF_DOUBLE, atom_to_float64(ypoints[i]) )
	end for
	
	result = c_func( xgnuplot_write_x_csv, {pfileName,pxpoints,pypoints,n,ptitle} )
	
	free( pfileName )
	free( pxpoints )
	free( pypoints )
	free( ptitle )
	
	return result
end function

--
-- Writes a multi column CSV file for use with gnuplot commands later.  Allows files to also be
-- saved for post analysis with excel for example. Note that when used with gnuplot, since there
-- may be more than one column the whole "1:3" or whatever should be used.
--
-- Uses title as gnuplot "comment" on the first line.
--
-- @param fileName  file name to write to.  This should be the same name used in the gnuplot command
-- @param list      A sequence of rows. Each row is a sequence of column data.
-- @param title     Title to write for the first line of the .csv file, will be preceeded by "#"
-- @return int <0 if file wasn't written.
--
global function gnuplot_write_multi_csv( sequence fileName, sequence list, sequence title )
	
	integer n, numColumns, result
	atom pfileName, plist, ptitle
	
	if length( list ) < 1 then
		puts( 2, "list cannot be empty\n" )
		?1/0
	end if
	
	n = length( list )
	numColumns = length( list[1] )
	
	pfileName = allocate_string( fileName )
	plist = allocate( n * numColumns * SIZEOF_DOUBLE )
	ptitle = allocate_string( title )
	
	for i = 1 to n do
		
		if length( list[i] ) != numColumns then
			printf( 2, "length( list[%d] ) != numColumns (%d)\n", {i,numColumns} )
			?1/0
		end if
		
		for j = 1 to numColumns do
			poke( plist + (i-1) * SIZEOF_DOUBLE + (j-1) * SIZEOF_DOUBLE, atom_to_float64(list[i][j]) )
		end for
		
	end for
	
	result = c_func( xgnuplot_write_multi_csv, {pfileName,plist,n,numColumns,ptitle} )
	
	free( pfileName )
	free( plist )
	free( ptitle )
	
	return result
end function

