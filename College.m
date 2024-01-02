clear variables;

addpath( genpath( 'YALMIP' ) );

% College.csv is downloaded from https://collegefootballdata.com/exporter/games?year=2023&seasonType=both&division=fbs

warning( 'off', 'MATLAB:table:ModifiedAndSavedVarnames' );

Table = readtable( 'College.csv', 'TextType', 'string' );

Table = sortrows( Table, { 'StartDate', 'Id' } );

Table( Table.Season ~= 2023, : ) = [];
Table( Table.HomeDivision ~= "fbs", : ) = [];
Table( Table.AwayDivision ~= "fbs", : ) = [];

Table( Table.Completed ~= "true", : ) = [];
Table( ~isfinite( Table.HomePoints ), : ) = [];
Table( ~isfinite( Table.AwayPoints ), : ) = [];

Scores = [ Table.AwayPoints, Table.HomePoints ];
IDs = [ Table.AwayTeam, Table.HomeTeam ];
Overtime = ( Table.AwayPoints > Table.AwayLineScores_0_ + Table.AwayLineScores_1_ + Table.AwayLineScores_2_ + Table.AwayLineScores_3_ ) | ( Table.HomePoints > Table.HomeLineScores_0_ + Table.HomeLineScores_1_ + Table.HomeLineScores_2_ + Table.HomeLineScores_3_ );
NeutralSite = Table.NeutralSite == "true";

[ Mean, HomeOffset, OvertimeOffset, Offense, Defense, Teams ] = EstimatePoissionRegressionOnScores( Scores, IDs, Overtime, NeutralSite, 1 );

Results = PostProcessResults( Offense, Defense, Teams );
