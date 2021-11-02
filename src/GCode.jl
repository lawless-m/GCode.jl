module GCode

@enum POSITION absolute relative

export absolute, relative
export linear_moves, feed_rate, positioning, set_position

function print_code(io::IO, code::String, args::Dict; range=nothing, rfrom=1)
	function w(i) 
		print(io, code)
		for k in filter(k->k!=';', keys(args))
			print(io, ' ', uppercase(k), args[k][i])
		end
		if haskey(args, ';')
			print(io, " ; ", args[';'][i])
		end
		print(io, "\n")
	end
	
	if range == nothing
		range=rfrom:length(dict_entry(args))
	end
	
	w.(range)
	return range
end

dict_entry(d; i=1) = d[collect(keys(d))[i]]
entry_isa(d, t; i=1) = isa(dict_entry(d;i=i), t)
arrayize_dict(d) = Dict(k=>[d[k]] for k in keys(d))
dict_of_arrays(d) = entry_isa(d, Array)

function linear_moves(io::IO, points::Dict)
	print_code(io, "G00", points, range=1:1)
	print_code(io, "G01", points, rfrom=2)
end

function feed_rate(io::IO, r)
	print_code(io, "G01", Dict('F'=>[r], ';'=>["Feed rate"]))
end

function positioning(io::IO, p::POSITION)
	if p == absolute
		print_code(io, "G90", Dict(';'=>["Absolute Positioning"]))
	else
		print_code(io, "G91", Dict(';'=>["Relative Positioning"]))
	end
end

function set_position(io::IO, points::Dict)
	if dict_of_arrays(points)
		print_code(io, "G92", points)
	else
		print_code(io, "G92", arrayize_dict(points))
	end
end

###
end
