clear variables;

addpath( genpath( 'YALMIP' ) );

% College.csv is downloaded from https://collegefootballdata.com/exporter/games?year=2023&seasonType=regular&division=fbs

warning( 'off', 'MATLAB:table:ModifiedAndSavedVarnames' );

Table = readtable( 'College.csv', 'TextType', 'string' );

Table( Table.Season ~= 2023, : ) = [];
Table( Table.SeasonType ~= "regular", : ) = [];
Table( Table.HomeDivision ~= "fbs", : ) = [];
Table( Table.AwayDivision ~= "fbs", : ) = [];

Table( Table.Completed ~= "true", : ) = [];
Table( ~isfinite( Table.HomePoints ), : ) = [];
Table( ~isfinite( Table.AwayPoints ), : ) = [];

Scores = [ Table.AwayPoints, Table.HomePoints ];
IDs = [ Table.AwayTeam, Table.HomeTeam ];
Overtime = false( size( Scores, 1 ), 1 );
NeutralSite = Table.NeutralSite == "true";

[ Mean, HomeOffset, OvertimeOffset, Offense, Defense, Teams ] = EstimatePoissionRegressionOnScores( Scores, IDs, Overtime, NeutralSite );

NTeams = numel( Teams );

Combined = Offense + Defense;

[ ~, ~, OffenseRank ] = unique( Offense );
[ ~, ~, DefenseRank ] = unique( Defense );
[ ~, ~, CombinedRank ] = unique( Combined );

OffenseRank = NTeams + 1 - OffenseRank;
DefenseRank = NTeams + 1 - DefenseRank;
CombinedRank = NTeams + 1 - CombinedRank;

Results = table( OffenseRank, DefenseRank, CombinedRank, 'RowNames', Teams );

Results = sortrows( Results, 'CombinedRank' );
