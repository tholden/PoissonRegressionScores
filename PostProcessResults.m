function Results = PostProcessResults( Offense, Defense, Teams )

    Combined = Offense + Defense;
    
    [ NTeams, NTotalWeeks ] = size( Combined );
    
    Results = cell( NTotalWeeks, 1 );
    
    for n = 1 : NTotalWeeks
    
        [ ~, ~, OffenseRank ] = unique( Offense( :, n ) );
        [ ~, ~, DefenseRank ] = unique( Defense( :, n ) );
        [ ~, ~, CombinedRank ] = unique( Combined( :, n ) );
        
        OffenseRank = NTeams + 1 - OffenseRank;
        DefenseRank = NTeams + 1 - DefenseRank;
        CombinedRank = NTeams + 1 - CombinedRank;
        
        Results{ n } = table( OffenseRank, DefenseRank, CombinedRank, 'RowNames', Teams );
        
        Results{ n } = sortrows( Results{ n }, 'CombinedRank' );
    
    end

end
