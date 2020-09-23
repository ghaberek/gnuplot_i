
include "../include/gnuplot_i.e"

constant SLEEP_LGTH  = 2
constant NPOINTS     = 50

procedure main()
	
	atom h1, h2, h3, h4
	sequence x, y
	
	--
	-- Initialize the gnuplot handle
	--
	
	puts(1, "*** example of gnuplot control through C ***\n")
	h1 = gnuplot_init()
	
	--
	-- Slopes
	--
	
	gnuplot_setstyle(h1, "lines")
	
	puts(1, "*** plotting slopes\n")
	puts(1, "y = x\n")
	gnuplot_plot_slope(h1, 1.0, 0.0, "unity slope")
	sleep(SLEEP_LGTH)
	
	puts(1, "y = 2*x\n")
	gnuplot_plot_slope(h1, 2.0, 0.0, "y=2x")
	sleep(SLEEP_LGTH)
	
	puts(1, "y = -x\n")
	gnuplot_plot_slope(h1, -1.0, 0.0, "y=-x")
	sleep(SLEEP_LGTH)
	
	--
	-- Equations
	--
	
	gnuplot_resetplot(h1)
	puts(1, "\n\n")
	puts(1, "*** various equations\n")
	puts(1, "y = sin(x)\n")
	gnuplot_plot_equation(h1, "sin(x)", "sine")
	sleep(SLEEP_LGTH)
	
	puts(1, "y = log(x)\n")
	gnuplot_plot_equation(h1, "log(x)", "logarithm")
	sleep(SLEEP_LGTH)
	
	puts(1, "y = sin(x)*cos(2*x)\n")
	gnuplot_plot_equation(h1, "sin(x)*cos(2*x)", "sine product")
	sleep(SLEEP_LGTH)
	
	--
	-- Equations
	--
	
	gnuplot_resetplot(h1)
	puts(1, "\n\n")
	puts(1, "*** various equations\n")
	puts(1, "y = sin(x)\n")
	gnuplot_plot_equation(h1, "sin(x)", "sine")
	sleep(SLEEP_LGTH)
	
	puts(1, "y = log(x)\n")
	gnuplot_plot_equation(h1, "log(x)", "logarithm")
	sleep(SLEEP_LGTH)
	
	puts(1, "y = sin(x)*cos(2*x)\n")
	gnuplot_plot_equation(h1, "sin(x)*cos(2*x)", "sine product")
	sleep(SLEEP_LGTH)
	
	--
	-- Styles
	--
	
	gnuplot_resetplot(h1)
	puts(1, "\n\n")
	puts(1, "*** showing styles\n")
	
	puts(1, "sine in points\n")
	gnuplot_setstyle(h1, "points")
	gnuplot_plot_equation(h1, "sin(x)", "sine")
	sleep(SLEEP_LGTH)
	
	puts(1, "sine in impulses\n")
	gnuplot_setstyle(h1, "impulses")
	gnuplot_plot_equation(h1, "sin(x)", "sine")
	sleep(SLEEP_LGTH)
	
	puts(1, "sine in steps\n")
	gnuplot_setstyle(h1, "steps")
	gnuplot_plot_equation(h1, "sin(x)", "sine")
	sleep(SLEEP_LGTH)
	
	--
	-- User defined 1d and 2d point sets
	--
	
	gnuplot_resetplot(h1)
	gnuplot_setstyle(h1, "impulses")
	puts(1, "\n\n")
	puts(1, "*** user-defined lists of doubles\n")
	x = repeat( 0, NPOINTS )
	for i = 1 to NPOINTS do
		x[i] = i * i
	end for
	gnuplot_plot_x(h1, x, "user-defined doubles")
	sleep(SLEEP_LGTH)
	
	puts(1, "*** user-defined lists of points\n")
	x = repeat( 0, NPOINTS )
	y = repeat( 0, NPOINTS )
	for i = 1 to NPOINTS do
	    x[i] = i
	    y[i] = i * i
	end for
	gnuplot_resetplot(h1)
	gnuplot_setstyle(h1, "points")
	gnuplot_plot_xy(h1, x, y, "user-defined points")
	sleep(SLEEP_LGTH)
	
	--
	-- Multiple output screens
	--
	
	puts(1, "\n\n")
	puts(1, "*** multiple output windows\n")
	gnuplot_resetplot(h1)
	gnuplot_setstyle(h1, "lines")
	h2 = gnuplot_init()
	gnuplot_setstyle(h2, "lines")
	h3 = gnuplot_init()
	gnuplot_setstyle(h3, "lines")
	h4 = gnuplot_init()
	gnuplot_setstyle(h4, "lines")
	
	puts(1, "window 1: sin(x)\n")
	gnuplot_plot_equation(h1, "sin(x)", "sin(x)")
	sleep(SLEEP_LGTH)
	puts(1, "window 2: x*sin(x)\n")
	gnuplot_plot_equation(h2, "x*sin(x)", "x*sin(x)")
	sleep(SLEEP_LGTH)
	puts(1, "window 3: log(x)/x\n")
	gnuplot_plot_equation(h3, "log(x)/x", "log(x)/x")
	sleep(SLEEP_LGTH)
	puts(1, "window 4: sin(x)/x\n")
	gnuplot_plot_equation(h4, "sin(x)/x", "sin(x)/x")
	sleep(SLEEP_LGTH)
	
	--
	-- close gnuplot handles
	--
	
	puts(1, "\n\n")
	puts(1, "*** end of gnuplot example\n")
	gnuplot_close(h1)
	gnuplot_close(h2)
	gnuplot_close(h3)
	gnuplot_close(h4)
	
end procedure

main()
