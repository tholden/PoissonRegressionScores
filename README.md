# PoissonRegressionScores

Ranks NFL and College Football teams using Poisson regression in MATLAB.

The regression estimated is:
```math
\log{\mathbb{E}\mathrm{PointsScored}_{t,i}} = \alpha + \beta \mathrm{AtHomeDummy}_{t,i} + \omicron \mathrm{OvertimeDummy}_{t} + \sum_{j=1}^J{\gamma_j \mathrm{TeamOffenseDummy}_{t,i,j}} - \sum_{j=1}^J{\delta_j \mathrm{TeamDefenseDummy}_{t,i,j}}
```
where $t$ indexes games, $i\in\{1,2\}$ indexes the teams playing that game, and where there are $J$ teams in total.

Uses YALMIP & Mosek to estimate the regression to guaranteed global optimality.

# License

The code is licensed under the GPLv3 license included. This does not apply to the data file "College.csv" which is copyright CollegeFootballData.com.

