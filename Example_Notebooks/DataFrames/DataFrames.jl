### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ 97ccf6e7-c415-4454-8964-58ea0d29d632
begin
    using DataFrames
    using NamedArrays
    using OrderedCollections
    using Statistics
end

# ╔═╡ 95e62562-a75a-4e5b-8f96-877bfe03e0e7
md""" **This Pluto notebook is based on a blog by Bogamił. You can find his great posts [here](https://bkamins.github.io/)! And I can certainly recommend his upcoming [book](https://www.manning.com/books/julia-for-data-analysis).**"""

# ╔═╡ 704f1f37-b227-465b-98ba-ead8fd7961fd
md" ## DataFrames.jl minilanguage explained."

# ╔═╡ 4304f998-4209-4a12-8fe4-bc34991d159a
md" ### Introduction."

# ╔═╡ f108dcae-0db1-4c56-bcec-b207f7ea53b9
md"
As it is end-of-year I thought of writing a longer post that would be a useful reference to DataFrames.jl users.

In DataFrames.jl we have five functions that can be used to perform transformations of columns of a data frame:

1. **combine**: create a new DataFrame populated with columns that are results of transformations applied to the source data frame columns;
2. **select**: create a new DataFrame that has the same number of rows as the source data frame populated with columns that are results of transformations applied to the source data frame columns; (the exception to the above number of rows invariant is select(df) which produces an empty data frame);
3. **select!**: the same as select but updates the passed data frame in place;
4. **transform**: the same as select but keeps the columns that were already present in the data frame (note though that these columns can be potentially modified by the transformations passed to transform);
5. **transform!**: the same as transform but updates the passed data frame in place.

The same functions also work with **GroupedDataFrames** with the difference that the transformations are applied to groups and then combined.

Here, an important distinction is that combine again allows transformations to produce any number of rows and they are combined in the order of groups in the GroupedDataFrame. On the other hand select, select!, transform and transform! require transformations to produce the same number of rows for each group as the source group and produce a result that has the same row order as the parent data frame of GroupedDataFrame passed. This rule has two important implications:

1. it is not allowed to perform select, select!, transform and transform! operations on a GroupedDataFrame whose groups do not cover all rows of the parent data frame;
2. select, select!, transform and transform!, contrary to combine, ignore the order of groups in the GroupedDataFrame.

In this post I want to explain what I mean when I write transformations. These transformations follow a so-called DataFrames.jl **minilanguage** that is largely based on using => operator. You can find a specification of this minilanguage [here](https://dataframes.juliadata.org/latest/man/split_apply_combine/). However, because the rules have to be precise they are relatively hard to read. Therefore in this post I will introduce them by example. I will give all the examples with data frames as a source, but as noted above they naturally extend to GroupedDataFrame case so I will add the examples for GroupedDataFrame only in cases when it is especially relevant (in order to read these parts of the post please earlier check out how groupby function works in DataFrames.jl).

This post is written under Julia 1.5.3 and DataFrames.jl 0.22.2 (it was also checked to work correctly on Julia 1.6.1 and DataFrames.jl 1.2.0)."


# ╔═╡ 23a682af-3fec-45ed-93c9-b0c99934c41b
md"

!!! note

This Pluto notebook has been used with Julia 1.9-DEV and DataFrames.jl v1.3"

# ╔═╡ 4cf7e701-2f61-4e98-9744-32729ddd8110
md" #### Widen the notebook."

# ╔═╡ d4482972-4b5a-489a-b7a9-02ce5731aba3
html"""
<style>
    main {
        margin: 0 auto;
        max-width: 2000px;
        padding-left: max(160px, 10%);
        padding-right: max(160px, 10%);
    }
</style>
"""

# ╔═╡ 728767af-2d07-4c00-83e7-c8ed2d3981e2
md" 
The data frame that we are going to use in our examples is defined as follows (I sampled some random data to populate it, with the exception of one name to celebrate [this](https://www.chessgames.com/perl/chessgame?gid=2015531) recent masterpiece):"

# ╔═╡ 2c024e43-68e7-457d-962b-477f6ca8d6e4
df = DataFrame(id = 1:6,
    name = ["Aaron Aardvark", "Belen Barboza",
        "春 陈", "Даниил Дубов",
        "Elżbieta Elbląg", "Felipe Fittipaldi"],
    age = [50, 45, 40, 35, 30, 25],
    eye = ["blue", "brown", "hazel", "blue", "green", "brown"],
    grade_1 = [95, 90, 85, 90, 95, 90],
    grade_2 = [75, 80, 65, 90, 75, 95],
    grade_3 = [85, 85, 90, 85, 80, 85])

# ╔═╡ 93a6cc62-eaf4-45dd-89df-05ff55a30adb
md" ### Column selection."

# ╔═╡ 56a596e4-b57b-433a-94ba-19e569568aa3
md"
These are the most simple operations that the discussed functions can perform. In this case the result of combine and select are the same (using transform is not very useful here, as it retains all the columns anyway).

The allowed column selectors are: column number, column name, a regular expression, Not, Between, Cols, All(), and :. In order to select a column or a set of columns you just pass them as arguments. Here is an example of a simple column selection:"

# ╔═╡ 13a4f227-021c-4842-81b1-30da2fc8e664
select(df, r"grade", :)

# ╔═╡ e60fa8a3-7489-4f61-80f5-94067423419d
md"""
Above, we use a common pattern showing how one can move columns to the front of the data frame. The r"grade" regular expression picks all columns that contain "grade" string in their name, then : picks all the remaining columns.

An important rule here is that if we pass several column selectors that pick multiple columns, as you can see above, it is allowed that they select the same columns and they are included in the target data frame using first-in-first-out policy. However, it is not allowed to select the same column twice using single column selectors, so this works:"""

# ╔═╡ e81f8cbd-33f6-4172-9998-5a671d5be138
select(df, "name", [2])

# ╔═╡ 7c51566f-47f1-4fe3-a031-ba390fc09db4
md"

!!! note

It is not allowed to return vectors of different lengths in different transformations"

# ╔═╡ 2b974df7-31b6-4f65-bc3f-8509149e5b7e
combine(df, :age, :eye => unique => :eye)

# ╔═╡ 3b0dbd57-d78a-47f0-a468-1d2f4c2a609a
md" The same rule applies also to more advanced transformations that I cover below (i.e. duplicates are allowed only in plain column selectors picking multiple columns)."

# ╔═╡ 459ced29-0d0c-4b25-bb17-e31c6fb18331
md" A few more regular expression examples:"

# ╔═╡ 5922598b-ff6c-4e34-bcfd-c5e38321c355
select(df, r"1", r"2", :id)

# ╔═╡ 38f41ef8-cae4-4b24-a8aa-478fc88ff718
select(df, r"[1|2]", :id)

# ╔═╡ 11944184-a771-4223-bff6-7debd3bc6656
select(df, r"[1-9]", :id)

# ╔═╡ 62346bbd-f61f-40e8-b9fa-687a81a160f4
select(df, "name", [1])

# ╔═╡ f520f3a7-28b5-4b15-9154-e3ee03d4fb67
select(df, "name", [1, 3])

# ╔═╡ 5d2d5e59-9d5e-40ba-8821-531d3ef8c3a2
md" ### Basic transformations."

# ╔═╡ ffca4846-cf60-4187-ac17-a7506e1fc6e2
md"
The simplest way to specify a transformation is

source\_column => transformation => target\_column_name

In this scenario the source\_column is passed as an argument to transformation and stored in target\_column_name column.

Here is an example:"

# ╔═╡ 0f6e6d41-4e74-4a79-bf64-4e7183f6e014
select(df, :age => mean => :meanage)

# ╔═╡ 9adaea24-e31e-4589-8f40-4a18897854f6
md" Observe that because select produces as many rows in the produced data frame as there are rows in the source data frame, a single value is repeated accordingly. This is not the case for combine. However, if other columns in combine would produce multiple rows the repetition also happens:"

# ╔═╡ 5aeb9de6-419f-42f0-a609-9b7bda343e25
combine(df, :age => mean => :meanage)

# ╔═╡ c159baf2-b55c-4eef-915e-410e06dddcd7
combine(df, :age => mean => :meanage, :eye => unique => :eye)

# ╔═╡ d9059a47-d032-40a1-a6f3-2d0f5506c228
md"
Note, however, that it is not allowed to return vectors of different lengths in different transformations:
"

# ╔═╡ ea8f6f22-83e5-4b43-89cd-86296f0cfa87
combine(df, :age, :eye => unique => :eye)

# ╔═╡ ba441753-c0a3-423c-9baa-b2f969472def
md" Let us discuss one more example, this case using GroupedDataFrame. As you can see below vectors get expanded into multiple rows by default, e.g.:"

# ╔═╡ c39a062e-7764-401a-8125-44b30249f2e0
combine(groupby(df, :eye),
    :name => (x -> identity(x)) => :name,
    :age => mean => :age)

# ╔═╡ a3c878fd-b69e-4bc2-b821-11572c700357
md" Observe that I used (x -> identity(x)) transformation although in this case it would be enough just to write :name; the reason is that I wanted to highlight that if you use an anonymous function in the transformation definition you have to wrap it in ( and ) as shown above; otherwise the expression is parsed by Julia in an unexpected way due to the => operator precedence level"

# ╔═╡ 22825283-8a82-40cf-8178-bbfa163579e8
md" In some cases it would be more natural not to expand the :name column into multiple rows. You can easily achieve it by protecting the value returned by the transformation using Ref (just as in broadcasting"

# ╔═╡ 242db192-f25b-432e-92f5-88ef74683d60
combine(groupby(df, :eye),
    :name => (x -> Ref(identity(x))) => :name,
    :age => mean => :age)

# ╔═╡ 4f2fe53e-c9ce-41e1-8235-b43ffd93a09b
combine(groupby(df, :eye), :name => Ref => :name, :age => mean => :age)

# ╔═╡ 29c7004a-2309-4b5c-93f3-1ba3c7204ca7
md" Often you want to apply some function not to the whole column of a data frame, but rather to its individual elements. Normally one would achieve this using broadcasting like this:"

# ╔═╡ c2569a42-d6ad-4e1d-aa28-9de6e615f8e4
select(df, :name => (x -> uppercase.(x)) => :NAME)

# ╔═╡ dad7ff3d-afca-4a39-b97a-80b4398eb3f8
md" This pattern is encountered very often in practice, therefore there is a ByRow convenience wrapper for a function that creates its broadcasted variant:"

# ╔═╡ 60686766-8fef-4dfd-a693-e6619a3cbd48
select(df, :name => ByRow(uppercase) => :NAME)

# ╔═╡ fd45b1e2-17f8-45b1-bc2a-e4338f89a6a8
select(df, :name => ByRow(uppercase))

# ╔═╡ c161ad15-0ff7-4ae8-be50-3aff1a4ae34f
md" If you want to avoid this then pass renemecols=false keyword argument (this is mostly useful if you perform transformations):"

# ╔═╡ fbb71345-020e-4216-9aae-31aaa9582c25
select(df,
    :grade_1 => ByRow(x -> x / 100),
    :grade_2 => ByRow(x -> x / 100),
    :grade_3 => ByRow(x -> x / 100),
    renamecols=false)

# ╔═╡ 015cd68c-226f-49fe-8efb-1a5a44c66c72
md" Similarly to skipping target column name you can skip the transformation part of the pattern we discussed, in which case it is assumed to be the identity function. In effect we get a way to rename columns in transformations:"

# ╔═╡ c18fbe3b-8c05-4893-b7b7-c18e7a8babd7
select(df, r"grade", :grade_1 => :g1, :grade_2 => :g2, :grade_3 => :g3)

# ╔═╡ c2b9ab49-4ec1-4f95-b820-05aa7ab43e92
md" Transform holds on to all original colums:"

# ╔═╡ ac268ad8-4073-49e9-9ee6-3b169f37c95a
transform(df, r"grade", :grade_1 => :g1, :grade_2 => :g2, :grade_3 => :g3)

# ╔═╡ 9784eac7-d5b5-4e6a-97cf-cbe5166a9786
md" If you want to perform multiple column transformations that have a similar structure (as in the example above) you can pass a vector of transformations:"

# ╔═╡ 2f0933f5-5082-45a0-aa0e-1d8d9bd1ce5b
select(df,
    [x => ByRow(x -> x / 100) for x in [:grade_1, :grade_2, :grade_3]],
    renamecols=false)

# ╔═╡ c3a408f9-60ac-4cca-bb73-e17a8e21b83c
md" or even shorter using broadcasting and taking advantage of names function:"

# ╔═╡ 81c90630-7417-4ce1-8a4e-2c6a698dcad1
select(df, names(df, r"grade") .=> ByRow(x -> x / 100), renamecols=false)

# ╔═╡ 722ee31b-0697-436e-b3ef-56d05b0705e6
md" You now know almost all about single column selection. The only thing left to learn is that nrow function has a special treatment. It does not require passing source column name (but allows specifying of target column name; the default name is :nrow) and produces number of rows in the passed data frame. Here is an example of both:"

# ╔═╡ c55dbd2a-9d55-4028-ac03-9e6c881e0c01
combine(groupby(df, :eye), nrow, nrow => :count)

# ╔═╡ 751d35db-0377-4b5d-9aa4-254ddf1a1619
md" That was a lot of information. Probably this is a good moment to take a short break.

Next we move on to the cases when there are multiple source columns or multiple columns are produced as a result of the transformation."

# ╔═╡ 8374e2fd-705d-436c-a6b5-9e0d8f01181d
md" ### Multiple source columns."

# ╔═╡ f10877f1-9ec3-44ce-95d8-e701ee88b0e2
md" The simplest way to pass multiple columns to a transformation is to pass their list in a vector. In this case these columns are passed as consecutive positional arguments to the function. Here is an example (also observe how automatic column naming is done in this case):"

# ╔═╡ 58f10c62-8676-4291-8d52-aec66be347c0
combine(df,
    [:age, :grade_1] => cor,
    [:age, :grade_2] => cor,
    [:age, :grade_3] => cor)

# ╔═╡ 89dee517-a965-4431-bbec-a0fbe91aee2b
md" Alternatively you can pass the columns as a single argument being a NamedTuple, in order to achieve this wrap the list of passed columns in AsTable. Here is a simple example:"

# ╔═╡ 497d898c-4ed1-464d-ae24-ab1a24de1b95
combine(df, :grade_1, :grade_2,
    AsTable([:grade_1, :grade_2]) => ByRow(x -> x.grade_1 > x.grade_2))

# ╔═╡ b1cf5e96-ca8f-411c-94ab-9ef2411583e2
md" Let us see these two rules at play in a common task of finding a sum of several columns:"

# ╔═╡ 8061f2da-fdc8-4fb6-a0d6-d0a106ff61f1
select(df, names(df, r"grade") => +, AsTable(names(df, r"grade")) => sum)

# ╔═╡ dd6fae70-25cc-4553-9cbf-c0ba1548e04d
md" ### Multiple target columns."

# ╔═╡ d09f41eb-2b70-4870-87f0-a3389a08a214
md" Normally all the transformation functions assume that a single column is returned from a transformation function. Here is a more advanced example:"

# ╔═╡ 73f16fe2-e4ed-4b86-9b40-da48948f0dcc
select(df,
    :name => ByRow(x -> (; ([:firstname, :lastname] .=> split(x))...)))

# ╔═╡ bf8fb369-9025-4d5f-b398-4dcfef18e979
md" In the above code we have used the following pattern that is a convenient way of programmatic creation of NamedTuples:"

# ╔═╡ df986151-71ea-47d1-8269-77b8036167a3
(; :a => 1, :b => 2)

# ╔═╡ 0d53e8ad-f5b2-45db-ad38-ecb83650211b
(; [:a => 1, :b => 2]...)

# ╔═╡ 66655f22-29da-433a-8a89-d93e8101b541
md" However, it is natural to ask if it is possible to produce the separate :firstname and :lastname columns in the data frame. You can do it by adding AsTable as target column names specifier:"

# ╔═╡ 7125d891-8c9c-45d9-a016-948372faab1a
select(df, :name =>
    ByRow(x -> (; ([:firstname, :lastname] .=> split(x))...)) =>
    AsTable)

# ╔═╡ a22b51fe-8788-41dd-847a-f8640540281f
md" In general it is not required that one has to produce a vector of NamedTuples to get this result. It is enough to have any standard iterable (e.g. a vector or a Tuple):"

# ╔═╡ 26968589-eeea-439e-bb4e-19929ecf74ff
select(df, :name => ByRow(split) => AsTable)

# ╔═╡ ba292d7a-0e47-4859-8d5b-6b04dbd865b3
md" Note that as split produces a vector (without column names) the names are generated automatically as :x1 and :x2. You can override this behavior by specifying the target column names explicitly:"

# ╔═╡ 01eb77db-44aa-46d0-8d50-c51030322bb1
select(df, :name => ByRow(split) => [:firstname, :lastname])

# ╔═╡ eb6b92a5-0eea-4f3b-9b04-edb1fcd200a8
md" Several values that can be returned by a transformation are treated to produce multiple columns by default. Therefore they are not allowed to be returned from a function unless AsTable or multiple target column names are specified.

Here is an example:"

# ╔═╡ 6b2e1f90-8f67-4824-b49b-9fc9d249ce0c
combine(df, :age => (x -> (age=x, age2 = x.^2)) => AsTable)

# ╔═╡ 8597f050-cf19-4396-b888-321b0ded15e3
md" The list of return value types treated in this way consists of four elements:

1. AbstractDataFrame,
2. DataFrameRow,
3. AbstractMatrix,
4. NamedTuple.

In the example above we returned a NamedTuple. Note, however, that returning a NamedTuple is not the same as returning a vector of NamedTuples (as we did in the topmost example in this section) as this is allowed."

# ╔═╡ 2cd94ec3-b774-49ed-b7af-cb0b3606bfb1
md" ### Traditional transformation style."

# ╔═╡ d6e320ee-e5b9-4138-8deb-2d6cc5d3334e
md" The traditional transformation style in the combine function was to pass a transformation as a function (without using the => minilanguage). This style is also allowed currently in all transformation functions. Additionally if you want to use this approach you can pass the function as a first argument of the function (which is often convenient in combination with do block style).

In this traditional style we are not allowed to specify source columns. Therefore such a function always takes a data frame (it is most useful with GroupedDataFrame where the data frame is representing a given group of the source data frame)

Similarly traditional style does not allow specifying target column names. Therefore the following defaults are taken:

1. if AbstractDataFrame, DataFrameRow, AbstractMatrix, or NamedTuple is returned then it is assumed to produce multiple columns (in the case of NamedTuple it must contain only vectors or only single values, as if they are mixed an error is thrown).
2. all other return values are treated as a single column (where returning a vector produces multiple rows and returning any other value produces one row).
"

# ╔═╡ a1b70a6f-971c-4a87-a859-ca30b82a6d84
combine(groupby(df, :eye)) do sdf
    return mean(sdf.age)
end

# ╔═╡ 6dbd2b3f-0402-4e7c-a1b9-d52cf15b78e1
combine(groupby(df, :eye), sdf -> mean(sdf.age))

# ╔═╡ 258e3e23-b2a2-40fc-8689-c9b816288804
combine(groupby(df, :eye),
    sdf -> (count = nrow(sdf),
        mean_age = mean(sdf.age),
        std_age = std(sdf.age)))

# ╔═╡ 9a21b4ee-7c9b-4191-a355-ec8d5e5e47b1
md" ### Special treatment of grouping columns."

# ╔═╡ e8b11ede-b660-4b4b-abc4-354fb4b66c1e
transform(groupby(df, :eye),
    :eye => ByRow(uppercase) => :eye,
    keepkeys=false)

# ╔═╡ 8cb83821-a76e-4d5c-b3f9-b3aba59a505a
md"

!!! note

For transform the key columns would be retained in the produced data frame even with keepkeys=false; in this case this keyword argument only influences the fact if we check that key columns have not changed in this case)"

# ╔═╡ be869c1a-fcf9-4aa4-ab63-03bc43d75d36
md" ### Conclusions."

# ╔═╡ ca0599f7-ccf6-4b52-a7df-4a1b21647e27
md" This was long. As a conclusion let me comment that all the above-mentioned styles can be freely combined in a single transformation call:"

# ╔═╡ 3a603271-90e6-46f9-aec5-9db0ac52195b
combine(groupby(df, :eye),
               r"grade", names(df, r"grade") => (+) => :total_grade,
               sdf -> nrow(sdf), nrow, :age => :AGE)

# ╔═╡ f3919d40-7f60-4b22-8456-c0edcbac2998
md" If you got here then congratulations – you have mastered the DataFrames.jl transformation minilanguage."

# ╔═╡ de3a7023-51b6-449a-a120-d0eb48423a5e
md" ## Below some additional notes."

# ╔═╡ 41ffaff2-d968-4ab4-90ed-0a5bf9209482
md" ### Subset option."

# ╔═╡ 2ad68661-5d83-4e06-9642-5bd5ba9cdf31
subset(df, :eye => ByRow(==("blue")), :grade_2 => ByRow(==(90)))

# ╔═╡ 5cecc2ba-2915-4552-a846-12096bc4d959
select(df, :name => ByRow(x -> contains(x, "Aardvark")))

# ╔═╡ 0fcf6900-183a-4349-b728-0ab943f0b017
md" ### NamedArray conversion."

# ╔═╡ b3d82e23-0b7e-40b9-b985-dd6ee696cb24
md" DataFrames are not very suitable to hold a summary, say a model summary, and access the entires with `na[:a, :mean]`"

# ╔═╡ a326a4f7-e67b-4942-86f0-cd86c9729a0b
function toNamedArray(df::DataFrame, params=df[:, :parameters], stats=names(df))
    parameters = Pair{Symbol, Int}[]
    for (index, par) in enumerate(params)
        append!(parameters, [par => index])
    end
    return NamedArray(
        round.(estimates; digits=2), 
            (OrderedDict(parameters...), 
            OrderedDict(:median=>1, :mad_sd=>2, :mean=>3, :std=>4)),
            ("Parameter", "Statistic")
    )
end

# ╔═╡ e2579a26-1c70-48ca-90f6-1a415f2dfeb1
begin
    estimates = [3.0 1.0 3.01 1.1; 0.9 0.2 0.88 0.2; 0.0 1.0 0.001 1.0]
    df_na = DataFrame("median" => estimates[:, 1], "mad_sd" => estimates[:, 2], 
        "mean" => estimates[:, 3], "std" => estimates[:, 4])
    df_na.parameters = Symbol.(["a", "b", "σ"])
    df_na
end

# ╔═╡ 4f02519f-dbfe-4ffe-b7e0-8b9bc7129d4b
na = toNamedArray(df_na)

# ╔═╡ 029308b7-3654-40a8-ab9e-61a5cba51e69
na[:σ, :mad_sd]

# ╔═╡ d30934ef-6428-4894-bf67-501db861eec3
na[Symbol("σ"), Symbol("mad_sd")]

# ╔═╡ c12760e1-9c3b-4801-8e24-8e35d608f504
df1 = DataFrame(g=repeat(1:3, inner=3), x=1:9, y=9:-1:1)

# ╔═╡ 93bb8ec4-0ba7-4793-b8cc-648ed545adf3
md" ### Grouped DataFrames."

# ╔═╡ 5d29d609-f954-4011-8373-e6ea2ae5c62d
gdf=groupby(df1, :g)

# ╔═╡ de11fe58-2532-43e4-a2ff-7c2207b1fb2a
gdf[(g=2,)]

# ╔═╡ 2b9bf2f4-9cd7-4910-8ce7-5530d967eb5f
gdf[[(g=2,), (g=3,)]]

# ╔═╡ 1a7e9a7f-cb81-4062-82e6-83c30d5d4d18
gdf[2]

# ╔═╡ 782cd0db-59f8-47a7-97bc-84d703b9ebf0
combine(gdf, valuecols(gdf) .=> mean)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
NamedArrays = "86f7a689-2022-50b4-a561-43c23ac3c673"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
DataFrames = "~1.4.4"
NamedArrays = "~0.9.6"
OrderedCollections = "~1.4.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0-DEV"
manifest_format = "2.0"
project_hash = "624c207f8c2ba328791b193983082ccab84305be"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d4f69885afa5e6149d0cab3818491565cf41446d"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "19b1417ff479c07e523fcbf2fd735a3fde3d1ab3"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.2.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─95e62562-a75a-4e5b-8f96-877bfe03e0e7
# ╟─704f1f37-b227-465b-98ba-ead8fd7961fd
# ╟─4304f998-4209-4a12-8fe4-bc34991d159a
# ╟─f108dcae-0db1-4c56-bcec-b207f7ea53b9
# ╟─23a682af-3fec-45ed-93c9-b0c99934c41b
# ╟─4cf7e701-2f61-4e98-9744-32729ddd8110
# ╠═d4482972-4b5a-489a-b7a9-02ce5731aba3
# ╠═97ccf6e7-c415-4454-8964-58ea0d29d632
# ╟─728767af-2d07-4c00-83e7-c8ed2d3981e2
# ╠═2c024e43-68e7-457d-962b-477f6ca8d6e4
# ╟─93a6cc62-eaf4-45dd-89df-05ff55a30adb
# ╟─56a596e4-b57b-433a-94ba-19e569568aa3
# ╠═13a4f227-021c-4842-81b1-30da2fc8e664
# ╟─e60fa8a3-7489-4f61-80f5-94067423419d
# ╠═e81f8cbd-33f6-4172-9998-5a671d5be138
# ╟─7c51566f-47f1-4fe3-a031-ba390fc09db4
# ╠═2b974df7-31b6-4f65-bc3f-8509149e5b7e
# ╟─3b0dbd57-d78a-47f0-a468-1d2f4c2a609a
# ╟─459ced29-0d0c-4b25-bb17-e31c6fb18331
# ╠═5922598b-ff6c-4e34-bcfd-c5e38321c355
# ╠═38f41ef8-cae4-4b24-a8aa-478fc88ff718
# ╠═11944184-a771-4223-bff6-7debd3bc6656
# ╠═62346bbd-f61f-40e8-b9fa-687a81a160f4
# ╠═f520f3a7-28b5-4b15-9154-e3ee03d4fb67
# ╟─5d2d5e59-9d5e-40ba-8821-531d3ef8c3a2
# ╟─ffca4846-cf60-4187-ac17-a7506e1fc6e2
# ╠═0f6e6d41-4e74-4a79-bf64-4e7183f6e014
# ╟─9adaea24-e31e-4589-8f40-4a18897854f6
# ╠═5aeb9de6-419f-42f0-a609-9b7bda343e25
# ╠═c159baf2-b55c-4eef-915e-410e06dddcd7
# ╟─d9059a47-d032-40a1-a6f3-2d0f5506c228
# ╠═ea8f6f22-83e5-4b43-89cd-86296f0cfa87
# ╟─ba441753-c0a3-423c-9baa-b2f969472def
# ╠═c39a062e-7764-401a-8125-44b30249f2e0
# ╟─a3c878fd-b69e-4bc2-b821-11572c700357
# ╟─22825283-8a82-40cf-8178-bbfa163579e8
# ╠═242db192-f25b-432e-92f5-88ef74683d60
# ╠═4f2fe53e-c9ce-41e1-8235-b43ffd93a09b
# ╟─29c7004a-2309-4b5c-93f3-1ba3c7204ca7
# ╠═c2569a42-d6ad-4e1d-aa28-9de6e615f8e4
# ╟─dad7ff3d-afca-4a39-b97a-80b4398eb3f8
# ╠═60686766-8fef-4dfd-a693-e6619a3cbd48
# ╠═fd45b1e2-17f8-45b1-bc2a-e4338f89a6a8
# ╟─c161ad15-0ff7-4ae8-be50-3aff1a4ae34f
# ╠═fbb71345-020e-4216-9aae-31aaa9582c25
# ╟─015cd68c-226f-49fe-8efb-1a5a44c66c72
# ╠═c18fbe3b-8c05-4893-b7b7-c18e7a8babd7
# ╟─c2b9ab49-4ec1-4f95-b820-05aa7ab43e92
# ╠═ac268ad8-4073-49e9-9ee6-3b169f37c95a
# ╟─9784eac7-d5b5-4e6a-97cf-cbe5166a9786
# ╠═2f0933f5-5082-45a0-aa0e-1d8d9bd1ce5b
# ╟─c3a408f9-60ac-4cca-bb73-e17a8e21b83c
# ╠═81c90630-7417-4ce1-8a4e-2c6a698dcad1
# ╟─722ee31b-0697-436e-b3ef-56d05b0705e6
# ╠═c55dbd2a-9d55-4028-ac03-9e6c881e0c01
# ╟─751d35db-0377-4b5d-9aa4-254ddf1a1619
# ╟─8374e2fd-705d-436c-a6b5-9e0d8f01181d
# ╟─f10877f1-9ec3-44ce-95d8-e701ee88b0e2
# ╠═58f10c62-8676-4291-8d52-aec66be347c0
# ╟─89dee517-a965-4431-bbec-a0fbe91aee2b
# ╠═497d898c-4ed1-464d-ae24-ab1a24de1b95
# ╟─b1cf5e96-ca8f-411c-94ab-9ef2411583e2
# ╠═8061f2da-fdc8-4fb6-a0d6-d0a106ff61f1
# ╟─dd6fae70-25cc-4553-9cbf-c0ba1548e04d
# ╟─d09f41eb-2b70-4870-87f0-a3389a08a214
# ╠═73f16fe2-e4ed-4b86-9b40-da48948f0dcc
# ╟─bf8fb369-9025-4d5f-b398-4dcfef18e979
# ╠═df986151-71ea-47d1-8269-77b8036167a3
# ╠═0d53e8ad-f5b2-45db-ad38-ecb83650211b
# ╟─66655f22-29da-433a-8a89-d93e8101b541
# ╠═7125d891-8c9c-45d9-a016-948372faab1a
# ╟─a22b51fe-8788-41dd-847a-f8640540281f
# ╠═26968589-eeea-439e-bb4e-19929ecf74ff
# ╟─ba292d7a-0e47-4859-8d5b-6b04dbd865b3
# ╠═01eb77db-44aa-46d0-8d50-c51030322bb1
# ╟─eb6b92a5-0eea-4f3b-9b04-edb1fcd200a8
# ╠═6b2e1f90-8f67-4824-b49b-9fc9d249ce0c
# ╟─8597f050-cf19-4396-b888-321b0ded15e3
# ╟─2cd94ec3-b774-49ed-b7af-cb0b3606bfb1
# ╟─d6e320ee-e5b9-4138-8deb-2d6cc5d3334e
# ╠═a1b70a6f-971c-4a87-a859-ca30b82a6d84
# ╠═6dbd2b3f-0402-4e7c-a1b9-d52cf15b78e1
# ╠═258e3e23-b2a2-40fc-8689-c9b816288804
# ╟─9a21b4ee-7c9b-4191-a355-ec8d5e5e47b1
# ╠═e8b11ede-b660-4b4b-abc4-354fb4b66c1e
# ╟─8cb83821-a76e-4d5c-b3f9-b3aba59a505a
# ╟─be869c1a-fcf9-4aa4-ab63-03bc43d75d36
# ╟─ca0599f7-ccf6-4b52-a7df-4a1b21647e27
# ╠═3a603271-90e6-46f9-aec5-9db0ac52195b
# ╟─f3919d40-7f60-4b22-8456-c0edcbac2998
# ╟─de3a7023-51b6-449a-a120-d0eb48423a5e
# ╟─41ffaff2-d968-4ab4-90ed-0a5bf9209482
# ╠═2ad68661-5d83-4e06-9642-5bd5ba9cdf31
# ╠═5cecc2ba-2915-4552-a846-12096bc4d959
# ╟─0fcf6900-183a-4349-b728-0ab943f0b017
# ╟─b3d82e23-0b7e-40b9-b985-dd6ee696cb24
# ╠═a326a4f7-e67b-4942-86f0-cd86c9729a0b
# ╠═e2579a26-1c70-48ca-90f6-1a415f2dfeb1
# ╠═4f02519f-dbfe-4ffe-b7e0-8b9bc7129d4b
# ╠═029308b7-3654-40a8-ab9e-61a5cba51e69
# ╠═d30934ef-6428-4894-bf67-501db861eec3
# ╠═c12760e1-9c3b-4801-8e24-8e35d608f504
# ╟─93bb8ec4-0ba7-4793-b8cc-648ed545adf3
# ╠═5d29d609-f954-4011-8373-e6ea2ae5c62d
# ╠═de11fe58-2532-43e4-a2ff-7c2207b1fb2a
# ╠═2b9bf2f4-9cd7-4910-8ce7-5530d967eb5f
# ╠═1a7e9a7f-cb81-4062-82e6-83c30d5d4d18
# ╠═782cd0db-59f8-47a7-97bc-84d703b9ebf0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
