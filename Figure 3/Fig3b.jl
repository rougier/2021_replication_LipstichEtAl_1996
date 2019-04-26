using DifferentialEquations
using Plots

n_parasites = 100

#Figure 2
# c = 4.0;
# ux = 0.2;
# ux1 = fill(0.2, n_parasites); #le ux et uy 1000 à cause de la β # une autre façon :[0.2 for x in 1:1000]
# uy = rand(200:1000, n_parasites)/1000 #doit être toujours >= à ux
# u1 = (uy - ux1);
# βy = 3 * u1 ./ (u1.+ 1)
# bx = 1.0;
# by = 0.1;
#ey = bx - by
# ey = fill(0.9, n_parasites);    # constant for fig 2 part 1

c = 4.0;
ux = 0.2;
ux1 = fill(0.2, n_parasites); #le ux et uy 1000 à cause de la β # une autre façon :[0.2 for x in 1:1000]
uy = rand(200:1000, n_parasites)/1000;
r1 = rand(0.0:1000, n_parasites)/1000;
r2 = rand(0.0:1000, n_parasites)/1000;
r3 = rand(0.0:1000, n_parasites)/1000;
bx = 1.0;
by = bx .* r1 .* (1 .- r1 .* r2);
# V0 = by*ux./(bx*uy_avg)
V0 = (by .* ux) ./ (bx .* uy)
α = 1 .- V0
βy = r1 .-(α.* by)/bx
ey = bx .* (1 .- r3) .* (1 .- (r1 .* r2));

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

# SANDRINES TEST
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
        N[:,Int(solution.t[t]+1)] = pop
    end

    # add solution to N matrix
    #global N[i.*1000-999,i.*1000,:] = hcat(solution.u)
    #global N[i.*5-4,i.*5,:] = hcat(solution.u)

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

plot(Np[:,2:end], c=:grey, lw=0.4, alpha=0.4)
plot!(Np[:,1], c=:black, lw=5, leg=false)
# plot!(sum(Np[:,2:end]; dims=2))