function [ Mean, HomeOffset, OvertimeOffset, Offense, Defense, Teams ] = EstimatePoissionRegressionOnScores( Scores, IDs, Overtime, NeutralSite )

    NMatches = size( Scores, 1 );

    assert( size( IDs, 1 ) == NMatches );
    assert( size( IDs, 2 ) == 2 );
    assert( size( Scores, 2 ) == 2 );

    [ Teams, ~, OffenseIDs ] = unique( IDs(:) );

    NTeams = numel( Teams );

    OffenseIDs = reshape( OffenseIDs, NMatches, 2 );
    DefenseIDs = fliplr( OffenseIDs );

    Home = [ zeros( NMatches, 1 ); double( ~NeutralSite ) ];

    Scores = Scores(:);
    Overtime = double( [ Overtime(:); Overtime(:); ] );
    OffenseIDs = OffenseIDs(:);
    DefenseIDs = DefenseIDs(:);

    NObservations = 2 * NMatches;

    OffenseIndicators = sparse( ( 1 : NObservations ).', OffenseIDs, ones( NObservations, 1 ), NObservations, NTeams, NObservations );
    DefenseIndicators = sparse( ( 1 : NObservations ).', DefenseIDs, ones( NObservations, 1 ), NObservations, NTeams, NObservations );

    Mean = sdpvar( 1, 1 );
    HomeOffset = sdpvar( 1, 1 );
    OvertimeOffset = sdpvar( 1, 1 );
    Offense = sdpvar( NTeams, 1 );
    Defense = sdpvar( NTeams, 1 );

    LogPrediction = Mean + HomeOffset * Home + OvertimeOffset * Overtime + OffenseIndicators * Offense - DefenseIndicators * Defense;

    LogLikelihood = sum( Scores .* LogPrediction - exp( LogPrediction ) );

    Conditions = [ sum( Offense ) == 0, sum( Defense ) == 0 ];

    SolverOutput = optimize( Conditions, -LogLikelihood, sdpsettings( 'verbose', 1, 'showprogress', 1, 'warning', 1, 'cachesolvers', 1, 'solver', 'mosek' ) );

    assert( SolverOutput.problem == 0 );

    Mean = value( Mean );
    HomeOffset = value( HomeOffset );
    OvertimeOffset = value( OvertimeOffset );
    Offense = value( Offense );
    Defense = value( Defense );

end
