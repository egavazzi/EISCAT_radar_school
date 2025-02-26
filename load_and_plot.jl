using Dates
using GLMakie
using HDF5

## Load and plot VHF data
file = "EISCAT_2024-08-13_tau7_54@vhf.hdf5" # VHF


fid = h5open(file, "r")
data = read(fid)
close(fid)

# data["data"]["par2d"]
# data["metadata"]["par2d"][1, 1:20]
# data["metadata"]["par2d"][1, 20:40]
# data["metadata"]["par2d"][1, 67]

#=
data["data"]["par2d"] is a 2D array of size [n_z x n_t, n_parameters].

Each parameter is saved as looong vectors of size [n_z x n_t]. We need to find n_z and
n_t to restructure (reshape) them into 2D arrays of size [n_z, n_t].
=#
# Extract time
t = data["data"]["utime"]
tstart = t[:, 1]
tstop = t[:, 2]
tmean = unix2datetime.((tstart .+ tstop) ./ 2)

# Find nz and nt
nt = length(tmean)
length_data = size(data["data"]["par2d"], 1)
nz = Int(length_data / nt)

# Extract h
h_raw = data["data"]["par2d"][:, 1]
h = reshape(h_raw, nz, nt)[:, 1]

# Extract Ne, Ti, Te and Vi
Ne_raw = data["data"]["par2d"][:, 3]
Ne = reshape(Ne_raw, nz, nt)

Ti_raw = data["data"]["par2d"][:, 4]
Ti = reshape(Ti_raw, nz, nt)

Tr_raw = data["data"]["par2d"][:, 5] # Tr = Te / Ti
Tr = reshape(Tr_raw, nz, nt)
Te = Ti .* Tr

Vi_raw = data["data"]["par2d"][:, 7]
Vi = reshape(Vi_raw, nz, nt)

# Remove badly fitted data
status_raw = data["data"]["par2d"][:, 67] # status of the fit (0 = fit ok)
status = reshape(status_raw, nz, nt)
Ne[status .!= 0] .= NaN
Te[status .!= 0] .= NaN
Ti[status .!= 0] .= NaN
Vi[status .!= 0] .= NaN

# VHF latitudes (obtained from Madrigal)
Latitude = [70.75, 70.87, 70.94, 71.01, 71.07, 71.14, 71.21, 71.28, 71.41, 71.48, 71.55,
    71.68, 71.88, 72.07, 72.21, 72.41, 72.60, 72.80, 72.99, 73.20, 73.45,
    73.70, 73.95, 74.22, 74.53, 74.82, 75.08, 75.38, 75.70, 75.99, 76.35,
    76.65, 76.90, 77.35, 77.64, 77.99, 78.33, 78.66, 79.05, 79.43, 79.76,
    80.13, 80.51, 80.88, 81.25, 81.59, 82.01, 82.36, 82.71, 83.01, 83.76]

# Plot
ymin = 75
ymax = 1000
conversion = Makie.DateTimeConversion(DateTime)
xlim_val = [DateTime(2024, 08, 13, 16, 29), DateTime(2024, 08, 13, 18, 00)]

f = Figure(size = (800, 1000), fontsize = 16)
# Ne
ax1 = Axis(f[1, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3),
          dim1_conversion = conversion, ylabel = "Altitude (km)", title = file)
hm = heatmap!(tmean, h / 1e3, Ne'; colorscale = log10, colorrange = (1e10, 1e12),
              colormap = :inferno)
cb = Colorbar(f[1, 2], hm; label = "Ne (m⁻³)")

# Te
ax2 = Axis(f[2, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Te'; colorrange = (0, 4000), colormap = :inferno)
cb = Colorbar(f[2, 2], hm; label = "Te (K)")

# Ti
ax3 = Axis(f[3, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Ti'; colorrange = (0, 4000), colormap = :inferno)
cb = Colorbar(f[3, 2], hm; label = "Ti (K)")

# Vi
ax4 = Axis(f[4, 1], xminorticksvisible = true, xminorticks = IntervalsBetween(3), ylabel = "Altitude (km)")
hm = heatmap!(tmean, h / 1e3, Vi'; colorrange = (-400, 400), colormap = :RdBu)
cb = Colorbar(f[4, 2], hm; label = "Vi (m/s)")

linkaxes!(ax1, ax2, ax3, ax4)
xlims!(ax4, xlim_val[1], xlim_val[2])
ylims!(ax4, ymin, ymax)

# Add latitude as a second y-axis (to the right)
#=
This is done by choosing the same limits as the left y-axis (altitude), but using a custom
formatter that replaces the altitude label by the corresponding latitude value.
=#
custom_formatter(values) = map(v -> string(Latitude[findmin(abs.(h / 1e3 .- v))[2]]), values)
for i in 1:4
    ax = Axis(f[i, 1], yaxisposition = :right, ytickformat = custom_formatter, ylabel = "Latitude (°)")
    hidespines!(ax)
    hidexdecorations!(ax)
    ylims!(ax, ymin, ymax)
end

display(f)

##
save("vhf_54.png", f; px_per_unit = 2)
