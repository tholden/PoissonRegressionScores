function [ Mean, HomeOffset, OvertimeOffset, Offense, Defense, Teams ] = EstimatePoissionRegressionOnScores( Scores, IDs, Overtime, NeutralSite, NPredictWeeks )

    NMatches = size( Scores, 1 );

    assert( size( IDs, 1 ) == NMatches );
    assert( size( IDs, 2 ) == 2 );
    assert( size( Scores, 2 ) == 2 );

    [ Teams, ~, OffenseIDs ] = unique( IDs(:) );

    NTeams = numel( Teams );

    OffenseIDs = reshape( OffenseIDs, NMatches, 2 );
    DefenseIDs = fliplr( OffenseIDs );

    Home = tvec( [ zeros( NMatches, 1 ), double( ~NeutralSite ) ] );

    Scores = tvec( Scores );
    Overtime = tvec( double( [ Overtime(:), Overtime(:) ] ) );
    OffenseIDs = tvec( OffenseIDs );
    DefenseIDs = tvec( DefenseIDs );

    NObservations = 2 * NMatches;

    Weeks = zeros( NObservations, 1 );

    PlayedThisWeek = zeros( 1, NTeams );

    NWeeks = 1;

    for t = 1 : NObservations

        PlayedThisWeek( OffenseIDs( t ) ) = PlayedThisWeek( OffenseIDs( t ) ) + 1;
        PlayedThisWeek( DefenseIDs( t ) ) = PlayedThisWeek( DefenseIDs( t ) ) + 1;

        if any( PlayedThisWeek > 2 )

            PlayedThisWeek = zeros( 1, NTeams );
            NWeeks = NWeeks + 1;

        end

        Weeks( t ) = NWeeks;

    end

    yalmip clear;

    Mean = sdpvar( 1, 1 );
    HomeOffset = sdpvar( 1, 1 );
    OvertimeOffset = sdpvar( 1, 1 );

    OffensePermanent = sdpvar( 1, NTeams, 'full' );
    DefensePermanent = sdpvar( 1, NTeams, 'full' );

    OffenseTransitory = sdpvar( NWeeks + NPredictWeeks, NTeams, 'full' );
    DefenseTransitory = sdpvar( NWeeks + NPredictWeeks, NTeams, 'full' );

    Offense = bsxfun( @plus, OffensePermanent, OffenseTransitory );
    Defense = bsxfun( @plus, DefensePermanent, DefenseTransitory );

    rho = 1 - 1 / sqrt( NWeeks );
    rho2 = rho * rho;

    DSS = ( 1 - rho2 ) * ( sum( OffenseTransitory( 1, : ) .^ 2 ) + sum( DefenseTransitory( 1, : ) .^ 2 ) ) + sum( sum( ( OffenseTransitory( 2 : end, : ) - rho * OffenseTransitory( 1 : ( end - 1 ), : ) ) .^ 2 ) ) + sum( sum( ( DefenseTransitory( 2 : end, : ) - rho * DefenseTransitory( 1 : ( end - 1 ), : ) ) .^ 2 ) );

    LogPrediction = Mean + Home * HomeOffset + Overtime * OvertimeOffset + Offense( sub2ind( [ NWeeks + NPredictWeeks, NTeams ], Weeks, OffenseIDs ) ) - Defense( sub2ind( [ NWeeks + NPredictWeeks, NTeams ], Weeks, DefenseIDs ) );

    Conditions = [ sum( OffensePermanent(:) ) == 0, sum( DefensePermanent(:) ) == 0, LogPrediction <= log( max( 1, Scores + 0.5 ) ), LogPrediction >= log( max( 0, Scores - 0.5 ) ) ];

    SolverOutput = optimize( Conditions, DSS, sdpsettings( 'verbose', 0, 'showprogress', 0, 'warning', 1, 'cachesolvers', 1, 'solver', 'mosek' ) );

    assert( SolverOutput.problem == 0 );

    MaxLogLikelihoods = Scores .* value( LogPrediction ) - exp( value( LogPrediction ) );

    MaxLogLikelihood = sum( MaxLogLikelihoods );

    LogLikelihoods = Scores .* LogPrediction - exp( LogPrediction );

    LogLikelihood = sum( LogLikelihoods );

    Conditions = [ sum( OffensePermanent(:) ) == 0, sum( DefensePermanent(:) ) == 0, LogLikelihood >= MaxLogLikelihood ];

    SolverOutput = optimize( Conditions, DSS, sdpsettings( 'verbose', 0, 'showprogress', 0, 'warning', 1, 'cachesolvers', 1, 'solver', 'mosek' ) );

    assert( SolverOutput.problem == 0 );

    MaxDSS = value( DSS );

    disp( 'Maximum possible DSS:' );
    disp( MaxDSS );

    LogLikelihoods = Scores .* LogPrediction - exp( LogPrediction );

    LogLikelihood = sum( LogLikelihoods );

    BIC = log( NObservations ) * 2 * NTeams * NWeeks * ( DSS / MaxDSS ) - 2 * LogLikelihood;

    Conditions = [ sum( OffensePermanent(:) ) == 0, sum( DefensePermanent(:) ) == 0 ];

    SolverOutput = optimize( Conditions, BIC, sdpsettings( 'verbose', 0, 'showprogress', 0, 'warning', 1, 'cachesolvers', 1, 'solver', 'mosek' ) );

    assert( SolverOutput.problem == 0 );

    Mean = value( Mean );
    HomeOffset = value( HomeOffset );
    OvertimeOffset = value( OvertimeOffset );
    Offense = value( Offense.' );
    Defense = value( Defense.' );

    disp( 'Final DSS:' );
    disp( value( DSS ) );

end

function z = tvec( z )

    z = z.';
    z = z(:);

end
