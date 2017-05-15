using Stan
using Compat
using Mamba
import Mamba: describe

function describe_str(c::Chains; q::Vector=[0.025, 0.25, 0.5, 0.75, 0.975],
           etype=:bm, args...)
    out = string(
        Mamba.header(c),
        "\nEmpirical Posterior Estimates:\n",
        sprint(io -> showall(io, Mamba.summarystats(c; etype=etype, args...), false)),
        "\nQuantiles:\n",
        sprint(io -> showall(io, Mamba.quantile(c, q=q), false))
    )
    
    monitor = ["theta", "lp__", "accept_stat__"]

    sim = c[:, monitor, :]
    p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);

    vbox(codemirror(out, readonly=true, linenumbers=false), p...)
end


function run_model(input)
    data = input[:data]
    model_str = input[:code]
    d = parse(data) |> eval
    stanmodel = Stanmodel(name="_model", model=model_str)
    sim = stan(stanmodel, d, "/tmp", CmdStanDir=CMDSTAN_HOME)
    describe_str(sim)
end


function main(window)

    push!(window.assets, "codemirror")
    push!(window.assets, "widgets")
    input = Input(Dict())
    s = Escher.sampler()

    input_pane = (vbox(
        hbox(
            size(50vw, 50vh, codemirror(name=:code) |> watch!(s)),
            hskip(1em),
            size(50vw, 50vh, codemirror(name=:data) |> watch!(s))),
        vskip(1em),
        hbox(button("Run") |> trigger!(s)),
        vskip(1em),
    ) |> Escher.sample(s)) >>> input

    output_pane =
        consume(run_model, input; init="Ready to take inputs.", typ=Any)

    vbox(
        title(2, "StanBox"),
        vskip(1em),
        vbox(input_pane, vskip(1em), output_pane),
    ) |> pad(1em)
end
