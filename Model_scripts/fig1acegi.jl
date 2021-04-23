########### Defines the parameters & plot for Fig 1 a,c,e,g,i ###########

bi = 0.1; # set the birth rate of infected individuals as a constant 0.1

# import required variables/modules common to all simulations
include("../Model_scripts/fig1params.jl")
include("../Model_scripts/Functions.jl")

# now that we have all the requirements, let's run the simulation
run_simulation();

Np = N';

########### Figure 1a ###########

labels = ["" for i = 1:1:n_parasites];
labels2 = vcat("Infected", labels);
labels2 = hcat(labels2...);

# plot the number of infected hosts
plot(
    Np[:,2:end],
    c=:blue,
    lw=1.5,
    alpha=0.4,
    title="by=0.1\n \nNumber of infected and uninfected hosts",
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
    label = "Total parasites"
)

# save figure as a PNG
png("Figure1/graph_1a.png")


########### Figure 1g ###########

# ui of the survival strains
survival = (Np .> 0.0)[:,2:end];

# weighted average mortality (for noise reduction)
ui_w_avg = sum(Np[:,2:end] .* ui'; dims=2) ./ sum(Np[:,2:end]; dims=2);

# plot the average mortality through time
plot(
    ui_w_avg,
    c=:black,
    lw=1.5,
    title="Average mortality in the population",
    xlabel="Time",
    ylabel="Mean mortality (ui)",
    leg=false,
    ylims=(0,1)
)

# save figure as a PNG
png("Figure1/graph_1g.png")


########### Figure 1e ###########

# strains that survive for βy
survived_βy = survival .* βy';
βy_avg = sum(survived_βy; dims=2) ./ sum(survival; dims=2);
βy_w_avg = sum(Np[:,2:end] .* βy'; dims=2) ./ sum(Np[:,2:end]; dims=2);

# calculating weighted H0
k=1
H0_w = c * βy_w_avg ./ ui_avg .* k .* (1 - ux / bx);

# calculating weighted V0
bi_avg = sum(Np[:,2:end] .* bi'; dims=2) ./ sum(Np[:,2:end]; dims=2);
V0_w = bi_avg .* ux ./ (bx * ui_avg);

# calculating weighted R0
R0_w = H0_w + V0_w;

# plot the average V0
plot(
    V0_w,
    c=:black,
    lw=1.5,
    title="Average vertical cases in the population",
    xlabel="Time",
    ylabel="Mean V0",
    leg=false,
    ylims=(0,1)
)

# save figure as a PNG
png("Figure1/graph_1e")


########### Figure 1c ###########

# plot the average weighted R0
plot(
    R0_w,
    c=:black,
    lw=1.5,
    title="Average R0 in the population",
    xlabel="Time",
    ylabel="Mean R0",
    leg=false,
    ylims=(0,6)
)

# save figure as a PNG
png("Figure1/graph_1c")


########### Figure 1i ###########

# use the function in Functions.jl to calculate the evenness
evenness_data = mapslices(calculate_evenness, Np[:,2:end]; dims=2);

# plot the evenness through time
plot(
    evenness_data,
    c=:black,
    lw=0.5,
    title="Evenness",
    xlabel="Time",
    ylabel="Relative abundance (log)",
    leg=false,
    ylims=(0,1)
)

# save figure as a PNG
png("Figure1/graph_1i.png")
