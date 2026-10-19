# Usage: [repld] julia --project=… profile.jl '<setup>' '<expr>' [focus-regex] [top=25]
# Prints the timing of `expr`, its hottest frames, and JET's runtime-dispatch reports.
using Profile, Chairmarks, JET

setup, expr = ARGS[1], ARGS[2]
focus = length(ARGS) >= 3 && !isempty(ARGS[3]) ? Regex(ARGS[3]) : nothing
top = length(ARGS) >= 4 ? parse(Int, ARGS[4]) : 25

# Top-level `using`/`import` must stay top-level; the rest of the setup becomes locals captured by
# the closure, so the profiled code sees concretely typed values rather than untyped globals.
const M = Module(:Profiled)
# `a; b` on one line parses as a nested `:toplevel`
flat(x) = x isa Expr && x.head === :toplevel ? mapreduce(flat, vcat, x.args; init = Any[]) : Any[x]
stmts = flat(Meta.parseall(setup))
isimport(x) = x isa Expr && x.head in (:using, :import)
foreach(x -> Core.eval(M, x), filter(isimport, stmts))
body = Expr(:block, flat(Meta.parseall(expr))...)
f = Core.eval(M, :(() -> begin
    $(Expr(:block, filter(!isimport, stmts)...))
    () -> $body
end))
g = Base.invokelatest(f)
const gm = only(methods(g))
# Packages named in the setup's imports: JET reports only dispatch sites inside them.
pkgpath(x) = x isa Expr && x.head === :(:) ? pkgpath(x.args[1]) : x isa Expr && x.head === :. ? x.args[1] : nothing
targets = Tuple(unique(getfield(M, p) for x in filter(isimport, stmts) for a in x.args for p in (pkgpath(a),) if p isa Symbol))
Base.invokelatest(g)

b = Base.invokelatest(() -> @b $g())
println("time: ", b)

# A frame counts once per sample (inclusive) up to the outermost frame of `expr`; self time includes
# C callees (e.g. libpython), so a Julia line that calls into Python owns that Python time.
# ~20 ms bursts with a young-generation GC between them: objects awaiting finalizers (e.g. PythonCall
# handles, whose Python objects live until then) otherwise pile up, slow every call, and inflate
# whichever lines allocate (Python's own GC rescans them all). One `@profile` spans all bursts:
# restarting it per burst multiplies the sample rate (seen ~8× on Julia 1.13, macOS). Samples taken
# in the forced GC never reach `expr`'s frame, so they drop out below.
burst = max(1, ceil(Int, 0.02 / max(b.time, 1e-9)))
bursts = 100
Profile.init(n = 10^6, delay = 1e-3)  # also shrinks a buffer an earlier run in the session enlarged
Profile.clear()
forced = Ref(0.0)
st = Base.invokelatest() do
    @timed @profile for _ in 1:bursts
        for _ in 1:burst
            g()
        end
        forced[] += @elapsed GC.gc(false)
    end
end
n = burst * bursts
gcpct = round(100 * max(0.0, st.gctime - forced[]) / (st.time - forced[]); digits = 1)
data = Profile.fetch(include_meta = false)
lidict = Profile.getdict(data)
Profile.clear()
key(sf) = string(sf.func, " ", basename(string(sf.file)), ":", sf.line)
incl, self = Dict{String, Int}(), Dict{String, Int}()
total = 0
frames = String[]   # one sample's frames, innermost first, up to the frame of `expr`
inexpr = false
for ip in data
    global total, inexpr
    if ip == 0
        if inexpr
            total += 1
            foreach(k -> incl[k] = get(incl, k, 0) + 1, unique(frames))
            isempty(frames) || (self[frames[1]] = get(self, frames[1], 0) + 1)
        end
        empty!(frames); inexpr = false
        continue
    end
    inexpr && continue
    for sf in lidict[ip]
        sf.from_c && continue
        mi = sf.linfo isa Core.CodeInstance ? sf.linfo.def : sf.linfo
        mi isa Core.MethodInstance && mi.def === gm && (inexpr = true; break)
        basename(string(sf.file)) == "none" || push!(frames, key(sf))  # `none`: the expression itself, inlined
    end
end
# GC pauses land on whichever line allocates, so a high share blurs line attribution.
println("profile: $total samples over $n calls; GC $gcpct%")
rows = sort!([k => v for (k, v) in incl if isnothing(focus) || occursin(focus, k)]; by = last, rev = true)
pct(v) = lpad(string(round(100v / max(total, 1); digits = 1)), 5)
println("  incl%  self%  frame")
for (k, v) in first(rows, top)
    println("  ", pct(v), "  ", pct(get(self, k, 0)), "  ", first(k, 120))
end

kw = isempty(targets) ? (;) : (; target_modules = targets)
r = Base.invokelatest(() -> report_opt(g, (); kw...))
sites = Dict{String, Int}()
for rep in JET.get_reports(r)
    fr = rep.vst[end]
    sig = hasproperty(rep, :sig) ? join(x isa Type ? "::" * first(string(x), 60) : string(x) for x in rep.sig._sig) : ""
    sig = replace(sig, r"\b(?:[A-Za-z_]\w*\.)+(?=[A-Za-z_#])" => "")  # module qualifiers
    k = string(basename(string(fr.file)), ":", lpad(fr.line, 4), "  ", sig)
    sites[k] = get(sites, k, 0) + 1
end
println("runtime dispatch in $(isempty(targets) ? "all modules" : join(targets, ", ")) (JET report_opt): $(length(sites)) sites")
for (k, c) in first(sort!(collect(sites); by = first), top)  # by file, then line
    println("  ", c > 1 ? "×$c " : "", first(k, 200))
end

# A warm session outlives this run: release what it allocated (and the Python objects behind it).
data = lidict = r = nothing
GC.gc()
