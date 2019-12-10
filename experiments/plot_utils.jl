using Interact
using Reel
using AutoViz

# Strings describing the goal of each lane
goal_map = Dict(1 => "turn right", 2 =>"straight", 3=>"straight", 4=>"turn left", 5=>"turn left", 6=> "turn right")

# whether the signal is on the right side
lane_right = Dict(
    1=> true,
    2=>true,
    3=>false,
    4=> false,
    5=> false,
    6 => true
    )

function plot_scene(scene, models, roadway; egoid = nothing)
    car_colors = Dict{Int, Colorant}()
    cam = FitToContentCamera(.1)
    overlays = SceneOverlay[]
    for (index,veh) in enumerate(scene)
        i = veh.id
        li = laneid(veh)
        if egoid == nothing || i != egoid
            car_colors[i] = colorant"red"
        else
            car_colors[i] = colorant"blue"
        end
        push!(overlays, BlinkerOverlay(on = veh.state.blinker, veh = Vehicle(veh),right=lane_right[li]))
        push!(overlays, TextOverlay(pos = veh.state.veh_state.posG + VecE2(-3, 3), text = [ string("id: ", veh.id, ", goal: ", goal_map[li])], color = colorant"black", incameraframe=true))
    end
    render(Scene(scene), roadway, overlays, cam=cam, car_colors = car_colors)
end

function make_interact(scenes, models, roadway; egoid = nothing)
    # interactive visualization
    @manipulate for frame_index in 1 : length(scenes)
        plot_scene(scenes[frame_index], models, roadway, egoid=egoid)
    end
end

function make_video(scenes, models, roadway, filename; egoid = nothing)
    frames = Frames(MIME("image/png"), fps=10)
    # interactive visualization
    for frame_index in 1 : length(scenes)
        c = plot_scene(scenes[frame_index], models, roadway, egoid=egoid)
        push!(frames, c)
    end
    write(filename, frames)
end

function plot_training(training_log)
    p1 = plot(training_log["return"], xlabel="Iterations", ylabel="Return", title = "Average batch return", label="")
    p2 = plot(training_log["grad_norm"], xlabel="Iterations", ylabel="grad_norm", title = "Clipped Grad norm", label="")
    p3 = plot(training_log["kl"], xlabel="Iterations", ylabel="KL Divergence", title = "KL Divergence", label="")
    p4 = plot(training_log["lr"], xlabel="Iterations", ylabel="Learning Rate", title = "Learning Rate", label="")
    plot(p1,p2,p3, layout = (3,1))
end

