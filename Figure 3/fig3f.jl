using DifferentialEquations
using Plots

n_parasites = 100

#parameters
c = 4.0;
ux = 0.2;
ux1 = fill(0.2, n_parasites); #le ux et uy 1000 à cause de la β # une autre façon :[0.2 for x in 1:1000]
uy = rand(200:1000, n_parasites)/1000;
r1 = rand(0.0:1000, n_parasites)/1000;
r2 = rand(0.0:1000, n_parasites)/1000;
r3 = rand(0.0:1000, n_parasites)/1000;
bx = 1.0;
by = bx .* r1 .* (1 .- r1 .* r2)
V0 = (by .* ux) ./ (bx .* uy)
α = 1 .- V0
βy = r1 .-(α.* by)/bx;
ey = bx .* (1 .- r3) .* (1 .- (r1 .* r2))   # constant for fig 2 part 1

Y = zeros(Float64, length(ey));
Y[1] = 1.0;
X0 = 10.0;

# differential equations formula for finding densities of each pop at next time step
function fonction(u, p, t)
    x = u[1]
    y = u[2:end]
    regul = (1-(sum(u))/(p.K))
    dx = (p.bx*x + sum(p.ey.*y))*regul - p.ux*x-p.c*sum(p.βy.*y)*x
    dy = p.by .* y .* regul .- p.uy .* y .+ p.c .* p.βy .* x .* y
    return vcat(dx, dy)
end

debut = 0.0
duree = 1000.0
fin = debut + duree
N = zeros(Float64, (n_parasites+1, (n_parasites-1)*Int(duree)+1))
new_U = vcat(X0, Y)
parameters = (bx = bx, βy = βy, ey = ey, c = c, K = 80.0, ux = ux, by = by, uy = uy)

# each strain introduction (1000x)
@progress "Simulation" for i in 2:length(Y)
    # initial conditions
    prob = ODEProblem(fonction, new_U, (debut,fin), parameters)
    solution = solve(prob, saveat=debut:1.0:fin)
    for t in eachindex(solution.t)
        pop = solution.u[t]
        uy_avg = avg_w_survived
        for i in 1:n_parasites
            if (pop.<0)[i]
                pop[i] = 0
            end
        end
        N[:,Int(solution.t[t]+1)] = pop
    end

    # set conditions & new parasite for next loop
    global new_U = solution[end]
    new_y = findfirst(x -> x == 0.0, new_U)
    new_U[new_y] = 1.0

    # set limits for next loop
    global debut = fin
    #global fin = Float64((i+1).* 1000.0)
    global fin = debut + duree
end

Np = N'

#strains that survive at each time step for uy
survival = (Np.>0.0)[:,2:end]
survived_ui = survival.*uy'
avg_survived = sum(survived_ui; dims=2)./sum(survival; dims=2)
avg_w_survived = sum(Np[:,2:end].*uy'; dims=2)./sum(Np[:,2:end]; dims=2)
uy_avg = avg_w_survived

survived_by = survival.*by'
avg_by_survived = sum(survived_by; dims=2)./sum(survival; dims=2)
avg_w_by = sum(Np[:,2:end].*by'; dims=2)./sum(Np[:,2:end]; dims=2)
by_avg = avg_w_by

#calculating R0


V0= by_avg  .*ux./(bx*uy_avg)
plot(V0, title = "Vertical cases", xlabel = "Time", ylabel = "Mean V0", leg = false, ylims = (0.0,1.0))
# png("Figure 3/graph_3f")
