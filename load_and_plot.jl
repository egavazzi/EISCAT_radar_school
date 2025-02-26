using Dates
using GLMakie
using HDF5

##
VHF_file = "EISCAT_2024-08-13_tau7_54@vhf.hdf5" # VHF

fid = h5open(VHF_file, "r")
data = read(fid)
close(fid)

data["data"]["par2d"]
# data["metadata"]["par2d"][1, 1:20]
# data["metadata"]["par2d"][1, 20:40]
# data["metadata"]["par2d"][1, 67]

# Extract time
t = data["data"]["utime"]
tstart = t[:, 1]
tstop = t[:, 2]
tmean = unix2datetime.((tstart .+ tstop) ./ 2) #|> x -> Dates.format.(x, "HH:MM:SS") |> x -> Dates.DateTime.(x, dateformat"HH:MM:SS")

# Extract h
length_data = size(data["data"]["par2d"], 1)
nz = 51
nt = Int(length_data / nz)
h_raw = data["data"]["par2d"][:, 1]
h = reshape(h_raw, nz, nt)[:, 1]

# VHF latitudes
Latitude = [70.75
            70.87
            70.94
            71.01
            71.07
            71.14
            71.21
            71.28
            71.41
            71.48
            71.55
            71.68
            71.88
            72.07
            72.21
            72.41
            72.60
            72.80
            72.99
            73.20
            73.45
            73.70
            73.95
            74.22
            74.53
            74.82
            75.08
            75.38
            75.70
            75.99
            76.35
            76.65
            76.90
            77.35
            77.64
            77.99
            78.33
            78.66
            79.05
            79.43
            79.76
            80.13
            80.51
            80.88
            81.25
            81.59
            82.01
            82.36
            82.71
            83.01
            83.76
            ]

# Extract Ne
Ne_raw = data["data"]["par2d"][:, 3]
Ne = reshape(Ne_raw, nz, nt)

Ti_raw = data["data"]["par2d"][:, 4]
Ti = reshape(Ti_raw, nz, nt)

Tr_raw = data["data"]["par2d"][:, 5]
Tr = reshape(Tr_raw, nz, nt)
Te = Ti .* Tr

Vi_raw = data["data"]["par2d"][:, 7]
Vi = reshape(Vi_raw, nz, nt)

status_raw = data["data"]["par2d"][:, 67]
status = reshape(status_raw, nz, nt)
# Ne[status .!= 0] .= NaN
# Te[status .!= 0] .= NaN
# Ti[status .!= 0] .= NaN
# Vi[status .!= 0] .= NaN

# Plot
ymax = 1000
ymin = 75
conversion = Makie.DateTimeConversion(DateTime)
xlimits_val = [DateTime(2024, 08, 13, 16, 29), DateTime(2024, 08, 13, 18, 00)]
lat_pos_ymax = findmin(abs.(h / 1e3 .- ymax))[2]
lat_pos_ymin = findmin(abs.(h / 1e3 .- ymin))[2]
custom_formatter(values) = map(v -> string(Latitude[findmin(abs.(h / 1e3 .- v))[2]]), values)

set_theme!(fontsize = 16)

f = Figure(size = (800, 1000))
# Ne
ax = Axis(f[1, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), dim1_conversion = conversion, ylabel = "Altitude (km)", title = VHF_file)
hm = heatmap!(tmean, h / 1e3, Ne'; colorscale = log10, colormap = :inferno,
    colorrange = (1e10, 1e12))
cb = Colorbar(f[1, 2], hm; label = "Ne (m⁻³)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[1, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

# Te
ax = Axis(f[2, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Te'; colormap = :inferno,
    colorrange=(0, 4000))
cb = Colorbar(f[2, 2], hm; label = "Te (K)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[2, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

# Ti
ax = Axis(f[3, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Ti'; colormap = :inferno,
colorrange = (0, 4000))
cb = Colorbar(f[3, 2], hm; label = "Ti (K)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[3, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

# Vi
ax = Axis(f[4, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Vi', colormap = :RdBu,
colorrange = (-400, 400))
cb = Colorbar(f[4, 2], hm; label = "Vi (m/s)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[4, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

display(GLMakie.Screen(), f)


##
save("vhf_54.png", f; px_per_unit = 2)













##
ESR_file = "EISCAT_2024-08-13_tau7_180@42m.hdf5" # ESR

fid = h5open(ESR_file, "r")
data = read(fid)
close(fid)

data["data"]["par2d"]
# data["metadata"]["par2d"][1, 1:20]
# data["metadata"]["par2d"][1, 20:40]
# data["metadata"]["par2d"][1, 67]

# Extract time
t = data["data"]["utime"]
tstart = t[:, 1]
tstop = t[:, 2]
tmean = unix2datetime.((tstart .+ tstop) ./ 2)

# Extract h
length_data = size(data["data"]["par2d"], 1)
nz = 54
nt = Int(length_data / nz)
h_raw = data["data"]["par2d"][:, 1]
h = reshape(h_raw, nz, nt)[:, 1]

# ESR latitudes
Latitude = [77.99
            77.99
            77.99
            77.98
            77.98
            77.97
            77.97
            77.96
            77.96
            77.95
            77.94
            77.94
            77.93
            77.92
            77.91
            77.89
            77.88
            77.86
            77.85
            77.83
            77.81
            77.79
            77.77
            77.75
            77.73
            77.71
            77.68
            77.66
            77.63
            77.60
            77.58
            77.55
            77.52
            77.49
            77.46
            77.42
            77.39
            77.36
            77.32
            77.29
            77.25
            77.22
            77.18
            77.14
            77.10
            77.07
            77.03
            76.99
            76.95
            76.90
            76.86
            76.80
            76.74
            76.71
            ]

# Extract Ne
Ne_raw = data["data"]["par2d"][:, 3]
Ne = reshape(Ne_raw, nz, nt)

Ti_raw = data["data"]["par2d"][:, 4]
Ti = reshape(Ti_raw, nz, nt)

Tr_raw = data["data"]["par2d"][:, 5]
Tr = reshape(Tr_raw, nz, nt)
Te = Ti .* Tr

Vi_raw = data["data"]["par2d"][:, 7]
Vi = reshape(Vi_raw, nz, nt)

status_raw = data["data"]["par2d"][:, 67]
status = reshape(status_raw, nz, nt)
Ne[status .!= 0] .= NaN
Te[status .!= 0] .= NaN
Ti[status .!= 0] .= NaN
Vi[status .!= 0] .= NaN

# Plot
ymax = 1000
ymin = 75
conversion = Makie.DateTimeConversion(DateTime)
xlimits_val = [DateTime(2024, 08, 13, 16, 29), DateTime(2024, 08, 13, 18, 00)]
lat_pos_ymax = findmin(abs.(h / 1e3 .- ymax))[2]
lat_pos_ymin = findmin(abs.(h / 1e3 .- ymin))[2]
custom_formatter(values) = map(v -> string(Latitude[findmin(abs.(h / 1e3 .- v))[2]]), values)

set_theme!(fontsize = 16)

f = Figure(size = (800, 1000))
# Ne
ax = Axis(f[1, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), dim1_conversion = conversion, ylabel = "Altitude (km)", title = ESR_file)
hm = heatmap!(tmean, h / 1e3, Ne'; colorscale = log10, colormap = Reverse(:inferno),
    colorrange = (1e10, 1e12))
cb = Colorbar(f[1, 2], hm; label = "Ne (m⁻³)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[1, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

# Te
ax = Axis(f[2, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Te'; colormap = Reverse(:inferno),
    colorrange=(0, 4000))
cb = Colorbar(f[2, 2], hm; label = "Te (K)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[2, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

# Ti
ax = Axis(f[3, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Ti'; colormap = Reverse(:inferno),
colorrange = (0, 4000))
cb = Colorbar(f[3, 2], hm; label = "Ti (K)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[3, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

# Vi
ax = Axis(f[4, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Vi', colormap = Reverse(:inferno),
colorrange = (-400, 400))
cb = Colorbar(f[4, 2], hm; label = "Vi (m/s)")
ylims!(ax, ymin, ymax)
xlims!(ax, xlimits_val[1], xlimits_val[2])
ax2 = Axis(f[4, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
hidespines!(ax2)
hidexdecorations!(ax2)
ylims!(ax2, ymin, ymax)

display(f)


##
save("esr_180.png", f; px_per_unit = 2)
