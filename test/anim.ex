
include "../include/gnuplot_i.e"

procedure main()
	
	atom h1
	
	puts(1, "*** example of gnuplot control through C ***\n")
	h1 = gnuplot_init()
	
	for phase = 0.1 to 10 by 0.1 do
		gnuplot_resetplot(h1)
		gnuplot_cmd(h1, "plot sin(x+%g)", phase)
	end for
	
	for phase = 10 to 0.1 by -0.1 do
		gnuplot_resetplot(h1)
		gnuplot_cmd(h1, "plot sin(x+%g)", phase)
	end for
	
	gnuplot_close(h1)
	
end procedure

main()
