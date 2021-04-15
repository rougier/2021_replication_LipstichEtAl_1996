########### Defines the parameters & plot for Fig 3 a,c,e,g,i ###########

c = 0.5; # set the host contact rate as a constant 0.5

# import required variables/modules common to all simulations
include("../Model_scripts/fig3params.jl");
include("../Model_scripts/Functions.jl");

# now that we have all the requirements, let's run the simulation
run_simulation();

Np = N';

########### Figure 3a ###########

labels = ["" for i = 1:1:n_parasites];
labels2 = vcat("Infected", labels);
labels2 = hcat(labels2...);

# plot the number of infected hosts
plot(
    Np[:,2:end],
    c=:blue,
    lw=1.5,
    alpha=0.4,
    title="c=0.5\n \nNumber of infected and uninfected hosts",
    xlabel="Time",
    ylabel="Number of individuals",
    label=labels2,
    ylims=(0,100)
)

# add the number of uninfected hosts
plot!(
    Np[:,1],
    c=:black,
    lw=1.5,
    label="Uninfected"
)

# add the total number of parasites
plot!(
    sum(Np[:,2:end]; dims=2),
    c=:red,
    label = "Total # parasites"
)

# save figure as a PNG
png("Figure3/graph_3a.png")


########### Figure 3c ###########

# ui of the survival strains
survival = (Np .> 0.0)[:,2:end];
ui_avg = sum(Np[:,2:end] .* ui'; dims=2) ./ sum(Np[:,2:end]; dims=2);

# strains that survive for βy
survived_βy = survival .* βy';

# weighted β
βy_w_avg = sum(Np[:,2:end] .* βy'; dims=2) ./ sum(Np[:,2:end]; dims=2);

# calculating weighted H0
k = 1;
H0_w = c * βy_w_avg ./ ui_avg .* k .* (1 - ux / bx);

# calculating weighted V0
bi_avg = sum(Np[:,2:end] .* bi'; dims=2) ./ sum(Np[:,2:end]; dims=2);
V0_w = bi_avg .* ux ./ (bx * ui_avg);

# calculating weighted R0
R0_w = H0_w + V0_w;

# plot the average weighted R0
plot(R0_w,
    c=:black,
    lw=1.5,
    title = "Average R0 in the population",
    xlabel = "Time",
    ylabel = "Mean R0",
    leg = false,
    ylims=(0,7)
)

# save figure as a PNG
png("Figure3/graph_3c")


########### Figure 3e ###########

# plot the average V0
plot(
    V0_w,
    c=:black,
    lw=1.5,
    title="Average V0 in the population",
    xlabel="Time",
    ylabel="Mean V0",
    leg=false,
    ylims=(0.0,1.0)
)

# save figure as a PNG
png("Figure3/graph_3e.png")


########### Figure 3g ###########
# mean virulence
vir = (1 .- (bi .+ ei) .* ux ./ (bx .* ui));

# weighted virulence
avg_w_virulence = sum(Np[:,2:end] .* vir'; dims=2) ./ sum(Np[:,2:end]; dims=2);

# plot the average horizontal transmission
plot(
    βy_w_avg,
    c=:black,
    title="Virulence and beta",
    label="Beta",
    xlabel="Time",
    ylabel="Mean virulence & \n Mean Beta",
    ylims=(0,1)
)

# add the average weighted virulence to the plot
plot!(
    avg_w_virulence,
    lw=1.5,
    c=:blue,
    label="Virulence"
)

# save figure as a PNG
png("Figure3/graph_3g.png")


########### Figure 3i ###########

# use the function in Functions.jl to calculate the evenness
evenness_data = mapslices(calculate_evenness, Np[:,2:end]; dims=2);

# plot the evenness through time
plot(evenness_data,
    c=:black,
    lw=1.5,
    title="Evenness",
    xlabel="Time",
    ylabel="Relative abundance (log)",
    leg=false,
    ylims=(0,1)
)

# save figure as a PNG
png("Figure3/graph_3i.png")
