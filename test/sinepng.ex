
include "../include/gnuplot_i.e"

procedure main()
	
	atom g
	
	g = gnuplot_init()
	
	gnuplot_cmd(g, "set terminal png", {})
	gnuplot_cmd(g, "set output \"sine.png\"", {})
	gnuplot_plot_equation(g, "sin(x)", "Sine wave")
	gnuplot_close(g)
	
end procedure

main()
