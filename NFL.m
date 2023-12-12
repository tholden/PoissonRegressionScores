clear variables;

addpath( genpath( 'YALMIP' ) );

WebPage = webread( 'https://www.footballdb.com/games/index.html', weboptions( 'UserAgent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' ) );

WebPage = regexprep( WebPage, '(?<=class\s*\=\s*"statistics".*)</tbody>.*?<tbody>', '', 'ignorecase' );

writelines( WebPage, 'NFLData.html' );

Table = readtable( 'NFLData.html', 'TableSelector', '//*[contains(@class, ''statistics'')]' );

delete NFLData.html;

Table( Table.Box == "--", : ) = [];

Scores = [ Table.Var1, Table.Var2 ];
IDs = [ Table.Visitor, Table.Home ];
Overtime = Table.Var3 == "OT";

[ Mean, HomeOffset, OvertimeOffset, Offense, Defense, Teams ] = EstimatePoissionRegressionOnScores( Scores, IDs, Overtime, false( size( Overtime ) ) );

Teams = regexprep( Teams, '[A-Z]+\>', '' );

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
